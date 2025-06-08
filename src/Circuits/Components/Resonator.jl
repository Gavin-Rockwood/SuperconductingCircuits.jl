export Resonator, init
"""
    Resonator

A structure representing a quantum resonator component in a superconducting circuit.

# Fields
- `dim::Int`: The Hilbert space dimension of the resonator.
- `params::Dict`: Dictionary containing the physical parameters of the resonator.
- `H_op::qt.QuantumObject`: The Hamiltonian operator of the resonator.
- `eigenstates::Vector`: Vector of eigenstates of the resonator Hamiltonian.
- `eigenenergies::Vector`: Vector of eigenenergies corresponding to the eigenstates.
- `loss_ops::Dict`: Dictionary of loss (dissipation) operators associated with the resonator.
- `a_op::qt.QuantumObject`: The annihilation (lowering) operator for the resonator.
- `N_op::qt.QuantumObject`: The number operator for the resonator.

# Description
This structure encapsulates all relevant quantum properties and operators for a resonator component, facilitating simulation and analysis within superconducting circuit models.
"""
@kwdef struct Resonator <: Component
    dim :: Int
    params :: Dict
    H_op :: qt.QuantumObject
    eigenstates :: Vector
    eigenenergies :: Vector
    loss_ops :: Dict

    a_op :: qt.QuantumObject
    N_op :: qt.QuantumObject

    

end


"""
    init_resonator(Eosc, N; name = "Resonator", kappa_c = 1/(1000*1000), kappa_d = 0)

Initialize a quantum resonator component with specified parameters.

# Arguments
- `Eosc::Number`: Oscillator energy (frequency) of the resonator.
- `N::Int`: Hilbert space dimension (number of Fock states).
- `name::String` (optional): Name of the resonator (default: "Resonator").
- `kappa_c::Number` (optional): Cavity decay rate (default: 1e-6).
- `kappa_d::Number` (optional): Dephasing rate (default: 0).

# Returns
- `Resonator`: An instance of the `Resonator` type containing:
    - `params`: Dictionary of resonator parameters.
    - `dim`: Hilbert space dimension.
    - `H_op`: Hamiltonian operator.
    - `N_op`: Number operator.
    - `eigenenergies`: Eigenenergies of the Hamiltonian.
    - `eigenstates`: Eigenstates of the Hamiltonian.
    - `a_op`: Annihilation operator.
    - `loss_ops`: Dictionary of collapse (decay) and dephasing operators.

# Description
Constructs the Hamiltonian and relevant operators for a quantum resonator, including the annihilation operator, number operator, and loss operators for both cavity decay and dephasing. The function returns a `Resonator` object with all relevant properties initialized.
"""

function init_resonator(Eosc, N; name = "Resonator", kappa_c = 1/(1000*1000), kappa_d =  0)

    a_op = qt.destroy(N)
    N_op = a_op'*a_op
    H_op = Eosc*N_op

    eigenenergies, eigenstates = qt.eigenstates(H_op)

    # Cavity Collapse
    C_op = 0*H_op
    for i in 1:(N-1)
        im1 = i-1
        psi_i = qt.fock(N, i)
        psi_im1 = qt.fock(N, im1)
        C_op += sqrt(kappa_c)*sqrt(i)*psi_im1*psi_i'
    end

    D_op = 0*H_op
    for i in 1:(N-1) # this skips the 0 state becasue the coefficient is 0
        psi_i = qt.fock(N, i)
        D_op += sqrt(2*kappa_d)*sqrt(i)*psi_i*psi_i'
    end

    loss_ops = Dict("Collapse" => C_op, "Dephasing" => D_op)

    params = Dict(:Eosc => Eosc, :N => N, :kappa_c => kappa_c, :kappa_d => kappa_d, :name => name)
    return Resonator(params = params, dim = N, H_op = H_op, N_op = N_op, eigenenergies = eigenenergies, eigenstates=eigenstates, a_op = a_op, loss_ops = loss_ops)
end



"""
    init_resonator(Params::T) where T<:Dict

Initialize a resonator using a dictionary of parameters.

# Arguments
- `Params::Dict`: A dictionary containing the resonator parameters. Must include the keys:
    - `:Eosc`: The oscillator energy.
    - `:N`: The number of levels or modes.
  Additional keyword parameters can be included and will be forwarded to the underlying `init_resonator` method.

# Returns
- The result of calling `init_resonator(Eosc, N; params...)` with the extracted and remaining parameters.
"""

function init_resonator(Params::T) where T<:Dict
    params = deepcopy(Params)
    Eosc = params[:Eosc]
    delete!(params, :Eosc)
    N = params[:N]
    delete!(params, :N)
    init_resonator(Eosc, N; params...)
end
