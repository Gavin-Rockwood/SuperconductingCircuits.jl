#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
# # Circuit Elements
# The core component of the SuperconductingCircuits.jl package is the circuit elements. 
import SuperconductingCircuits as SCC
using Logging #hide
disable_logging(Logging.Warn); #hide
#
# 

# :::tabs

# == Qubit
freq = 5.0
name = "TestQubit"
qubit = SCC.Circuits.init_qubit(freq, name=name);

# == Resonator
Eosc = 5.0
name = "TestResonator"
N = 10
resonator = SCC.Circuits.init_resonator(Eosc, N, name=name);

# == Transmon
EC = 0.2
EJ = 1.0
n_full = 60
ng = 0.0
N = 10
name = "TestTransmon"
transmon = SCC.Circuits.init_transmon(EC, EJ, N, name=name, ng = ng, n_full=n_full);

# == Fluxonium
EJ = 8.9
EC = 2.5
EL = 0.5
flux = 0.33
N = 10
name = "TestFluxonium"
fluxonium = SCC.Circuits.init_fluxonium(EC, EJ, EL, N; name=name, flux = 0.33);

# == SNAIL
EJ = 90
EC = 0.177
EL = 64
alpha = 0.147
Phi_e = 0.35
dim_full = 120
N = 6

snail = SCC.Circuits.init_snail(EC, EJ, EL, alpha, Phi_e, dim_full, N, name="TestSNAIL");

# :::