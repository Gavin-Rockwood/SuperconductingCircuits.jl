
# SuperconductingCircuits.jl Documentation {#SuperconductingCircuits.jl-Documentation}

:::tabs

== Circuits

## Circuits {#Circuits}
<details class='jldocstring custom-block' open>
<summary><a id='SuperconductingCircuits.Circuits.Circuit' href='#SuperconductingCircuits.Circuits.Circuit'><span class="jlbinding">SuperconductingCircuits.Circuits.Circuit</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Circuit
```


A structure representing a quantum circuit in the SuperconductingCircuits framework.

**Fields**
- `H_op::qt.QuantumObject`: The Hamiltonian operator describing the circuit.
  
- `dressed_energies::Dict`: Dictionary containing the dressed energy levels of the circuit.
  
- `dressed_states::Dict`: Dictionary containing the dressed quantum states of the circuit.
  
- `dims::Tuple`: Tuple specifying the dimensions of the circuit&#39;s Hilbert space.
  
- `order::Vector`: Vector specifying the order of components or subsystems in the circuit.
  
- `loss_ops::Dict{String, qt.QuantumObject}`: Dictionary mapping loss channel names to their corresponding quantum operators.
  
- `components::Dict{String, Any}`: Dictionary of circuit components, keyed by name.
  
- `interactions::Vector`: Vector of interactions present in the circuit.
  
- `stuff::Dict{String, Any}`: Miscellaneous circuit-related data.
  
- `drives::Dict{String, Any}`: Dictionary of drive terms applied to the circuit.
  
- `gates::Dict{String, Any}`: Dictionary of quantum gates defined for the circuit.
  
- `ops::Dict{String, Any}`: Dictionary of additional operators relevant to the circuit.
  
- `io_stuff::Dict{String, Any}`: Dictionary containing input/output related information.
  
- `dressed_order::Vector`: Vector specifying the order of dressed states or subsystems.
  

**Description**

The `Circuit` struct encapsulates all relevant information for modeling, simulating, and analyzing a superconducting quantum circuit, including its Hamiltonian, components, interactions, and various operators.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/Gavin-Rockwood/SuperconductingCircuits.jl/blob/966d7665f97d09d9fd15d1f9b6fdc67dc428033d/src/Circuits/Circuits.jl#L24-L47" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SuperconductingCircuits.Circuits.init_circuit-Tuple{AbstractArray{Dict}, Any, Any}' href='#SuperconductingCircuits.Circuits.init_circuit-Tuple{AbstractArray{Dict}, Any, Any}'><span class="jlbinding">SuperconductingCircuits.Circuits.init_circuit</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
init_circuit(components::AbstractArray{Dict}, types, interactions; kwargs...)
```


Initializes a circuit by constructing its components and applying specified interactions.

**Arguments**
- `components::AbstractArray{Dict}`: An array of dictionaries, each containing the parameters for a circuit component.
  
- `types`: An array specifying the type of each component, used to select the appropriate constructor from `Component_inits`.
  
- `interactions`: Data structure describing the interactions between components.
  
- `kwargs...`: Additional keyword arguments passed to the underlying `init_circuit` method.
  

**Returns**
- The initialized circuit object.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/Gavin-Rockwood/SuperconductingCircuits.jl/blob/966d7665f97d09d9fd15d1f9b6fdc67dc428033d/src/Circuits/CircuitConstructor.jl#L116-L129" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SuperconductingCircuits.Circuits.init_circuit-Tuple{AbstractArray{SuperconductingCircuits.Circuits.Component}, Any}' href='#SuperconductingCircuits.Circuits.init_circuit-Tuple{AbstractArray{SuperconductingCircuits.Circuits.Component}, Any}'><span class="jlbinding">SuperconductingCircuits.Circuits.init_circuit</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
init_circuit(components::AbstractArray{Component}, interactions; operators_to_add=Dict{String, Any}(), use_sparse=true, dressed_kwargs=Dict{Symbol, Any}())
```


Initialize a quantum circuit from a list of components and their interactions.

**Arguments**
- `components::AbstractArray{Component}`: An array of `Component` objects representing the subsystems of the circuit.
  
- `interactions`: A collection describing the interactions between components. Each interaction is typically a tuple or array where the first element is the coupling strength and the remaining elements specify the operators for each component.
  
- `operators_to_add=Dict{String, Any}()`: (Optional) A dictionary of additional operators to add to the circuit, keyed by operator name.
  
- `use_sparse=true`: (Optional) If `true`, use sparse matrix representations for operators and Hamiltonians.
  
- `dressed_kwargs=Dict{Symbol, Any}()`: (Optional) Keyword arguments passed to the dressed state calculation, such as `:f` (function for transformation) and `:step_number` (number of steps).
  

**Returns**
- `circuit::Circuit`: An initialized `Circuit` object containing the Hamiltonian, dressed states and energies, loss operators, component dictionary, and other relevant circuit information.
  

**Details**
- Constructs the total Hilbert space dimensions and identity operators for each component.
  
- Builds the bare Hamiltonian (`H_op_0`) and adds interaction terms to form the full Hamiltonian (`H_op`).
  
- Calculates dressed states and energies using `get_dressed_states`.
  
- Assembles loss operators for each component.
  
- Organizes components and other circuit data into a `Circuit` struct.
  
- Optionally adds user-specified operators to the circuit.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/Gavin-Rockwood/SuperconductingCircuits.jl/blob/966d7665f97d09d9fd15d1f9b6fdc67dc428033d/src/Circuits/CircuitConstructor.jl#L1-L24" target="_blank" rel="noreferrer">source</a></Badge>

</details>


## Components {#Components}

### Qubit {#Qubit}
<details class='jldocstring custom-block' open>
<summary><a id='SuperconductingCircuits.Circuits.Qubit' href='#SuperconductingCircuits.Circuits.Qubit'><span class="jlbinding">SuperconductingCircuits.Circuits.Qubit</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Qubit
```


