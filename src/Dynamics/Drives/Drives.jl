abstract type Drive end

@kwdef struct StaticDrive 
    op :: String
    envelope :: String
    envelope_params :: Dict{Symbol, Any}
    frequency :: Float64
    phase :: Float64
    amplitude :: Float64
    time :: Float64
    notes :: Dict{Any, Any}
end


include("Envelopes/Envelopes.jl")
include("DriveCoefficient.jl")
include("DriveHamiltonian.jl")
include("DriveCalibration.jl")
