function get_drive(circuit :: Circuit, drive_params :: AbstractArray{Dynamics.CircuitDriveParam})
    general_drive_params = [Dynamics.GeneralDriveParam(op = circuit.ops[drive_param.op], coef_param = drive_param.coef_param) for drive_param in drive_params]
    drive = Dynamics.get_drive(general_drive_params)
    drive.drive_params = drive_params
    return drive
end

function Dynamics.get_drive(circuit :: Circuit, drive_param :: Dynamics.CircuitDriveParam)
    Dynamics.get_drive(circuit, [drive_param])
end
