"""
    propagate_floquet_modes(modes_t0, U, t, T; propagator_kwargs=Dict{Symbol, Any}())

Propagates a set of Floquet modes from the initial time `t₀` to a later time `t` using the provided propagator `U`.

# Arguments
- `modes_t0`: Array of Floquet modes at the initial time `t₀`.
- `U`: A propagator object with an `eval` method, used to compute the time evolution operator.
- `t`: The target time to which the modes should be propagated.
- `T`: The period of the Floquet system.
- `propagator_kwargs`: (Optional) Dictionary of keyword arguments to pass to the propagator's `eval` method.

# Returns
- An array of Floquet modes at time `t`.

# Notes
- If `t` is an integer multiple of `T`, the function returns the initial modes unchanged.
- Otherwise, the function computes the propagator for the time offset `t % T` and applies it to each mode.
"""
function propagate_floquet_modes(modes_t0, H, t, T; propagator_kwargs=Dict{Symbol, Any}())
    if t%T == 0
        return modes_t0
    end
    U_t = propagator(H, t%T; solver_kwargs = propagator_kwargs)
    return [U_t*modes_t0[i] for i in 1:length(modes_t0)]
end