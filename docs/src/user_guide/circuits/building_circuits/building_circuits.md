```@meta
EditURL = "building_circuits.jl"
```

# Building a Circuit

````julia
using SuperconductingCircuits;
````

In this example, we will build a transmon+resonator circuit.
## Building a Circuit
### Initializing Circuit Elements

We first initialize a transmon.

````julia
transmon_params = Dict{Symbol, Any}();
transmon_params[:name] = "transmon";
transmon_params[:EJ] = 26.96976142643705;
transmon_params[:EC] = 0.10283303447280807;
transmon_params[:N] = 10;
transmon_params[:n_full] = 60;

transmon = init_components["transmon"](; transmon_params...);
````

We now initialize a resonator.

````julia
resonator_params = Dict{Symbol, Any}();
resonator_params[:name] = "resonator";
resonator_params[:Eosc] = 6.228083962082612;
resonator_params[:N] = 10;

resonator = init_components["resonator"](; resonator_params...);
````

Here we have initialized two circuit elements: a transmon and a resonator.

````julia
circuit_elements = [transmon, resonator];
````

These are placed into a list called `circuit_elements` and the order of the elements in this list is important, as it will determine the order of the operators in the interactions and operators defined later.

### Defining Interactions
Interactions between elements are defined as a list of lists, where each list contains the interaction
strength as the first element and then, as a string, the operator and the involved modes. Note that the operators
have a ":" before them, such as ":n_op" for the transmon charge operator, and ":a_op" for the resonator annihilation operator.
These are properties of the circuit elements, such as "transmon.n_op" and will be parsed as such in the circuit initialization
using the `parse_and_eval` function.

````julia
interactions = [[0.026877206812551357, ":n_op", "1im*(:a_op-:a_op')"]];
````

The order of the operators in this list is important, and must be the same as the order as the list of circuit elements.

### Defining Extra Operators
We can also define some composite operators that we can use later. These will be stored in the "circuit.ops" dictionary.

````julia
operators = Dict{String, Any}("a" => ["", ":a_op"], "nt" => [":n_op", ""]);
````

Here we have defined two operators: "a" which is just the resonator annihilation operator, and "nt" which is the transmon charge operator.
Each is defined via a list, in the same fashion as the interactions. The blank elements in the list are elements that will be
replaced with an identity operator on that elements Hilbert space. The elements of this list can take the same form as the interactions,
such as "1im*(:a_op-:a_op')" for the resonator as they are parsed in the same way as the interactions. This allows for some internal
consistency in the circuit definition and makes it easier to save and load circuits, especially when drives and gates are defined.

### Putting it all together

````julia
circuit = init_circuit(circuit_elements, interactions; operators_to_add = operators);
````

## Circuit Properties
On its own, the circuit has several properties:

````julia
println(fieldnames(typeof(circuit)));
````

````
(:H_op, :dressed_energies, :dressed_states, :dims, :order, :loss_ops, :components, :interactions, :stuff, :drives, :gates, :ops, :io_stuff, :dressed_order)

````

| Property | Description |
|----------|-------------|
| `circuit.elements` | A list of the circuit elements in the order they were defined. |
| `circuit.interactions` | A list of the interactions between the circuit elements. This is the exact list used to initialize the circuit|
| `circuit.H_op`| The Hamiltonian of the circuit. |
| `circuit.ops` | A dictionary of the operators defined in the circuit. This is useful when working with gates. |
| `circuit.dressed_states` | The dressed states of the circuit. These are the eigenstates of the Hamiltonian and are indexed by their corresponding bare states. This indexing is done by adiabatically turning on the interactions and tracking the state evolution.|
| `circuit.dressed_energies` | The corresponding energies of the dressed states. |
| `circuit.dims` | The dimensions of the Hilbert spaces of the circuit elements. |
| `circuit.order` | The order of the circuit elements in the circuit and is a list of the names of the circuit elements. This is the same as the order of the elements in the `circuit.elements` list. |

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

