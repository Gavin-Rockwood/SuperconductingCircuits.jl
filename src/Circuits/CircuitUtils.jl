function add_operator!(circuit :: Circuit, operator :: AbstractArray{String}, name :: String)
    if length(operator) != length(circuit.components)
        error("The operator must be the same length as the number of components in the circuit.")
    end
    ops = []
    for i in 1:length(operator)
        op = Utils.parse_and_eval(replace(operator[i], ":" => "x.:"), circuit.components[circuit.order[i]])
        if op == nothing
            op = qt.qeye(circuit.components[circuit.order[i]].dim)
        end
        push!(ops, op)
    end

    circuit.ops[name] = qt.tensor(ops...)
    
end