"""
    add_operator!(circuit::Circuit, operator::AbstractArray{String}, name::String; use_sparse=true)

Adds a custom operator to the given `circuit` object.

# Arguments
- `circuit::Circuit`: The circuit to which the operator will be added.
- `operator::AbstractArray{String}`: An array of operator strings, one for each component in the circuit. The length must match the number of components in the circuit.
- `name::String`: The name under which the operator will be stored in the circuit.
- `use_sparse` (optional, default = `true`): Whether to convert the operator matrices to sparse format.

# Description
For each component in the circuit, parses and evaluates the corresponding operator string. If the operator is not defined (`nothing`), uses the identity operator for that component. Optionally converts each operator to a sparse matrix. The resulting operators are combined using a tensor product and stored in the circuit's `ops` dictionary under the given `name`. The original operator definitions are also stored in `circuit.stuff["ops_def"]`.

# Throws
- An error if the length of `operator` does not match the number of components in the circuit.
"""
function add_operator!(circuit :: Circuit, operator :: AbstractArray{String}, name :: String; use_sparse = true)
    if length(operator) != length(circuit.components)
        error("The operator must be the same length as the number of components in the circuit.")
    end
    ops = []
    for i in 1:length(operator)
        op = Utils.parse_and_eval(replace(operator[i], ":" => "x.:"), circuit.components[circuit.order[i]])
        if op == nothing
            op = qt.qeye(circuit.components[circuit.order[i]].dim)
        end
        if use_sparse
            op = qt.sparse(op)
        end
        push!(ops, op)
    end

    circuit.ops[name] = qt.tensor(ops...)
    circuit.stuff["ops_def"][name] = operator
    
end

"""
    get_dressed_states(H0::qt.QuantumObject, components::AbstractArray{Component}, interactions; step_number=20, f=x->x^3)

Compute the dressed states, energies, and orderings for a quantum system as interaction strengths are adiabatically turned on.

# Arguments
- `H0::qt.QuantumObject`: The initial (bare) Hamiltonian of the system.
- `components::AbstractArray{Component}`: Array of system components, each with a defined Hilbert space dimension and eigenstates.
- `interactions`: List of interaction specifications. Each interaction is an array where the first element is the coupling strength, and subsequent elements specify operators (or "1" for identity) for each component. The string "hc" can be included to add the Hermitian conjugate.
- `step_number`: (Optional) Number of steps in the adiabatic interpolation. Default is 20.
- `f`: (Optional) Function mapping the interpolation parameter (from 0 to 1) to the interaction scaling. Default is `x -> x^3`.

# Returns
A vector containing:
1. `dressed_states::Dict`: Mapping from bare state tuples to the corresponding dressed state at the final step.
2. `dressed_energies::Dict`: Mapping from bare state tuples to the corresponding dressed energy at the final step.
3. `dressed_order::Vector{Tuple}`: Vector mapping the dressed state order (by energy) to the bare state tuple.

# Description
The function interpolates between the bare Hamiltonian and the fully interacting Hamiltonian by scaling the interaction terms according to `f`. At each step, it computes the eigenstates and energies, tracks the evolution of each bare state, and returns the dressed states, energies, and their order at the final step.
"""
function get_dressed_states(H0 :: qt.QuantumObject, components :: AbstractArray{CircuitComponent}, interactions; step_number = 20, f = x -> x^3)
    state_history = []
    energy_history = []
    order_history = []
    δ0s = LinRange(0, 1, step_number)
    δs = f.(δ0s)
    for δ in δs
        H = H0
        for interaction in interactions
            g = interaction[1]
            full_op = []
            for j in 1:length(components)
                op = qt.qeye(components[j].dim)
                if interaction[j+1] != "1"    
                    op = Utils.parse_and_eval(replace(interaction[j+1], ":" => "x.:"), components[j])
                end
                push!(full_op, op)
            end
            H += δ*g*qt.tensor(full_op...)
            if "hc" in interaction
                H += δ*g*qt.tensor(full_op...)'
            end
        end
        spectra, states = qt.eigenstates(H)
        push!(state_history, states)
        push!(energy_history, real.(spectra))
        push!(order_history, collect(1:(length(spectra))))
    end
    bare_states = Dict{Any, Any}()
    to_iter = []
    for i in 1:length(components)
        push!(to_iter, collect(0:(components[i].dim-1)))
    end
    for state in Iterators.product(to_iter...)
        psis = []
        for i in 1:length(components)
            push!(psis, components[i].eigenstates[state[i]+1])
        end
        bare_states[state] = qt.tensor(psis...)
    end

    tracking_res = Utils.state_tracker(state_history, bare_states, other_sorts = Dict("energy" => energy_history, "order" => order_history))

    dressed_states = Dict{Any, Any}()
    dressed_energies = Dict{Any, Any}()
    dressed_order = Vector{Tuple}(undef, length(bare_states))
    for state in keys(bare_states)
        dressed_energies[state] = tracking_res[State = At(string(state)), Step = At(step_number)]["energy"]
        dressed_states[state] = tracking_res[State = At(string(state)), Step = At(step_number)]["psi"]
        dressed_order[tracking_res[State = At(string(state)), Step = At(step_number)]["order"]] = state
    end

    return [dressed_states, dressed_energies, dressed_order]
end


"""
    save(circuit::Circuit, filename::String)

Serialize and save the given `circuit` object to a file specified by `filename`.

The function collects the following information from the `circuit`:
- `order`: The order of the circuit.
- `components`: A dictionary mapping component names to their parameters.
- `interactions`: A list of circuit interactions.
- `stuff`: Additional circuit data stored in the `stuff` field.

# Arguments
- `circuit::Circuit`: The circuit object to be saved.
- `filename::String`: The path to the file where the circuit data will be saved.

# Note
The actual file writing operation is not implemented in this function.
"""
function save(circuit :: Circuit, filename :: String)
    to_save = Dict{String, Any}()
    to_save["order"] = circuit.order
    to_save["components"] = Dict{String, Any}()
    for component in circuit.components
        to_save["components"][component.params[:name]] = component.params
    end
    for i in 1:length(circuit.interactions)
        to_save["interactions"][i] = circuit.interactions[i]
    end

    to_save["stuff"] = Dict{String, Any}()
    for key in keys(circuit.stuff)
        to_save["stuff"][key] = circuit.stuff[key]
    end
end