"""
    sine_squared_envelope(t, drive_time; ramp_time = 0, offset = 0, phi = 0)

Generates a sine-squared envelope function value at time `t`.

# Arguments
- `t`: The current time at which to evaluate the envelope.
- `drive_time`: The total duration of the drive (not used in the current implementation, but may be relevant for context).
- `ramp_time`: The duration over which the envelope ramps up or down. If `ramp_time == 0`, the function returns 0.
- `offset`: The time offset to shift the envelope along the time axis.
- `phi`: An additional phase offset (in radians) applied to the sine argument.

# Returns
- The value of the sine-squared envelope at time `t`. Returns 0 if `ramp_time == 0`, otherwise returns `sin((π/2)*(t-offset)/ramp_time + phi)^2`.

"""
function sine_squared_envelope(t, drive_time; ramp_time = 0, offset = 0, phi = 0)
    if ramp_time == 0
        return 0
    else
        return sin((π/2)*(t-offset)/ramp_time + phi)^2
    end
end
envelope_dict["sine_squared"] = sine_squared_envelope

# function sine_squared_envelope_cal(x...)
#     drive_time = x[1]
#     envelope_Args = x[2]

#     envelope_Args["offset"] = drive_time/2
#     envelope_Args["ramp_time"] = drive_time/2

#     return envelope_Args
# end
# envelope_dict_cal["sine_squared"] = sine_squared_envelope_cal