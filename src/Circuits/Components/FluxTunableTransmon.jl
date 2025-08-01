"""
    FluxTunableTransmon

A struct representing a flux-tunable transmon qubit component in a superconducting circuit.

# Fields
- `params::Dict`: Dictionary containing the physical parameters of the flux-tunable transmon.
- `eigenenergies::Vector`: Vector of eigenenergies computed for the flux-tunable transmon Hamiltonian.
- `eigenstates::Vector`: Vector of eigenstates corresponding to the eigenenergies.
- `H_op::qt.QuantumObject`: Truncated Hamiltonian operator for the flux-tunable transmon, represented as a quantum object.
- `dim::Int`: Hilbert space dimension used for truncation.
- `loss_ops::Dict`: Dictionary of loss (dissipation) operators relevant to the flux-tunable transmon.
- `H_op_full::qt.QuantumObject`: Full (untruncated) Hamiltonian operator for the flux-tunable transmon.
- `n_op_full::qt.QuantumObject`: Full (untruncated) charge operator (U(1) number operator).
- `n_op::qt.QuantumObject`: Truncated charge operator.

# Description
The `FluxTunableTransmon` struct encapsulates all relevant data and operators for simulating a flux-tunable transmon qubit, including its Hamiltonian, eigenstates, and loss mechanisms. It is designed for use in quantum circuit simulations and analysis. 
    The Hamiltonian is derived from https://arxiv.org/pdf/1803.09813
"""
@kwdef struct FluxTunableTransmon <: CircuitComponent
    params :: Dict
    eigenenergies :: Vector
    eigenstates :: Vector
    H_op :: qt.QuantumObject
    dim :: Int
    loss_ops :: Dict
    
    H_op_full :: qt.QuantumObject

    n_op_full :: qt.QuantumObject # Cut U(1) charge operator
    n_op :: qt.QuantumObject # Truncated n operator 

    phi_op_full :: qt.QuantumObject # Full flux operator
    phi_op :: qt.QuantumObject # Truncated flux operator

    phi_op_dyn:: qt.QobjEvo # Dynamic flux operator for time-dependent simulations
end

function init_flux_tunable_transmon(EC, EJ1, EJ2, N; PhiE0 = 0.0, name = "Flux-Tunable Transmon", n_full = 60,  ng = 0, kappa_c = 1/(56*1000), kappa_d = 1.2348024316109425e-5)
    Phi0 = 1/2 # h/2e with h = e = 1
    dim_full = 2*n_full+1
    I_op_full = qt.eye(dim_full)


    EJ0 = EJ1+EJ2
    d = (EJ1 - EJ2) / (EJ1 + EJ2)

    EJ(Phi) = EJ0*cos(π*Phi/Phi0)*sqrt(1+d^2 * tan(π*Phi/Phi0)^2)

    jump_op_full = qt.tunneling(dim_full, 1)

    n_op_full = qt.num(dim_full) - n_full

    H_op_full = 4*EC*(ng*I_op_full - n_op_full)^2 - 0.5*EJ(PhiE0)*(jump_op_full)

    eigsys_full = qt.eigenstates(H_op_full)

    P = zeros(ComplexF64, dim_full, N)
    for i in 1:N
        P[:, i] = eigsys_full.vectors[:, i]
    end

    H_mat_full = H_op_full.data
    H_mat = P'*H_mat_full*P
    n_mat_full = n_op_full.data
    n_mat = P'*n_mat_full*P

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
    params = Dict(:EC => EC, :EJ => EJ, :ng => ng, :n_full => n_full, :N => N, :name => name, :kappa_c => kappa_c, :kappa_d => kappa_d)

    return FluxTunableTransmon(params = params, dim = N, H_op_full = H_op_full, H_op = H_op, n_op_full = n_op_full, n_op = n_op, eigenenergies = eigenenergies, eigenstates=eigenstates, loss_ops = loss_ops)
end