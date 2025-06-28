```@meta
EditURL = "circuit_elements.jl"
```

# Circuit Elements
The core component of the SuperconductingCircuits.jl package is the circuit elements.

````julia
using SuperconductingCircuits
````

## Looking at all the Circuit Elements

### Qubit

````julia
freq = 5.0
name = "Qubit"
qubit = init_qubit(freq, name=name);
````

### Resonator

````julia
Eosc = 5.0
name = "Resonator"
N = 10
resonator = init_resonator(Eosc, N, name=name);
````

### Transmon

````julia
EC = 0.2
EJ = 1.0
n_full = 60
ng = 0.0
N = 10
name = "Transmon"
transmon = init_transmon(EC, EJ, N, name=name, ng = ng, n_full=n_full);
````

### Fluxonium

````julia
EJ = 8.9
EC = 2.5
EL = 0.5
flux = 0.33
N = 10
name = "Fluxonium"
fluxonium = init_fluxonium(EC, EJ, EL, N; name=name, flux = 0.33);
````

### SNAIL

````julia
EJ = 90
EC = 0.177
EL = 64
alpha = 0.147
Phi_e = 0.35
dim_full = 120
N = 6
name = "SNAIL"

snail = init_snail(EC, EJ, EL, alpha, Phi_e, dim_full, N, name=name);
````

## Some Other Initialization Tools
Also, a list of all the circuit elements can be initialized using the `init_components` dictionary.

````julia
println(keys(init_components));
````

````
Any["snail", "resonator", "transmon", "qubit", "fluxonium"]

````

A circuit element can be initialized as:

````julia
transmon = init_transmon(EC, EJ, N; name=name, ng = ng, n_full=n_full);
````

It is also possible to initialize using a dictionary of the parameters

````julia
transmon_params = Dict{Symbol, Any}();
transmon_params[:name] = name;
transmon_params[:EJ] = EJ;
transmon_params[:EC] = EC;
transmon_params[:N] = N;
transmon_params[:ng] = ng;
transmon_params[:n_full] = n_full;

transmon = init_components["transmon"](; transmon_params...);
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

