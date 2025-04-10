@kwdef struct floquet_basis
    e_quasi :: Vector
    modes :: Function
    T :: Number
end

include("Floquet_Utils.jl")
include("Floquet_Basis.jl")
include("Floquet_Sweep.jl")