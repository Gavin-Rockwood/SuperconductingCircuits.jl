export EnsembleTimeEvolutionProblem
import QuantumToolbox: sesolve
"""
    EnsembleTimeEvolutionProblem{PT<:TimeEvolutionProblem, PF<:Function}

A structure representing an ensemble time evolution problem for quantum systems.

# Fields
- `prob::PT`: The base time evolution problem.
- `func::PF`: A function used to modify or sample parameters for each trajectory in the ensemble.
- `iterate_params::Bool`: If `true`, parameters are iterated for each trajectory; otherwise, the same parameters are used.
- `full_iterator::AbstractArray`: An array containing all parameter sets or states to be used in the ensemble.
- `n_states::Int`: The number of initial states.
- `trajectories::Int`: The total number of trajectories to simulate.

# Usage
This is used when setting up ensemble sesolve problems, useful for simulating multiple quantum states or parameter sets in parallel. 

Example:
```julia
    H = 2 * π * 0.1 * sigmax()
    ψ0 = basis(2, 0) # spin-up
    tlist = LinRange(0.0, 100.0, 100)

    ψs = [ψ0, basis(2, 1)] # spin-up and spin-down

    params = collect(Iterators.product([0,1,2,3,4,5], [0,1,2,3,4,5], [0,1,2,3,4,5]))
    res = sesolve(H, ψs, tlist; params = params, iterate_params = true, alg = Tsit5(), progress_bar=false);
```
"""
struct EnsembleTimeEvolutionProblem{PT<:qt.TimeEvolutionProblem,PF<:Function, X<:Vector{T} where T<:qt.QuantumObject{qt.Ket}, Y<:AbstractArray}
    prob::PT
    func::PF
    states::X
    params::Y
    problem_dims::Tuple
    trajectories::Int
end
function EnsembleTimeEvolutionProblem(
    prob::PT,
    states::Vector{T},
    params::AbstractArray = [[]]
    ) where {PT<:qt.TimeEvolutionProblem, T<:qt.QuantumObject{qt.Ket}}
    
    problem_dims = (length(states), length(params))

    function ensemble_func(prob, i, repeat)
        state_id = mod1(i, problem_dims[1])
        param_id = div(i - 1, problem_dims[1]) + 1
        return qt.remake(prob, u0 = states[state_id].data)#, p = params[param_id])
    end
    trajectories = prod(problem_dims)
    return EnsembleTimeEvolutionProblem(prob, ensemble_func, states, params, problem_dims, trajectories)
end


function sesolve(prob::EnsembleTimeEvolutionProblem, alg::qt.OrdinaryDiffEqAlgorithm = DE.Tsit5(); backend = DE.EnsembleThreads())
   ensemble_prob = DE.EnsembleProblem(prob.prob.prob, prob_func = prob.func)
   sols = DE.solve(ensemble_prob, alg, backend, trajectories = prob.trajectories)
   
   to_return = Array{qt.TimeEvolutionSol}(undef, prob.problem_dims)
    for i in 1:length(sols)
        ψt = map(ϕ -> qt.QuantumObject(ϕ, type = qt.Ket(), dims = prob.prob.dimensions), sols[i].u)
        sol = qt.TimeEvolutionSol(
                    prob.prob.times,
                    sols[i].t,
                    ψt,
                    qt._get_expvals(sols[i], qt.SaveFuncSESolve),
                    sols[i].retcode,
                    sols[i].alg,
                    sols[i].prob.kwargs[:abstol],
                    sols[i].prob.kwargs[:reltol],
                )
        to_return[CartesianIndices(to_return)[i]] = sol
    end
    
    return to_return
end

function sesolve(
    H::Union{qt.AbstractQuantumObject{qt.Operator},Tuple},
    ψ0s::Vector{T},
    tlist::AbstractVector;
    alg::qt.OrdinaryDiffEqAlgorithm = DE.Tsit5(),
    e_ops::Union{Nothing,AbstractVector,Tuple} = nothing,
    params = qt.NullParameters(),
    progress_bar::Union{Val,Bool} = Val(false),
    inplace::Union{Val,Bool} = Val(true),
    backend = DE.EnsembleThreads(),
    kwargs...,) where T<:qt.QuantumObject{qt.Ket}
    
    prob_init = qt.sesolveProblem(
        H,
        ψ0s[1],
        tlist;
        e_ops = e_ops,
        params = params,
        progress_bar = progress_bar,
        inplace = inplace,
        kwargs...,
        )
    
    trajectories = length(ψ0s)

    # function ensemble_func(prob, i, repeat)
    #     return remake(prob, u0 = ψ0s[i].data)
    # end

    # ensemble_prob = EnsembleTimeEvolutionProblem(prob_init, ensemble_func, ψ0s, trajectories)
    ensemble_prob = EnsembleTimeEvolutionProblem(
        prob_init,
        ψ0s,
        [params]
    )
    return sesolve(ensemble_prob, alg; backend = backend)
end