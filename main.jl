using Random
using SymPy

# Definición de tipos de restricciones
@enum RestrictionType Eq Gt Lt GtEq LtEq

# Definición de conjuntos de restricciones
@enum RestrictionSetType Normal J_0_g J_0_LP_v J_0_L0_v J_Ne_L0_v

# Clase base para funciones
abstract type Function end

struct FunctionBase <: Function
    vars_
    func_str
    func_atomic

    function FunctionBase(var_names::Vector{String}, function_atomic::String)
        vars_ = sympy(var_names)
        func_str = function_atomic
        func_atomic = sympify(func_str)
        return new(vars_, func_str, func_atomic)
    end

    function eval(self, values::Vector{Float64})
        @assert length(values) == length(self.vars_)
        subs = Dict(zip(self.vars_, values))
        return self.func_atomic.subs(subs)
    end
end

# Clase para funciones de problema
struct ProblemFunction <: Function
    vars_::Vector{String}
    func_base::FunctionBase

    function ProblemFunction(var_leader::Vector{String}, var_follower::Vector{String}, function_atomic::String, leader_level::Bool=true)
        func_base = FunctionBase(vcat(var_leader, var_follower), function_atomic)
        return new(var_leader, func_base)
    end

    function eval(self, values::Vector{Float64})
        
        return self.func_base.eval(values)
    end
end

# Clase para funciones de restricción
struct RestrictionFunction <: Function
    const_add::Float64
    original_str_restriction::String
    restriction_type::RestrictionSetType
    left_part
    right_part

    function RestrictionFunction(var_names::Vector{String}, restriction::String, restriction_set_type::RestrictionSetType=RestrictionSetType.Normal)
        const_add = 0.0
        original_str_restriction = restriction
        refactored_restriction = refactor_restriction(restriction)
        return new(const_add, original_str_restriction, restriction_set_type, refactored_restriction.lhs, refactored_restriction.rhs)
    end

    function refactor_restriction(restriction::String)
        start = findfirst(==( '('), restriction)
        relation = restriction[1:start-1]
        temp = split(restriction[start+1:end-1], ",")
        left = temp[1]
        right = temp[2]
        return "$(relation)((($left)-($right)-($const_add)),0)"
    end

    function eval_to_number(self, values::Vector{Float64})
        @assert length(values) == length(self.vars_)
        subs = Dict(zip(self.vars_, values))
        lhs = self.left_part
        return lhs.subs(subs)
    end
end

# Funciones auxiliares para ajustar restricciones
function fix_eq0(restrictions::Vector{RestrictionFunction}, point::Vector{Float64})
    for restriction in restrictions
        if restriction.restriction_type == RestrictionSetType.Normal
            continue
        end
        if !(restriction.restriction_type in [RestrictionSetType.J_0_g, RestrictionSetType.J_0_L0_v, RestrictionSetType.J_0_LP_v])
            continue
        end
        val = restriction.eval_to_number(point)
        if val == 0
            continue
        end
        restriction.const_add_value = -val
    end
end

function fix_lt0(restrictions::Vector{RestrictionFunction}, point::Vector{Float64})
    for restriction in restrictions
        if restriction.restriction_type == RestrictionSetType.Normal
            continue
        end
        if !(restriction.restriction_type in [RestrictionSetType.J_Ne_L0_v])
            continue
        end
        val = restriction.eval_to_number(point)
        if val < 0
            continue
        end
        restriction.const_add_value = -val - rand()
    end
end

# Clase para el solucionador
struct Solver
    leader_function::ProblemFunction
    leader_restrictions::Vector{RestrictionFunction}
    follower_function::ProblemFunction
    follower_restrictions::Vector{RestrictionFunction}
    seed::Int

    function Solver(leader_function::ProblemFunction, leader_restrictions::Vector{RestrictionFunction}, follower_function::ProblemFunction, follower_restrictions::Vector{RestrictionFunction}, seed::Int=123)
        return new(leader_function, leader_restrictions, follower_function, follower_restrictions, seed)
    end

    function evaluate_point(self, point::Vector{Float64})
        leader_val = self.leader_function.eval(point)
        follower_val = self.follower_function.eval(point)

        fix_eq0(self.leader_restrictions, point)
        fix_eq0(self.follower_restrictions, point)
        fix_lt0(self.follower_restrictions, point)

        return (leader_val, follower_val)
    end

    function show_changes(self)
        println("Printing the changes")
        println("Leader restrictions")
        for l_res in self.leader_restrictions
            if l_res.const_add != 0
                println("$l_res the constant is $l_res.const_add")
            end
        end
        println("Follower restrictions")
        for f_res in self.follower_restrictions
            if f_res.const_add != 0
                println("$f_res the constant is $f_res.const_add")
            end
        end
    end
end

# Función principal para ejecutar el solver
function maain()
    l_1 = "Eq(((x_1--2)),3)"

    solver = Solver(
        ProblemFunction(["x_1"], String[], "x_1^2", true),  # Cambiar x_1**2 por x_1^2
        [RestrictionFunction(["x_1"], l_1, RestrictionSetType.J_0_g)],
        ProblemFunction(["x_1"], String[], "x_1^2", false),  # Cambiar x_1**2 por x_1^2
        [RestrictionFunction(["x_1"], "Gt(((x_1--2)),3)", RestrictionSetType.J_Ne_L0_v)]
    )

    leader_val, follower_val = solver.evaluate_point([22.0])  # Cambiar [22] por [22.0]
    println("Leader Value: $leader_val")
    println("Follower Value: $follower_val")

    solver.show_changes()
end

# Ejecutar la función principal
maain()