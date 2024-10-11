
include("parser.jl")
push!(LOAD_PATH,@__DIR__)
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

""""Dado el valor devuelve el valor necesario"""
function Fix_value(value::Num)::Num
    return -value
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
add_value::Num

end 
# Inicializar
"""
Funcion que inicializa la struct Fun

"""
function Func_init(expr_str::String,point::Dict)
    # Tomar el nombre de las variables
    vars_name::Vector{Symbol}=MyParser.extract_variable_names(expr_str)
    # Registrar las variables
    MyParser.add_to_symbolics(vars_name)
    # Obtener la expresion
    expr=MyParser.parse_expression(expr_str)
    # Obtener Valor
    value=MyParser.eval_point(expr,point)
    # Obtener constante de aproximación
    fix_value=Fix_value(value)

    a=Func(vars_name=vars_name,expr_str=expr_str,expr=expr,point=point,evaluation_value=value,add_value=fix_value)
    return a
end


a=Func_init("x_1+2",Dict("x_1" =>2))

println(a)

#end