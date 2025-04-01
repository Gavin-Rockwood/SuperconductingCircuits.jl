"""
 components: List of components that will be used 
 interactions: list of interactions between the components. 
    An interaction is a list of the form:
        [g, op1 symbol, op2 symbol, ....]
    For example, the transmon-resonator interaction ign̂(â- â') will be written as 
        [g, ":n_op", "1im*(:a_op - :a_op')"]
    This then gets passed through a meta.parse function after adding inserting the components before the :. This list must be the 
    number of components plus 1. If the operator is to be the identity, just write "1". Finally, if the interaction needs to have
    hermitian conjugate added, then there can be an extra entree at the end that is "hc".
"""

function init_Circuit(components :: AbstractArray{Component}, interactions)
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

    I = qt.eye(prod(dims), dims = dims)
    H_op = 0*I

    for i in 1:length(components)
        op = []
        for j in 1:length(Is)
            push!(op, Is[j])
        end
        op[i] = components[i].H_op
        H_op += qt.tensor(op...)
    end

    for interaction in interactions
        g = interaction[1]
        full_op = []
        for j in 1:length(components)
            op = Is[j]
            if interaction[j+1] != "1"    
                # this is all some magic julia stuff to get the eval to work inside the function. Tis some magical shit afoot
                #exprtoeval = Meta.parse(replace(interaction[j+1], ":" => "x.:"))
                #@eval eval_func(x) = $exprtoeval
                #invokelatest() do # Time travels the evaluation of the function into the future where it is defined 
                #    op = eval_func(components[j])
                #end
                op = Utils.parse_and_eval(replace(interaction[j+1], ":" => "x.:"), components[j])
            end
            push!(full_op, op)
        end
        H_op += g*qt.tensor(full_op...)
        if "hc" in interaction
            H_op += qt.tensor(full_op...)'
        end
    end

    de_unsort, ds_unsort = qt.eigenstates(H_op)
    bare_states = Dict{Any, Any}()
    to_iter = []
    for i in 1:length(dims)
        push!(to_iter, collect(0:(dims[i]-1)))
    end
    for state in Iterators.product(to_iter...)
        psis = []
        for i in 1:length(components)
            push!(psis, components[i].eigenstates[state[i]+1])
        end
        bare_states[state] = qt.tensor(psis...)
    end

    tracking_res = Utils.State_Tracker([ds_unsort], bare_states, other_sorts = Dict("energy" => [de_unsort]))
    
    dressed_states = Dict{Any, Any}()
    dressed_energies = Dict{Any, Any}()

    for state in Iterators.product(to_iter...)
        dressed_states[state] = tracking_res[State = At(string(state)), Step = At(1)]["psi"]
        dressed_energies[state] = tracking_res[State = At(string(state)), Step = At(1)]["energy"]
    end


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

    return Circuit(H_op = H_op, dressed_energies = dressed_energies, dressed_states = dressed_states, dims = dims, order = order, loss_ops = loss_ops, components = comp_dict, interactions = interactions, stuff = Dict{Any, Any}(), static_gates = Dict{Any, Any}(), dynamic_gates = Dict{Any, Any}(), ops = Dict{Any, Any}())
end

"""
    This one takes in a list of component parameter dictionaries 
    instead of components. 
"""
function init_Circuit(components :: AbstractArray{Dict}, types, interactions)
    component_list = []
    for i in 1:length(components)
        push!(component_list, Component_inits[types[i]](component))
    end
    init_Circuit(component_list, interactions)
end