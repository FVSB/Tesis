
include("parser.jl")
push!(LOAD_PATH, @__DIR__)
#module ProblemFunction
using Symbolics
using ..MyParser
# Definir los enums 
# Definición del enum RestrictionType
@enum RestrictionType begin
    Eq
    Gt
    Lt
    GtEq
    LtEq
end

# Definición del enum RestrictionSetType
@enum RestrictionSetType begin
    Normal
    J_0_g
    J_0_LP_v
    J_0_L0_v
    J_Ne_L0_v
end

# Función para obtener la descripción de cada tipo
function description(rst::RestrictionSetType)
    descriptions = Dict(
        Normal => "Normal restriction",
        J_0_g => "Active in Leader",
        J_0_LP_v => "Active in Follower Lambda Positive",
        J_0_L0_v => "Active in Follower Lambda Zero",
        J_Ne_L0_v => "Negative in Follower Lambda Zero"
    )
    return get(descriptions, rst, "Unknown restriction")
end


"""
Genera un numero random mayor que cero y menor que uno
"""
function get_rand()
    epsilon = 1e-10
    rand()+epsilon
end

""""Dado el valor devuelve el valor necesario"""
function Fix_value(value::Num,restriction_set_type::RestrictionSetType)::Num
    if restriction_set_type in [Normal] # Es pq no esta en los J
        return 0
    end
    if restriction_set_type in [J_Ne_L0_v]
        if value<0 # Si el valor es menor que cero se cumple la condicion
            return value
        end
        return (value+get_rand())*-1 
    end 
    return value*-1
end

"""
    Func

Estructura abstracta que representa lo básico de una función.

# Campos
- `vars_name::Symbol`: Vector con el nombre de las variables de esta expresion.
- `expr_str::String`: La expresion que se va a entrar.
"""
@kwdef mutable struct Func
    vars_name::Vector{Symbol}
    expr_str::String
    expr
    point::Dict # De Num de symbolics a Float64
    evaluation_value::Num
    is_leader::Bool

end
# Inicializar
"""
Funcion que inicializa la struct Fun

"""
function Func_init(expr_str::String, point::Dict, is_leader::Bool)::Func
    # Tomar el nombre de las variables
    vars_name::Vector{Symbol} = MyParser.extract_variable_names(expr_str)
    # Registrar las variables
    MyParser.add_to_symbolics(vars_name)
    # Obtener la expresion
    expr = MyParser.parse_expression(expr_str)
    # Obtener Valor
    value = MyParser.eval_point(expr, point)
    # Obtener constante de aproximación
    #fix_value=Fix_value(value)

    a = Func(vars_name=vars_name, expr_str=expr_str, expr=expr, point=point, evaluation_value=value, is_leader=is_leader)
    return a
end


@kwdef mutable struct Restriction_Func
    vars_name::Vector{Symbol}
    expr_str::String
    expr
    point::Dict # De Num de symbolics a Float64
    evaluation_value::Num
    add_const::Num
    restriction_type::RestrictionType
    restriction_set_type::RestrictionSetType
end


"""
Crea una nueva restriccion
"""
function Restriction_init(expr_str::String, point::Dict, restriction_type::RestrictionType, restriction_set_type::RestrictionSetType)::Restriction_Func
    # Tomar el nombre de las variables
    vars_name::Vector{Symbol} = MyParser.extract_variable_names(expr_str)
    # Registrar las variables
    MyParser.add_to_symbolics(vars_name)
    # Obtener las expresiones
    left, rigth = MyParser.separate_equation(expr_str)
    #TODO: Despues añadir aca la logica para virar las inecuaciones
    # Nueva expresion de la ecuación
    new_expr = left - rigth
    # Obtener valor 
    value = MyParser.eval_point(new_expr, point)
    # Constante a añadir
    fix_value = Fix_value(value,restriction_set_type)

    Restriction_Func(vars_name=vars_name, expr_str=expr_str, expr=new_expr, point=point, evaluation_value=value, add_const=fix_value, restriction_type=restriction_type, restriction_set_type=restriction_set_type)

end
"""Estructura para guardar las expresiones de las restricciones"""
struct Def_Restriction
    expr_str::String
    restriction_set_type::RestrictionSetType
    restriction_type::RestrictionType
    is_leader::Bool
end

struct Optimization_Problem
    leader_fun::Func
    leader_restrictions::Vector{Restriction_Func}
    follower_fun::Func
    follower_restrictions::Vector{Restriction_Func}
end

function Fix_Restrictions(Leader_str_expr::String,leader_def_restrictions::Vector{Def_Restriction},Follower_str_expr::String,follower_def_restrictions::Vector{Def_Restriction},point::Dict)
    leader_fun=Func_init(Leader_str_expr,point,true)
    leader_restrictions::Vector{Restriction_Func}=[]
    for item::Def_Restriction in leader_def_restrictions
        
            temp::Restriction_Func=Restriction_init(item.expr_str,point,item.restriction_type,item.restriction_set_type)
            push!(leader_restrictions,temp)
    end

    follower_fun=Func_init(Follower_str_expr,point,false)
    follower_restrictions::Vector{Restriction_Func}=[]
    for item::Def_Restriction in follower_def_restrictions
        temp::Restriction_Func=Restriction_init(item.expr_str,point,item.restriction_type,item.restriction_set_type)
        push!(follower_restrictions,temp)
    end
    return Optimization_Problem(leader_fun,leader_restrictions,follower_fun,follower_restrictions)
end

## Example




#end