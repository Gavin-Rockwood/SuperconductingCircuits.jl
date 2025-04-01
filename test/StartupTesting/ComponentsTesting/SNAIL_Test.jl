# Test initialization of SNAIL
@testset "SNAIL.jl" begin
    EJ = 90
    EC = 0.177
    EL = 64
    alpha = 0.147
    Phi_e = 0.35
    dim_full = 120
    N = 6

    snail = SCC.Circuits.init_SNAIL(EC, EJ, EL, alpha, Phi_e, dim_full, N, name="TestSNAIL")
    for req in SCC.Circuits.Component_Required_Objects
        @test hasfield(typeof(snail), req)
    end



end

