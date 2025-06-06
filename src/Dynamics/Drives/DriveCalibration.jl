function calibrate_drive_time!(drive_coef_param :: StaticDriveCoefParam, H_op :: qt.QuantumObject, drive_op :: qt.QuantumObject, t_range, psi0, to_min::Function; samples_per_level = 5, maxiter = 5, tol = 1e-3, solver_kwargs = Dict{Symbol, Any}())
    best_time = 0.0
    for i in 1:maxiter
        sample_mins = []
        times = collect(LinRange(t_range[1], t_range[end], samples_per_level))
        @info "Times: $times"
        for j in 1:samples_per_level
            drive_coef_param.drive_time = times[j]
            drive_param = GeneralDriveParam(op = drive_op, coef_param = drive_coef_param)
            drive = Dynamics.get_drive(drive_param)

            dt = abs(1/drive_param.coef_param.frequency)
            evo_res = qt.sesolve(2*pi*(H_op+drive.drive), psi0, 0:dt:times[j]; alg = DE.Vern9(), solver_kwargs...)
            push!(sample_mins, to_min(evo_res.states[end]))
        end
        @info "Iter $i mins: $sample_mins"
        j_best = argmin(sample_mins)
        if j_best == 1
            t_range[1] = times[1]
        elseif j_best > 1
            t_range[1] = times[j_best-1]
        end
        
        if j_best == samples_per_level
            t_range[end] = times[samples_per_level]
        elseif j_best < samples_per_level
            t_range[end] = times[j_best+1]
        end
        best_time = times[j_best]
        if sample_mins[j_best] < tol
            @info "Minimum Beats Tolerance: $sample_mins[j_best]"
            @info "Best Time: $(times[j_best])"
            @info "Returning This Time"
            drive_coef_param.drive_time = best_time
            return nothing
        end
    end
    @info "Never Beat the Tolerance"
    @info "Returning the Best Time"
    drive_coef_param.drive_time = best_time
    return nothing
end

function calibrate_drive_time!(drive_param :: GeneralDriveParam, H_op :: qt.QuantumObject, t_range, psi0, to_min::Function; kwargs...)
    calibrate_drive_time!(drive_param.coef_param, H_op, drive_param.op, t_range, psi0, to_min; kwargs...)
end


function calibrate_drive_time(drive_coef_param :: StaticDriveCoefParam, H_op :: qt.QuantumObject, drive_op :: qt.QuantumObject, t_range, psi0, to_min::Function; samples_per_level = 5, maxiter = 5, tol = 1e-3, solver_kwargs = Dict{Symbol, Any}(), return_drive = true, include_H = true)
    drive_coef_param = deepcopy(drive_coef_param)
    calibrate_drive_time!(drive_coef_param, H_op, drive_op, t_range, psi0, to_min; samples_per_level = samples_per_level, maxiter = maxiter, tol = tol, solver_kwargs = solver_kwargs)
    if return_drive
        drive_param = GeneralDriveParam(op = drive_op, coef_param = drive_coef_param) 
        if include_H
            drive = Dynamics.get_drive(drive_param, H_op = H_op)
        else
            drive = Dynamics.get_drive(drive_param)
        end
        return drive
    else
        return drive_coef_param
    end
end

function calibrate_drive_time(drive_param :: GeneralDriveParam, H_op :: qt.QuantumObject, t_range, psi0, to_min::Function; kwargs...)
    drive_param = deepcopy(drive_param)
    calibrate_drive_time(drive_param.coef_param, H_op, drive_param.op, t_range, psi0, to_min; kwargs...)
end


