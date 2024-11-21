# Define the restrictions

include("restriction_types.jl")
"""
    struct Def_Restriction

A structure to store definitions of restrictions, including their expressions, types, and associated parameters.

# Fields
- `expr_str::String`: String representation of the restriction expression.
- `restriction_set_type::RestrictionSetType`: The set type the restriction belongs to (e.g., active, inactive).
- `restriction_type::RestrictionType`: The type of restriction (e.g., inequality, equality).
- `is_leader::Bool`: Indicates whether the restriction is for the leader function.
- `miu::Number`: A parameter `miu` associated with the restriction.
- `beta::Number`: A parameter `beta` associated with the restriction.
- `lambda::Number`: A parameter `lambda` associated with the restriction, potentially for optimization purposes.
- `gamma::Number`: A parameter `gamma` used for adjustments or scaling.

# Notes
This structure serves as a container for the essential properties and parameters of restrictions, often used in optimization problems.
"""
struct Def_Restriction
    expr_str::String
    restriction_set_type::RestrictionSetType
    restriction_type::RestrictionType
    is_leader::Bool
    miu::Number
    beta::Number
    lambda::Number
    gamma::Number
end

"""
    Base.show(io::IO, obj::Def_Restriction)

Displays the details of a `Def_Restriction` object in a human-readable format.

# Arguments
- `io::IO`: The input/output stream where the output is written.
- `obj::Def_Restriction`: The restriction definition object to display.

# Output
Prints a formatted summary of the restriction's properties, including its type, associated parameters, and membership in a set.

# Example
```julia
def_restriction = Def_Restriction("x^2 + y <= 10", :active_set, :inequality, true, 0.1, 0.5, 1.0, 0.2)
Base.show(stdout, def_restriction)
```
"""
function Base.show(io::IO, obj::Def_Restriction)
    println("Restriction Definition Details")
    println(repeat("-", 30))
    
    restriction_type = obj.restriction_type
    println("Restriction type: $restriction_type")
    println(repeat("-", 30))
    
    restriction_type_set = obj.restriction_set_type
    println("Set type: $restriction_type_set")
    println(repeat("-", 30))
    
    is_leader = obj.is_leader
    println("Belongs to leader function: $is_leader")
    println(repeat("-", 30))
    
    miu = obj.miu
    println("Value of miu: $miu")
    println(repeat("-", 30))
    
    beta = obj.beta
    println("Value of beta: $beta")
    println(repeat("-", 30))
    
    lambda = obj.lambda
    println("Value of lambda: $lambda")
    println(repeat("-", 30))
    
    gamma = obj.gamma
    println("Value of gamma: $gamma")
    println(repeat("-", 30))
end

"""
    Def_Restriction_init(restriction_expr_str, restriction_set_type, restriction_type, is_leader, miu, beta, lambda, gamma)

Constructor function for creating `Def_Restriction` objects.

# Arguments
- `restriction_expr_str::String`: The string representation of the restriction expression.
- `restriction_set_type::RestrictionSetType`: The set type the restriction belongs to.
- `restriction_type::RestrictionType`: The type of restriction (e.g., inequality, equality).
- `is_leader::Bool`: Indicates whether the restriction is for the leader function.
- `miu::Number`: Parameter `miu` associated with the restriction.
- `beta::Number`: Parameter `beta` associated with the restriction.
- `lambda::Number`: Parameter `lambda` associated with the restriction.
- `gamma::Number`: Parameter `gamma` associated with the restriction.

# Returns
- `Def_Restriction`: A new instance of the `Def_Restriction` structure.

# Example
```julia
def_restriction = Def_Restriction_init("x^2 + y <= 10", :active_set, :inequality, true, 0.1, 0.5, 1.0, 0.2)
println(def_restriction)
```
"""
function Def_Restriction_init(restriction_expr_str::String, restriction_set_type::RestrictionSetType,
    restriction_type::RestrictionType, is_leader::Bool, miu::Number,
    beta::Number, lambda::Number, gamma::Number)
    return Def_Restriction(
        restriction_expr_str, 
        restriction_set_type, 
        restriction_type, 
        is_leader, 
        miu, 
        beta, 
        lambda, 
        gamma
    )
end




