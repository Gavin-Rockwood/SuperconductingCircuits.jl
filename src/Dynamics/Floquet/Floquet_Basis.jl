function get_floquet_basis(H::Union{qt.QuantumObject, qt.QobjEvo}, T; t0 = 0, propagator_kwargs = Dict{Symbol, Any}())
    
    U = get_propagator(H)#, T+t0, ti = t0; propagator_kwargs...)
    U_T = U.eval(T+t0, t0; propagator_kwargs...)

    eigvals, eigvecs = qt.eigenstates(U_T)
    eigvals = -angle.(eigvals)/T#imag(log.(λs))
    
    return floquet_basis(eigvals, t->propagate_floquet_modes(eigvecs, U, t, T; propagator_kwargs = propagator_kwargs), T)
end
