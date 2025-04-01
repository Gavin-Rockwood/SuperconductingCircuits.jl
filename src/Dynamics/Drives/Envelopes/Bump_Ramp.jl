function Bump_Ramp_Envelope(t, drive_time; ramp_time = 1, k = 2)
    if t<ramp_time
        return Bump_Envelope(t, 2*ramp_time; k = k)
    elseif (t<=(drive_time-ramp_time)) && (t>=ramp_time)
        return 1
    elseif t>(drive_time-ramp_time)
        return Bump_Envelope(t, 2*ramp_time, k = k, center = drive_time-ramp_time)
    end
end
Envelope_Dict["Bump_Ramp"] = Bump_Ramp_Envelope

function Bump_Ramp_Envelope_Cal(x...)
    drive_time = x[1]
    Envelope_Args = x[2]

    if !("k" in keys(Envelope_Args))
        Envelope_Args["k"] = 2
        @warn "k not specified, using default value of 2"
    end
    
    return Envelope_Args
end

Envelope_Dict_Cal["Bump_Ramp"] = Bump_Ramp_Envelope_Cal