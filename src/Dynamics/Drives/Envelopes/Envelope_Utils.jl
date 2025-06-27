 """
This takes an envelope function and digitizes it to a step length. 
The default step length is 2.3 ns which is the time resolution of the DAC in the lab
"""
function digitize_envelope(envelope; step_length = 2.3)
    function digitized_envelope(t)
        N = floor(t/step_length)
        return envelope(N*step_length)
    end
    return digitized_envelope
end

"""
    get_envelope(drive_time, envelope_name, envelope_kwargs; digitize = false, step_length = 2.3)

Constructs and returns an envelope function for a given drive time and envelope type.

# Arguments
- `drive_time`: The total duration of the drive (in appropriate time units).
- `envelope_name`: The name (key) of the envelope type to use. Must correspond to a key in `envelope_dict`.
- `envelope_kwargs`: A dictionary of keyword arguments to be passed to the envelope function.
- `digitize` (optional): If `true`, the envelope will be digitized using the specified `step_length`. Defaults to `false`.
- `step_length` (optional): The step length to use when digitizing the envelope. Defaults to `2.3`.

# Returns
- A function `envelope(t)` that computes the envelope value at time `t`. If `digitize` is `true`, returns a digitized version of the envelope.

"""
function get_envelope(drive_time, envelope_name, envelope_kwargs; digitize = false, step_length = 2.3)
    envelope_kwargs_sym = Dict{Symbol, Any}()
    for key in keys(envelope_kwargs)
        envelope_kwargs_sym[Symbol(key)] = envelope_kwargs[key]
    end

    function envelope(t)
        return envelope_dict[envelope_name](t, drive_time; envelope_kwargs_sym...)
    end

    if digitize
        return digitize_envelope(envelope; step_length = step_length)
    else
        return envelope
    end
end