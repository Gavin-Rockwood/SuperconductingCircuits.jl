# Test initialization of Fluxonium
@testset "Fluxonium.jl" begin
    EJ = 8.9
    EC = 2.5
    EL = 0.5
    flux = 0.33
    N = 10
    name = "TestFluxonium"
    fluxonium = SCC.Circuits.init_fluxonium(EC, EJ, EL, N; name=name, flux = 0.33)
    for req in SCC.Circuits.Component_Required_Objects
        @test hasfield(typeof(fluxonium), req)
    end

    to_comp = [-1.72737703,  1.343799  ,  8.49448413, 12.13437429, 13.34329487, 17.70414565]
    res = qt.eigenstates(fluxonium.H_op).values[1:length(to_comp)];
    @test all(abs.(res .- to_comp) .< 1e-8)

end