"""
    init_circuit(components::AbstractArray{Component}, interactions; operators_to_add=Dict{String, Any}(), use_sparse=true, dressed_kwargs=Dict{Symbol, Any}())

Initialize a quantum circuit from a list of components and their interactions.

# Arguments
- `components::AbstractArray{Component}`: An array of `Component` objects representing the subsystems of the circuit.
- `interactions`: A collection describing the interactions between components. Each interaction is typically a tuple or array where the first element is the coupling strength and the remaining elements specify the operators for each component.
- `operators_to_add=Dict{String, Any}()`: (Optional) A dictionary of additional operators to add to the circuit, keyed by operator name.
- `use_sparse=true`: (Optional) If `true`, use sparse matrix representations for operators and Hamiltonians.
- `dressed_kwargs=Dict{Symbol, Any}()`: (Optional) Keyword arguments passed to the dressed state calculation, such as `:f` (function for transformation) and `:step_number` (number of steps).

# Returns
- `circuit::Circuit`: An initialized `Circuit` object containing the Hamiltonian, dressed states and energies, loss operators, component dictionary, and other relevant circuit information.

# Details
- Constructs the total Hilbert space dimensions and identity operators for each component.
- Builds the bare Hamiltonian (`H_op_0`) and adds interaction terms to form the full Hamiltonian (`H_op`).
- Calculates dressed states and energies using `get_dressed_states`.
- Assembles loss operators for each component.
- Organizes components and other circuit data into a `Circuit` struct.
- Optionally adds user-specified operators to the circuit.

---
---
# Overloaded As:
---
# init_circuit(components::AbstractArray{Dict}, types, interactions; kwargs...)
Instead of taking in a list of initialized circuit elements, this takes in a list of parameter dictionaries and a list of of the corresponding circuit element types instead.
# Arguments
- `components::AbstractArray{Dict}`: An array of dictionaries, each containing the parameters for a circuit component.
- `types`: An array specifying the type of each component, used to select the appropriate constructor from `Component_inits`.
- `interactions`: Data structure describing the interactions between components.
- `kwargs...`: Additional keyword arguments passed to the underlying `init_circuit` method.

"""
function init_circuit(components :: AbstractArray{T1}, 
    interactions; 
    operators_to_add = Dict{String, Any}(), 
    use_sparse = true,
    dressed_kwargs = Dict{Symbol, Any}()
    ) where T1 <: CircuitComponent

    dims = []
    Is = []
    order = []
    params = []
    for component in components
        push!(dims, component.dim)
        push!(Is, qt.eye(component.dim))
        push!(order, component.params[:name])
        push!(params, component.params)
    end
    dims = tuple(dims...)

    if !(:f in keys(dressed_kwargs))
        dressed_kwargs[:f] = x -> x^3
    end
    if !(:step_number in keys(dressed_kwargs))
        dressed_kwargs[:step_number] = 10
    end
    I = qt.eye(prod(dims), dims = dims)
    H_op_0 = 0*I

    for i in 1:length(components)
        op = []
        for j in 1:length(Is)
            push!(op, Is[j])
        end
        op[i] = components[i].H_op
        H_op_0 += qt.tensor(op...)
    end

    H_op = H_op_0
    num = 0
    for interaction in interactions
        g = interaction[1]
        full_op = []
        for j in 1:length(components)
            op = Is[j]
            if interaction[j+1] != "1"    
                num += 1
                #println(num)
                op = Utils.parse_and_eval(replace(interaction[j+1], ":" => "x.:"), components[j])
            end
            push!(full_op, op)
        end
        H_op += g*qt.tensor(full_op...)
        if "hc" in interaction
            H_op += qt.tensor(full_op...)'
        end
    end

    if use_sparse
        H_op = qt.sparse(H_op)
    end
  
    dressed_states, dressed_energies, dressed_order = get_dressed_states(H_op_0, components, interactions; dressed_kwargs...)

    loss_ops = Dict{Any, Any}()
    for i in 1:length(components)
        for key in keys(components[i].loss_ops)
            op = components[i].loss_ops[key]
            full_op = copy(Is)
            full_op[i] = op
            loss_ops[components[i].params[:name]*" "*key] = qt.tensor(full_op...)
        end
    end

    comp_dict = Dict{Any, Any}()
    for i in 1:length(components)
        comp_dict[components[i].params[:name]] = components[i]
    end

    circuit = Circuit(H_op = H_op,
            dressed_energies = dressed_energies,
            dressed_states = dressed_states,
            dims = dims,
            order = order,
            loss_ops = loss_ops,
            components = comp_dict,
            interactions = interactions, 
            stuff = Dict{String, Any}("ops_def" => Dict{String, Any}()),
            drives = Dict{Any, Any}(),
            gates = Dict{Any, Any}(),
            ops = Dict{Any, Any}(),
            io_stuff = Dict{Any, Any}(),
            dressed_order = dressed_order)
    
    for operator in keys(operators_to_add)
        add_operator!(circuit, operators_to_add[operator], operator; use_sparse = use_sparse)
    end

    return circuit
end

function init_circuit(components :: AbstractArray{Dict}, types, interactions; kwargs...)
    component_list = []
    for i in 1:length(components)
        push!(component_list, Component_inits[types[i]](component))
    end
    init_circuit(component_list, interactions; kwargs...)
end