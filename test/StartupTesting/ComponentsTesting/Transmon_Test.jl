# Test initialization of Transmon
@testset "Transmon.jl" begin
    EC = 0.2
    EJ = 1.0
    N_full = 60
    ng = 0.0
    N = 5
    name = "TestTransmon"
    transmon = SCC.Circuits.init_Transmon(EC, EJ, N_full, N, name=name, ng = ng)
    for req in SCC.Circuits.Component_Required_Objects
        @test hasfield(typeof(transmon), req)
    end

end