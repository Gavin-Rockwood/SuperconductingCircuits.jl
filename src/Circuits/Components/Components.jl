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

include("ComponentUtils.jl")

init_components = Dict{Any, Any}() # The keys here need to be same names as the struct names
include("Resonator.jl")
init_components["resonator"] = init_resonator
include("SNAIL.jl")
init_components["snail"] = init_snail
include("Transmon.jl")
init_components["transmon"] = init_transmon
include("Qubit.jl")
init_components["qubit"] = init_qubit
