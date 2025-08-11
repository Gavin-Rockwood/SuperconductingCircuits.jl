"""
    get_floquet_basis(H::Union{qt.QuantumObject, qt.QobjEvo}, T; t0 = 0, propagator_kwargs = Dict{Symbol, Any}())

Compute the Floquet basis for a time-periodic Hamiltonian.

# Arguments
- `H::Union{qt.QuantumObject, qt.QobjEvo}`: The time-dependent Hamiltonian, either as a quantum object or a time-evolution operator.
- `T`: The period of the Hamiltonian.
- `t0`: (optional) Initial time. Defaults to `0`.
- `propagator_kwargs`: (optional) Dictionary of keyword arguments to pass to the propagator functions.

# Returns
- A tuple containing the Floquet quasi-energies and a function that returns the time-evolved Floquet modes at any given time.

# Description
This function computes the Floquet basis by:
1. Calculating the propagator over one period.
2. Diagonalizing the propagator to obtain Floquet quasi-energies and modes.
3. Returning the quasi-energies and a function for propagating the Floquet modes in time.
"""
function get_floquet_basis(H::Union{qt.QuantumObject, qt.QobjEvo}, T; t0 = 0, propagator_kwargs = Dict{Symbol, Any}())
    
    #U_T = U.eval(T+t0, t0; propagator_kwargs...)
    U_T = propagator(H, T+t0; ti = t0, propagator_kwargs...)

    eigvals, eigvecs = qt.eigenstates(U_T)
    eigvals = -angle.(eigvals)/T#imag(log.(λs))
    
    return floquet_basis(eigvals, t->propagate_floquet_modes(eigvecs, H, t, T; propagator_kwargs = propagator_kwargs), T)
end
