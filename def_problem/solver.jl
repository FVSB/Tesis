# Import
# Import module to Fix_Restrictions
include("fix_restrictions.jl")

"""
Computes the gradient of a vector of symbolic functions with respect to a set of symbolic variables.

# Arguments
- `funcs::Vector{Num}`: A vector of symbolic expressions representing the functions to differentiate.
- `vars::Vector{Num}`: A vector of symbolic variables with respect to which the gradient is computed.

# Returns
- `Vector{Vector{Num}}`: A vector where each element is the gradient of the corresponding function in `funcs` with respect to `vars`.
"""
function gradient_from_vector_func(funcs::Vector{Num}, vars::Vector{Num})
    resp = []
    for item in funcs
        push!(resp, Symbolics.gradient(item, vars))
    end
    return resp
end

"""
Calculates the gradient of the leader function (F) with respect to problem variables and evaluates it at a given point.

# Arguments
- `opt_problem::Optimization_Problem`: A struct representing the optimization problem, containing the leader's function, constraints, and the evaluation point.
- `problem_vars::Vector{Num}`: A vector of symbolic variables representing the problem's variables.

# Returns
- `Vector{Num}`: The gradient of the leader function evaluated at the provided point.
"""
function calculate_diff_F_xy(opt_problem::Optimization_Problem, problem_vars::Vector{Num})
    leader_fun = opt_problem.leader_fun
    leader_expr = leader_fun.expr
    grad_F = gradient_from_vector_func([leader_expr], problem_vars)[1]
    grad_val = substitute_point_in_vector(grad_F, opt_problem.point)
    return grad_val
end

"""
Defines factor types used in constraints: miu, lambda, beta, and alpha.
"""
@enum FactorType begin
    miu_
    lambda_
    beta_
    alpha_
end

"""
Retrieves the factor value associated with a given constraint and factor type.

# Arguments
- `restr_func::Restriction_Func`: A struct representing the constraint.
- `factor_type::FactorType`: The type of factor to retrieve (e.g., `miu_`, `lambda_`).

# Returns
- `Float64`: The value of the specified factor for the given constraint.

# Throws
- `ArgumentError`: If the factor type is invalid.
"""
function get_factor_value(restr_func::Restriction_Func, factor_type::FactorType)
    if factor_type == miu_
        return restr_func.miu
    elseif factor_type == lambda_
        return restr_func.lambda
    elseif factor_type == beta_
        return restr_func.beta
    else
        throw(ArgumentError("The factor type $factor_type is invalid"))
    end
end

"""
Calculates the weighted summation of constraint gradients, where each gradient is multiplied by its corresponding factor.

# Arguments
- `restrictions::Vector{Restriction_Func}`: A vector of constraint structures.
- `problem_vars::Vector{Num}`: A vector of symbolic variables.
- `point::Dict`: A dictionary mapping variables to their values for evaluation.
- `factor_type::FactorType`: The type of factor to multiply with each constraint.

# Returns
- `Vector{Num}`: The summation of the gradients of the constraints, weighted by their factors, evaluated at the given point.
"""
function calculate_grad_xy_restr_dot_factor(restrictions::Vector{Restriction_Func}, problem_vars::Vector{Num}, point::Dict, factor_type::FactorType)::Vector{Num}
    vector_value = zeros(length(problem_vars))
    for restriction in restrictions
        restr_expr = restriction.expr
        grad_restriction = Symbolics.gradient(restr_expr, problem_vars)
        vector_result = substitute_point_in_vector(grad_restriction, point)
        factor = get_factor_value(restriction, factor_type)
        vector_result *= factor
        vector_value += vector_result
    end
    return vector_value
end

"""
Calculates the summation of active constraints' gradients, each weighted by its `miu` factor.

# Arguments
- `opt_problem::Optimization_Problem`: The optimization problem containing constraints, functions, and evaluation point.
- `problem_vars::Vector{Num}`: A vector of symbolic variables representing the problem's variables.

# Returns
- `Vector{Num}`: The summation of active gradients weighted by their `miu` factors.
"""
function calculate_g_s_active_mui_factor(opt_problem::Optimization_Problem, problem_vars::Vector{Num})::Vector{Num}
    restrictions = opt_problem.leader_restrictions
    point = opt_problem.point
    return calculate_grad_xy_restr_dot_factor(restrictions, problem_vars, point, miu_)
end

"""
Calculates the summation of constraint gradients from the follower level, each weighted by its `beta` factor.

# Arguments
- `opt_problem::Optimization_Problem`: The optimization problem containing follower constraints and the evaluation point.
- `problem_vars::Vector{Num}`: A vector of symbolic variables representing the problem's variables.

# Returns
- `Vector{Num}`: The weighted summation of follower constraint gradients by their `beta` factors.
"""
function calculate_sum_vj_bj(opt_problem::Optimization_Problem, problem_vars::Vector{Num})
    follower_restr = opt_problem.follower_restrictions
    point = opt_problem.point
    return calculate_grad_xy_restr_dot_factor(follower_restr, problem_vars, point, beta_)
end

