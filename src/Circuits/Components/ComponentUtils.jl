"""
    CheckComponentRequirements(component::Component) -> Vector{Symbol}

Checks whether the given `component` has all required attributes specified in `Component_Required_Objects`.
If any required attributes are missing, it raises an error listing the missing attributes.

# Arguments
- `component::Component`: The component to check for required attributes.


"""
function CheckComponentRequirements(component::CircuitComponent)
    missing_attrs = []
    for attr in Component_Required_Objects
        if !haskey(component, attr)
            push!(missing_attrs, attr)
        end
    end
    if !isempty(missing_attrs)
        error("Component is missing required attributes: $(missing_attrs)")
    end
end