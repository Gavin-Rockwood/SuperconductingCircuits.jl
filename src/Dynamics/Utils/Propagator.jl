import DifferentialEquations as DE
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