function propagate_floquet_modes(modes_t0, U, t, T; propagator_kwargs=Dict{Symbol, Any}())
    if t%T == 0
        return modes_t0
    end
    U_t = U.eval(t%T, 0, propagator_kwargs)
    return [U_t*modes_t0[i] for i in 1:length(modes_t0)]
end