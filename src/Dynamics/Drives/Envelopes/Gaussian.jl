"""
    guassian_envelope(t, drive_time; sigma_factor=4, mu=0)

Computes the value of a Gaussian envelope at time `t` for a given `drive_time`.

# Arguments
- `t`: The time at which to evaluate the envelope.
- `drive_time`: The total duration of the drive pulse.
- `sigma_factor`: (optional) The factor by which `drive_time` is divided to obtain the standard deviation `sigma` of the Gaussian. Default is 4.
- `mu`: (optional) The mean (center) of the Gaussian. If set to `"center"`, it will be set to `drive_time/2`. Default is 0.

# Returns
- The value of the Gaussian envelope at time `t`. Returns 0 if `sigma` is 0.
"""
function envelope_gaussian(t, drive_time; sigma_factor=4, mu = 0)
    sigma = drive_time/sigma_factor
    if mu == "center"
        mu = drive_time/2
    end

    if sigma == 0
        return 0
    else
        return exp(-(t-mu)^2/(2*sigma^2))
    end
end
envelope_dict["gaussian"] = envelope_gaussian

# function guassian_envelope_cal(x...)
#     drive_time = x[1]
#     envelope_Args = x[2]
#     envelope_Args["mu"] = drive_time/2

#     return envelope_Args
# end
# envelope_dict_cal["guassian"] = guassian_envelope_cal

