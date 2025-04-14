export Resonator, init
@kwdef struct Resonator <: Component
    dim :: Int
    params :: Dict
    H_op :: qt.QuantumObject
    eigenstates :: Vector
    eigenenergies :: Vector
    loss_ops :: Dict

    a_op :: qt.QuantumObject
    N_op :: qt.QuantumObject

    

end

function init_resonator(Eosc, N; name = "Resonator", kappa_c = 1/(1000*1000), kappa_d =  0)

    a_op = qt.destroy(N)
    N_op = a_op'*a_op
    H_op = Eosc*N_op

    eigenenergies, eigenstates = qt.eigenstates(H_op)

    # Cavity Collapse
    C_op = 0*H_op
    for i in 1:(N-1)
        im1 = i-1
        psi_i = qt.fock(N, i)
        psi_im1 = qt.fock(N, im1)
        C_op += sqrt(kappa_c)*sqrt(i)*psi_im1*psi_i'
    end

    D_op = 0*H_op
    for i in 1:(N-1) # this skips the 0 state becasue the coefficient is 0
        psi_i = qt.fock(N, i)
        D_op += sqrt(2*kappa_d)*sqrt(i)*psi_i*psi_i'
    end

    loss_ops = Dict("Collapse" => C_op, "Dephasing" => D_op)

    params = Dict(:Eosc => Eosc, :N => N, :kappa_c => kappa_c, :kappa_d => kappa_d, :name => name)
    return Resonator(params = params, dim = N, H_op = H_op, N_op = N_op, eigenenergies = eigenenergies, eigenstates=eigenstates, a_op = a_op, loss_ops = loss_ops)
end

function init_resonator(Params::T) where T<:Dict
    params = deepcopy(Params)
    Eosc = params[:Eosc]
    delete!(params, :Eosc)
    N = params[:N]
    delete!(params, :N)
    init_resonator(Eosc, N; params...)
end