A structure representing a quantum bit (qubit) component in a superconducting circuit.

**Fields**
- `dim::Int`: The Hilbert space dimension of the qubit (Always 2).
  
- `params::Dict`: Dictionary containing the physical parameters of the qubit.
  
- `H_op::qt.QuantumObject`: The Hamiltonian operator of the qubit, represented as a quantum object.
  
- `eigenstates::Vector`: Vector containing the eigenstates of the qubit Hamiltonian.
  
- `eigenenergies::Vector`: Vector containing the eigenenergies corresponding to the eigenstates.
  
- `loss_ops::Dict`: Dictionary of loss (dissipation) operators associated with the qubit.
  
- `freq::Float64`: The transition frequency of the qubit.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/Gavin-Rockwood/SuperconductingCircuits.jl/blob/966d7665f97d09d9fd15d1f9b6fdc67dc428033d/src/Circuits/Components/Qubit.jl#L1-L14" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SuperconductingCircuits.Circuits.init_qubit-Tuple{Any}' href='#SuperconductingCircuits.Circuits.init_qubit-Tuple{Any}'><span class="jlbinding">SuperconductingCircuits.Circuits.init_qubit</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
init_qubit(freq; name = "Qubit")
```


Initialize a `Qubit` object with the specified transition frequency `freq`.

**Arguments**
- `freq::Number`: The transition frequency of the qubit.
  
- `name::String` (optional): The name of the qubit. Defaults to `"Qubit"`.
  

**Returns**
- `Qubit`: An initialized `Qubit` object containing the Hamiltonian operator, eigenenergies, eigenstates, and other parameters.
  

**Details**

The function constructs the qubit Hamiltonian as `H_op = freq * qt.sigmaz() / 2`, computes its eigenenergies and eigenstates, and returns a `Qubit` object with these properties.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/Gavin-Rockwood/SuperconductingCircuits.jl/blob/966d7665f97d09d9fd15d1f9b6fdc67dc428033d/src/Circuits/Components/Qubit.jl#L29-L43" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SuperconductingCircuits.Circuits.init_qubit-Tuple{T} where T<:Dict' href='#SuperconductingCircuits.Circuits.init_qubit-Tuple{T} where T<:Dict'><span class="jlbinding">SuperconductingCircuits.Circuits.init_qubit</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
init_qubit(Params::T) where T<:Dict
```


Initializes a qubit using a dictionary of parameters.

**Arguments**
- `Params::Dict`: A dictionary containing at least the key `:freq` (the qubit frequency) and any additional keyword parameters required for qubit initialization.
  

**Returns**
- The result of calling `init_qubit` with the extracted frequency and remaining parameters.
  

**Notes**
- The function makes a deep copy of the input dictionary to avoid mutating the original.
  
- The `:freq` key is extracted and removed from the dictionary before passing the remaining parameters as keyword arguments.
  

**Example**


<Badge type="info" class="source-link" text="source"><a href="https://github.com/Gavin-Rockwood/SuperconductingCircuits.jl/blob/966d7665f97d09d9fd15d1f9b6fdc67dc428033d/src/Circuits/Components/Qubit.jl#L54-L70" target="_blank" rel="noreferrer">source</a></Badge>

</details>


### Resonator {#Resonator}
<details class='jldocstring custom-block' open>
<summary><a id='SuperconductingCircuits.Circuits.Resonator' href='#SuperconductingCircuits.Circuits.Resonator'><span class="jlbinding">SuperconductingCircuits.Circuits.Resonator</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Resonator
```


A structure representing a quantum resonator component in a superconducting circuit.

**Fields**
- `dim::Int`: The Hilbert space dimension of the resonator.
  
- `params::Dict`: Dictionary containing the physical parameters of the resonator.
  
- `H_op::qt.QuantumObject`: The Hamiltonian operator of the resonator.
  
- `eigenstates::Vector`: Vector of eigenstates of the resonator Hamiltonian.
  
- `eigenenergies::Vector`: Vector of eigenenergies corresponding to the eigenstates.
  
- `loss_ops::Dict`: Dictionary of loss (dissipation) operators associated with the resonator.
  
- `a_op::qt.QuantumObject`: The annihilation (lowering) operator for the resonator.
  
- `N_op::qt.QuantumObject`: The number operator for the resonator.
  

**Description**

This structure encapsulates all relevant quantum properties and operators for a resonator component, facilitating simulation and analysis within superconducting circuit models.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/Gavin-Rockwood/SuperconductingCircuits.jl/blob/966d7665f97d09d9fd15d1f9b6fdc67dc428033d/src/Circuits/Components/Resonator.jl#L2-L19" target="_blank" rel="noreferrer">source</a></Badge>

</details>


### SNAIL {#SNAIL}

### Transmon {#Transmon}
<details class='jldocstring custom-block' open>
<summary><a id='SuperconductingCircuits.Circuits.Transmon' href='#SuperconductingCircuits.Circuits.Transmon'><span class="jlbinding">SuperconductingCircuits.Circuits.Transmon</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Transmon
```


