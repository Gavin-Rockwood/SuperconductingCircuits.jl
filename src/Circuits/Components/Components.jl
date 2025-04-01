# Defining Component Abstract Type
abstract type Component end
# All components will have:
# - a dimension (dim)
# - a Hamiltonian (H_op)
# - eigenenergies
# eigenstates
# - a dictionary called "loss_ops" that can be filled with collapse and dephasing operators (loss_ops)
# -a dictionary "params" which contains all the parameters that go into the init function where they keys are symbols
Component_Required_Objects = [:H_op, :params, :eigenstates, :eigenenergies, :dim, :loss_ops]

init_Components = Dict{Any, Any}() # The keys here need to be same names as the struct names
include("Resonator.jl")
init_Components["Resonator"] = init_Resonator
include("SNAIL.jl")
init_Components["SNAIL"] = init_SNAIL
include("Transmons.jl")
init_Components["Transmon"] = init_Transmon
include("Qubit.jl")
init_Components["Qubit"] = init_Qubit
