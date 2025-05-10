function guassian_envelope(t, drive_time; sigma_factor=4, mu = 0)
    sigma = drive_time/sigma_factor
    if mu == "center"
        mu = drive_time/2
    end
    return exp(-(t-mu)^2/(2*sigma^2))
end
envelope_dict["guassian"] = guassian_envelope

# function guassian_envelope_cal(x...)
#     drive_time = x[1]
#     envelope_Args = x[2]
#     envelope_Args["mu"] = drive_time/2

#     return envelope_Args
# end
# envelope_dict_cal["guassian"] = guassian_envelope_cal

