#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
# Building a Circuit
"""
using SuperconductingCircuits;
using QuantumToolbox
#using Logging #hide
#disable_logging(Logging.warning); #hide

md"""
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
"""
qubit = init_qubit(5.0, name="Qubit");
ν = 5.0
H_D = qubit.H_op + QobjEvo((sigmax(), (p,t) -> sin(2π * ν * t)));
md"""
We then use `get_floquet_basis` to compute the Floquet basis for this Hamiltonian. The period of the drive is set to $T = 1/ν$.
"""
F_b = get_floquet_basis(H_D, 1/ν);

md"""
The floquet basis is a `floquet_basis` object that contains the Floquet quasienergies and a function to compute the Floquet modes at any time. We can access the quasienergies and modes as follows:
"""
F_b.e_quasi
md"""
The floquet at a time $t$ can be obtained by calling the `modes` function on the `floquet_basis` object:
"""
F_b.modes(1.0)
md"""
The period for the Floquet basis is stored in the `T` field of the `floquet_basis` object:
"""
F_b.T

md"""
## Sweeping Floquet Parameters.
The floquet spectrum can be computed for a family of Hamiltonians by sweeping over a parameter of interest. In the example we will well be working 
out we will be sweeping over the drive frequency of a qubit drive to identify a resonance.  

The first step is to define a function that returns the Hamiltonian for a given drive frequency and a range of drive frequencies. 
"""
function H_func(ν)
    return qubit.H_op + QobjEvo((sigmax(), (p,t) -> sin(2π * ν * t)))
end
νs = 1:0.1:9.0;
md"""
Next, we can use the `floquet_sweep` function to compute the Floquet modes and quasienergies for each drive frequency. The `T` parameter is set to the period of the drive, which is $1/ν$.
"""
F_sweep = floquet_sweep(H_func, νs, 1 ./νs, use_logging=false); # keeps progress bars from being printed
