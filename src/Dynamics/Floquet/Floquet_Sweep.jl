"""
    floquet_sweep(H_func, sampling_points, T; sampling_times=[], use_logging=true, states_to_track=Dict{Any, Any}(), propagator_kwargs=Dict{Any, Any}())

Performs a parameter sweep to compute Floquet modes and quasienergies for a family of time-dependent Hamiltonians.

# Arguments
- `H_func`: A function that takes a parameter value from `sampling_points` and returns the corresponding Hamiltonian.
- `sampling_points`: An array of parameter values over which to perform the sweep.
- `T`: The period of the drive. Can be a scalar (applied to all points) or an array matching `sampling_points`.
- `sampling_times`: (Optional) Array of times at which to evaluate the Floquet modes for each parameter set. Defaults to zeros.
- `use_logging`: (Optional) If `true`, logs progress and status messages.
- `states_to_track`: (Optional) A dictionary of states to track across the sweep. If provided, state tracking is performed.
- `propagator_kwargs`: (Optional) Dictionary of keyword arguments to pass to the propagator used in Floquet basis calculation.

# Returns
A dictionary with the following keys:
- `"F_Modes"`: Array of Floquet modes for each parameter set.
- `"F_Energies"`: Array of Floquet quasienergies for each parameter set.
- `"Tracking"`: (Optional) Results from state tracking, if `states_to_track` is provided.

# Notes
- If a parameter value in `sampling_points` is repeated, previously computed results are reused.
- Progress is displayed using a progress bar if logging is enabled.
- Requires `get_floquet_basis` and `Utils.state_tracker` to be defined elsewhere.
"""
function floquet_sweep(H_func,
    sampling_points,
    T;
    sampling_times = [],
    use_logging=true,
    states_to_track::T1 =  Dict{Any, Any}(),
    propagator_kwargs = Dict{Any, Any}()
    )where T1<:Dict
    STEPS = length(sampling_points)

    F_Modes = []
    F_Energies = []
    F_bases = []

    if (use_logging) @info "Beginning Floquet Sweep" end
    Ts = T
    if typeof(T) <:Number
        Ts = ones(STEPS)*T
    end
    if length(sampling_times) != STEPS
        sampling_times = ones(STEPS)*0
    end
    P = Progress(STEPS)
    for i in 1:STEPS
        # Check if we have already done this parameter set. This way I can just reuse the values instead of recalculating. 
        checking_if_done = findall(x->x == sampling_points[i], sampling_points[1:i-1])
        if length(checking_if_done) >0
            idx = checking_if_done[1]
            floquet_basis = F_bases[idx]
            push!(F_Energies, floquet_basis.e_quasi)
            push!(F_Modes, floquet_basis.modes(sampling_times[i]))
            push!(F_bases, floquet_basis)
            next!(P)
        else
            if (use_logging) @debug "On Param Set Number $i" end
            
            H = H_func(sampling_points[i])
            floquet_basis = get_floquet_basis(H, Ts[i]; propagator_kwargs = propagator_kwargs)
            #qvals, qvecs = Get_Floquet_t0_Eigsys(H, Ts[i], t0 = t0, propagator_kwargs=propagator_kwargs)
            qvals = floquet_basis.e_quasi
            qvecs = floquet_basis.modes(sampling_times[i])
            push!(F_Energies, qvals)
            push!(F_Modes, qvecs)
            push!(F_bases, floquet_basis)
            next!(P)
        end
    end

    res = Dict{Any, Any}()
    res["F_Modes"] = F_Modes
    res["F_Energies"] = F_Energies

    if (use_logging) @info "Done With Floquet Sweep" end
    
    if length(states_to_track) > 0
        if (use_logging) @info "Tracking State" end
        other_sorts = Dict("Quasienergies" => F_Energies)
        tracking_res = Utils.state_tracker(F_Modes, states_to_track, other_sorts = other_sorts, use_logging = use_logging)
        res["Tracking"] = tracking_res
    end
    return res
end