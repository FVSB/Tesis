
using Symbolics
include("model.jl")
#module MiModulo
include("model.jl")
include("solver.jl")
using Symbolics

function copy(vector_receptor::Vector{Symbolics.Num}, vector_sender::Vector{Symbolics.Num})
    for i in 1:length(vector_sender)
        push!(vector_receptor, vector_sender[i])
    end
end

#macro myvariables(args...)
#    return   # Usar esc para mantener el contexto
#end

using Symbolics

macro myvariables(problem, args...)

    # Crear una expresión para evaluar la macro @variables con los argumentos proporcionados
    vars_expr = esc(:(Symbolics.@variables $(args...)))

    # Devolver una expresión para agregar las variables a vector_to_add
    quote
        new_vars = $vars_expr
        append!($problem.vars, new_vars)  # Agregar las variables al vector
        new_vars  # Retornar las nuevas variables creadas
    end
end





function Num_to_Expr(val::Symbolics.Num)
    return Symbolics.toexpr(val)
end

function Num_to_String(val::Symbolics.Num)

    return string(val)

end

function Num_to_funct_string(val::Symbolics.Num)
    # Convertirlo a String
    # Despues devolver el tipo ecuacion o inecuacion
    to_str = Num_to_String(val)
    # Separar y conocer que tipo expresion esc
    rest_types = Dict("==" => Eq, "<=" => LtEq, ">=" => GtEq, "<" => Lt, ">" => Gt)
    for substring in ["==", "<=", ">=", "<", ">"]
        if occursin(substring, to_str)
            # Si ocurre eso entonces mandar 
            t = rest_types[substring]
            # Cambiar eso por ==
            result = replace(to_str, substring => "==")
            # Devuelve primero el string y despues el tipo
            return (result, t)
        end
    end


end
function LeaderRestriccionConvert(model::OptimizationModel)
    # Verificar si el vector esta vacio para devolver nothing
    if isempty(model.leaders_restriction)
        return Vector{Def_Restriction}()
    end
    temp::Vector{Def_Restriction} = Def_Restriction[]
    for restriction::LeaderRestrictionProblem in model.leaders_restriction

        rest_str, type_restriction = Num_to_funct_string(restriction.expr)
        a = Def_Restriction_init(rest_str, restriction.restriction_set_type, type_restriction, true, restriction._miu, 0, 0, 0)
        push!(temp, a)
    end
    return temp
end

function FollowerRestrictionsConvert(model::OptimizationModel)
    # Verificar si el vector esta vacio para devolver nothing
    if isempty(model.follower_restriction_problem)
        return Vector{Def_Restriction}()
    end
    temp::Vector{Def_Restriction} = Def_Restriction[]
    for restriction::FollowerRestrictionProblem in model.follower_restriction_problem

        rest_str, type_restriction = Num_to_funct_string(restriction.expr)
        a = Def_Restriction_init(rest_str, restriction.restriction_set_type, type_restriction, false, 0, restriction._beta, restriction._lambda, restriction._gamma)
        push!(temp, a)
    end
    return temp
end

"""
Dado un problema y un punto genera el nuevo problema donde el punto es estacionario de la clase 
dependiente de los multiplicadores
"""
function CreateProblem(model::OptimizationModel)::Tuple{Optimization_Problem,Vector{Number}}
    leader_obj_str::String = Num_to_String(model.leader_problem.expr)
    leader_restrictions::Vector{Def_Restriction} = LeaderRestriccionConvert(model)
    leader_vars::Vector{Symbolics.Num} = model.leader_problem.vars
    follower_obj_str::String = Num_to_String(model.follower_problem.expr)
    follower_restrictions::Vector{Def_Restriction} = FollowerRestrictionsConvert(model)
    follower_vars::Vector{Symbolics.Num} = model.follower_problem.vars
    _alpha::Vector{Number} = model._alpha
    is_alpha_null::Bool = model.is_alpha_zero
    point::Dict = transformar_llaves(model.point, Num_to_String)


    opt_problem = Fix_Restrictions(leader_obj_str, leader_restrictions, follower_obj_str, follower_restrictions, point, leader_vars, follower_vars, _alpha, is_alpha_null)
    println(opt_problem)
    if is_alpha_null
        _alpha=zeros(length(follower_vars))
    end
    BF_Vector = Make_BF(opt_problem, leader_vars, follower_vars, _alpha)
    println(BF_Vector)

    return (opt_problem, BF_Vector)

end


#export myvariables,OptimizationModel,Problem,GeneratorModel  # Exportar la macro para que sea accesible fuera del módulo

#end