A struct representing a transmon qubit component in a superconducting circuit.

**Fields**
- `params::Dict`: Dictionary containing the physical parameters of the transmon.
  
- `eigenenergies::Vector`: Vector of eigenenergies computed for the transmon Hamiltonian.
  
- `eigenstates::Vector`: Vector of eigenstates corresponding to the eigenenergies.
  
- `H_op::qt.QuantumObject`: Truncated Hamiltonian operator for the transmon, represented as a quantum object.
  
- `dim::Int`: Hilbert space dimension used for truncation.
  
- `loss_ops::Dict`: Dictionary of loss (dissipation) operators relevant to the transmon.
  
- `H_op_full::qt.QuantumObject`: Full (untruncated) Hamiltonian operator for the transmon.
  
- `n_op_full::qt.QuantumObject`: Full (untruncated) charge operator (U(1) number operator).
  
- `n_op::qt.QuantumObject`: Truncated charge operator.
  

**Description**

The `Transmon` struct encapsulates all relevant data and operators for simulating a transmon qubit, including its Hamiltonian, eigenstates, and loss mechanisms. It is designed for use in quantum circuit simulations and analysis.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/Gavin-Rockwood/SuperconductingCircuits.jl/blob/966d7665f97d09d9fd15d1f9b6fdc67dc428033d/src/Circuits/Components/Transmon.jl#L1-L19" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SuperconductingCircuits.Circuits.init_transmon-NTuple{4, Any}' href='#SuperconductingCircuits.Circuits.init_transmon-NTuple{4, Any}'><span class="jlbinding">SuperconductingCircuits.Circuits.init_transmon</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
init_transmon(EC, EJ, N_full, N; name = "Transmon", ng = 0, kappa_c = 1/(56*1000), kappa_d = 1.2348024316109425e-5)
```


Initialize a Transmon qubit Hamiltonian and associated operators.

**Arguments**
- `EC::Real`: Charging energy of the transmon.
  
- `EJ::Real`: Josephson energy of the transmon.
  
- `N_full::Int`: Number of charge states to include in the full Hilbert space (dimension will be `2*N_full+1`).
  
- `N::Int`: Number of energy levels to keep in the truncated Hilbert space.
  
- `name::String`: (Optional) Name of the transmon instance. Defaults to `"Transmon"`.
  
- `ng::Real`: (Optional) Offset charge. Defaults to `0`.
  
- `kappa_c::Real`: (Optional) Collapse (relaxation) rate. Defaults to `1/(56*1000)`.
  
- `kappa_d::Real`: (Optional) Dephasing rate. Defaults to `1.2348024316109425e-5`.
  

**Returns**
- `Transmon`: An instance of the `Transmon` type containing:
  - `params`: Dictionary of parameters used for initialization.
    
  - `dim`: Truncated Hilbert space dimension.
    
  - `H_op_full`: Full Hamiltonian operator.
    
  - `H_op`: Truncated Hamiltonian operator.
    
  - `n_op_full`: Full number operator.
    
  - `n_op`: Truncated number operator.
    
  - `eigenenergies`: Eigenenergies of the truncated Hamiltonian.
    
  - `eigenstates`: Eigenstates of the truncated Hamiltonian.
    
  - `loss_ops`: Dictionary of collapse (`"Collapse"`) and dephasing (`"Dephasing"`) operators.
    
  

**Notes**
- The function constructs the transmon Hamiltonian in the charge basis, diagonalizes it, and projects onto the lowest `N` energy eigenstates.
  
- Collapse and dephasing operators are constructed in the truncated basis.
  
- Hermiticity of operators is checked and enforced.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/Gavin-Rockwood/SuperconductingCircuits.jl/blob/966d7665f97d09d9fd15d1f9b6fdc67dc428033d/src/Circuits/Components/Transmon.jl#L35-L66" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SuperconductingCircuits.Circuits.init_transmon-Tuple{T} where T<:Dict' href='#SuperconductingCircuits.Circuits.init_transmon-Tuple{T} where T<:Dict'><span class="jlbinding">SuperconductingCircuits.Circuits.init_transmon</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
init_transmon(Params::T) where T<:Dict
```


Initialize a transmon qubit using a dictionary of parameters.

**Arguments**
- `Params::Dict`: A dictionary containing the following required keys:
  - `:EC`: Charging energy.
    
  - `:EJ`: Josephson energy.
    
  - `:N_full`: Total number of charge states.
    
  - `:N`: Number of charge states to use in the truncated basis.
    
  Any additional keyword arguments in the dictionary will be forwarded to the underlying `init_transmon` method.
  

**Returns**
- An initialized transmon object (type depends on the implementation of `init_transmon`).
  

**Notes**
- The function extracts required parameters from the dictionary and passes them, along with any remaining parameters, to the lower-level `init_transmon` constructor.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/Gavin-Rockwood/SuperconductingCircuits.jl/blob/966d7665f97d09d9fd15d1f9b6fdc67dc428033d/src/Circuits/Components/Transmon.jl#L131-L149" target="_blank" rel="noreferrer">source</a></Badge>

