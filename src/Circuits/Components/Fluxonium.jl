# DOI: https://doi.org/10.1103/PhysRevB.87.024510
@kwdef struct Fluxonium <: Component
    params :: Dict
    eigenenergies :: Vector
    eigenstates :: Vector
    H_op :: qt.QuantumObject
    dim :: Int
    loss_ops :: Dict
    
    H_op_full :: qt.QuantumObject

    phi_op_full :: qt.QuantumObject # Cut U(1) charge operator
    phi_op :: qt.QuantumObject # Truncated n operator

    n_op_full :: qt.QuantumObject # Cut U(1) charge operator
    n_op :: qt.QuantumObject # Truncated n operator

end


"""
    init_fluxonium(EJ, EC, EL, N; flux = 0.0, N_full = 110, kappa_c = 0, kappa_d = 0, name = "Fluxonium")

Initialize a Fluxonium circuit Hamiltonian and associated operators.

# Arguments
- `EJ::Number`: Josephson energy.
- `EC::Number`: Charging energy.
- `EL::Number`: Inductive energy.
- `N::Int`: Number of energy levels to keep in the truncated Hilbert space.

# Keyword Arguments
- `flux::Number=0.0`: External flux threading the circuit (in units of flux quantum).
- `N_full::Int=110`: Dimension of the full Hilbert space before truncation.
- `kappa_c::Number=0`: Collapse (relaxation) rate.
- `kappa_d::Number=0`: Dephasing rate.
- `name::String="Fluxonium"`: Name identifier for the circuit.

# Returns
- `Fluxonium`: A struct containing the circuit parameters, Hamiltonian operators (full and truncated), eigenenergies, eigenstates, and loss operators.

# Details
This function constructs the full Hamiltonian for a Fluxonium circuit, diagonalizes it, and projects relevant operators (Hamiltonian, phase, number) onto the truncated subspace of the lowest `N` eigenstates. It also constructs collapse and dephasing operators for use in open quantum system simulations. The paper this Hamiltonian is based off of is "Circuit QED with fluxonium qubits: Theory of the dispersive regime" by Zhu et al. https://doi.org/10.1103/PhysRevB.87.024510.
"""
function init_fluxonium(EC, EJ, EL, N; flux = 0.0, N_full = 110, kappa_c = 0, kappa_d = 0, name = "Fluxonium")
    dim_full = N_full

    I_op_full = qt.eye(dim_full)
    c = qt.destroy(dim_full)
    phi_0 = (8*EC/EL)^(1/4)
    omega = sqrt(8*EC*EL)
    phi_op_full = phi_0/sqrt(2)*(c + c')
    n_op_full = -1im/(sqrt(2)*phi_0)*(c - c')

    H_op_full = omega*(c'*c+0.5*I_op_full) - EJ*qt.cos(phi_op_full - 2*pi*flux)
    herm_check = norm(H_op_full - H_op_full')
    if herm_check > 1e-9
        println("Herm_check for Ĥ_full: $herm_check")
    end
    H_op_full = 0.5*(H_op_full + H_op_full')

    eigsys_full = qt.eigenstates(H_op_full)

    P = zeros(ComplexF64, dim_full, N)
    for i in 1:N
        P[:, i] = eigsys_full.vectors[:, i]
    end
    H_mat_full = H_op_full.data
    H_mat = P'*H_mat_full*P
    n_mat_full = n_op_full.data
    n_mat = P'*n_mat_full*P
    phi_mat_full = phi_op_full.data
    phi_mat = P'*phi_mat_full*P




    
    H_op = qt.Qobj(H_mat)
    herm_check = norm(H_op - H_op')
    if herm_check > 1e-9
        println("Herm_check for H_op Failed with value $herm_check")
    end
    H_op = 0.5*(H_op+H_op')
    n_op = qt.Qobj(n_mat)
    herm_check = norm(n_op - n_op') 
    if herm_check > 1e-9
        println("Herm_check for n_op Failed with value $herm_check")
    end
    n_op = 0.5*(n_op+n_op')
    phi_op = qt.Qobj(phi_mat)
    herm_check = norm(phi_op - phi_op')
    if herm_check > 1e-9
        println("Herm_check for phi_op Failed with value $herm_check")
    end
    phi_op = 0.5*(phi_op+phi_op')
    
    eigenenergies, eigenstates = qt.eigenstates(H_op)
    D_op = 0*H_op
    for i in 1:(N-1) # this skips the 0 state becasue the coefficient is 0
        psi_i = qt.fock(N, i)
        D_op += sqrt(2*kappa_d)*sqrt(i)*psi_i*psi_i'
    end
    C_op = 0*H_op   
    for i in 1:(N-1)
        im1 = i-1
        psi_im1 = qt.fock(N, i-1)
        psi_i = qt.fock(N, i)
        C_op += sqrt(kappa_c)*sqrt(i)*psi_im1*psi_i'
    end
    loss_ops = Dict("Collapse" => C_op, "Dephasing" => D_op)
    params = Dict(:EJ => EJ, :EC => EC, :EL => EL, :N_full => N_full, :N => N, :flux => flux, :name => name, :kappa_c => kappa_c, :kappa_d => kappa_d)
    return Fluxonium(params = params, dim = N, H_op_full = H_op_full, H_op = H_op, phi_op_full = phi_op_full, phi_op = phi_op, n_op_full = n_op_full, n_op = n_op, eigenenergies = eigenenergies, eigenstates=eigenstates, loss_ops = loss_ops)
end

function init_fluxonium(; EJ = 8.9, EC = 2.5, EL = 0.5, N = 10, kwargs...)
    init_fluxonium(EC, EJ, EL, N; kwargs...)
end