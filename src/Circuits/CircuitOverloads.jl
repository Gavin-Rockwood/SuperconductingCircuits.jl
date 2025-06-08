function Dynamics.get_drive(circuit :: Circuit, drive_params :: AbstractArray{Dynamics.CircuitDriveParam}; kwargs...)
    #general_drive_params = [Dynamics.GeneralDriveParam(op = circuit.ops[drive_param.op], coef_param = drive_param.coef_param) for drive_param in drive_params]
    #drive = Dynamics.get_drive(general_drive_params; kwargs...)
    drive_coef_params = [drive_params[i].coef_param for i in 1:length(drive_params)]
    ops = [circuit.ops[drive_params[i].op] for i in 1:length(drive_params)]
    drive = Dynamics.get_drive(drive_coef_params, ops; drive_params = drive_params, kwargs...)
    return drive
end

function Dynamics.get_drive(circuit :: Circuit, drive_param :: Dynamics.CircuitDriveParam; drive_name = "", kwargs...)
    if drive_name == ""
        drive_name = "drive_1"
    end
    Dynamics.get_drive(circuit, [drive_param]; drive_names = [drive_name], kwargs...)
end


# function Dynamics.calibrate_drive_time!(drive_param :: Dynamics.CircuitDriveParam, circuit :: Circuit, t_range, psi0, to_min :: Function; kwargs...)
#     Dynamics.calibrate_drive_time!(drive_param.coef_param, circuit.H_op, circuit.ops[drive_param.op], t_range, psi0, to_min; kwargs...)
# end

# function Dynamics.calibrate_drive_time(drive_param :: Dynamics.CircuitDriveParam, circuit :: Circuit, t_range, psi0, to_min :: Function; kwargs...)
#     res = Dynamics.calibrate_drive_time(drive_param.coef_param, circuit.H_op, circuit.ops[drive_param.op], t_range, psi0, to_min; kwargs...)
#     if typeof(res) <: Dynamics.StaticDriveCoefParam
#         res = Dynamics.CircuitDriveParam(open = drive_param.op, coef_param = res)
#     end
#     return res
# end

# function Dynamics.calibrate_drive_time!(drive_coef_param :: Dynamics.StaticDriveCoefParam, circuit :: Circuit, drive_op, args...; kwargs...)
#     Dynamics.calibrate_drive_time!(drive_coef_param, circuit.H_op, circuit.ops[drive_op], args...; kwargs...)
# end

# function Dynamics.calibrate_drive_time(drive_coef_param :: Dynamics.StaticDriveCoefParam, circuit :: Circuit, drive_op, args...; kwargs...)
#     Dynamics.calibrate_drive_time(drive_coef_param, circuit.H_op, circuit.ops[drive_op], args...; kwargs...)
# end