</details>


## Utils {#Utils}
<details class='jldocstring custom-block' open>
<summary><a id='SuperconductingCircuits.Circuits.add_operator!-Tuple{SuperconductingCircuits.Circuits.Circuit, AbstractArray{String}, String}' href='#SuperconductingCircuits.Circuits.add_operator!-Tuple{SuperconductingCircuits.Circuits.Circuit, AbstractArray{String}, String}'><span class="jlbinding">SuperconductingCircuits.Circuits.add_operator!</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
add_operator!(circuit::Circuit, operator::AbstractArray{String}, name::String; use_sparse=true)
```


Adds a custom operator to the given `circuit` object.

**Arguments**
- `circuit::Circuit`: The circuit to which the operator will be added.
  
- `operator::AbstractArray{String}`: An array of operator strings, one for each component in the circuit. The length must match the number of components in the circuit.
  
- `name::String`: The name under which the operator will be stored in the circuit.
  
- `use_sparse` (optional, default = `true`): Whether to convert the operator matrices to sparse format.
  

**Description**

For each component in the circuit, parses and evaluates the corresponding operator string. If the operator is not defined (`nothing`), uses the identity operator for that component. Optionally converts each operator to a sparse matrix. The resulting operators are combined using a tensor product and stored in the circuit&#39;s `ops` dictionary under the given `name`. The original operator definitions are also stored in `circuit.stuff["ops_def"]`.

**Throws**
- An error if the length of `operator` does not match the number of components in the circuit.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/Gavin-Rockwood/SuperconductingCircuits.jl/blob/966d7665f97d09d9fd15d1f9b6fdc67dc428033d/src/Circuits/CircuitUtils.jl#L1-L17" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SuperconductingCircuits.Circuits.get_dressed_states-Tuple{QuantumToolbox.QuantumObject, AbstractArray{SuperconductingCircuits.Circuits.Component}, Any}' href='#SuperconductingCircuits.Circuits.get_dressed_states-Tuple{QuantumToolbox.QuantumObject, AbstractArray{SuperconductingCircuits.Circuits.Component}, Any}'><span class="jlbinding">SuperconductingCircuits.Circuits.get_dressed_states</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
get_dressed_states(H0::qt.QuantumObject, components::AbstractArray{Component}, interactions; step_number=20, f=x->x^3)
```


Compute the dressed states, energies, and orderings for a quantum system as interaction strengths are adiabatically turned on.

**Arguments**
- `H0::qt.QuantumObject`: The initial (bare) Hamiltonian of the system.
  
- `components::AbstractArray{Component}`: Array of system components, each with a defined Hilbert space dimension and eigenstates.
  
- `interactions`: List of interaction specifications. Each interaction is an array where the first element is the coupling strength, and subsequent elements specify operators (or &quot;1&quot; for identity) for each component. The string &quot;hc&quot; can be included to add the Hermitian conjugate.
  
- `step_number`: (Optional) Number of steps in the adiabatic interpolation. Default is 20.
  
- `f`: (Optional) Function mapping the interpolation parameter (from 0 to 1) to the interaction scaling. Default is `x -> x^3`.
  

**Returns**

A vector containing:
1. `dressed_states::Dict`: Mapping from bare state tuples to the corresponding dressed state at the final step.
  
2. `dressed_energies::Dict`: Mapping from bare state tuples to the corresponding dressed energy at the final step.
  
3. `dressed_order::Vector{Tuple}`: Vector mapping the dressed state order (by energy) to the bare state tuple.
  

**Description**

The function interpolates between the bare Hamiltonian and the fully interacting Hamiltonian by scaling the interaction terms according to `f`. At each step, it computes the eigenstates and energies, tracks the evolution of each bare state, and returns the dressed states, energies, and their order at the final step.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/Gavin-Rockwood/SuperconductingCircuits.jl/blob/966d7665f97d09d9fd15d1f9b6fdc67dc428033d/src/Circuits/CircuitUtils.jl#L39-L59" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SuperconductingCircuits.Circuits.save-Tuple{SuperconductingCircuits.Circuits.Circuit, String}' href='#SuperconductingCircuits.Circuits.save-Tuple{SuperconductingCircuits.Circuits.Circuit, String}'><span class="jlbinding">SuperconductingCircuits.Circuits.save</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
save(circuit::Circuit, filename::String)
```


Serialize and save the given `circuit` object to a file specified by `filename`.

The function collects the following information from the `circuit`:
- `order`: The order of the circuit.
  
- `components`: A dictionary mapping component names to their parameters.
  
- `interactions`: A list of circuit interactions.
  
- `stuff`: Additional circuit data stored in the `stuff` field.
  

**Arguments**
- `circuit::Circuit`: The circuit object to be saved.
  
- `filename::String`: The path to the file where the circuit data will be saved.
  

**Note**

The actual file writing operation is not implemented in this function.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/Gavin-Rockwood/SuperconductingCircuits.jl/blob/966d7665f97d09d9fd15d1f9b6fdc67dc428033d/src/Circuits/CircuitUtils.jl#L116-L133" target="_blank" rel="noreferrer">source</a></Badge>

</details>


== Dynamics

## Dynamics {#Dynamics}
<details class='jldocstring custom-block' open>
<summary><a id='SuperconductingCircuits.Dynamics.calibrate_drive-Tuple{QuantumToolbox.QuantumObjectEvolution, Any, Any, Function}' href='#SuperconductingCircuits.Dynamics.calibrate_drive-Tuple{QuantumToolbox.QuantumObjectEvolution, Any, Any, Function}'><span class="jlbinding">SuperconductingCircuits.Dynamics.calibrate_drive</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
calibrate_drive(drive_op::qt.QobjEvo, t_range0, psi0, to_min::Function; samples_per_level=5, maxiters=7, tol=1e-3, approx_tol=1e-8, solver_kwargs=Dict{Symbol, Any}(), return_drive=true, include_H=true, dt=1e-2)
```


