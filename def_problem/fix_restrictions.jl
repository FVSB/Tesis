# Import from another scripts

# Import utils 
include("utils.jl")
# Import the parser methods
include("parser.jl")
# Import enums to define types of constraints.
include("structs/restriction_types.jl")
# Import the structs to internal use
# Import the internal functions structs
include("structs/functions.jl")
# Import the Optimization Problem struct
include("structs/optimization_problem.jl")
# Import the Def_Restriction struct 
include("structs/def_restrictions.jl")

##################################################
#                                                #
#               Functions Inits                  #                             
#                                                #
##################################################


# Init the Leader and Follower structs
"""
Initializes a `Func` object.

# Arguments
- `expr_str::String`: The expression as a string.
- `point::Dict`: Mapping from variables to their values.
- `is_leader::Bool`: Indicates if this is the leader function.

# Returns
- `Func`: The initialized function object.
"""
function Func_init(expr_str::String, point::Dict, is_leader::Bool)::Func
    vars_name::Vector{Symbol} = extract_variable_names(expr_str)
    add_to_symbolics(vars_name)
    expr = parse_expression(expr_str)
    value = eval_point(expr, point)
    a = Func(vars_name=vars_name, expr_str=expr_str, expr=expr, point=point, evaluation_value=value, is_leader=is_leader)
    return a
end

# Init the restrictions structs

"""
    compute_bj(restriction_expr, alpha, point, ys_vars, restriction_set_type, gamma)::Number

Computes the vector `bj` corresponding to an active restriction `g`.

# Arguments
- `restriction_expr`: The symbolic expression of the restriction.
- `alpha::Vector`: A vector of coefficients for the restriction variables.
- `point::Dict`: A dictionary mapping variable symbols to numerical values.
- `ys_vars::Vector{Num}`: The symbolic variables involved in the computation.
- `restriction_set_type::RestrictionSetType`: The type of the restriction set (e.g., `Normal`, `J_0_g`, etc.).
- `gamma::Number`: A scaling factor used in the computation.

# Returns
- `Number`: The computed value of `bj`.

# Notes
- If the restriction set type is not active (e.g., `Normal` or `J_0_g`), `bj` is returned as 0.
- Ensures the dimensions of `alpha` and `ys_vars` are consistent.
"""
function compute_bj(restriction_expr, alpha::Vector, point::Dict, ys_vars::Vector{Num},
    restriction_set_type::RestrictionSetType, gamma::Number)::Number

    # Ensure the indices are active; otherwise, return 0
    if restriction_set_type in [Normal, J_0_g]
        return 0
    end

    # Calculate the norm of the vector alpha
    alpha_norm = norm(alpha)

    # Verify that the dimensions of `ys_vars` match the size of `alpha`
    ys_len = length(ys_vars)
    alpha_len = length(alpha)
    @assert ys_len == alpha_len "The length of alpha is $alpha_len, but the length of ys_vars is $ys_len. These must be equal."

    # Compute the gradient of the restriction with respect to the variables
    grad_expr = Symbolics.gradient(restriction_expr, ys_vars)

    # Substitute the gradient values at the given point
    vector_val = substitute_point_in_vector(grad_expr, point)

    # Compute bj based on the restriction set type
    if restriction_set_type == J_0_LP_v  # In this case, gamma must be 0
        return dot(-vector_val, alpha) / (alpha_norm * alpha_norm)
    else  # For other types, lambda is considered 0
        return (dot(-vector_val, alpha) + gamma) / (alpha_norm * alpha_norm)
    end
end

"""
Adjusts the given value based on the specified restriction set type.

# Arguments:
- `value::Num`: The numeric value to be adjusted.
- `restriction_set_type::RestrictionSetType`: The type of restriction set that determines how the value is modified.

# Returns:
The adjusted value according to the rules for the given restriction set type.
"""
function Fix_value(value::Num, restriction_set_type::RestrictionSetType)::Num
   
    # If the restriction set type is "J_Ne_L0_v", apply specific adjustments
    if restriction_set_type in [J_Ne_L0_v]
        if value < 0
            # If the value is less than zero, the condition is met; return the value as is
            return value
        end
        # Otherwise, adjust the value by adding a random number and negating it
        return (value + get_rand()) * -1
    end

    # For all other cases, negate the value
    return value * -1
