"""
    square_envelope(t, drive_time)

Returns the value of a square envelope function at time `t` for a given `drive_time`.

# Arguments
- `t`: The current time (can be a scalar or array).
- `drive_time`: The duration of the drive (not used in this function).

# Returns
- `1.0`: The function always returns 1.0, representing a constant (square) envelope.
"""
function square_envelope(t, drive_time)
    return 1.0
end
envelope_dict["square"] = square_envelope



# function square_envelope_cal(x...)
#     drive_time = x[1]
#     envelope_Args = x[2]
#     return envelope_Args
# end
# envelope_dict_cal["square"] = square_envelope_cal






