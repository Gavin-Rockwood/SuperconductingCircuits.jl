@kwdef struct Qubit <: Component
    dim :: Int = 2
    params :: Dict
    H_op :: qt.QuantumObject
    eigenstates :: Vector
    eigenenergies :: Vector

    loss_ops :: Dict

    freq :: Float64
end

function init_qubit(freq; name = "Qubit")
    H_op= freq*qt.sigmaz()/2
    eigenenergies, eigenstates = qt.eigenstates(H_op)

    params = Dict(:freq => freq, :name => name)

    return Qubit(params = params, freq = freq, H_op = H_op, eigenenergies = eigenenergies, eigenstates = eigenstates, loss_ops = Dict())
end

function init_qubit(Params::T) where T<:Dict
    params = deepcopy(Params)
    freq = params[:freq]
    delete!(params, :freq)
    init_qubit(freq; params...)
end