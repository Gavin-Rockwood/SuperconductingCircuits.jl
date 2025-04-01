function State_Tracker(state_history::Vector, states_to_track::Dict; other_sorts = Dict{Any, Any}(), use_logging = true)
    STEPS = length(state_history)
    NUM_IN_STEP = length(state_history[1])
    NUM_TO_TRACK = length(states_to_track)

    state_keys = (collect(keys(states_to_track)))
    other_keys = collect(keys(other_sorts))
    
    history = fill(Dict{Any, Any}(), Dim{:State}(string.(state_keys)), Dim{:Step}(1:STEPS))
    #return history
    history = map(deepcopy, history)
    #return history
    P = Progress(STEPS)
    for state in state_keys
        if use_logging @debug "Tracking State $state" end
        psi_i = 0
        psi_im1 = states_to_track[state]
        for step in 1:STEPS
            @debug "    On Step $step / $STEPS"
            overlaps = zeros(NUM_IN_STEP)
            for j in 1:NUM_IN_STEP
                overlaps[j] = (abs(psi_im1'*state_history[step][j]))^2
                if use_logging @debug "Overlap for state $j : "*string(overlaps[j]) end
            end 
            if use_logging @debug "Max overlap: "*string(maximum(overlaps)) end
            
            max_loc = argmax(overlaps)
            psi_i = state_history[step][max_loc]
            history[State = At(string(state)), Step = At(step)]["psi"] = psi_i
            history[State = At(string(state)), Step = At(step)]["overlap"] = maximum(overlaps)

            for key in other_keys
                history[State = At(string(state)), Step = At(step)][key] = other_sorts[key][step][max_loc]
            end
            psi_im1 = psi_i
        end
        next!(P)
    end
    return history 
end

