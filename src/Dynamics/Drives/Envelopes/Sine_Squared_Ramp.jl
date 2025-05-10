function sine_squared_ramp_envelope(t, drive_time; ramp_time = 10)
    # sine_squared_envelope does not use the drive_time argument
    flat_top_time = drive_time-2*ramp_time
    if t<=ramp_time
        return sine_squared_envelope(t,nothing; ramp_time = ramp_time)
    elseif (t>ramp_time) & (t<flat_top_time+ramp_time)
        return 1.0+0*t # the 0*t is for autodif :d
    elseif t>=flat_top_time+ramp_time
        return sine_squared_envelope(t, nothing; ramp_time = ramp_time, offset = flat_top_time+ramp_time, phi = π/2)
    end
end
envelope_dict["sine_squared_ramp"] = sine_squared_ramp_envelope


# function sine_squared_ramp_envelope_cal(x...)
#     t = x[1]
#     envelope_Args = x[2]
#     envelope_Args["pulse_time"] = t
#     return envelope_Args
# end
# envelope_dict_cal["sine_squared_ramp"] = sine_squared_ramp_envelope_cal