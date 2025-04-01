"""
drive_ops is either a tuple (op, coef(t)) or a list of tuples. 
"""
function Get_Drive_Hamiltonian(H_op, drive_ops)
    if typeof(drive_ops[1]) <: qt.QuantumObject
        drive_ops = (drive_ops,)  
    end
    H = qt.QobjEvo(((H_op), drive_ops...))
    
end

"""
Get_Drive_Hamiltonian that takes in a StaticDrive object instead of a tuple 
"""
function Get_Drive_Hamiltonian(H_op, H_D_op, drive::StaticDrive)
    digitize = false
    if "digitize" in drive.notes
        digitize = drive.notes["digitize"]
    end
    drive_coef = Get_Drive_Coefficient(drive; digitize = digitize)

    Get_Drive_Hamiltonian(H_op, (H_D_op, drive_coef))
end