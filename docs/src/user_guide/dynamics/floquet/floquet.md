```@meta
EditURL = "floquet.jl"
```

# Building a Circuit

````julia
using SuperconductingCircuits;
using QuantumToolbox
````

## Overview of Floquet
We begin with an abstract time dependent Hamiltonian $H(t)$ that is periodic with a period $T$, such that $H(t) = H(t+T)$. For such a Hamiltonian, there exists a set of solutions
$$
    \ket{\Psi_\alpha(t)} = e^{-i\varepsilon_\alpha t/\hbar}\ket{\Phi_\alpha(t)}
$$
where $\ket{\Psi_\alpha(t)}$ are the Floquet states, $\ket{\Phi_\alpha(t)}$ are the $T$ periodic Floquet modes and $\varepsilon_\alpha$ are the Floquet quasienergies. This is known as the Floquet theorem and the quasienergies are defined modulo $2\pi\hbar/T$. We can solve for the quasienergies and the Floquet modes by looking at the time evolution operator $U(t,t_0) = \mathcal{T}\exp\left[-i\int_{t_0}^t H(t')dt'\right]$ where $\mathcal{T}$ is the time ordering operator. The Floquet modes are defined as
$$
    \ket{\Phi_\alpha(t)} = U(t,0)\ket{\Phi^0_\alpha}
$$
where $\ket{\Phi_\alpha^0}$ are the eigenstates of $U(T,0)$ and the quasienergies are the corresponding eigenvalues.

To see how this physics is implemented, we begin with a driven qubit

````julia
qubit = init_qubit(5.0, name="Qubit");
ν = 5.0
H_D = qubit.H_op + QobjEvo((sigmax(), (p,t) -> sin(2π * ν * t)));
````

We then use `get_floquet_basis` to compute the Floquet basis for this Hamiltonian. The period of the drive is set to $T = 1/ν$.

````julia
F_b = get_floquet_basis(H_D, 1/ν);
````

The floquet basis is a `floquet_basis` object that contains the Floquet quasienergies and a function to compute the Floquet modes at any time. We can access the quasienergies and modes as follows:

````julia
F_b.e_quasi
````

````
2-element Vector{Float64}:
  12.57032556233629
 -12.57032556233629
````

The floquet at a time $t$ can be obtained by calling the `modes` function on the `floquet_basis` object:

````julia
F_b.modes(1.0)
````

````
2-element Vector{QuantumToolbox.QuantumObject{QuantumToolbox.Ket, QuantumToolbox.Dimensions{1, Tuple{QuantumToolbox.Space}}, Vector{ComplexF64}}}:
 
Quantum Object:   type=Ket()   dims=[2]   size=(2,)
2-element Vector{ComplexF64}:
 -0.3827312305043718 + 0.5276598144270003im
 -0.6138688076975416 - 0.4452603458229931im
 
Quantum Object:   type=Ket()   dims=[2]   size=(2,)
2-element Vector{ComplexF64}:
 -0.6138688076975415 + 0.44526034582299306im
  0.3827312305043721 + 0.5276598144270003im
````

The period for the Floquet basis is stored in the `T` field of the `floquet_basis` object:

````julia
F_b.T
````

````
0.2
````

## Sweeping Floquet Parameters.
The floquet spectrum can be computed for a family of Hamiltonians by sweeping over a parameter of interest. In the example we will well be working
out we will be sweeping over the drive frequency of a qubit drive to identify a resonance.

The first step is to define a function that returns the Hamiltonian for a given drive frequency and a range of drive frequencies.

````julia
function H_func(ν)
    return qubit.H_op + QobjEvo((sigmax(), (p,t) -> sin(2π * ν * t)))
end
νs = 1:0.1:9.0;
````

Next, we can use the `floquet_sweep` function to compute the Floquet modes and quasienergies for each drive frequency. The `T` parameter is set to the period of the drive, which is $1/ν$.

````julia
F_sweep = floquet_sweep(H_func, νs, 1 ./νs, use_logging=false); # keeps progress bars from being printed
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