Calibrates the duration of a quantum drive by minimizing a user-specified cost function over a given time range.

**Arguments**
- `drive_op::qt.QobjEvo`: The time-dependent drive operator (Hamiltonian) to be calibrated.
  
- `t_range0`: Initial time range (tuple or array) over which to search for the optimal drive duration.
  
- `psi0`: Initial quantum state for the evolution.
  
- `to_min::Function`: A function that takes the final state and returns a scalar value to be minimized (e.g., infidelity).
  
- `samples_per_level`: Number of time samples to evaluate per iteration (default: 5).
  
- `maxiters`: Maximum number of iterations for the calibration loop (default: 7).
  
- `tol`: Tolerance for the minimum value of the cost function to consider the calibration successful (default: 1e-3).
  
- `approx_tol`: Tolerance for considering two time points as approximately equal (default: 1e-8).
  
- `solver_kwargs`: Additional keyword arguments to pass to the ODE solver (default: empty dictionary).
  
- `return_drive`: If `true`, returns the calibrated drive (currently unused, default: true).
  
- `include_H`: If `true`, includes the Hamiltonian in the evolution (currently unused, default: true).
  
- `dt`: Time step for the evolution solver (default: 1e-2).
  

**Returns**
- A two-element array `[best_time, best_fid]` where:
  - `best_time`: The optimal drive duration found.
    
  - `best_fid`: The minimum value of the cost function achieved.
    
  

**Description**

This function iteratively samples the cost function over a shrinking time interval, searching for the drive duration that minimizes the user-provided `to_min` function. The search continues until the minimum value falls below the specified tolerance or the maximum number of iterations is reached.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/Gavin-Rockwood/SuperconductingCircuits.jl/blob/966d7665f97d09d9fd15d1f9b6fdc67dc428033d/src/Dynamics/Drives/DriveCalibration.jl#L1-L27" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SuperconductingCircuits.Dynamics.find_resonance-Union{Tuple{T1}, Tuple{Any, Any, T1}} where T1<:Dict' href='#SuperconductingCircuits.Dynamics.find_resonance-Union{Tuple{T1}, Tuple{Any, Any, T1}} where T1<:Dict'><span class="jlbinding">SuperconductingCircuits.Dynamics.find_resonance</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
find_resonance(H_func, freqs, reference_states::T1; show_plot=false, plot_freq_offset=0, plotxlabel="Drive Frequencies (GHz)") where T1 <: Dict
```


Finds the resonance frequency and approximate drive time for a driven quantum system using Floquet theory.

**Arguments**
- `H_func`: A function that generates the system Hamiltonian as a function of parameters.
  
- `freqs`: An array of drive frequencies (in GHz) to sweep over.
  
- `reference_states::T1`: A dictionary mapping state labels to reference states to track during the Floquet sweep.
  
- `show_plot`: (optional) If `true`, displays plots of the quasienergies and their differences. Default is `false`.
  
- `plot_freq_offset`: (optional) Frequency offset to apply to the x-axis of the plots. Default is `0`.
  
- `plotxlabel`: (optional) Label for the x-axis of the plots. Default is `"Drive Frequencies (GHz)"`.
  

**Returns**
- A two-element array:
  1. The resonance frequency (in GHz) where the minimum energy gap occurs.
    
  2. The approximate drive time associated with the resonance.
    
  

**Description**

This function performs a sweep over the provided drive frequencies, computes the Floquet quasienergies for the specified reference states, and determines the resonance by fitting the minimum energy gap to a model function. Optionally, it can display plots of the quasienergies and their differences.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/Gavin-Rockwood/SuperconductingCircuits.jl/blob/966d7665f97d09d9fd15d1f9b6fdc67dc428033d/src/Dynamics/Drives/ResonanceFinder.jl#L1-L21" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SuperconductingCircuits.Dynamics.floquet_sweep-Union{Tuple{T1}, Tuple{Any, Any, Any}} where T1<:Dict' href='#SuperconductingCircuits.Dynamics.floquet_sweep-Union{Tuple{T1}, Tuple{Any, Any, Any}} where T1<:Dict'><span class="jlbinding">SuperconductingCircuits.Dynamics.floquet_sweep</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
floquet_sweep(H_func, sampling_points, T; sampling_times=[], use_logging=true, states_to_track=Dict{Any, Any}(), propagator_kwargs=Dict{Any, Any}())
```


Performs a parameter sweep to compute Floquet modes and quasienergies for a family of time-dependent Hamiltonians.

