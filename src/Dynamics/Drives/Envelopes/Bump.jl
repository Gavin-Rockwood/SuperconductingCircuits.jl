"""
    envelope_bump(t, drive_time; k = 2, mu = "center")

Computes a smooth, localized "bump" envelope function at time `t` over a total `drive_time`.

# Arguments
- `t::Number`: The time at which to evaluate the envelope.
- `drive_time::Number`: The total duration of the envelope.
- `k::Number=2`: (Optional) Sharpness parameter controlling the steepness of the bump's edges.
- `mu::Union{Number, String}="center"`: (Optional) Center of the bump. If set to `"center"`, the bump is centered at `drive_time/2`.

# Returns
- `Number`: The value of the bump envelope at time `t`. Returns `0` outside the interval, `1` at the center, and a smooth exponential bump within.

# Notes
The bump envelope is defined such that it is zero outside the interval `[mu - drive_time/2, mu + drive_time/2]`, peaks at `mu`, and smoothly decays to zero at the boundaries. The parameter `k` controls the sharpness of the bump.
"""
function envelope_bump(t, drive_time; k = 2, mu = "center")
    if mu == "center"
        mu = drive_time/2
    end
    x = (t-mu)/(drive_time/2)
    if x<=-1
        return 0
    elseif x>=1
        return 0
    elseif x == 0
        return 1
    else
        return exp(k*x^2/(x^2-1))
    end
    
end
envelope_dict["bump"] = envelope_bump

# function bump_envelope_cal(x...)
#     drive_time = x[1]
#     Envelope_Args = x[2]
#     if !("k" in keys(Envelope_Args))
#         Envelope_Args["k"] = 2
#         @warn "k not specified, using default value of 2"
#     end

#     return Envelope_Args
# end
# envelope_dict_cal["Bump"] = bump_envelope_cal