function bump_envelope(t, drive_time; k = 2, center = "None")
    if center == "None"
        center = drive_time/2
    end
    x = (t-center)/(drive_time/2)
    if x<=-1
        return 0
    elseif x>=1
        return 0
    elseif x == 0
        return 1
    else
        return exp(k*x^2/(x^2-1))
    end
    
end
envelope_dict["bump"] = bump_envelope

function bump_envelope_cal(x...)
    drive_time = x[1]
    Envelope_Args = x[2]
    if !("k" in keys(Envelope_Args))
        Envelope_Args["k"] = 2
        @warn "k not specified, using default value of 2"
    end

    return Envelope_Args
end
envelope_dict_cal["Bump"] = bump_envelope_cal