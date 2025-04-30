function find_stark_shifts(H_func, base_freq, amplitude, starkshifts, reference_states::T1; show_plot = false) where T1<:Dict
    drive_freqs = base_freq .+ starkshifts
    sampling_points = []
    state_keys= collect(keys(reference_states))
    
    for drive_freq in drive_freqs
        push!(sampling_points, Dict(:frequency => drive_freq, :amplitude => amplitude))
    end
    
    floq_sweep = floquet_sweep(H_func, sampling_points, 1.0./drive_freqs; states_to_track = reference_states)

    quasienergies = []
    for state in state_keys
        vals_temp = []
        for i in 1:length(drive_freqs)
            val = floq_sweep["Tracking"][State = At(string(state)), Step = At(i)]["Quasienergies"]/(2*pi)
            #if val < 0
            #    val += 2*abs(drive_freqs[i])
            #end
            push!(vals_temp, val)
        end
        push!(quasienergies, vals_temp)
    end

    diffs1 = abs.(quasienergies[1] .- quasienergies[2])
    diffs2 = 2*abs.(drive_freqs) .- abs.(quasienergies[1] .- quasienergies[2])

    to_fit = [minimum([abs(diffs1[i]), abs(diffs2[i])]) for i in 1:length(diffs1)]

    fit_func(t, p) = p[3]*sqrt.((t.-p[1]).^2 .+ p[2].^2)
    p0 = zeros(3)
    p0[1] = starkshifts[argmin(to_fit)]
    p0[2] = minimum(to_fit)
    p0[3] = abs((maximum(to_fit)-minimum(to_fit))/(starkshifts[argmax(to_fit)]-starkshifts[argmin(to_fit)]))
    fit = LF.curve_fit(fit_func, starkshifts, to_fit, p0)
    @info "Stark Shift: "*Utils.tostr(fit.param[1])
    @info "Approximate Drive Time: "*Utils.tostr(1/(2*fit.param[2]*fit.param[3]))

    if show_plot
        f = cm.Figure(size = (800, 500), px_per_unit = 3)

        ax1 = cm.Axis(f[1,1], title = "Floquet Energies", xlabel = "Stark Shifts", ylabel = "Quasienergies (GHz)")
        ax2 = cm.Axis(f[2,1], title = "Difference", xlabel = "Stark Shifts", ylabel = "Dif (GHz)")

        colorlist = [:forestgreen, :coral]
        markers = ['+', '×']

        for i in 1:length(state_keys)
            state = state_keys[i]
            cm.scatterlines!(ax1, starkshifts, quasienergies[i], label = string(state), color = colorlist[i], marker = markers[i], linewidth = 0.5, markersize = 20)
        end
        cm.axislegend(ax1)
        x2 = collect(LinRange(starkshifts[1], starkshifts[end], 101))
        y2 = fit_func(x2, fit.param)

        fitted_shift = round(fit.param[1], sigdigits = 3)
        cm.lines!(ax2, x2, y2, color = :forestgreen, alpha = 0.25, linewidth= 8, label = "Fitted Stark Shift: $fitted_shift GHz")
        cm.scatterlines!(ax2, starkshifts, to_fit, label = "Difs", marker = '+', markersize = 20, color = :black, linewidth = 0.5)
        #cm.axislegend(ax2)
        cm.display(f)
    end
    return [fit.param[1], 1/(2*fit.param[2]*fit.param[3])]
end

function find_stark_shifts(H0, drive_op, base_freq, amplitude, starkshifts, reference_states::T1; kwargs...) where T1<:Dict
    H_func(param) = qt.QobjEvo((H0, (drive_op, (p,t) -> param[:amplitude]*sin(2*pi*param[:frequency]*t))))

    find_stark_shifts(H_func, base_freq, amplitude, starkshifts, reference_states; kwargs...)
end