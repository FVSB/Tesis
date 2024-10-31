
include("parser.jl")
push!(LOAD_PATH, @__DIR__)
module ProblemFunction
using Symbolics
using LinearAlgebra
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
export RestrictionType, Eq, Gt, Lt, GtEq, LtEq
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
export RestrictionSetType, Normal, J_0_g, J_0_L0_v, J_0_LP_v, J_Ne_L0_v, description

"""
Genera un numero random mayor que cero y menor que uno
"""
function get_rand()
    epsilon = 1e-10
    rand() + epsilon
end

""""Dado el valor devuelve el valor necesario"""
function Fix_value(value::Num, restriction_set_type::RestrictionSetType)::Num
    if restriction_set_type in [Normal] # Es pq no esta en los J
        return 0
    end
    if restriction_set_type in [J_Ne_L0_v]
        if value < 0 # Si el valor es menor que cero se cumple la condicion
            return value
        end
        return (value + get_rand()) * -1
    end
    return value * -1
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

function Base.show(io::IO,func::Func)
    vars_name = func.vars_name
    println("Nombre de variables: $vars_name ")
    expr_str = func.expr_str
    println("Expresion en str: $expr_str")
    expr = func.expr
    println("Expresion parseada $expr")
    point = func.point
    println("Punto a evaluar $point")
    evaluation_value = func.evaluation_value
    println("Valor de evaluacion $evaluation_value")
    is_leader = func.is_leader
    println("Es funcion lider $is_leader")

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
    #grad_expr # Expresion del gradiente una vez hallado el bj correspondiente
    #bj # Valor de bj que se calculó
    point::Dict # De Num de symbolics a Float64
    evaluation_value::Num
    add_const::Num
    restriction_type::RestrictionType
    restriction_set_type::RestrictionSetType
    miu::Number
    beta::Number
    lambda::Number
    gamma::Number
    
end


function Base.show(io::IO,restr_func::Restriction_Func)
    vars_name::Vector{Symbol} = restr_func.vars_name
    println("Nombre de variables: $vars_name ")
    expr_str::String = restr_func.expr_str
    println("Expresion en str: $expr_str")
    expr = restr_func.expr
    println("Expresion parseada $expr")
    point::Dict = restr_func.point
    println("Punto a evaluar $point")
    evaluation_value::Num = restr_func.evaluation_value
    println("Valor de evaluacion $evaluation_value")
    add_const::Num = restr_func.add_const
    println("Valor constante añadida $add_const")
    restriction_type::RestrictionType = restr_func.restriction_type
    println("Tipo de restriccion $restriction_type")
    restriction_set_type::RestrictionSetType = restr_func.restriction_set_type
    println("Cjt ind que pertenece $restriction_set_type")
    miu=restr_func.miu
    println("El valor de miu es $miu")
    beta=restr_func.beta
    println("El valor de Beta es $beta")
    lambda=restr_func.lambda
    println("El valor de lambda es $lambda")
    gamma=restr_func.gamma
    println("El valor de gamma es $gamma")



end

"""
Dada una restriccion de g activa halla su vector bj correspondiente

"""
function compute_bj(restriction_expr,
    alpha::Vector,
    point::Dict,
    ys_vars::Vector{Num},
    restriction_set_type::RestrictionSetType,gamma::Number)::Number

# Decir que si no son indices activos del follower no deben estar aca
if restriction_set_type in [Normal,J_0_g]
    return 0
end
# Hallar la norma de alpha
alpha_norm=norm(alpha)
 # Ver si la cant de variables y coincide con la dimension de alpha
ys_len=length(ys_vars)
alpha_len=length(alpha)
@assert ys_len==alpha_len "El length de alpha es $alpha_len y el de las ys es $ys_len y deben ser iguales"
# Calcular el gradiente de la restricción
grad_expr=Symbolics.gradient(restriction_expr,ys_vars)
# Hallar el valor del vector gradiente en el punto
vector_val=MyParser.substitute_point_in_vector(grad_expr,point)
# Calcular bj
if restriction_set_type == J_0_LP_v  # En este  caso gamma debe ser 0
    return dot(-vector_val,alpha)/alpha_norm
