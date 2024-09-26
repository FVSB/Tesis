using Symbolics
using Random

# Definimos los tipos de restricciones y el conjunto de restricciones
@enum RestrictionType Eq Gt Lt GtEq LtEq

@enum RestrictionSetType Normal J_0_g J_0_LP_v J_0_L0_v J_Ne_L0_v

# Clase abstracta para las funciones
abstract type AbstractFunction end

# Clase para las funciones generales
struct Function <: AbstractFunction
    vars_::Vector{Symbol}
    func_str::String
    func_atomic
end

function FunctionFactory(var_names::Vector{String}, function_atomic::String)
    vars_ = [Symbol(var_name) for var_name in var_names]
    func_atomic = eval(Meta.parse(function_atomic))
    return Function(vars_, function_atomic, func_atomic)
end

function eval_function(func::Function, values::Vector{Float64})
    # Validamos que el número de variables coincida
    @assert length(values) == length(func.vars_)
    subs = Dict(var => val for (var, val) in zip(func.vars_, values))
    return substitute(func.func_atomic, subs)
end

# Clase para las funciones del problema
struct ProblemFunction <: AbstractFunction
    vars_lider::Vector{Symbol}
    vars_follower::Vector{Symbol}
    func_str::String
    func_atomic
    leader_level::Bool
end

function ProblemFunctionFactory(var_lider::Vector{String}, var_follower::Vector{String}, function_atomic::String, leader_level::Bool)
    all_vars = [var_lider ;var_follower]
    func = FunctionFactory(all_vars, function_atomic)
    return ProblemFunction(Symbol.(var_lider), Symbol.(var_follower), func.func_str, func.func_atomic, leader_level)
end

# Clase para las restricciones
struct RestrictionFunction <: AbstractFunction
    vars_::Vector{Symbol}
    func_str::String
    func_atomic
    left_part
    right_part
    const_add::Float64
    restriction_type::RestrictionSetType
end

function refactor_restriction(restriction::String, const_add_value::Float64)
    start = findfirst('(', restriction)
    relation = restriction[1:start-1]
    temp = split(restriction[start+1:end-1], ",")
    left = temp[1]
    right = temp[2]
    return "$relation(($left)-($right)-($const_add_value),0)"
end

function RestrictionFunction(var_names::Vector{String}, restriction::String, restriction_set_type::RestrictionSetType=Normal)
    vars_ = [Symbol(var_name) for var_name in var_names]
    const_add = 0.0
    refactored_restriction = refactor_restriction(restriction, const_add)
    func_atomic = eval(Meta.parse(refactored_restriction))
    left_part = lhs(func_atomic)
    right_part = rhs(func_atomic)
    return RestrictionFunction(vars_, refactored_restriction, func_atomic, left_part, right_part, const_add, restriction_set_type)
end

function eval_to_number(restriction::RestrictionFunction, values::Vector{Float64})
    subs = Dict(var => val for (var, val) in zip(restriction.vars_, values))
    return substitute(restriction.left_part, subs)
end

function _fix_eq0(restrictions::Vector{RestrictionFunction}, point::Vector{Float64})
    for restriction in restrictions
        if restriction.restriction_type == Normal
            continue
        end
        val = eval_to_number(restriction, point)
        if val != 0
            restriction.const_add = -val
        end
    end
end

function _fix_lt0(restrictions::Vector{RestrictionFunction}, point::Vector{Float64})
    for restriction in restrictions
        if restriction.restriction_type != J_Ne_L0_v
            continue
        end
        val = eval_to_number(restriction, point)
        if val >= 0
            restriction.const_add = -(val + rand())
        end
    end
end

# Clase para resolver el problema
struct Solver
    leader_function::ProblemFunction
    leader_restrictions::Vector{RestrictionFunction}
    follower_function::ProblemFunction
    follower_restrictions::Vector{RestrictionFunction}
    seed::Int
end

function Solver(leader_function::ProblemFunction, leader_restrictions::Vector{RestrictionFunction}, 
                follower_function::ProblemFunction, follower_restrictions::Vector{RestrictionFunction}, 
                seed::Int=123)
    Random.seed!(seed)
    return Solver(leader_function, leader_restrictions, follower_function, follower_restrictions, seed)
end

function evaluate_point(solver::Solver, point::Vector{Float64})
    leader_val = eval_function(solver.leader_function, point)
    follower_val = eval_function(solver.follower_function, point)

    _fix_eq0(solver.leader_restrictions, point)
    _fix_eq0(solver.follower_restrictions, point)
    _fix_lt0(solver.follower_restrictions, point)

    return leader_val, follower_val
end

function show_changes(solver::Solver)
    println("Imprimiendo los cambios:")
    println("Restricciones del líder:")
    for res in solver.leader_restrictions
        if res.const_add != 0
            println("$(res.func_str), constante: $(res.const_add)")
        end
    end

    println("Restricciones del seguidor:")
    for res in solver.follower_restrictions
        if res.const_add != 0
            println("$(res.func_str), constante: $(res.const_add)")
        end
    end
end

# Asumimos que ya se ha definido todo lo anterior, así que importamos las funciones necesarias
# usando . para importar desde el mismo archivo
# importamos desde el mismo archivo donde están las definiciones anteriores.

# Definición de las funciones a evaluar

l_1 = "Eq(((x_1--2)), 3)"

# Crear un solver
ProblemFunctionFactory(["x_1"], [" "], "x_1^2",true)

#solver = Solver(
#    ProblemFunction(["x_1"], [], "x_1^2", true),
#    [RestrictionFunction(["x_1"], "Eq(((x_1--2)), 3)", J_0_g)],
#    ProblemFunction(["x_1"], [], "x_1^2", false),
#    [RestrictionFunction(["x_1"], "Gt(((x_1--2)), 3)", J_Ne_L0_v)]
#)

# Evaluar el punto [22]
#leader_val,follower_val=evaluate_point(solver,[22])


# Mostrar los cambios
#show_changes(Solver)
