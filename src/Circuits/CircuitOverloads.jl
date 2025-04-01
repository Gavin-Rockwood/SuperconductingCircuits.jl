"""
Get_Drive_Hamiltonian that takes in a circuit and drive object
"""
function Dynamics.Get_Drive_Hamiltonian(circuit::Circuits.Circuit, drive::StaticDrive)
    Dynamics.Get_Drive_Hamiltonian(circuit.H_op, circuit.ops[drive.op], drive)
end