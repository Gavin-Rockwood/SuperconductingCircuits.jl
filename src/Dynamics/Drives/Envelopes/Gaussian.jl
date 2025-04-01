function Guassian_Envelope(t, drive_time; sigma_factor=4, mu = 0)
    sigma = drive_time/sigma_factor
    mu = mu
    return exp(-(t-mu)^2/(2*sigma^2))
end
Envelope_Dict["Guassian"] = Guassian_Envelope

function Guassian_Envelope_Cal(x...)
    drive_time = x[1]
    Envelope_Args = x[2]
    Envelope_Args["mu"] = drive_time/2

    return Envelope_Args
end
Envelope_Dict_Cal["Guassian"] = Guassian_Envelope_Cal