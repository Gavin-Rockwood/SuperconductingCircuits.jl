function Get_Floquet_t0_Eigsys(H, T; t0 = 0, propagator_kwargs = Dict{Any, Any}())
    
    U = propagator(H, T+t0, ti = t0; propagator_kwargs...)

    eigvals, eigvecs = qt.eigenstates(U)
    eigvals = -angle.(eigvals)/T#imag(log.(λs))
    return eigvals, eigvecs
end

function Floquet_t0_Sweep(H_func,
    sampling_points,
    T;
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

            # if "t0" in keys(list_of_params[i])
            #     t0 = list_of_params[i]["t0"]
            # else    
            #     t0 = 0
            # end
            t0 = 0
            qvals, qvecs = Get_Floquet_t0_Eigsys(H, Ts[i], t0 = t0, propagator_kwargs=propagator_kwargs)
            # if ("t" in keys(list_of_params[i])) & (length(states_to_track) == 0)
            #     for j in 1:length(λ⃗s)
            #         op_params = Dict{Any, Any}()
            #         op_params["epsilon"] = ε
            #         op_params["freq_d"] = ν
            #         op_params["shift"] = 0
            #         T = (abs(1/op_params["freq_d"]))
            #         op_params["pulse_time"] = list_of_params[i]["t"]#%T
            #         n = floor(list_of_params[i]["t"]/(abs(1/op_params["freq_d"])))*T
                    
            #         if "Envelope" in keys(list_of_params[i])
            #             op_params["Envelope"] = list_of_params[i]["Envelope"]
            #         else
            #             op_params["Envelope"] = "Square"
            #         end
            #         if "Envelope Args" in keys(list_of_params[i])
            #             op_params["Envelope Args"] = list_of_params[i]["Envelope Args"]
            #         else
            #             op_params["Envelope Args"] = Dict{Any, Any}()
            #         end
            #         λ⃗s[j] = RunSingleOperator(hilbertspace.Ĥ, drive_op, λ⃗s[j], op_params; to_return = "Last", progress_bar = false, use_logging = false)#*ℯ^(-1im*λs[j]*n*T)
            #     end
            # end

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


        # if (use_logging) @info "Running the necessary time evolutions" end
        # P = Progress(STEPS)
        # for step in 1:STEPS   
        #     if ("t" in keys(sampling_points[step]))
        #         op_params = Dict{Any, Any}()
        #         op_params["epsilon"] = sampling_points[step]["ε"]
        #         op_params["freq_d"] = list_of_params[step]["ν"]
        #         op_params["shift"] = 0
        #         T = (abs(1/op_params["freq_d"]))
        #         n = floor(list_of_params[step]["t"]/(abs(1/op_params["freq_d"])))*T
        #         op_params["pulse_time"] = list_of_params[step]["t"]%T
        #         op_params["Envelope"] = "Square"
        #         op_params["Envelope Args"] = Dict{Any, Any}()
        #         for j in 1:length(states_to_track) 
        #             state_key = string(collect(keys(states_to_track))[j])
        #             ψ = tracking_res[State = At(state_key), Step = At(step)]["ψ"]
                    
        #             qe = tracking_res[State = At(state_key), Step = At(step)]["Quasienergies"]
        #             ψ = RunSingleOperator(hilbertspace.Ĥ, drive_op, ψ, op_params; to_return = "Last", progress_bar = false, use_logging = false)
        #             tracking_res[State = At(state_key), Step = At(step)]["ψ"] = ℯ^(-1im*qe*n*T)*ψ
        #         end
        #     end
        #     next!(P)
        # end
    end
    return res
end