function calibrate_drive(drive_op :: qt.QobjEvo, t_range0, psi0, to_min :: Function; samples_per_level = 5, maxiters = 7, tol = 1e-3, approx_tol = 1e-8, solver_kwargs = Dict{Symbol, Any}(), return_drive = true, include_H = true, dt = 1e-2)
    best_time = 0.0
    t_range = [float(t_range0[1]), float(t_range0[end])]
    previous_times = []
    previous_mins = []
    best_fid = 0.0
    for i in 1:maxiters
        sample_mins = []
        times = collect(LinRange(t_range[1], t_range[end], samples_per_level))
        @info "Times: $times"
        for j in 1:samples_per_level
            if times[j] in previous_times
                loc = findall(x-> isapprox(x, times[j], atol=approx_tol), previous_times)[1]
                push!(sample_mins, previous_mins[loc])
            else
                drive_time = times[j]
                evo_res = qt.sesolve(2*pi*drive_op, psi0, 0:dt:times[j]; alg = DE.Vern9(), params = [drive_time], solver_kwargs...)
                push!(sample_mins, to_min(evo_res.states[end]))
            end
        end
        @info "Iter $i mins: $sample_mins"
        j_best = argmin(sample_mins)
        if j_best == 1
            t_range[1] = times[1]
        elseif j_best > 1
            t_range[1] = times[j_best-1]
        end
        
        if j_best == samples_per_level
            t_range[end] = times[samples_per_level]
        elseif j_best < samples_per_level
            t_range[end] = times[j_best+1]
        end
        best_time = times[j_best]
        best_fid = sample_mins[j_best]
        if sample_mins[j_best] < tol
            @info "Minimum Beats Tolerance: $(sample_mins[j_best])"
            @info "Best Time: $(times[j_best])"
            @info "Returning This Time"
            return [best_time, best_fid]
        end
        previous_times = times
        previous_mins = sample_mins
    end
    @info "Never Beat the Tolerance"
    @info "Returning the Best Time"
    return [best_time, best_fid]
end


function get_FLZ_flattop(H_op, drive_op, freq, epsilon, envelope_func :: Function, ramp_time, psi0, psi1; dt = 0, theta_guess = [0.0, 0.0], number_eps_samples = 10)
    if dt == 0
        dt = 1/freq
    end

    times_to_sample = sort(unique(vcat(collect(0:dt:ramp_time), ramp_time)))
    epsilons_to_sample = [[epsilon*envelope_func(t)] for t in times_to_sample]

    H_func(param) = H_op+qt.QobjEvo((drive_op, (p,t) -> param[1]*sin(2π*freq*t)))

    states_to_track = Dict{Any, Any}("psi0" => psi0, "psi1" => psi1)
    floq_sweep_res = floquet_sweep(H_func, epsilons_to_sample, 1/freq; states_to_track = states_to_track, sampling_times = times_to_sample)
    floq_frequency =  floq_sweep_res["Tracking"][State = At("psi0"), Step = At(length(epsilons_to_sample))]["Quasienergies"]/pi-floq_sweep_res["Tracking"][State = At("psi1"), Step = At(length(epsilons_to_sample))]["Quasienergies"]/pi

    ψ0_floq = floq_sweep_res["Tracking"][State = At("psi0"), Step = At(length(epsilons_to_sample))]["psi"]
    ψ1_floq = floq_sweep_res["Tracking"][State = At("psi1"), Step = At(length(epsilons_to_sample))]["psi"]

    H_drive = H_op + qt.QobjEvo((drive_op, (p,t) -> epsilon*envelope_func(t)*sin(2π*freq*t)))

    drive_res_0 = qt.sesolve(2pi*H_drive, psi0, times_to_sample; alg = DE.Vern9())
    psi0_final = drive_res_0.states[end]
    to_minimize0(θ) = 1-abs(psi0_final' * (ψ0_floq + ℯ^(1im*θ[1])*ψ1_floq))^2/2
    θ = Optim.optimize(to_minimize0, [theta_guess[1]]).minimizer[1]

    # drive_res_1 = qt.sesolve(2pi*H_drive, psi1, times_to_sample; alg = DE.Vern9())
    # psi1_final = drive_res_1.states[end]
    # to_minimize1(θ) = 1-abs(psi1_final' * (ψ0_floq - ℯ^(1im*θ[1])*ψ1_floq))^2/2
    # θ1 = Optim.optimize(to_minimize1, [theta_guess[2]]).minimizer[1]
    
    θr = mod2pi(π - 2*θ)#(θ0+θ1))
    println("floq_frequency: $floq_frequency")
    println("θ: $θ, θr: $θr")
    return abs(θr/(π*floq_frequency))
end