**Arguments**
- `H_func`: A function that takes a parameter value from `sampling_points` and returns the corresponding Hamiltonian.
  
- `sampling_points`: An array of parameter values over which to perform the sweep.
  
- `T`: The period of the drive. Can be a scalar (applied to all points) or an array matching `sampling_points`.
  
- `sampling_times`: (Optional) Array of times at which to evaluate the Floquet modes for each parameter set. Defaults to zeros.
  
- `use_logging`: (Optional) If `true`, logs progress and status messages.
  
- `states_to_track`: (Optional) A dictionary of states to track across the sweep. If provided, state tracking is performed.
  
- `propagator_kwargs`: (Optional) Dictionary of keyword arguments to pass to the propagator used in Floquet basis calculation.
  

**Returns**

A dictionary with the following keys:
- `"F_Modes"`: Array of Floquet modes for each parameter set.
  
- `"F_Energies"`: Array of Floquet quasienergies for each parameter set.
  
- `"Tracking"`: (Optional) Results from state tracking, if `states_to_track` is provided.
  

**Notes**
- If a parameter value in `sampling_points` is repeated, previously computed results are reused.
  
- Progress is displayed using a progress bar if logging is enabled.
  
- Requires `get_floquet_basis` and `Utils.state_tracker` to be defined elsewhere.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/Gavin-Rockwood/SuperconductingCircuits.jl/blob/966d7665f97d09d9fd15d1f9b6fdc67dc428033d/src/Dynamics/Floquet/Floquet_Sweep.jl#L1-L25" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SuperconductingCircuits.Dynamics.get_FLZ_flattop-Tuple{Any, Any, Any, Any, Function, Any, Any, Any}' href='#SuperconductingCircuits.Dynamics.get_FLZ_flattop-Tuple{Any, Any, Any, Any, Function, Any, Any, Any}'><span class="jlbinding">SuperconductingCircuits.Dynamics.get_FLZ_flattop</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
get_FLZ_flattop(H_op, drive_op, freq, epsilon, envelope_func, ramp_time, psi0, psi1; dt=0, n_theta_samples=100, number_eps_samples=10)
```


Compute the flat-top Floquet-Landau-Zener (FLZ) calibration time for a driven quantum system.

**Arguments**
- `H_op`: The static Hamiltonian operator of the system.
  
- `drive_op`: The operator corresponding to the drive term.
  
- `freq`: The drive frequency (in Hz).
  
- `epsilon`: The drive amplitude.
  
- `envelope_func::Function`: A function specifying the envelope of the drive pulse as a function of time.
  
- `ramp_time`: The duration of the ramp (in the same units as time).
  
- `psi0`: The initial quantum state (typically the ground state).
  
- `psi1`: The target quantum state (typically the excited state).
  

**Keyword Arguments**
- `dt`: Time step for sampling during the ramp. If set to 0 (default), it is set to `1/freq`.
  
- `n_theta_samples`: Number of samples for the phase optimization grid search (default: 100).
  
- `number_eps_samples`: Number of epsilon samples for the Floquet sweep (default: 10).
  

**Returns**
- The calibrated flat-top time (in the same units as `ramp_time`) required for the FLZ protocol, based on the phase difference between the Floquet states and the driven evolution.
  

**Notes**
- This function performs a Floquet sweep to track the evolution of the system under the drive and optimizes the phase to match the final state to the Floquet eigenstates.
  
- The function prints the computed Floquet frequency and phase information for diagnostic purposes.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/Gavin-Rockwood/SuperconductingCircuits.jl/blob/966d7665f97d09d9fd15d1f9b6fdc67dc428033d/src/Dynamics/Drives/DriveCalibration.jl#L78-L104" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SuperconductingCircuits.Dynamics.get_floquet_basis-Tuple{Union{QuantumToolbox.QuantumObject, QuantumToolbox.QuantumObjectEvolution}, Any}' href='#SuperconductingCircuits.Dynamics.get_floquet_basis-Tuple{Union{QuantumToolbox.QuantumObject, QuantumToolbox.QuantumObjectEvolution}, Any}'><span class="jlbinding">SuperconductingCircuits.Dynamics.get_floquet_basis</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
get_floquet_basis(H::Union{qt.QuantumObject, qt.QobjEvo}, T; t0 = 0, propagator_kwargs = Dict{Symbol, Any}())
```


Compute the Floquet basis for a time-periodic Hamiltonian.

**Arguments**
- `H::Union{qt.QuantumObject, qt.QobjEvo}`: The time-dependent Hamiltonian, either as a quantum object or a time-evolution operator.
  
- `T`: The period of the Hamiltonian.
  
- `t0`: (optional) Initial time. Defaults to `0`.
  
- `propagator_kwargs`: (optional) Dictionary of keyword arguments to pass to the propagator functions.
  

**Returns**
- A tuple containing the Floquet quasi-energies and a function that returns the time-evolved Floquet modes at any given time.
  

**Description**

This function computes the Floquet basis by:
1. Calculating the propagator over one period.
  
2. Diagonalizing the propagator to obtain Floquet quasi-energies and modes.
  
