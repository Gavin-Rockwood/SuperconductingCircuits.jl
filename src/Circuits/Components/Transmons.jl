@kwdef struct Transmon <: Component
    params :: Dict
    eigenenergies :: Vector
    eigenstates :: Vector
    H_op :: qt.QuantumObject
    dim :: Int
    loss_ops :: Dict
    
    H_op_full :: qt.QuantumObject

    n_op_full :: qt.QuantumObject # Cut U(1) charge operator
    n_op :: qt.QuantumObject # Truncated n operator

end

function init_transmon(EC, EJ, N_full, N; name = "Transmon",  ng = 0, kappa_c = 1/(56*1000), kappa_d = 1.2348024316109425e-5)
    dim_full = 2*N_full+1
    I_op_full = qt.eye(dim_full)
    
    jump_op_full = qt.tunneling(dim_full, 1)

    n_op_full = qt.num(dim_full) - N_full

    H_op_full = 4*EC*(ng*I_op_full - n_op_full)^2 - 0.5*EJ*(jump_op_full)

    eigsys_full = qt.eigenstates(H_op_full)

    P = zeros(ComplexF64, dim_full, N)
    for i in 1:N
        P[:, i] = eigsys_full.vectors[:, i]
    end

    H_mat_full = H_op_full.data
    H_mat = P'*H_mat_full*P
    n_mat_full = n_op_full.data
    n_mat = P'*n_mat_full*P

    H_op = qt.Qobj(H_mat)
    
    herm_check = norm(H_op - H_op')
    if herm_check > 1e-9
        println("Herm_check for H_op Failed with value $herm_check")
    end

    H_op = 0.5*(H_op+H_op')
    
    n_op = qt.Qobj(n_mat)
    
    herm_check = norm(n_op - n_op')
    if herm_check > 1e-9
        println("Herm_check for n_op Failed with value $herm_check")
    end

    n_op = 0.5*(n_op+n_op')


    eigenenergies, eigenstates = qt.eigenstates(H_op)

    D_op = 0*H_op
    for i in 1:(N-1) # this skips the 0 state becasue the coefficient is 0
        psi_i = qt.fock(N, i)
        D_op += sqrt(2*kappa_d)*sqrt(i)*psi_i*psi_i'
    end

    C_op = 0*H_op
    for i in 1:(N-1)
        im1 = i-1
        psi_im1 = qt.fock(N, i-1)
        psi_i = qt.fock(N, i)
        C_op += sqrt(kappa_c)*sqrt(i)*psi_im1*psi_i'
    end
    
    loss_ops = Dict("Collapse" => C_op, "Dephasing" => D_op)
    params = Dict(:EC => EC, :EJ => EJ, :ng => ng, :N_full => N_full, :N => N, :name => name, :kappa_c => kappa_c, :kappa_d => kappa_d)

    return Transmon(params = params, dim = N, H_op_full = H_op_full, H_op = H_op, n_op_full = n_op_full, n_op = n_op, eigenenergies = eigenenergies, eigenstates=eigenstates, loss_ops = loss_ops)
end

function init_transmon(Params::T) where T<:Dict
    params = deepcopy(Params)
    EC = params[:EC]
    delete!(params, :EC)
    EJ = params[:EJ]
    delete!(params, :EJ)
    N_full = params[:N_full]
    delete!(params, :N_full)
    N = params[:N]
    delete!(params, :N)
    init_transmon(EC, EJ, N_full, N; params...)
end
