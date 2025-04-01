@testset "Initialize Transmon" begin
    transmon_params = Dict{Symbol, Any}()
    transmon_params[:name] = "transmon"
    transmon_params[:EJ] = 26.96976142643705
    transmon_params[:EC] = 0.10283303447280807
    transmon_params[:N] = 10
    transmon_params[:N_full] = 60

    transmon = SCC.Circuits.init_Components["Transmon"](transmon_params)

    resonator_params = Dict{Symbol, Any}()
    resonator_params[:name] = "resonator"
    resonator_params[:Eosc] = 6.228083962082612
    resonator_params[:N] = 10

    resonator = SCC.Circuits.init_Components["Resonator"](resonator_params)

    interactions = [[0.026877206812551357, ":n_op", "1im*(:a_op-:a_op')"]]
    circuit = 0
    circuit = SCC.Circuits.init_Circuit([transmon, resonator], interactions)
    @test typeof(circuit) <: SCC.Circuits.Circuit

end