
# function findstarkshift(H_op,
#     H_D_op,
#     psi1,
#     psi2,
#     base_frequency,
#     amplitude,
#     starkshifts;
#     make_plot = true,
#     state_names = ["1", "2"], 
#     Floquet_t0_Sweep_kwargs = Dict{Any, Any}())

#     frequencies = base_frequency .+ starkshifts
    
#     envelope(t) = 1.0
#     function H_func(frequency)
#         drive_coef = get_drive_coefficient(amplitude, frequency, 0.0, envelope)
#         return qt.QObjEvo(H_op, (H_D_op, drive_coef))
#     end
#     Ts = 1.0 ./ frequencies
#     states_to_track = Dict{Any, Any}(state_names[1] => psi1, state_names[2] => psi2)
#     Floquet_t0_Sweep_kwargs["states_to_track"] = states_to_track

#     Floq_Sweep_Res = Floquet_t0_Sweep(H_func, frequencies, Ts; Floquet_t0_Sweep_kwargs...)

#     ys = []
#     for state in ["1", "2"]
#         ys_temp = []
#         for i in 1:length(frequencies)
#             val = Floq_Sweep_Res["Tracking"][State = At(string(state)), Step = At(i)]["Quasienergies"]/pi
#             if val < 0
#                 val += 2*abs(frequencies[i])
#             end
#             push!(ys_temp, val)
#         end
#         push!(ys, ys_temp)
#     end

#     x = starkshifts
#     difs1 = abs.(ys[1] .- ys[2])
#     difs2 = 2*abs.(frequencies) .- abs.(ys[1] .- ys[2])

#     difs = []
#     for i in 1:length(difs1)
#         push!(difs, min(difs1[i], difs2[i]))
#     end

#     to_fit(t,p) = p[3]*sqrt.((t.-p[1]).^2 .+ p[2].^2)
#     p0 = zeros(3)
#     p0[1] = x[argmin(difs)]
#     p0[2] = minimum(difs)
#     p0[3] = abs((maximum(difs)-minimum(difs))/(x[argmax(difs)]-x[argmin(difs)]))
#     fit = LF.curve_fit(to_fit, x, difs, p0)

#     @info "Fit Stuff: "*Utils.tostr(fit.param)

#     to_return = Dict{Any, Any}("Stark Shift" => fit.param[1], "Approximate Drive Time" => 1/(fit.param[2]*fit.param[3]), "ys" => ys, "difs" => difs, "fit" => fit)

#     if make_plot 
#         f = cm.Figure(size = (800, 500), px_per_unit = 3)

#         ax1 = cm.Axis(f[1,1], title = "Floquet Energies", xlabel = "Stark Shifts", ylabel = "Quasienergies (GHz)")
#         ax2 = cm.Axis(f[2,1], title = "Difference", xlabel = "Stark Shifts", ylabel = "Dif (GHz)")


#         x = Real.(collect(νs.-ν))
#         y = []

#         colorlist = [:forestgreen, :coral]
#         markers = ['+', '×']

#         for i in 1:length(dims(tracking_res, :State))
#             state = dims(tracking_res, :State)[i]
#             cm.scatterlines!(ax1, x, ys[i], label = state, color = colorlist[i], marker = markers[i], linewidth = 0.5, markersize = 20)
#             #cm.lines!(ax1, x, y, color = colorlist[i], linewidth = 0.5)
#         end
#         cm.axislegend(ax1)


#         x2 = collect(LinRange(x[1], x[end], 101))
#         y2 = to_fit(x2, fit.param)

#         fitted_shift = round(fit.param[1], sigdigits = 3)
#         cm.lines!(ax2, x2, y2, color = :forestgreen, alpha = 0.25, linewidth= 8, label = "Fitted Stark Shift: $fitted_shift GHz")
#         cm.scatterlines!(ax2, x, difs, label = "Difs", marker = '+', markersize = 20, color = :black, linewidth = 0.5)
#         cm.axislegend(ax2)
#         cm.display(f)

#         if return_fig_data
#             top_dat = Dict{Any, Any}("x" => x)
#             for i in 1:length(dims(tracking_res, :State))
#                 state = dims(tracking_res, :State)[i]
#                 top_dat[state] = ys[i]
#             end

#             bottom_dat = Dict{Any, Any}("x" => x, "y" => difs, "fit_x" => x2, "fit_y" => y2)

#             fig_data = Dict{Any, Any}("top" => top_dat, "bottom" => bottom_dat)
#             to_return["fig_data"] = fig_data
#         end
#     end
    
#     return to_return
    
# end