end


"""
    Restriction_init(expr_str, point, restriction_type, restriction_set_type, miu, beta, lambda, gamma, alpha, ys_vars, is_alpha_zero)

Initializes a new `Restriction_Func` object with the given parameters and computes its corresponding 
`bj` vector if required.

# Arguments
- `expr_str::String`: The string representation of the restriction equation.
- `point::Dict`: Dictionary mapping variables to their numeric values.
- `restriction_type::RestrictionType`: The type of the restriction (e.g., inequality, equality).
- `restriction_set_type::RestrictionSetType`: The restriction set type.
- `miu::Number`, `beta::Number`, `lambda::Number`, `gamma::Number`: Numerical parameters for the restriction.
- `alpha::Vector`: A vector associated with the restriction variables.
- `ys_vars::Vector{Num}`: Symbolic variables for the restriction.
- `is_alpha_zero::Bool`: Flag indicating if `alpha` is zero.

# Returns
- `Restriction_Func`: A new instance of the `Restriction_Func` structure.

# Notes
- If `is_alpha_zero` is `false`, the function computes `bj` and modifies the restriction expression accordingly.
- Handles logical adjustments for inequalities by flipping signs when necessary.
"""
function Restriction_init(expr_str::String, point::Dict, restriction_type::RestrictionType,
    restriction_set_type::RestrictionSetType, miu::Number, beta::Number, lambda::Number, gamma::Number,
    alpha::Vector, ys_vars::Vector{Num}, is_alpha_zero::Bool)::Restriction_Func

    # Extract variable names from the expression
    vars_name::Vector{Symbol} = extract_variable_names(expr_str)

    # Register the variables in the symbolic environment
    add_to_symbolics(vars_name)

    # Separate the equation into left-hand and right-hand sides
    left, right = separate_equation(expr_str)

    # Create a new expression by subtracting the right-hand side from the left-hand side
    new_expr = left - right

    # Adjust inequalities by flipping signs when the restriction type indicates greater-than comparisons
    if restriction_type in [GtEq, Gt]  # For greater-than or greater-than-or-equal types
        new_expr = -new_expr
    end
    # Ajust in the equality case to the active index is Normal
    if restriction_type==Eq
        restriction_set_type=Normal
    end
    # Compute the `bj` vector if `alpha` is non-zero
    if !is_alpha_zero
        bj = compute_bj(new_expr, alpha, point, ys_vars, restriction_set_type, gamma)
        # Modify the restriction expression by adding the dot product of `bj` and `alpha` with `ys_vars`
        new_expr = new_expr + dot((bj * alpha), ys_vars)
    end

    # Evaluate the restriction at the given point
    value = eval_point(new_expr, point)

    # Compute the fixed value to add based on the restriction set type
    fix_value = Fix_value(value, restriction_set_type)
    
    # Update the expression with the add value
    new_expr=new_expr+fix_value
    # Return a new `Restriction_Func` object
    Restriction_Func(
        vars_name=vars_name,
        expr_str=expr_str,
        expr=new_expr,
        point=point,
        evaluation_value=value,
        add_const=fix_value,
        restriction_type=restriction_type,
        restriction_set_type=restriction_set_type,
        miu=miu,
        beta=beta,
        lambda=lambda,
        gamma=gamma
    )
end

# Utils methods

"""
Calculates the gradient of an expression with respect to a set of variables 
and evaluates the gradient at a specific point.

# Arguments:
- `func_expr`: The symbolic expression for which the gradient is calculated.
- `point::Dict`: A dictionary containing the values of the variables at the evaluation point.
- `vars_grad::Vector{Num}`: A vector of variables with respect to which the gradient will be calculated.

# Returns:
A vector representing the gradient of the expression evaluated at the given point.
"""
function calculate_grad_and_evaluate_in_point(func_expr, point::Dict, vars_grad::Vector{Num})::Vector
    # Compute the gradient of the expression with respect to the given variables
    grad = Symbolics.gradient(func_expr, vars_grad)
    # Substitute the values of the point into the gradient and return the result
    return substitute_point_in_vector(grad, point)
