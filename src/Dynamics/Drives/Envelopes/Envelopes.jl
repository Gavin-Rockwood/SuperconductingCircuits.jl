module Envelopes
    Envelope_Dict = Dict{Any, Any}()
    Envelope_Dict_Cal = Dict{Any, Any}()

    include("Square.jl")
    include("Gaussian.jl")
    include("Gaussian_Ramp.jl")
    include("Sine_Squared.jl")
    include("Sine_Squared_Ramp.jl")
    include("Bump.jl")
    include("Bump_Ramp.jl")

    """
    This takes an envelope function and digitizes it to a step length. 
    The default step length is 2.3 ns which is the time resolution of the DAC in the lab
    """
    function Digitize_Envelope(envelope; step_length = 2.3)
        function digitized_envelope(t)
            N = floor(t/step_length)
            return envelope(N*step_length)
        end
        return digitized_envelope
    end

    function Get_Envelope(drive_time, envelope_name, envelope_kwargs; digitize = false, step_length = 2.3)
        envelope_kwargs_sym = Dict{Symbol, Any}()
        for key in keys(envelope_kwargs)
            envelope_kwargs_sym[Symbol(key)] = envelope_kwargs[key]
        end

        function envelope(t)
            return Envelope_Dict[envelope_name](t, drive_time; envelope_kwargs_sym...)
        end

        if digitize
            return Digitize_Envelope(envelope; step_length = step_length)
        else
            return envelope
        end
    end

end