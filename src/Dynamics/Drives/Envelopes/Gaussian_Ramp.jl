"""
    gaussian_ramp_envelope(t, drive_time; ramp_time=10, sigma_factor=4)

Generates a smooth envelope function with Gaussian-shaped rising and falling edges and a flat top.

# Arguments
- `t`: The current time at which to evaluate the envelope.
- `drive_time`: The total duration of the envelope.
- `ramp_time`: (optional) The duration of the Gaussian ramp at the beginning and end of the envelope. Default is 10.
- `sigma_factor`: (optional) The width factor for the Gaussian ramps. Default is 4.

# Returns
- The value of the envelope at time `t`. The envelope ramps up with a Gaussian profile, stays flat at 1.0, and then ramps down with a Gaussian profile.

# Notes
- The function assumes the existence of a `guassian_envelope` function for generating the Gaussian ramps.
- The flat top duration is calculated as `drive_time - 2*ramp_time`.
- The `0*t` term ensures compatibility with automatic differentiation tools.
"""
function envelope_gaussian_ramp(t, drive_time; ramp_time = 10, sigma_factor = 4)
    flat_top_time = drive_time - 2*ramp_time

    if t<= ramp_time
        loc_drive_time = ramp_time
        return envelope_gaussian(t, loc_drive_time; sigma_factor = sigma_factor, mu = ramp_time)
    elseif (t>ramp_time) & (t<flat_top_time+ramp_time)
        return 1.0+0*t # the 0*t is for autodif :d
    elseif (t>=flat_top_time+ramp_time)
        loc_drive_time = drive_time - (flat_top_time+ramp_time)
        mu = flat_top_time+ramp_time
        return envelope_gaussian(t, loc_drive_time; sigma_factor = sigma_factor, mu = mu)
    end
end
envelope_dict["gaussian_ramp"] = envelope_gaussian_ramp

# function gaussian_ramp_envelope_cal(x...)
#     t = x[1]
#     envelope_Args = x[2]
#     return envelope_Args
# end
# envelope_dict_cal["gaussian_ramp"] = gaussian_ramp_envelope_cal