"""
    find_resonance(H_func, freqs, reference_states::T1; show_plot=false, plot_freq_offset=0, plotxlabel="Drive Frequencies (GHz)") where T1 <: Dict

Finds the resonance frequency and approximate drive time for a driven quantum system using Floquet theory.

# Arguments
- `H_func`: A function that generates the system Hamiltonian as a function of parameters.
- `freqs`: An array of drive frequencies (in GHz) to sweep over.
- `reference_states::T1`: A dictionary mapping state labels to reference states to track during the Floquet sweep.
- `show_plot`: (optional) If `true`, displays plots of the quasienergies and their differences. Default is `false`.
- `plot_freq_offset`: (optional) Frequency offset to apply to the x-axis of the plots. Default is `0`.
- `plotxlabel`: (optional) Label for the x-axis of the plots. Default is `"Drive Frequencies (GHz)"`.

# Returns
- A two-element array:
    1. The resonance frequency (in GHz) where the minimum energy gap occurs.
    2. The approximate drive time associated with the resonance.

# Description
This function performs a sweep over the provided drive frequencies, computes the Floquet quasienergies for the specified reference states, and determines the resonance by fitting the minimum energy gap to a model function. Optionally, it can display plots of the quasienergies and their differences.
"""
function find_resonance(H_func, freqs, reference_states::T1; show_plot = false, plot_freq_offset = 0, plotxlabel = "Drive Frequencies (GHz)", propagator_kwargs = Dict{Any,Any}()) where T1 <: Dict
   sampling_points = []
   state_keys = collect(keys(reference_states))
    for freq in freqs
         push!(sampling_points, Dict(:frequency => freq))
    end 
    
    floq_sweep = floquet_sweep(H_func, sampling_points, 1.0./freqs; states_to_track = reference_states, propagator_kwargs = propagator_kwargs)
    
    quasienergies = []
    for state in state_keys
        vals_temp = []
        for i in 1:length(freqs)
            val = floq_sweep["Tracking"][State = At(string(state)), Step = At(i)]["Quasienergies"]/(2*pi)
            #if val < 0
            #    val += 2*abs(drive_freqs[i])
            #end
            push!(vals_temp, val)
        end
        push!(quasienergies, vals_temp)
    end

    diffs1 = abs.(quasienergies[1] .- quasienergies[2])
    diffs2 = 2*abs.(freqs) .- abs.(quasienergies[1] .- quasienergies[2])

    to_fit = [minimum([abs(diffs1[i]), abs(diffs2[i])]) for i in 1:length(diffs1)]

    fit_func(t, p) = p[3]*sqrt.((t.-p[1]).^2 .+ p[2].^2)
    p0 = zeros(3)
    p0[1] = freqs[argmin(to_fit)]
    p0[2] = minimum(to_fit)
    p0[3] = abs((maximum(to_fit)-minimum(to_fit))/(freqs[argmax(to_fit)]-freqs[argmin(to_fit)]))
    fit = LF.curve_fit(fit_func, freqs, to_fit, p0)
    @info "Resonance at : $(abs(fit.param[1])) GHz"
    @info "Approximate Drive Time: "*Utils.tostr(1/(2*fit.param[2]*fit.param[3]))

    if show_plot
        f = cm.Figure(size = (800, 500), px_per_unit = 3)
        ax1 = cm.Axis(f[1,1], title = "Floquet Energies", xlabel = plotxlabel, ylabel = "Quasienergies (GHz)")
        ax2 = cm.Axis(f[2,1], title = "Difference", xlabel = plotxlabel, ylabel = "Dif (GHz)")

        colorlist = [:forestgreen, :coral]
        markers = ['+', '×']

        for i in 1:length(state_keys)
            state = state_keys[i]
            cm.scatterlines!(ax1, freqs .- plot_freq_offset, quasienergies[i], label = string(state), color = colorlist[i], marker = markers[i], linewidth = 0.5, markersize = 20)
        end
        cm.axislegend(ax1)
        x2 = collect(LinRange(freqs[1], freqs[end], 101))
        y2 = fit_func(x2, fit.param)

        fitted_freq = round(fit.param[1], sigdigits = 3)
        cm.lines!(ax2, x2 .- plot_freq_offset, y2, color = :forestgreen, alpha = 0.25, linewidth= 8, label = "Fitted Frequency: $fitted_freq GHz")
        cm.scatterlines!(ax2, freqs .- plot_freq_offset, to_fit, label = "Difs", marker = '+', markersize = 20, color = :black, linewidth = 0.5)
        #cm.axislegend(ax2)
        cm.display(f)
    end
    return [fit.param[1], 1/(2*fit.param[2]*fit.param[3])]

end


function find_resonance(H0, drive_op, freqs, amplitude, reference_states::T1; kwargs...) where T1<:Dict
    H_func(param) = qt.QobjEvo((H0, (drive_op, (p,t) -> amplitude*sin(2*pi*param[:frequency]*t))))
    find_resonance(H_func, freqs, reference_states; kwargs...)
end