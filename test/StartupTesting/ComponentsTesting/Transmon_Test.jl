# Test initialization of Transmon
@testset "Transmon.jl" begin
    EC = 0.2
    EJ = 1.0
    n_full = 60
    ng = 0.0
    N = 10
    name = "TestTransmon"
    transmon = SCC.Circuits.init_transmon(EC, EJ, N, name=name, ng = ng, n_full=n_full)
    for req in SCC.Circuits.Component_Required_Objects
        @test hasfield(typeof(transmon), req)
    end
    to_comp = [-0.43061567,  0.69849487,  1.12260822,  3.23896747,  3.24546324, 7.21788738]
    res = qt.eigenstates(transmon.H_op).values[1:length(to_comp)];

    @test all(abs.(res .- to_comp) .< 1e-8)

end