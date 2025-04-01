@testset "Testing Floquet_t0" begin
    @testset "Testing 'Get_Floquet_t0_Eigsys'" begin
        qubit = SCC.Circuits.init_Qubit(1)

        H_D = qt.sigmax()
        coef(p, t) = cos(2*pi*qubit.freq*t)

        Ht = qt.QobjEvo((qubit.H_op, (H_D, coef)))
        T = 1/qubit.freq

        floq_res = SCC.Dynamics.Get_Floquet_t0_Eigsys(Ht, T)
        @test true
    end

    @testset "Testing 'FLoquet_t0_Sweep'" begin
        omega = 1.0*2*pi
        Delta = 0.2#*2*pi
        epsilon = 0.0*2*pi
        H0 = Delta/2 * qt.sigmax() - epsilon/2 * qt.sigmaz()

        eigvals, eigstates, U = qt.eigenstates(H0)
        states_to_track = Dict{Any, Any}()
        for i in 1:length(eigstates)
            states_to_track[i] = eigstates[i]
        end

        function H_func(A)
            H_D = qt.sigmaz()
            coef(p, t) = A/2.0*sin(omega*t)
            
            return qt.QobjEvo((H0, (H_D, coef)))
        end

        As = collect(range(0.0, 10.0, length = 100))#.*omega
        Ts = 2*pi./omega

        sweep_res = SCC.Dynamics.Floquet_t0_Sweep(H_func, As, Ts, states_to_track = states_to_track)
        @test true
        
        vals = []
        for state in [1,2]
            vals_temp = []
            for i in 1:length(As)
                push!(vals_temp, sweep_res["Tracking"][State = At(string(state)), Step = At(i)]["Quasienergies"])
            end
            push!(vals, vals_temp)
        end
        #println(vals[1])
        #println(As./omega)
        x = As#./omega
        divfac = 2*pi*Delta
        lim = ceil(maximum(abs.(vcat(vals...)./divfac)), sigdigits = 1)
        fig = up.Plot(; ylim=(-lim,lim), xlim=(x[1], x[end]))
        up.lineplot!(fig, x, vals[1]./divfac, name = "Floquet 1")
        up.lineplot!(fig, x, vals[2]./divfac, name = "Floquet 2")
        up.xlabel!(fig, "A/ω drive")
        up.ylabel!(fig, "Quasienergy/(2πΔ)")
        display(fig)

    end

end