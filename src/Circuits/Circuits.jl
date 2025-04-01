module Circuits
    import QuantumToolbox as qt
    import ..Utils
    import ..Dynamics
    using YAXArrays
    include("Components/Components.jl")

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

    @kwdef struct Circuit <: CircuitType
        H_op :: qt.QuantumObject
        dressed_energies :: Dict
        dressed_states :: Dict
        dims :: Tuple
        order :: Vector
        loss_ops :: Dict
        components :: Dict
        interactions :: Vector
        stuff :: Dict
        static_gates :: Dict
        dynamic_gates :: Dict
        ops :: Dict
    end
    include("CircuitConstructor.jl")


end