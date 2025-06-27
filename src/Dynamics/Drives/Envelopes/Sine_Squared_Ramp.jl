"""
    sine_squared_ramp_envelope(t, drive_time; ramp_time = 10)

Generates a smooth envelope function with sine-squared ramps at the beginning and end, and a flat top in between.

# Arguments
- `t`: The current time at which to evaluate the envelope.
- `drive_time`: The total duration of the envelope, including both ramps and the flat top.
- `ramp_time`: (optional, default=10) The duration of the rising and falling sine-squared ramps.

# Returns
- The value of the envelope at time `t`. The envelope smoothly ramps up using a sine-squared function for `ramp_time`, stays at 1.0 for the flat top, and ramps down with a sine-squared function at the end.

# Notes
- The function assumes the existence of `sine_squared_envelope`, which generates the ramp shape.
- The `0*t` term ensures compatibility with automatic differentiation tools.
- If `drive_time < 2*ramp_time`, the flat top duration will be zero or negative, which may not be intended.
"""
function envelope_sine_squared_ramp(t, drive_time; ramp_time = 10)
    # sine_squared_envelope does not use the drive_time argument
    flat_top_time = drive_time-2*ramp_time
    if t<=ramp_time
        return envelope_sine_squared(t,nothing; ramp_time = ramp_time)
    elseif (t>ramp_time) & (t<flat_top_time+ramp_time)
        return 1.0+0*t # the 0*t is for autodif :d
    elseif t>=flat_top_time+ramp_time
        return envelope_sine_squared(t, nothing; ramp_time = ramp_time, offset = flat_top_time+ramp_time, phi = π/2)
    end
end
envelope_dict["sine_squared_ramp"] = envelope_sine_squared_ramp


# function sine_squared_ramp_envelope_cal(x...)
#     t = x[1]
#     envelope_Args = x[2]
#     envelope_Args["pulse_time"] = t
#     return envelope_Args
# end
# envelope_dict_cal["sine_squared_ramp"] = sine_squared_ramp_envelope_cal