"""
    bump_ramp_envelope(t, drive_time; ramp_time=1, k=2)

Generates a time-dependent envelope function that smoothly transitions between 
a ramp-up, a constant plateau, and a ramp-down phase.

# Arguments
- `t::Number`: The current time at which the envelope is evaluated.
- `drive_time::Number`: The total duration of the drive.
- `ramp_time::Number`: The duration of the ramp-up and ramp-down phases. Defaults to `1`.
- `k::Number`: A parameter controlling the sharpness of the bump envelope. Defaults to `2`.

# Returns
- `Number`: The value of the envelope at time `t`.

# Behavior
- For `t < ramp_time`, the function returns a bump envelope that ramps up smoothly.
- For `ramp_time ≤ t ≤ drive_time - ramp_time`, the function returns a constant value of `1`.
- For `t > drive_time - ramp_time`, the function returns a bump envelope that ramps down smoothly.

# Notes
- The `bump_envelope` function is assumed to be a helper function that generates a smooth bump shape.
- The `center` keyword argument in the ramp-down phase adjusts the bump envelope to align with the end of the drive.

"""
function bump_ramp_envelope(t, drive_time; ramp_time = 1, k = 2)
    if t<ramp_time
        return bump_envelope(t, 2*ramp_time; k = k)
    elseif (t<=(drive_time-ramp_time)) && (t>=ramp_time)
        return 1
    elseif t>(drive_time-ramp_time)
        return bump_envelope(t, 2*ramp_time, k = k, center = drive_time-ramp_time)
    end
end
envelope_dict["bump_ramp"] = bump_ramp_envelope

function bump_ramp_envelope_cal(x...)
    drive_time = x[1]
    Envelope_Args = x[2]

    if !("k" in keys(Envelope_Args))
        Envelope_Args["k"] = 2
        @warn "k not specified, using default value of 2"
    end
    
    return Envelope_Args
end

envelope_dict_cal["bump_ramp"] = bump_ramp_envelope_cal