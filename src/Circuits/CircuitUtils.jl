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

function get_dressed_states(H0 :: qt.QuantumObject, components :: AbstractArray{Component}, interactions; step_number = 20, f = x -> x^3)
    state_history = []
    energy_history = []
    order_history = []
    δ0s = LinRange(0, 1, step_number)
    δs = f.(δ0s)
    println("δs: ", δs)
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
        push!(energy_history, spectra)
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