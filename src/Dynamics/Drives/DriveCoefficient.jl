function get_drive_coef(drive_coef_param :: StaticDriveCoefParam)
    envelope = Envelopes.get_envelope(drive_coef_param.drive_time, drive_coef_param.envelope, drive_coef_param.envelope_params)
    function coef(p,t)
        if t < drive_coef_param.delay
            return 0.0
        elseif t > drive_coef_param.drive_time + drive_coef_param.delay
            return 0.0
        else
            tt = t - drive_coef_param.delay
            return drive_coef_param.amplitude * envelope(t) * sin(2 * pi * drive_coef_param.frequency * t + drive_coef_param.phase)
        end
    end
    return coef
end


function get_drive(drive_coef_params :: AbstractArray{StaticDriveCoefParam}, ops; drive_names = [], H_op = 0.0, drive_params = [])
    drive_pairs = []
    times = []
    params_dict = Dict{String, DriveCoefParam}()
    includes_H = false
    for i in 1:length(drive_coef_params)
        param = drive_coef_params[i]
        push!(drive_pairs, (ops[i], get_drive_coef(param)))
        push!(times, param.drive_time+param.delay)
        if i <= length(drive_names)
            params_dict[drive_names[i]] = param
        else
            params_dict["drive_$(i)"] = param
        end
    end
    drive = qt.QobjEvo(tuple(drive_pairs...))
    drive_time = maximum(times)
    if (typeof(H_op) <: qt.QuantumObject) | (typeof(H_op) <: qt.QobjEvo)
        drive = drive+H_op
        includes_H = true
    end
    if !(length(drive_coef_params) == length(drive_params))
        drive_params = [GeneralDriveParam(op = op, coef_param = drive_coef_params[i]) for i in 1:length(drive_coef_params)]
    end
        
    return Drive(drive_params = drive_params, notes = Dict{Any, Any}(), drive = drive, drive_time = drive_time, includes_H = includes_H)
end



function get_drive(drive_params :: AbstractArray{GeneralDriveParam}; kwargs...)
    coef_params = [param.coef_param for param in drive_params]
    ops = [param.op for param in drive_params]
    get_drive(coef_params, ops; drive_params = drive_params, kwargs...)
end

function get_drive(drive_param :: GeneralDriveParam; drive_name = "", kwargs...)
    if drive_name == ""
        drive_name = "drive_1"
    end
    get_drive([drive_param]; drive_names = [drive_name], kwargs...)
end
