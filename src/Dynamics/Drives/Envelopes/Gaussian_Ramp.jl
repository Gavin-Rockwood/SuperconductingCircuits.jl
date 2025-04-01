function Gaussian_Ramp_Envelope(t, drive_time; ramp_time = 10, sigma_factor = 4)
    flat_top_time = drive_time - 2*ramp_time

    if t<= ramp_time
        loc_drive_time = ramp_time
        return Guassian_Envelope(t, loc_drive_time; sigma_factor = sigma_factor, mu = ramp_time)
    elseif (t>ramp_time) & (t<flat_top_time+ramp_time)
        return 1.0+0*t # the 0*t is for autodif :D
    elseif (t>=flat_top_time+ramp_time)
        loc_drive_time = drive_time - (flat_top_time+ramp_time)
        mu = flat_top_time+ramp_time
        return Guassian_Envelope(t, loc_drive_time; sigma_factor = sigma_factor, mu = mu)
    end
end
Envelope_Dict["Gaussian_Ramp"] = Gaussian_Ramp_Envelope

function Gaussian_Ramp_Envelope_Cal(x...)
    t = x[1]
    Envelope_Args = x[2]
    return Envelope_Args
end
Envelope_Dict_Cal["Gaussian_Ramp"] = Gaussian_Ramp_Envelope_Cal