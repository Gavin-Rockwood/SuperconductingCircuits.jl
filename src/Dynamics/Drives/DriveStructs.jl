abstract type DriveParam end
abstract type DriveCoefParam end

export DriveParam
export DriveCoefParam
export StaticDriveCoefParam
export DynamicDriveCoefParam
export GeneralDriveParam
export CircuitDriveParam
export Drive
export Gate


# Static drives have constant frequencies, dynamic drives have time dependent frequencies.
    # Need to add the dynamic drives as well as digital drives 
# this is used if the drive is defined with respect ot a circuit. The string for op should correspond to a key in Circuit.ops

@kwdef mutable struct StaticDriveCoefParam <: DriveCoefParam
    envelope :: String
    envelope_params :: Dict{Symbol, Any}
    frequency :: Number
    phase :: Number
    amplitude :: Number
    drive_time :: Number
    delay :: Number = 0.0
end 
    
@kwdef mutable struct DynamicDriveCoefParam <: DriveCoefParam
    envelope :: String
    envelope_params :: Dict{Symbol, Any}
    frequency :: Function
    phase :: Number
    amplitude :: Number
    drive_time :: Number
    delay :: Number = 0.0
end 

@kwdef struct GeneralDriveParam <: DriveParam
    op :: qt.QuantumObject
    coef_param :: DriveCoefParam
end

# This is used when overloading for circuit objects in CircuitOverloads.jl
@kwdef struct CircuitDriveParam <: DriveParam
    op :: String
    coef_param :: DriveCoefParam
end

@kwdef struct Drive
    drive_params :: AbstractArray{DriveParam}
    notes :: Dict{Any, Any}
    drive :: qt.QuantumObjectEvolution # this is the time dependent operator of the drive
    drive_time :: Number # this is the total amount of time the drives will be on for, it includes any delays.
    includes_H :: Bool
end

@kwdef struct Gate
    drive :: Drive
    gate :: qt.QuantumObject
    notes :: Dict{Any, Any}
end
