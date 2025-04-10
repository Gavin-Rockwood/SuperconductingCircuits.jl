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
    used_states = Array{Int}(undef, NUM_TO_TRACK,STEPS)*0

    for k in 1:length(state_keys)
        state = state_keys[k]
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
            if max_loc in used_states[:, step]
                println("------------------------------------------------------------------------")
                println("State $state at step $step has already been used.")
                println(reverse(sort(overlaps)[end-5:end]))
                prev_locs = findall(x->x == max_loc, used_states[:, step])
                println("It has been used: $prev_locs")
                println("The overlaps were: ")
                prev_overlaps = []
                for loc in prev_locs
                    old_state = state_keys[loc]
                    push!(prev_overlaps, history[State = At(string(old_state)), Step = At(step)]["overlap"])
                end
                println(prev_overlaps)


            end
            psi_i = state_history[step][max_loc]
            history[State = At(string(state)), Step = At(step)]["psi"] = psi_i
            history[State = At(string(state)), Step = At(step)]["overlap"] = maximum(overlaps)

            for key in other_keys
                history[State = At(string(state)), Step = At(step)][key] = other_sorts[key][step][max_loc]
            end
            psi_im1 = psi_i
        
            used_states[k, step] = max_loc
        end
        next!(P)
    end
    return history 
end

