import QuantumToolbox as qt
using LinearAlgebra
#using ProtoStructs
using ..Utils
#export Transmon, Init_Transmon

@kwdef struct SNAIL <: Component
    params :: Dict
    H_op :: qt.QuantumObject
    eigenenergies :: Vector
    eigenstates :: Vector
    dim :: Int
    loss_ops :: Dict
    
    
    H_op_full :: qt.QuantumObject
    

    n_op_full :: qt.QuantumObject # dim for truncated U(1) charge operator
    n_op :: qt.QuantumObject # Truncated n operator

    phi_op_full :: qt.QuantumObject
    phi_op :: qt.QuantumObject
    
end

module SNAIL_TOOLS
    using Symbolics
    import NonlinearSolve as NLS
    function c(n)
        @variables φ α N Φᵉ

        U = -α*cos(φ) - N * cos((φ - Φᵉ)/N)

        D = Differential(φ)^n

        return expand_derivatives(D(U))
    end

    function get_c_coeffs_bare(N_val, α_val, Φᵉ_val)
        @variables φ N α Φᵉ

        c_syms = []
        for n in 1:6
            c_sym = c(n)
            push!(c_syms, c_sym)
        end

        f_to_min(φ_val, p) = [Symbolics.value(substitute(c_syms[1], Dict(φ=>φ_val[1], N=>N_val, α => α_val, Φᵉ => Φᵉ_val)))]

        prob = NLS.NonlinearProblem(f_to_min, [0.0], [])
        φ_min = NLS.solve(prob)[1]
        @debug "φ_min: $φ_min"


        cs = [0.0]
        
        for n in 2:6
            push!(cs, Symbolics.value(substitute(c_syms[n], Dict(φ=>φ_min, N=>N_val, α=>α_val, Φᵉ=>Φᵉ_val))))
        end

        return cs
    end

    function get_c_coeffs_dressed(N, α, Φᵉ, Eʲ, Eˡ)
        cs = get_c_coeffs_bare(N, α, 2*π*Φᵉ)
        @debug "bare cs: $cs"
        p = Eˡ/(Eˡ+cs[2]*Eʲ)

        c2_dr = p*cs[2]
        c3_dr = cs[3]
        c4_dr = cs[4]-3*cs[3]^2/cs[2]*(1-p)/p
        c5_dr = cs[5]-10*cs[3]*cs[4]/cs[2]*(1-p)/p+15*cs[3]^3/cs[2]^2*(1-p)^2/p^2
        c6_dr = cs[6] - (10*cs[4]^2+15*cs[5]*cs[3])/(cs[2]*p)*(1-p) + (105*cs[4]*cs[3]^2)/(cs[2]*p)^2*(1-p)^2-(105*cs[3]^4)/(cs[2]*p)^3*(1-p)^3

        return [0, c2_dr, c3_dr, c4_dr, c5_dr, c6_dr]
    end
end

function init_snail(EC, EJ, EL, alpha, Phi_e,  dim_full, N; name = "SNAIL", N_Junc = 3)
    cs = SNAIL_TOOLS.get_c_coeffs_dressed(N_Junc, alpha, Phi_e, EJ, EL)
    @debug "dressed cs: $cs"
    
    nu = sqrt(8*cs[2]*EC*EJ)
    phi_zpf = (2*EC/EJ/cs[2])^(1/4)
    @debug "phi_zpf: $phi_zpf"
    n_zpf = 1/2/phi_zpf
    @debug "n_zpf: $n_zpf"

    a_op_full = qt.destroy(dim_full)
    n_op_full = 1im*(a_op_full'-a_op_full)
    phi_op_full = phi_zpf * (a_op_full'+a_op_full)

    herm_check = norm(phi_op_full-phi_op_full')
    
    if herm_check > 1e-9
        println("Herm_check for φ̂_full: $herm_check")
    end
    H_op_full = nu*a_op_full'*a_op_full

    den = 2
    for n in 3:6
        den *= n
        H_op_full+=EJ*cs[n]/den*(phi_op_full^n)
    end

    eigsys_full = qt.eigenstates(H_op_full)
    
    P = zeros(ComplexF64, dim_full, N)

    for i in 1:N
        P[:, i] = eigsys_full.vectors[:,i]
    end

    H_mat_full = H_op_full.data
    H_mat = P'*H_mat_full*P
    n_mat_full = n_op_full.data
    n_mat= P'*n_mat_full*P
    phi_mat_full = phi_op_full.data
    phi_mat = P'*phi_mat_full*P

    H_op = qt.Qobj(H_mat)
    herm_check = norm(H_op - H_op')
    if herm_check > 1e-9
        println("Herm_check for H_op Failed with value $herm_check")
    end
    H_op =  0.5*(H_op+H_op')

    n_op =  qt.Qobj(n_mat)
    herm_check = norm(n_op-n_op')
    if herm_check > 1e-9
        println("Herm_check for n_op Failed with value $herm_check")
    end
    n_op = 0.5*(n_op+n_op')



    phi_op =  qt.Qobj(phi_mat)
    herm_check = norm(phi_op - phi_op')
    if herm_check > 1e-9
        println("Herm_check for phi_op Failed with value $herm_check")
    end
    phi_op = 0.5*(phi_op+phi_op')

    eigenenergies, eigenstates = qt.eigenstates(H_op)
    params = Dict(:EC => EC, :EJ => EJ, :EL => EL, :alpha => alpha, :Phi_e => Phi_e, :dim_full => dim_full, :N => N, :name => name, :N_Junc => N_Junc)

    return SNAIL(params = params, dim = N, H_op_full = H_op_full, H_op = H_op, n_op_full = n_op_full, n_op = n_op, phi_op_full = phi_op_full, phi_op = phi_op, eigenstates = eigenstates, eigenenergies=eigenenergies, loss_ops = Dict{Any, Any}())
    

end

function init_snail(Params::T) where T<:Dict
    params = deepcopy(Params)
    EC = params[:EC]
    delete!(params, :EC)
    EJ = params[:EJ]
    delete!(params, :EJ)
    EL = params[:EL]
    delete!(params, :EL)
    alpha = params[:alpha]
    delete!(params, :alpha)
    Phi_e = params[:Phi_e]
    delete!(params, :Phi_e)
    dim_full = params[:dim_full]
    delete!(params, :dim_full)
    N = params[:N]
    delete!(params, :N)
    init_snail(EC, EJ, EL, alpha, Phi_e, dim_full, N; params...)
end