end

"""
Calculates the weighted sum of the gradients of constraints evaluated at a point, 
where each gradient is multiplied by its associated lambda.

# Arguments:
- `follower_restr::Vector{Restriction_Func}`: A vector containing the constraints, 
  each with its expression and associated lambda.
- `point::Dict`: A dictionary containing the values of the variables at the evaluation point.
- `vars_grad::Vector{Num}`: A vector of variables with respect to which the gradients will be calculated.

# Returns:
A vector representing the weighted sum of the gradients evaluated at the given point.
"""
function calculate_sum_grad_y_dot_lambda(follower_restr::Vector{Restriction_Func}, point::Dict, vars_grad::Vector{Num})::Vector
    # Initialize a zero vector with the size of the gradient variables
    temp = zeros(length(vars_grad))

    # Iterate over each constraint in the vector of constraints
    for restr::Restriction_Func in follower_restr
        # Get the lambda value associated with the constraint
        lambda = restr.lambda
        # Skip the current constraint if lambda is 0
        if lambda == 0
            continue
        end
        # Compute the gradient of the constraint and evaluate it at the point,
        # multiply it by lambda, and add it to the accumulated result
        temp += lambda * calculate_grad_and_evaluate_in_point(restr.expr, point, vars_grad)
    end

    # Return the resulting vector
    return temp
end

"""
Calculates the vector `bf` for the follower given the follower's function 
and active constraints.

# Arguments:
- `follower_fun::Func`: The follower's objective function.
- `follower_restrictions::Vector{Restriction_Func}`: A vector of the active constraints for the follower.
- `point::Dict`: A dictionary containing the values of the variables at the evaluation point.
- `ys_vars::Vector{Num}`: A vector of symbolic variables representing the follower's variables.

# Returns:
The `bf` vector for the follower as a negated sum of the gradient of the objective function 
and the weighted sum of the gradients of the constraints.
"""
function calculate_bf(follower_fun::Func, follower_restrictions::Vector{Restriction_Func}, point::Dict, ys_vars::Vector{Num})
    # Gradient of the follower's objective function evaluated at the point
    follower_eval = calculate_grad_and_evaluate_in_point(follower_fun.expr, point, ys_vars)

    # Weighted sum of the gradients of the follower's constraints evaluated at the point
    if !(isempty(follower_restrictions) || follower_restrictions === nothing)
        all_eval = calculate_sum_grad_y_dot_lambda(follower_restrictions, point, ys_vars)
        # Return the negated sum of the two computed vectors
        println("Va a retornar correctamente")
        return -(follower_eval + all_eval)
    end
    println("No hay restricciones del follower")
    return -follower_eval

end

