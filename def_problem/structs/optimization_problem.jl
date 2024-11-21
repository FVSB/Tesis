# Script that contains the struct for the Optimization Problem after making the problem
# feasible at the given point and adjusting (the bf vector is also generated)
"""
    struct Optimization_Problem

A structure to represent a bilevel optimization problem, containing the leader and follower functions, their respective restrictions, and other relevant data.

# Fields
- `leader_fun::Func`: The objective function for the leader in the optimization hierarchy.
- `leader_restrictions::Vector{Restriction_Func}`: A vector of restrictions applied to the leader's problem.
- `follower_fun::Func`: The objective function for the follower.
- `follower_restrictions::Vector{Restriction_Func}`: A vector of restrictions applied to the follower's problem.
- `point::Dict`: A dictionary representing the evaluation point with variable names as keys and their values as `Float64`.
- `bf::Vector`: A *bf* vector computed during the evaluation process.


# Notes
This structure encapsulates all the necessary components to define and solve a bilevel optimization problem, supporting leader-follower dynamics and constraints.
"""
struct Optimization_Problem
    leader_fun::Func
    leader_restrictions::Vector{Restriction_Func}
    follower_fun::Func
    follower_restrictions::Vector{Restriction_Func}
    point::Dict
    bf::Vector
end

"""
    Base.show(io::IO, obj::Optimization_Problem)

Displays the details of an `Optimization_Problem` object in a human-readable format.

# Arguments
- `io::IO`: The input/output stream where the output is written.
- `obj::Optimization_Problem`: The optimization problem object to display.

# Output
Prints a detailed summary of the leader's and follower's functions, their respective restrictions, the evaluation point, and other associated details.

# Example
```julia
opt_problem = Optimization_Problem(
    leader_fun, leader_restrictions, 
    follower_fun, follower_restrictions, 
    point, bf_vector
)
Base.show(stdout, opt_problem)
```
"""
function Base.show(io::IO, obj::Optimization_Problem)
    # Display the leader's objective function
    println("Leader's Objective Function:")
    show(obj.leader_fun)
    println(repeat("-", 30))
    
    # Display the leader's restrictions
    println("Leader's Restrictions:")
    for (index, restriction) in enumerate(obj.leader_restrictions)
        println(repeat("+", 30))
        println("Restriction $index")
        show(restriction)
        println(repeat("+", 30))
    end
    println(repeat("-", 30))
    
    # Display the follower's objective function
    println("Follower's Objective Function:")
    show(obj.follower_fun)
    println(repeat("-", 30))
    
    # Display the follower's restrictions
    println("Follower's Restrictions:")
    for (index, restriction) in enumerate(obj.follower_restrictions)
        println(repeat("+", 30))
        println("Restriction $index")
        show(restriction)
        println(repeat("+", 30))
    end
    println(repeat("-", 30))
    
    # Display the evaluation point
    point = obj.point
    println("Evaluation Point:")
    println(point)
    println(repeat("-", 30))
    
    # Separator for clarity
    println("_")
end