"""
Calculates the mixed derivatives of a function with respect to problem variables and lower-level variables.

# Arguments
- `func_expr::Num`: The symbolic expression of the function to differentiate.
- `vars::Vector{Num}`: Problem variables for the second gradient computation.
- `vars_y::Vector{Num}`: Lower-level variables for the first gradient computation.
- `point::Dict`: A dictionary mapping variables to their values for evaluation.

# Returns
- `Matrix{Num}`: A matrix of second-order derivatives, evaluated at the given point.
"""
function Calculate_diff_ys_xsys(func_expr::Num, vars::Vector{Num}, vars_y::Vector{Num}, point::Dict)
    A = Symbolics.gradient(func_expr, vars_y)
    grad_matrix = [Symbolics.gradient(A[i, j], vars) for i in 1:size(A, 1), j in 1:size(A, 2)]
    concat_matrix = hcat(grad_matrix...)
    return substitute_point_in_vector(concat_matrix, point)
end

"""
Computes the weighted sum of derivatives for selected constraints with respect to variables and weights.

# Arguments
- `opt_problem::Optimization_Problem`: The optimization problem containing constraints and evaluation point.
- `problems_vars::Vector{Num}`: Problem variables for gradient computation.
- `ys_vars::Vector{Num}`: Lower-level variables to consider in the computation.
- `alpha::Vector`: Weights for each lower-level variable.

# Returns
- `Matrix{Num}`: The weighted sum of derivatives for selected constraints.
"""
function calculate_select_vi_der_xy_of_x_dot_lambda_alpha(opt_problem::Optimization_Problem, problems_vars::Vector{Num}, ys_vars::Vector{Num}, alpha::Vector)
    ys_len = length(ys_vars)
    alpha_len = length(alpha)
    @assert ys_len == alpha_len "Alpha length is $alpha_len, while ys length is $ys_len. They must match."
    point = opt_problem.point
    A = zeros(length(problems_vars), ys_len)
    for vi in opt_problem.follower_restrictions
        vi_expr = vi.expr
        vi_grad_val = Calculate_diff_ys_xsys(vi_expr, problems_vars, ys_vars, point)
        lambda_i = vi.lambda
        A += vi_grad_val * lambda_i
    end
    # Add der xy der y follower  and add to A matrix
    A +=Calculate_diff_ys_xsys(opt_problem.follower_fun.expr,problems_vars,ys_vars,point)
    return A * alpha
end

"""
Calculates the BF vector for a bi-level optimization problem. This vector combines gradients and weighted derivatives 
of the leader's and follower's functions and constraints, using a weighting vector `alpha`.

# Arguments
- `opt_problem::Optimization_Problem`: The bi-level optimization problem containing the leader's and follower's functions, constraints, and evaluation point.
- `leader_vars_str::Vector{String}`: Vector of variable names (as strings) corresponding to the leader.
- `follower_vars_str::Vector{String}`: Vector of variable names (as strings) corresponding to the follower.
- `alpha::Vector`: A weighting vector of the same length as the follower variables `ys`.

# Returns
- `Vector`: The computed BF vector as a result of the combined calculations of gradients and constraints.

# Process
1. Concatenate the leader's and follower's variables.
2. Convert all variables to symbolic representations.
3. Compute and evaluate the gradient of the leader's function at the given point.
4. Compute the weighted sum of active constraints' gradients for the leader, multiplied by their `miu` factors.
5. Compute the mixed derivatives of selected follower constraints, weighted by their `lambda` factors and the provided `alpha`.
6. Compute the weighted sum of inactive follower constraints, multiplied by their `beta` factors.
7. Return the BF vector as the negative sum of these components.
"""
function Make_BF(
    opt_problem::Optimization_Problem,
    leader_vars_str::Vector{String},
    follower_vars_str::Vector{String},
    alpha::Vector
)::Vector
    # Combine leader and follower variable names into a single string vector
    problem_vars_str::Vector{String} = vcat(leader_vars_str, follower_vars_str)
    
    # Convert all problem variables to symbolic representations
    problem_vars = map(convert_Symbol_to_symbolic_num, problem_vars_str)
    
    # Convert follower variables to symbolic representations
    follower_vars = map(convert_Symbol_to_symbolic_num, follower_vars_str)
    
    # Compute the gradient of the leader's function and evaluate it
    f_grad = calculate_diff_F_xy(opt_problem, problem_vars)
    
    # Compute the weighted sum of the active leader constraints' gradients, multiplied by `miu`
    g_s_sum = calculate_g_s_active_mui_factor(opt_problem, problem_vars)
    
    # Compute the mixed derivatives of selected follower constraints, weighted by `lambda` and `alpha`
    vi_val = calculate_select_vi_der_xy_of_x_dot_lambda_alpha(opt_problem, problem_vars, follower_vars, alpha)
    
    # Compute the weighted sum of inactive follower constraints, weighted by `beta`
    vj_bj_sum = calculate_sum_vj_bj(opt_problem, problem_vars)
    
    # Return the BF vector as the negative sum of all computed components
    return -(f_grad + g_s_sum + vi_val + vj_bj_sum)
end
