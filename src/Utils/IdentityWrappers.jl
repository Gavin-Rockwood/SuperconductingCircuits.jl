"""
    identity_wrapper(𝕀̂_Dict::Dict, Operator_Dict; order = [])

Constructs a tensor product of operators, replacing identity operators with those specified in `Operator_Dict`.

# Arguments
- `𝕀̂_Dict::Dict`: A dictionary mapping subsystem keys to identity operators.
- `Operator_Dict::Dict`: A dictionary mapping subsystem keys to operators that should replace the corresponding identities.
- `order::Vector` (optional): An array specifying the order of subsystems in the tensor product. If not provided, the order of keys in `𝕀̂_Dict` is used.

# Returns
- The tensor product (using `qt.tensor`) of the operators, with identities replaced as specified.
"""
function identity_wrapper(𝕀̂_Dict::Dict, Operator_Dict; order = [])
    if length(order) == length(𝕀̂_Dict)
        key_list = order
    else
        key_list = collect(keys(𝕀̂_Dict))
    end

    op_Dict = deepcopy(𝕀̂_Dict)

    for key in keys(Operator_Dict)
        op_Dict[key] = Operator_Dict[key]
    end

    op_vec = []
    for i in 1:length(key_list)
        push!(op_vec, op_Dict[key_list[i]])
    end

    return qt.tensor(op_vec...)
end
