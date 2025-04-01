function Square_Envelope(t, drive_time)
    return 1.0
end
Envelope_Dict["Square"] = Square_Envelope



function Square_Envelope_Cal(x...)
    drive_time = x[1]
    Envelope_Args = x[2]
    return Envelope_Args
end
Envelope_Dict_Cal["Square"] = Square_Envelope_Cal






