function get_drive_coef(drive_param :: StaticDriveCoefParam)
    envelope = Envelopes.get_envelope(drive_param.drive_time, drive_param.envelope, drive_param.envelope_params)
    function coef(p,t)
        if t < drive_param.delay
            return 0.0
        elseif t > drive_param.drive_time + drive_param.delay
            return 0.0
        else
            tt = t - drive_param.delay
            return drive_param.amplitude * envelope(t) * sin(2 * pi * drive_param.frequency * t + drive_param.phase)
        end
    end
    return coef
end

function get_drive(drive_params :: AbstractArray{GeneralDriveParam}; drive_names = [])
    drive_pairs = []
    times = []
    param_dict = Dict{String, DriveCoefParam}()
    for i in 1:length(drive_params)
        param = drive_params[i].coef_param
        push!(drive_pairs, (drive_params[i].op, get_drive_coef(param)))
        push!(times, param.drive_time+param.delay)
        if i <= length(drive_names)
            param_dict[drive_names[i]] = param
        else
            param_dict["drive_$(i)"] = param
        end
    end

    drive = qt.QobjEvo(tuple(drive_pairs...))
    drive_time = maximum(times)
    
    return Drive(drive_params = drive_params, notes = Dict{Any, Any}(), drive = drive, drive_time = drive_time) 
end

function get_drive(drive_param :: GeneralDriveParam)
    get_drive([drive_param])
end
