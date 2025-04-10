
function Floquet_Sweep(H_func,
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
            push!(F_Energies, F_Energies[idx])
            push!(F_Modes, F_Modes[idx])
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
        tracking_res = Utils.State_Tracker(F_Modes, states_to_track, other_sorts = other_sorts, use_logging = use_logging)
        res["Tracking"] = tracking_res
    end
    return res
end