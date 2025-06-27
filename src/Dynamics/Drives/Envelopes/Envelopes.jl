module Envelopes
    envelope_dict = Dict{Any, Any}()

    # All envelope functions need to be defined as f(t, drive_time; kwargs...)
    # This is very important because it standardizes the envelope functions to make saving and reading 
    # parameters easier. 

    include("Square.jl")
    export envelope_square

    include("Gaussian.jl")
    export envelope_gaussian

    include("Gaussian_Ramp.jl")
    export envelope_gaussian_ramp

    include("Sine_Squared.jl")
    export envelope_sine_squared

    include("Sine_Squared_Ramp.jl")
    export envelope_sine_squared_ramp

    include("Bump.jl")
    export envelope_bump

    include("Bump_Ramp.jl")
    export envelope_bump_ramp

    include("Envelope_Utils.jl")
    export get_envelope
    export envelope_dict
end