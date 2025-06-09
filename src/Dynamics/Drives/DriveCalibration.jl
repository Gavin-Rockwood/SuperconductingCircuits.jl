"""
    calibrate_drive(drive_op::qt.QobjEvo, t_range0, psi0, to_min::Function; samples_per_level=5, maxiters=7, tol=1e-3, approx_tol=1e-8, solver_kwargs=Dict{Symbol, Any}(), return_drive=true, include_H=true, dt=1e-2)

Calibrates the duration of a quantum drive by minimizing a user-specified cost function over a given time range.

# Arguments
- `drive_op::qt.QobjEvo`: The time-dependent drive operator (Hamiltonian) to be calibrated.
- `t_range0`: Initial time range (tuple or array) over which to search for the optimal drive duration.
- `psi0`: Initial quantum state for the evolution.
- `to_min::Function`: A function that takes the final state and returns a scalar value to be minimized (e.g., infidelity).
- `samples_per_level`: Number of time samples to evaluate per iteration (default: 5).
- `maxiters`: Maximum number of iterations for the calibration loop (default: 7).
- `tol`: Tolerance for the minimum value of the cost function to consider the calibration successful (default: 1e-3).
- `approx_tol`: Tolerance for considering two time points as approximately equal (default: 1e-8).
- `solver_kwargs`: Additional keyword arguments to pass to the ODE solver (default: empty dictionary).
- `return_drive`: If `true`, returns the calibrated drive (currently unused, default: true).
- `include_H`: If `true`, includes the Hamiltonian in the evolution (currently unused, default: true).
- `dt`: Time step for the evolution solver (default: 1e-2).

# Returns
- A two-element array `[best_time, best_fid]` where:
    - `best_time`: The optimal drive duration found.
    - `best_fid`: The minimum value of the cost function achieved.

# Description
This function iteratively samples the cost function over a shrinking time interval, searching for the drive duration that minimizes the user-provided `to_min` function. The search continues until the minimum value falls below the specified tolerance or the maximum number of iterations is reached.
"""
function calibrate_drive(drive_op :: qt.QobjEvo, t_range0, psi0, to_min :: Function; samples_per_level = 5, maxiters = 7, tol = 1e-3, approx_tol = 1e-8, solver_kwargs = Dict{Symbol, Any}(), include_H = true, dt = 1e-2)
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


"""
    get_FLZ_flattop(
        H_op, drive_op, freq, epsilon, envelope_func, ramp_time, psi0, psi1;
        dt=0, n_theta_samples=100, number_eps_samples=10
    )

Determine the optimal flat-top duration for a Floquet-Landau-Zener (FLZ) protocol in a driven quantum system.

# Arguments
- `H_op`: Static system Hamiltonian.
- `drive_op`: Operator representing the drive interaction.
- `freq`: Drive frequency (Hz).
- `epsilon`: Drive amplitude.
- `envelope_func::Function`: Time-dependent envelope function for the drive pulse.
- `ramp_time`: Duration of the ramp segment (same time units as used elsewhere).
- `psi0`: Initial quantum state (e.g., ground state).
- `psi1`: Target quantum state (e.g., excited state).

# Keyword Arguments
- `dt`: Time step for numerical evolution. Defaults to `1/freq` if set to 0.
- `n_theta_samples`: Number of phase grid points for optimization (default: 100).
- `num_t_samples`: Number of time samples to evaluate the floquet modes (default: 10).
- `epsilons_to_sample`: Optional array of epsilon values to sample at each time step. If not provided, it is computed based on the envelope function.

# Returns
- The calibrated flat-top duration (same units as `ramp_time`) that aligns the system's evolution with the desired Floquet phase, facilitating high-fidelity state transfer.

# Details
This function simulates the system's evolution under a driven protocol, performing a Floquet analysis to optimize the phase accumulation. It searches for the flat-top time that best matches the target state, using grid search over phase and amplitude parameters. Diagnostic information about the Floquet frequency and phase is printed during execution.
"""
function get_FLZ_flattop(H_op, drive_op, freq, epsilon, envelope_func :: Function, ramp_time, psi0, psi1; num_t_samples = 10, epsilons_to_sample = [], n_theta_samples = 100, dt = 0)
    if dt == 0
        dt = 1/freq
    end
    times_to_sample = collect(LinRange(0, ramp_time, num_t_samples))
    if !(length(epsilons_to_sample) == length(times_to_sample))
        epsilons_to_sample = [[epsilon*envelope_func(t)] for t in times_to_sample]
        #println("epsilons_to_sample: $epsilons_to_sample")
    end

    H_func(param) = H_op+qt.QobjEvo((drive_op, (p,t) -> param[1]*sin(2π*freq*t)))

    states_to_track = Dict{Any, Any}("psi0" => psi0, "psi1" => psi1)
    floq_sweep_res = floquet_sweep(H_func, epsilons_to_sample, 1/freq; states_to_track = states_to_track, sampling_times = times_to_sample)
    floq_frequency =  floq_sweep_res["Tracking"][State = At("psi0"), Step = At(length(epsilons_to_sample))]["Quasienergies"]/(2pi)-floq_sweep_res["Tracking"][State = At("psi1"), Step = At(length(epsilons_to_sample))]["Quasienergies"]/(2pi)

    ψ0_floq = floq_sweep_res["Tracking"][State = At("psi0"), Step = At(length(epsilons_to_sample))]["psi"]
    ψ1_floq = floq_sweep_res["Tracking"][State = At("psi1"), Step = At(length(epsilons_to_sample))]["psi"]

    H_drive = H_op + qt.QobjEvo((drive_op, (p,t) -> epsilon*envelope_func(t)*sin(2π*freq*t)))

    drive_res_0 = qt.sesolve(2pi*H_drive, psi0, times_to_sample[1]:dt:times_to_sample[end]; alg = DE.Vern9())
    psi0_final = drive_res_0.states[end]
    to_minimize(θ) = 1-abs(psi0_final' * (ψ0_floq + ℯ^(1im*θ[1])*ψ1_floq))^2/2
    thetas = [[x] for x in LinRange(0,2π, n_theta_samples)]
    theta_guess = thetas[argmin(to_minimize.(thetas))[1]]
    println(theta_guess)
    θ = Optim.optimize(to_minimize, theta_guess).minimizer[1]

    # drive_res_1 = qt.sesolve(2pi*H_drive, psi1, times_to_sample; alg = DE.Vern9())
    # psi1_final = drive_res_1.states[end]
    # to_minimize1(θ) = 1-abs(psi1_final' * (ψ0_floq - ℯ^(1im*θ[1])*ψ1_floq))^2/2
    # θ1 = Optim.optimize(to_minimize1, [theta_guess[2]]).minimizer[1]
    
    θr = mod2pi(π - 2*θ)#(θ0+θ1))
    println("floq_frequency: $floq_frequency")
    println("θ: $θ, θr: $θr")
    return abs(θr/(2π*floq_frequency))
end