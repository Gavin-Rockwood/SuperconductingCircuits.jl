import DifferentialEquations as DE

"""
    Propagator

A structure representing a quantum propagator for time evolution.

# Fields
- `H::Union{qt.QobjEvo, qt.QuantumObject}`: The Hamiltonian or time-dependent operator governing the system's dynamics. This can be a `qt.QobjEvo` for time-dependent Hamiltonians or a `qt.QuantumObject` for time-independent cases.
- `eval::Function`: A function that computes the propagator or evolves the quantum state, typically as a function of time and initial state.
"""
@kwdef struct Propagator
    H :: Union{qt.QobjEvo, qt.QuantumObject}
    eval :: Function
end


"""
    propagator(H::Union{qt.QobjEvo, qt.QuantumObject}, tf; ti = 0, solver = DE.Vern9(), solver_kwargs = Dict{Any, Any}())

Compute the time-evolution operator (propagator) for a given time-dependent or time-independent Hamiltonian `H` from initial time `ti` to final time `tf`.

# Arguments
- `H::Union{qt.QobjEvo, qt.QuantumObject}`: The Hamiltonian, either as a time-dependent (`qt.QobjEvo`) or time-independent (`qt.QuantumObject`) quantum object.
- `tf`: The final time for propagation.
- `ti`: (optional) The initial time. Defaults to `0`.
- `solver`: (optional) The ODE solver to use from DifferentialEquations.jl. Defaults to `DE.Vern9()`.
- `solver_kwargs`: (optional) Additional keyword arguments to pass to the ODE solver.

# Returns
- `qt.Qobj`: The propagator (time-evolution operator) as a quantum object, mapping the system from time `ti` to `tf`.

# Notes
- The function internally constructs the ODE for the propagator in the Schrödinger picture and solves it using the specified solver.
- If the Hamiltonian is sparse, the propagator is returned as a sparse matrix.
"""
function propagator(H::Union{qt.QobjEvo, qt.QuantumObject}, tf; ti = 0, solver = DE.Vern9(), solver_kwargs = Dict{Any, Any}())
    H = qt.QobjEvo(H)

    function func(u, p, t)
        return -2*pi*1im*(H(t).data)*u
    end
    
    u0 = Matrix(qt.to_dense(qt.qeye(size(H)[1])))
    if typeof(H(0).data)<:qt.SparseMatrixCSC
        u0 = qt.to_sparse(u0)
    end
    

    tspan = (ti, tf)
    prob = DE.ODEProblem(func, u0.data, tspan)
    sol = DE.solve(prob, solver; solver_kwargs...)
    
    return qt.Qobj(sol.u[end], dims = H.dims)
end

"""
    get_propagator(H::Union{qt.QobjEvo, qt.QuantumObject})

Constructs a `Propagator` object for the given Hamiltonian `H`, which can be either a `qt.QobjEvo` or a `qt.QuantumObject`. 

The returned `Propagator` provides a function interface to compute the time-evolution operator for `H` over a specified time interval. The function accepts the final time `tf`, an optional initial time `ti` (default is 0), and an optional dictionary of solver keyword arguments `solver_kwargs`.

# Arguments
- `H::Union{qt.QobjEvo, qt.QuantumObject}`: The Hamiltonian for which the propagator is constructed.

# Returns
- `Propagator`: An object that can be called to compute the propagator for the specified time interval and solver options.
"""
function get_propagator(H :: Union{qt.QobjEvo, qt.QuantumObject})
    return Propagator(H, (tf, ti=0, solver_kwargs=Dict{Symbol, Any}())-> propagator(H, tf; ti=ti, solver_kwargs...))
end