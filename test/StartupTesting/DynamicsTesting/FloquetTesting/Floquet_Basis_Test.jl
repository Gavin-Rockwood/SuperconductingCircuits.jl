@testset "Testing 'get_floquet_basis'" begin
    qubit = SCC.Circuits.init_qubit(1)

    H_D = qt.sigmax()
    coef(p, t) = sin(2*pi*qubit.freq*t)

    Ht = qt.QobjEvo((qubit.H_op, (H_D, coef)))
    T = 1/qubit.freq

    floq_res = SCC.Dynamics.get_floquet_basis(Ht, T)
    @test true
end