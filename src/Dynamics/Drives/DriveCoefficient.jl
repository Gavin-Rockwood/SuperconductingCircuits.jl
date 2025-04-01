function Get_Drive_Coefficient(amplitude, frequency, phase, envelope; return_complex = false)
    eps_t(t) = amplitude*envelope(t)
    # the params and kwargs are needed for the form required to get the QobjEvo 
    drive_coef(p, t) = eps_t(t)*sin(2*pi*frequency*t+phase)
    drive_coef_C(p, t) = eps_t(t)*exp(-2im*pi*frequency*t+phase)

    if return_complex
        return drive_coef_C
    else
        return drive_coef
    end
end



function Get_Drive_Coefficient(drive::StaticDrive; kwargs...)
    digitize = false
    if "digitize" in drive.notes
        digitize = drive.notes["digitize"]
    end
    envelope = Envelopes.Get_Envelope(drive.drive_time, drive.envelope, drive.envelope_params; digitize = digitize)
    
    Get_Drive_Coefficient(drive.amplitude, drive.frequency, drive.phase, envelope; kwargs...)
end