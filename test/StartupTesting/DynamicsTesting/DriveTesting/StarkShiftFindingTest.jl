@testset "Finding Stark Shifts" begin
    transmon_params = Dict{Symbol, Any}()
    transmon_params[:name] = "transmon"
    transmon_params[:EJ] = 26.96976142643705
    transmon_params[:EC] = 0.10283303447280807
    transmon_params[:N] = 10
    transmon_params[:n_full] = 60

    transmon = SCC.Circuits.init_components["transmon"](;transmon_params...)

    resonator_params = Dict{Symbol, Any}()
    resonator_params[:name] = "resonator"
    resonator_params[:Eosc] = 6.228083962082612
    resonator_params[:N] = 10

    resonator = SCC.Circuits.init_components["resonator"](;resonator_params...)

    interactions = [[0.026877206812551357, ":n_op", "1im*(:a_op-:a_op')"]]
    circuit = 0
    operators_to_add = Dict{String, Any}("nt" => [":n_op", ""], "a" => ["",":a_op"])
    circuit = SCC.Circuits.init_circuit([transmon, resonator], interactions, use_sparse = true, operators_to_add = operators_to_add)
    
    H0 = circuit.H_op
    drive_op = circuit.ops["nt"]
    amplitude = 0.73
    base_freq = circuit.dressed_energies[(0,1)] - circuit.dressed_energies[(2,0)]
    reference_states = Dict{Any, Any}((0,1) => circuit.dressed_states[(0,1)], (2,0) => circuit.dressed_states[(2,0)])
    stark_shifts = LinRange(0.02, 0.05, 11)

    stark_shift_res = SCC.Dynamics.find_resonance(H0, drive_op, base_freq .+ stark_shifts, amplitude, reference_states)

    println("Stark Shift Results: ", stark_shift_res)
    @test true

end