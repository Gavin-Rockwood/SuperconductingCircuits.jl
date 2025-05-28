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