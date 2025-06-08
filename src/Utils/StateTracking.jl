"""
    state_tracker(state_history::Vector, states_to_track::Dict; other_sorts=Dict{Any, Any}(), use_logging=true)

Tracks the evolution of specified quantum states across a sequence of state histories.

# Arguments
- `state_history::Vector`: A vector where each element is a collection (e.g., vector or array) of quantum states at a given time step.
- `states_to_track::Dict`: A dictionary mapping state identifiers to their initial state vectors to be tracked.
- `other_sorts::Dict{Any, Any}` (optional): A dictionary mapping additional property names to arrays of properties, which are also tracked for each state and time step. Defaults to an empty dictionary.
- `use_logging::Bool` (optional): If `true`, enables debug and info logging for tracking progress and overlaps. Defaults to `true`.

# Returns
- `history`: A multidimensional array (AxisArray or similar) indexed by state and step, where each entry is a dictionary containing:
    - `"psi"`: The tracked state vector at that step.
    - `"overlap"`: The maximum overlap value found for the state at that step.
    - Additional keys for each property in `other_sorts`, containing their respective values.

# Description
For each state specified in `states_to_track`, the function iteratively finds, at each time step, the state in `state_history` with the maximum overlap (squared inner product) with the previous step's tracked state. It records the state vector, overlap, and any additional properties provided in `other_sorts`. The function also ensures that the same state is not assigned to multiple tracked states at the same step, logging a warning if this occurs.
"""
function state_tracker(state_history::Vector, states_to_track::Dict; other_sorts = Dict{Any, Any}(), use_logging = true)
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
                if use_logging
                    @info("------------------------------------------------------------------------")
                    @info("State $state at step $step has already been used.")
                    @info(reverse(sort(overlaps)[end-5:end]))
                end
                prev_locs = findall(x->x == max_loc, used_states[:, step])
                
                if use_logging
                    @info("It has been used: $prev_locs")
                    @info("The overlaps were: ")
                end
                prev_overlaps = []
                for loc in prev_locs
                    old_state = state_keys[loc]
                    push!(prev_overlaps, history[State = At(string(old_state)), Step = At(step)]["overlap"])
                end
                if use_logging
                    @info(prev_overlaps)
                end
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