else # Si entonces lambda = 0
    return (dot(-vector_val,alpha)+gamma)/alpha_norm
end
# Retornar bj

end
"""
Crea una nueva restriccion
"""
function Restriction_init(expr_str::String, point::Dict, restriction_type::RestrictionType, restriction_set_type::RestrictionSetType, miu::Number,
    beta::Number,
    lambda::Number,
    gamma::Number,
    alpha::Vector,
    ys_vars::Vector{Num},
    )::Restriction_Func
    # Tomar el nombre de las variables
    vars_name::Vector{Symbol} = MyParser.extract_variable_names(expr_str)
    # Registrar las variables
    MyParser.add_to_symbolics(vars_name)
    # Obtener las expresiones
    left, rigth = MyParser.separate_equation(expr_str)
    # Nueva expresion de la ecuación
    new_expr = left - rigth
    # logica para virar las inecuaciones
    if restriction_type in [GtEq,Gt] # Si es de mayor o mayor e igual multiplicar por menos uno los miembros
     new_expr=-new_expr
     end
    
    # Ahora hallar su vector bj correspondiente
    bj=compute_bj(new_expr,alpha,point,ys_vars,restriction_set_type,gamma)
    gg=bj*alpha
    aa=dot((bj*alpha),ys_vars)
    println("El valor del vector para despues multiplicar es $gg")
    println("El valor del vector a sumar es $aa")
    # Mi nueva expresion es 
    new_expr=new_expr+dot((bj*alpha),ys_vars)
    # Obtener valor 
    value = MyParser.eval_point(new_expr, point)
    # Constante a añadir
    fix_value = Fix_value(value, restriction_set_type)

    Restriction_Func(vars_name=vars_name, expr_str=expr_str, expr=new_expr, point=point, evaluation_value=value, add_const=fix_value, restriction_type=restriction_type, restriction_set_type=restriction_set_type,miu=miu,beta=beta,lambda=lambda,gamma=gamma)

end
"""Estructura para guardar las expresiones de las restricciones"""
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

function Base.show(io::IO,obj::Def_Restriction)
    println("Mostrar las definiciones de las restricciones")
    println(repeat("-", 30))
    restriction_type=obj.restriction_type
    println("Tipo de restriccion $restriction_type")
    println(repeat("-", 30))
    restriction_type_set=obj.restriction_set_type
    println("Conjunto de indices al que pertenece $restriction_type_set ")
    println(repeat("-", 30))
    is_leader=obj.is_leader
    println("Es de la funcion lider $is_leader")
    println(repeat("-", 30))
    miu=obj.miu
    println("El valor de miu es $miu")
    println(repeat("-", 30))
    beta=obj.beta
    println("El valor de beta es $beta")
    println(repeat("-", 30))
    lambda=obj.lambda
    println("El valor de lambda es $lambda")
    println(repeat("-", 30))
    gamma=obj.gamma
    println("El valor de gamma es: $gamma")
    println(repeat("-", 30))
end



"""
Funcion contructor de las definiciones de restricciones
"""
function Def_Restriction_init(restriction_expr_str::String, restriction_set_type::RestrictionSetType,
    restriction_type::RestrictionType,
    is_leader::Bool,miu::Number,
    beta::Number,
    lambda::Number,
    gamma::Number
    )
    return Def_Restriction(restriction_expr_str, restriction_set_type, restriction_type, is_leader,miu,beta,lambda,gamma)
end


struct Optimization_Problem
    leader_fun::Func
    leader_restrictions::Vector{Restriction_Func}
    follower_fun::Func
    follower_restrictions::Vector{Restriction_Func}
    point::Dict
    bf::Vector # Vector que se computa al calcular grad y de f + sum lambda_i *  grad y v_i = vector 0
end

function Base.show(io::IO,obj::Optimization_Problem)
    println("Mostrar la funcion objetivo del lider")
    show(obj.leader_fun)
    println(repeat("-", 30))
    println("Mostrar las restricciones del lider")
    for (index, val) in enumerate(obj.leader_restrictions)
        println(repeat("+", 30))
        println("Restriccion $index")
        show(val)
        println(repeat("+", 30))
    end
    println(repeat("-", 30))
    println("Mostrar funcion del follower")
    show(obj.follower_fun)
    println(repeat("-", 30))
    println("Mostrar las restricciones del follower")
    for (index, val) in enumerate(obj.follower_restrictions)
        println(repeat("+", 30))
        println("Restriccion $index")
        show(val)
        println(repeat("+", 30))
    end
    println(repeat("-", 30))
    point=obj.point
    println("Evaluar en el punto $point")
    println(repeat("-", 30))
    println("_")


