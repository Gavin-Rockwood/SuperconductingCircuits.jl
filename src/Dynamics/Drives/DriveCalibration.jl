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
            evo_res = qt.sesolve(2*pi*(H_op+drive.drive), psi0, 0:dt:times[j], alg = DE.Vern9(), solver_kwargs...)
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