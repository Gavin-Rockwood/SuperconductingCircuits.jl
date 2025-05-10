function gaussian_ramp_envelope(t, drive_time; ramp_time = 10, sigma_factor = 4)
    flat_top_time = drive_time - 2*ramp_time

    if t<= ramp_time
        loc_drive_time = ramp_time
        return guassian_envelope(t, loc_drive_time; sigma_factor = sigma_factor, mu = ramp_time)
    elseif (t>ramp_time) & (t<flat_top_time+ramp_time)
        return 1.0+0*t # the 0*t is for autodif :d
    elseif (t>=flat_top_time+ramp_time)
        loc_drive_time = drive_time - (flat_top_time+ramp_time)
        mu = flat_top_time+ramp_time
        return guassian_envelope(t, loc_drive_time; sigma_factor = sigma_factor, mu = mu)
    end
end
envelope_dict["gaussian_ramp"] = gaussian_ramp_envelope

# function gaussian_ramp_envelope_cal(x...)
#     t = x[1]
#     envelope_Args = x[2]
#     return envelope_Args
# end
# envelope_dict_cal["gaussian_ramp"] = gaussian_ramp_envelope_cal