3. Returning the quasi-energies and a function for propagating the Floquet modes in time.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/Gavin-Rockwood/SuperconductingCircuits.jl/blob/966d7665f97d09d9fd15d1f9b6fdc67dc428033d/src/Dynamics/Floquet/Floquet_Basis.jl#L1-L20" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SuperconductingCircuits.Dynamics.get_propagator-Tuple{Union{QuantumToolbox.QuantumObject, QuantumToolbox.QuantumObjectEvolution}}' href='#SuperconductingCircuits.Dynamics.get_propagator-Tuple{Union{QuantumToolbox.QuantumObject, QuantumToolbox.QuantumObjectEvolution}}'><span class="jlbinding">SuperconductingCircuits.Dynamics.get_propagator</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
get_propagator(H::Union{qt.QobjEvo, qt.QuantumObject})
```


Constructs a `Propagator` object for the given Hamiltonian `H`, which can be either a `qt.QobjEvo` or a `qt.QuantumObject`. 

The returned `Propagator` provides a function interface to compute the time-evolution operator for `H` over a specified time interval. The function accepts the final time `tf`, an optional initial time `ti` (default is 0), and an optional dictionary of solver keyword arguments `solver_kwargs`.

**Arguments**
- `H::Union{qt.QobjEvo, qt.QuantumObject}`: The Hamiltonian for which the propagator is constructed.
  

**Returns**
- `Propagator`: An object that can be called to compute the propagator for the specified time interval and solver options.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/Gavin-Rockwood/SuperconductingCircuits.jl/blob/966d7665f97d09d9fd15d1f9b6fdc67dc428033d/src/Dynamics/Utils/Propagator.jl#L57-L69" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SuperconductingCircuits.Dynamics.propagate_floquet_modes-NTuple{4, Any}' href='#SuperconductingCircuits.Dynamics.propagate_floquet_modes-NTuple{4, Any}'><span class="jlbinding">SuperconductingCircuits.Dynamics.propagate_floquet_modes</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
propagate_floquet_modes(modes_t0, U, t, T; propagator_kwargs=Dict{Symbol, Any}())
```


Propagates a set of Floquet modes from the initial time `t₀` to a later time `t` using the provided propagator `U`.

**Arguments**
- `modes_t0`: Array of Floquet modes at the initial time `t₀`.
  
- `U`: A propagator object with an `eval` method, used to compute the time evolution operator.
  
- `t`: The target time to which the modes should be propagated.
  
- `T`: The period of the Floquet system.
  
- `propagator_kwargs`: (Optional) Dictionary of keyword arguments to pass to the propagator&#39;s `eval` method.
  

**Returns**
- An array of Floquet modes at time `t`.
  

**Notes**
- If `t` is an integer multiple of `T`, the function returns the initial modes unchanged.
  
- Otherwise, the function computes the propagator for the time offset `t % T` and applies it to each mode.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/Gavin-Rockwood/SuperconductingCircuits.jl/blob/966d7665f97d09d9fd15d1f9b6fdc67dc428033d/src/Dynamics/Floquet/Floquet_Utils.jl#L1-L19" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SuperconductingCircuits.Dynamics.propagator-Tuple{Union{QuantumToolbox.QuantumObject, QuantumToolbox.QuantumObjectEvolution}, Any}' href='#SuperconductingCircuits.Dynamics.propagator-Tuple{Union{QuantumToolbox.QuantumObject, QuantumToolbox.QuantumObjectEvolution}, Any}'><span class="jlbinding">SuperconductingCircuits.Dynamics.propagator</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
propagator(H::Union{qt.QobjEvo, qt.QuantumObject}, tf; ti = 0, solver = DE.Vern9(), solver_kwargs = Dict{Any, Any}())
```


Compute the time-evolution operator (propagator) for a given time-dependent or time-independent Hamiltonian `H` from initial time `ti` to final time `tf`.

**Arguments**
- `H::Union{qt.QobjEvo, qt.QuantumObject}`: The Hamiltonian, either as a time-dependent (`qt.QobjEvo`) or time-independent (`qt.QuantumObject`) quantum object.
  
- `tf`: The final time for propagation.
  
- `ti`: (optional) The initial time. Defaults to `0`.
  
- `solver`: (optional) The ODE solver to use from DifferentialEquations.jl. Defaults to `DE.Vern9()`.
  
- `solver_kwargs`: (optional) Additional keyword arguments to pass to the ODE solver.
  

**Returns**
- `qt.Qobj`: The propagator (time-evolution operator) as a quantum object, mapping the system from time `ti` to `tf`.
  

**Notes**
- The function internally constructs the ODE for the propagator in the Schrödinger picture and solves it using the specified solver.
  
- If the Hamiltonian is sparse, the propagator is returned as a sparse matrix.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/Gavin-Rockwood/SuperconductingCircuits.jl/blob/966d7665f97d09d9fd15d1f9b6fdc67dc428033d/src/Dynamics/Utils/Propagator.jl#L18-L36" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SuperconductingCircuits.Dynamics.Propagator' href='#SuperconductingCircuits.Dynamics.Propagator'><span class="jlbinding">SuperconductingCircuits.Dynamics.Propagator</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Propagator
```


A structure representing a quantum propagator for time evolution.

**Fields**
- `H::Union{qt.QobjEvo, qt.QuantumObject}`: The Hamiltonian or time-dependent operator governing the system&#39;s dynamics. This can be a `qt.QobjEvo` for time-dependent Hamiltonians or a `qt.QuantumObject` for time-independent cases.
  
