# script to define the struct for the functions and restrictions

# Import 
# Import restrictions types enums 
include("restriction_types.jl")

using Symbolics 
using LinearAlgebra
# Leader and Followers objetive functions 

"""
    Func

Abstract structure representing the basics of a function.

# Fields
- `vars_name::Symbol`: Vector containing the variable names of this expression.
- `expr_str::String`: The string representation of the expression.
- `expr`: Parsed expression.
- `point::Dict`: Mapping from symbolic numbers to floating-point values.
- `evaluation_value::Num`: The evaluated value of the function.
- `is_leader::Bool`: Indicates if this is the leader function.
"""
@kwdef mutable struct Func
    vars_name::Vector{Symbol}
    expr_str::String
    expr
    point::Dict
    evaluation_value::Num
    is_leader::Bool
end

"""
Displays the contents of a `Func` object in a readable format.
"""
function Base.show(io::IO, func::Func)
    vars_name = func.vars_name
    println("Variable names: $vars_name")
    expr_str = func.expr_str
    println("Expression (string): $expr_str")
    expr = func.expr
    println("Parsed expression: $expr")
    point = func.point
    println("Evaluation point: $point")
    evaluation_value = func.evaluation_value
    println("Evaluation value: $evaluation_value")
    is_leader = func.is_leader
    println("Is leader function: $is_leader")
end




# Leader and Followers restrictions functions 



"""
    @kwdef mutable struct Restriction_Func

Defines a mutable structure for a restriction function, including its variables, parsed expression, 
gradient expression, evaluation points, and various parameters.

# Fields
- `vars_name::Vector{Symbol}`: List of variable names used in the expression.
- `expr_str::String`: String representation of the mathematical expression.
- `expr`: Parsed expression derived from `expr_str`.
- `point::Dict`: Dictionary mapping variable symbols to their corresponding float values.
- `evaluation_value::Num`: The result of evaluating the restriction function at the given `point`.
- `add_const::Num`: An additional constant value related to the restriction.
- `restriction_type::RestrictionType`: The type of the restriction (e.g., equality, inequality).
- `restriction_set_type::RestrictionSetType`: The set type the restriction belongs to.
- `miu::Number`: Parameter `miu` related to optimization or the restriction's behavior.
- `beta::Number`: Parameter `beta` related to the function.
- `lambda::Number`: Parameter `lambda`, potentially related to Lagrange multipliers.
- `gamma::Number`: Parameter `gamma`, representing a scaling or adjustment factor.

# Notes
This structure is intended to be used in optimization or constraint evaluation scenarios.
"""
@kwdef mutable struct Restriction_Func
    vars_name::Vector{Symbol}
    expr_str::String
    expr
    # Gradient expression to be computed after determining the corresponding bj
    # grad_expr
    # The computed value of bj
    # bj
    point::Dict # Maps variable symbols to Float64 values
    evaluation_value::Num
    add_const::Num
    restriction_type::RestrictionType
    restriction_set_type::RestrictionSetType
    miu::Number
    beta::Number
    lambda::Number
    gamma::Number
end

"""
    Base.show(io::IO, restr_func::Restriction_Func)

Displays the details of a `Restriction_Func` object in a human-readable format.

# Arguments
- `io::IO`: The input/output stream where the output is written.
- `restr_func::Restriction_Func`: The restriction function object to display.

# Output
Prints each field of the `Restriction_Func` instance with a descriptive label.

# Example
```julia
restr_func = Restriction_Func(
    vars_name = [:x, :y],
    expr_str = "x^2 + y^2",
    expr = :(x^2 + y^2),
    point = Dict(:x => 1.0, :y => 2.0),
    evaluation_value = 5.0,
    add_const = 3.0,
    restriction_type = :equality,
    restriction_set_type = :type1,
    miu = 0.5,
    beta = 0.1,
    lambda = 1.0,
    gamma = 2.0
)
Base.show(stdout, restr_func)
```
"""
function Base.show(io::IO, restr_func::Restriction_Func)
    vars_name::Vector{Symbol} = restr_func.vars_name
    println("Variable names: $vars_name")
    
    expr_str::String = restr_func.expr_str
    println("Expression (string): $expr_str")
    
    expr = restr_func.expr
    println("Parsed expression: $expr")
    
    point::Dict = restr_func.point
    println("Evaluation point: $point")
    
    evaluation_value::Num = restr_func.evaluation_value
    println("Evaluation value: $evaluation_value")
    
    add_const::Num = restr_func.add_const
    println("Additional constant: $add_const")
    
    restriction_type::RestrictionType = restr_func.restriction_type
    println("Restriction type: $restriction_type")
    
    restriction_set_type::RestrictionSetType = restr_func.restriction_set_type
    println("Restriction set type: $restriction_set_type")
    
    miu = restr_func.miu
    println("Value of miu: $miu")
    
    beta = restr_func.beta
    println("Value of beta: $beta")
    
    lambda = restr_func.lambda
    println("Value of lambda: $lambda")
    
    gamma = restr_func.gamma
    println("Value of gamma: $gamma")
end


