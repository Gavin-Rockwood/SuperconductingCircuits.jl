@testset "Initialize Transmon + Resonator" begin
    transmon_params = Dict{Symbol, Any}()
    transmon_params[:name] = "transmon"
    transmon_params[:EJ] = 26.96976142643705
    transmon_params[:EC] = 0.10283303447280807
    transmon_params[:N] = 10
    transmon_params[:n_full] = 60

    transmon = SCC.Circuits.init_components["transmon"](; transmon_params...)

    resonator_params = Dict{Symbol, Any}()
    resonator_params[:name] = "resonator"
    resonator_params[:Eosc] = 6.228083962082612
    resonator_params[:N] = 10

    resonator = SCC.Circuits.init_components["resonator"](; resonator_params...)

    interactions = [[0.026877206812551357, ":n_op", "1im*(:a_op-:a_op')"]]
    circuit = 0
    circuit = SCC.Circuits.init_circuit([transmon, resonator], interactions)
    @test typeof(circuit) <: SCC.Circuits.Circuit

    a = qt.eigenstates(circuit.H_op).values[1:6];
    b = [-24.64078957, -20.03711976, -18.4116475 , -15.54168515, -13.80818353, -12.18250554];

    @test all((abs.(b-a) .< 1e-8))

end