end
"""
Dada una expresion un punto y las variables a derivar hallar el gradiente de esa expresion y la evalua en el puntio
"""
function calculate_grad_and_evaluate_in_point(func_expr,point::Dict,vars_grad::Vector{Num})::Vector
grad=Symbolics.gradient(func_expr,vars_grad)
return MyParser.substitute_point_in_vector(grad,point)
end

"""
Dadas las restricciones el punto y las variables a calcular el gradiente 
halla los gradientes de cada restriccion en ese punto evaluado y despues multiplica por el despues se suma todo (Cada uno multiplicasdo por su lambda)
"""
function calculate_sum_grad_y_dot_lambda(follower_restr::Vector{Restriction_Func},point::Dict,vars_grad::Vector{Num})::Vector
    temp=zeros(length(vars_grad))
    for restr::Restriction_Func in follower_restr
        lambda=restr.lambda
        if lambda==0
            continue
        end
        temp+=lambda* calculate_grad_and_evaluate_in_point(restr.expr,point,vars_grad)
    end
    return temp
end

"""
Dado la funcion del follower y las restricciones activas se calcula el vector bf del follower
"""
function calculate_bf(follower_fun::Func,follower_restrictions::Vector{Restriction_Func},point::Dict,ys_vars::Vector{Num})
# Gradiente del follower
follower_eval=calculate_grad_and_evaluate_in_point(follower_fun.expr,point,ys_vars)

all_eval=calculate_sum_grad_y_dot_lambda(follower_restrictions,point,ys_vars)

return -(follower_eval+all_eval)

end


function Fix_Restrictions(Leader_str_expr::String,
     leader_def_restrictions::Vector{Def_Restriction},
      Follower_str_expr::String,
       follower_def_restrictions::Vector{Def_Restriction},
       point::Dict,
       lider_vars_str::Vector{String},
       follower_vars_str::Vector{String},
       alpha::Vector, # Vector alpha de dimension cantidad de valores de y
       is_alpha_zero::Bool # True si alpha es zero False si no lo es
        )
    
    ys_vars::Vector{Num}=MyParser.convert_Symbol_to_symbolic_num.(follower_vars_str)
    # Lider
    leader_fun = Func_init(Leader_str_expr, point, true)
    leader_restrictions::Vector{Restriction_Func} = []
    for item::Def_Restriction in leader_def_restrictions # Arreglar las restricciones del lider
        
        temp::Restriction_Func = Restriction_init(item.expr_str, point, item.restriction_type, item.restriction_set_type,item.miu,item.beta,item.lambda,item.gamma,alpha,ys_vars)
        push!(leader_restrictions, temp)
    end
    # Follower
    follower_fun = Func_init(Follower_str_expr, point, false) 
    follower_restrictions::Vector{Restriction_Func} = []
    for item::Def_Restriction in follower_def_restrictions # Arreglar las restricciones del follower
        temp::Restriction_Func = Restriction_init(item.expr_str, point, item.restriction_type, item.restriction_set_type,item.miu,item.beta,item.lambda,item.gamma,alpha,ys_vars)
        push!(follower_restrictions, temp)
    end
    if is_alpha_zero # Si alpha es numericamente cero no se calcula el vector BF
        return Optimization_Problem(leader_fun, leader_restrictions, follower_fun, follower_restrictions,point,zeros(length(ys_vars)))
    end
        bf=calculate_bf(follower_fun,follower_restrictions,point,ys_vars)
    return Optimization_Problem(leader_fun, leader_restrictions, follower_fun, follower_restrictions,point,bf)
end

# Export

export Optimization_Problem, Fix_Restrictions, Def_Restriction, Def_Restriction_init, Func, Restriction_Func, RestrictionSetType, RestrictionType, description

end