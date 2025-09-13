"""
    Qubit

A structure representing a quantum bit (qubit) component in a superconducting circuit.

# Fields
- `dim::Int`: The Hilbert space dimension of the qubit (Always 2).
- `params::Dict`: Dictionary containing the physical parameters of the qubit.
- `H_op::qt.QuantumObject`: The Hamiltonian operator of the qubit, represented as a quantum object.
- `eigenstates::Vector`: Vector containing the eigenstates of the qubit Hamiltonian.
- `eigenenergies::Vector`: Vector containing the eigenenergies corresponding to the eigenstates.
- `loss_ops::Dict`: Dictionary of loss (dissipation) operators associated with the qubit.
- `freq::Float64`: The transition frequency of the qubit.
"""
@kwdef struct Qubit <: CircuitComponent
    dim = 2
    params :: Dict
    H_op :: qt.QuantumObject
    eigenstates :: Vector
    eigenenergies :: Vector

    sigmaz_op :: qt.QuantumObject = qt.sigmaz()
    sigmax_op :: qt.QuantumObject = qt.sigmax()
    sigmay_op :: qt.QuantumObject = qt.sigmay()

    loss_ops :: Dict

    freq :: Float64
end



"""
    init_qubit(freq; name = "Qubit")

Initialize a `Qubit` object with the specified transition frequency `freq`.

# Arguments
- `freq::Number`: The transition frequency of the qubit.
- `name::String` (optional): The name of the qubit. Defaults to `"Qubit"`.

# Returns
- `Qubit`: An initialized `Qubit` object containing the Hamiltonian operator, eigenenergies, eigenstates, and other parameters.

# Details
The function constructs the qubit Hamiltonian as `H_op = freq * qt.sigmaz() / 2`, computes its eigenenergies and eigenstates, and returns a `Qubit` object with these properties.
"""
function init_qubit(freq; name = "Qubit")
    H_op= freq*qt.sigmaz()/2
    eigenenergies, eigenstates = qt.eigenstates(H_op)

    params = Dict(:freq => freq, :name => name)

    return Qubit(params = params, freq = freq, H_op = H_op, eigenenergies = eigenenergies, eigenstates = eigenstates, loss_ops = Dict())
end


"""
    init_qubit(Params::T) where T<:Dict

Initializes a qubit using a dictionary of parameters.

# Arguments
- `Params::Dict`: A dictionary containing at least the key `:freq` (the qubit frequency) and any additional keyword parameters required for qubit initialization.

# Returns
- The result of calling `init_qubit` with the extracted frequency and remaining parameters.

# Notes
- The function makes a deep copy of the input dictionary to avoid mutating the original.
- The `:freq` key is extracted and removed from the dictionary before passing the remaining parameters as keyword arguments.

# Example
"""

function init_qubit(; freq = 1, kwargs...)
    init_qubit(freq; kwargs...)
end

function Base.show(io::IO, component::Qubit)
    println(io, "Name: $(component.params[:name])")
    println(io, "  Parameters:")
    keys_to_show = [:freq]
    for key in keys_to_show
        println(io, "    $key: $(component.params[key])")
    end
        println(io, "  Dimensions:")
    println(io, "    Hilbert Space: $(component.dim)")
    println(io, "  Operators: H_op, sigmax_op, sigmay_op, sigmaz_op")
end