"""
Initializes and fixes the constraints for both the leader and the follower, 
calculates the follower's `bf` vector, and sets up the optimization problem.

# Arguments:
- `Leader_str_expr::String`: The leader's objective function as a string.
- `leader_def_restrictions::Vector{Def_Restriction}`: A vector of the leader's defined constraints.
- `Follower_str_expr::String`: The follower's objective function as a string.
- `follower_def_restrictions::Vector{Def_Restriction}`: A vector of the follower's defined constraints.
- `point::Dict`: A dictionary containing the initial values of the variables.
- `lider_vars_str::Vector{String}`: A vector of strings representing the leader's variables.
- `follower_vars_str::Vector{String}`: A vector of strings representing the follower's variables.
- `alpha::Vector`: A vector `alpha` used in the constraints, representing the size of `ys_vars`.
- `is_alpha_zero::Bool`: `True` if `alpha` is zero; `False` otherwise.

# Returns:
An `Optimization_Problem` object initialized with the leader's and follower's functions, 
their respective constraints, the initial point, and the follower's `bf` vector.
"""
function Fix_Restrictions(Leader_str_expr::String,
    leader_def_restrictions::Union{Vector{Def_Restriction},Nothing},
    Follower_str_expr::String,
    follower_def_restrictions::Union{Vector{Def_Restriction},Nothing},
    point::Dict,
    lider_vars_str::Vector{String},
    follower_vars_str::Vector{String},
    alpha::Vector,
    is_alpha_zero::Bool
)
    # Convert follower variable strings to symbolic variables
    ys_vars::Vector{Num} = convert_Symbol_to_symbolic_num.(follower_vars_str)

    # Initialize the leader's function
    leader_fun = Func_init(Leader_str_expr, point, true)
    leader_restrictions::Vector{Restriction_Func} = []

    # Process the leader's constraints
    if leader_def_restrictions != nothing
        for item::Def_Restriction in leader_def_restrictions
            # Initialize each restriction with alpha treated as a zero vector
            temp::Restriction_Func = Restriction_init(item.expr_str, point, item.restriction_type,
                item.restriction_set_type, item.miu, item.beta,
                item.lambda, item.gamma, alpha, ys_vars, true)
            push!(leader_restrictions, temp)
        end
    end

    # Initialize the follower's function
    follower_fun = Func_init(Follower_str_expr, point, false)
    follower_restrictions::Vector{Restriction_Func} = []

    # Process the follower's constraints
    if follower_def_restrictions != nothing
        for item::Def_Restriction in follower_def_restrictions
            temp::Restriction_Func = Restriction_init(item.expr_str, point, item.restriction_type,
                item.restriction_set_type, item.miu, item.beta,
                item.lambda, item.gamma, alpha, ys_vars, is_alpha_zero)
            push!(follower_restrictions, temp)
        end
    end

    # Calculate the `bf` vector for the follower
    bf = calculate_bf(follower_fun, follower_restrictions, point, ys_vars)

    # Return the complete optimization problem
    return Optimization_Problem(leader_fun, leader_restrictions, follower_fun, follower_restrictions, point, bf)
end

function Fix_Restrictions(Leader_str_expr::String,
    leader_def_restrictions::Union{Vector{Def_Restriction},Nothing},
    Follower_str_expr::String,
    follower_def_restrictions::Union{Vector{Def_Restriction},Nothing},
    point::Dict,
    lider_vars::Vector{Symbolics.Num},
    follower_vars::Vector{Symbolics.Num},
    alpha::Vector,
    is_alpha_zero::Bool
)
    # Convert follower variable strings to symbolic variables
    ys_vars::Vector{Num} = follower_vars

    # Initialize the leader's function
    leader_fun = Func_init(Leader_str_expr, point, true)
    leader_restrictions::Vector{Restriction_Func} = []

    # Process the leader's constraints
    if leader_def_restrictions != nothing
        for item::Def_Restriction in leader_def_restrictions
            # Initialize each restriction with alpha treated as a zero vector
            temp::Restriction_Func = Restriction_init(item.expr_str, point, item.restriction_type,
                item.restriction_set_type, item.miu, item.beta,
                item.lambda, item.gamma, alpha, ys_vars, true)
            push!(leader_restrictions, temp)
        end
    end

    # Initialize the follower's function
    follower_fun = Func_init(Follower_str_expr, point, false)
    follower_restrictions::Vector{Restriction_Func} = []

    # Process the follower's constraints
    if follower_def_restrictions != nothing
        for item::Def_Restriction in follower_def_restrictions
            temp::Restriction_Func = Restriction_init(item.expr_str, point, item.restriction_type,
                item.restriction_set_type, item.miu, item.beta,
                item.lambda, item.gamma, alpha, ys_vars, is_alpha_zero)
            push!(follower_restrictions, temp)
        end
    end

    # Calculate the `bf` vector for the follower
    bf = calculate_bf(follower_fun, follower_restrictions, point, ys_vars)

    # Return the complete optimization problem
    return Optimization_Problem(leader_fun, leader_restrictions, follower_fun, follower_restrictions, point, bf)
end

# Export 
export Fix_Restrictions


