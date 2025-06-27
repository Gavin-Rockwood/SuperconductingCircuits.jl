abstract type CircuitType end
# All components will have:
# - a dimension (dim)
# - a Hamiltonian (H_op)
# - an eigensystem (eigsys)
# - a dictionary called "loss_ops" that can be filled with collapse and dephasing operators
# - a list called "order" which is the list of the components and the order they will be indexed (order)
# - a dictionary "components" which contains the individual components in the circuit (components)
# - a dictionary "params" which contains all the parameters that go into the init function where they keys are symbols (params)
# - a dictionary "Interactions" which contains the interaction terms between the components (interactions)
# - Stuff is a dictionary that can be used to store any additional information (stuff)
# - A dictionary "static_gate" which contains the gates that can be applied to the circuit (static_gates)
#   - these are time independent objects that are just quantum objects
# - A dictionary "dynamic_gates" time evolution details for a specific operation (dynamic_gates)
# - important ops, dict of important ops in the circuit. (ops)

"""
    Circuit

A structure representing a quantum circuit in the SuperconductingCircuits framework.

# Fields
- `H_op::qt.QuantumObject`: The Hamiltonian operator describing the circuit.
- `dressed_energies::Dict`: Dictionary containing the dressed energy levels of the circuit.
- `dressed_states::Dict`: Dictionary containing the dressed quantum states of the circuit.
- `dims::Tuple`: Tuple specifying the dimensions of the circuit's Hilbert space.
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

# Description
The `Circuit` struct encapsulates all relevant information for modeling, simulating, and analyzing a superconducting quantum circuit, including its Hamiltonian, components, interactions, and various operators.
"""
@kwdef struct Circuit <: CircuitType
    H_op :: qt.QuantumObject
    dressed_energies :: Dict
    dressed_states :: Dict
    dims :: Tuple
    order :: Vector
    loss_ops :: Dict{String, qt.QuantumObject}
    components :: Dict{String, Any}
    interactions :: Vector
    stuff :: Dict{String, Any}
    drives :: Dict{String, Any}
    gates :: Dict{String, Any}
    ops :: Dict{String, Any}
    io_stuff :: Dict{String, Any}
    dressed_order :: Vector
end