# Test initialization of Qubit
@testset "Qubit.jl" begin
    freq = 5.0
    name = "TestQubit"
    qubit = SCC.Circuits.init_Qubit(freq, name=name)
    for req in SCC.Circuits.Component_Required_Objects
        @test hasfield(typeof(qubit), req)
    end
    
end


# omega = 5.0
# name = "TestQubit"
# qubit = SCC.Hilbertspaces.init_Qubit(omega, name=name)

# println("Made Qubit!")