- `eval::Function`: A function that computes the propagator or evolves the quantum state, typically as a function of time and initial state.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/Gavin-Rockwood/SuperconductingCircuits.jl/blob/966d7665f97d09d9fd15d1f9b6fdc67dc428033d/src/Dynamics/Utils/Propagator.jl#L3-L11" target="_blank" rel="noreferrer">source</a></Badge>

</details>


== Utils

## Utils {#Utils-2}
<details class='jldocstring custom-block' open>
<summary><a id='SuperconductingCircuits.Utils.identity_wrapper-Tuple{Dict, Any}' href='#SuperconductingCircuits.Utils.identity_wrapper-Tuple{Dict, Any}'><span class="jlbinding">SuperconductingCircuits.Utils.identity_wrapper</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
identity_wrapper(𝕀̂_Dict::Dict, Operator_Dict; order = [])
```


Constructs a tensor product of operators, replacing identity operators with those specified in `Operator_Dict`.

**Arguments**
- `𝕀̂_Dict::Dict`: A dictionary mapping subsystem keys to identity operators.
  
- `Operator_Dict::Dict`: A dictionary mapping subsystem keys to operators that should replace the corresponding identities.
  
- `order::Vector` (optional): An array specifying the order of subsystems in the tensor product. If not provided, the order of keys in `𝕀̂_Dict` is used.
  

**Returns**
- The tensor product (using `qt.tensor`) of the operators, with identities replaced as specified.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/Gavin-Rockwood/SuperconductingCircuits.jl/blob/966d7665f97d09d9fd15d1f9b6fdc67dc428033d/src/Utils/IdentityWrappers.jl#L1-L13" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SuperconductingCircuits.Utils.parse_and_eval-Tuple{Any, Any}' href='#SuperconductingCircuits.Utils.parse_and_eval-Tuple{Any, Any}'><span class="jlbinding">SuperconductingCircuits.Utils.parse_and_eval</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
parse_and_eval(expr::AbstractString, x)
```


Parses the string `expr` as a Julia expression, defines a function `eval_func(x)` that evaluates this expression with the given argument `x`, and then invokes this function using `invokelatest`.

**Arguments**
- `expr::AbstractString`: A string representing a Julia expression, which should be valid code involving the variable `x`.
  
- `x`: The value to substitute for `x` in the evaluated expression.
  

**Returns**
- The result of evaluating the parsed expression with the provided value of `x`.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/Gavin-Rockwood/SuperconductingCircuits.jl/blob/966d7665f97d09d9fd15d1f9b6fdc67dc428033d/src/Utils/RandomThings.jl#L18-L29" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SuperconductingCircuits.Utils.state_tracker-Tuple{Vector, Dict}' href='#SuperconductingCircuits.Utils.state_tracker-Tuple{Vector, Dict}'><span class="jlbinding">SuperconductingCircuits.Utils.state_tracker</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
state_tracker(state_history::Vector, states_to_track::Dict; other_sorts=Dict{Any, Any}(), use_logging=true)
```


Tracks the evolution of specified quantum states across a sequence of state histories.

**Arguments**
- `state_history::Vector`: A vector where each element is a collection (e.g., vector or array) of quantum states at a given time step.
  
- `states_to_track::Dict`: A dictionary mapping state identifiers to their initial state vectors to be tracked.
  
- `other_sorts::Dict{Any, Any}` (optional): A dictionary mapping additional property names to arrays of properties, which are also tracked for each state and time step. Defaults to an empty dictionary.
  
- `use_logging::Bool` (optional): If `true`, enables debug and info logging for tracking progress and overlaps. Defaults to `true`.
  

**Returns**
- `history`: A multidimensional array (AxisArray or similar) indexed by state and step, where each entry is a dictionary containing:
  - `"psi"`: The tracked state vector at that step.
    
  - `"overlap"`: The maximum overlap value found for the state at that step.
    
  - Additional keys for each property in `other_sorts`, containing their respective values.
    
  

**Description**

For each state specified in `states_to_track`, the function iteratively finds, at each time step, the state in `state_history` with the maximum overlap (squared inner product) with the previous step&#39;s tracked state. It records the state vector, overlap, and any additional properties provided in `other_sorts`. The function also ensures that the same state is not assigned to multiple tracked states at the same step, logging a warning if this occurs.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/Gavin-Rockwood/SuperconductingCircuits.jl/blob/966d7665f97d09d9fd15d1f9b6fdc67dc428033d/src/Utils/StateTracking.jl#L1-L20" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SuperconductingCircuits.Utils.tostr-Tuple{Any}' href='#SuperconductingCircuits.Utils.tostr-Tuple{Any}'><span class="jlbinding">SuperconductingCircuits.Utils.tostr</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
tostr(obj) -> String
```


Converts the given object `obj` to its plain text string representation by using the `show` function with the `"text/plain"` MIME type.

**Arguments**
- `obj`: Any Julia object to be converted to a string.
  

**Returns**
- `String`: The plain text representation of `obj`.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/Gavin-Rockwood/SuperconductingCircuits.jl/blob/966d7665f97d09d9fd15d1f9b6fdc67dc428033d/src/Utils/RandomThings.jl#L1-L11" target="_blank" rel="noreferrer">source</a></Badge>

</details>


:::
