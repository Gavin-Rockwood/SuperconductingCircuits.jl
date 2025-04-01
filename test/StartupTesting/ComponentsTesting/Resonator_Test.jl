# Test Initialization of Resonator
@testset "Resonator_Test.jl" begin
    Eosc = 5.0
    name = "TestResonator"
    N = 10
    resonator = SCC.Circuits.init_Resonator(Eosc, N, name=name)
    for req in SCC.Circuits.Component_Required_Objects
        @test hasfield(typeof(resonator), req)
    end

end