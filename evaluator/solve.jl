include("parser.jl")
include("function.jl")
push!(LOAD_PATH, @__DIR__)

using ..ProblemFunction
using Symbolics

"""
Dado un vector y las variables a elegir da el gradiente del vector con respecto a dichas variables
"""
function gradient_from_vector_func(funcs::Vector{Num},vars::Vector{Num})
    resp=[]
    for item in funcs
        push!(resp,ProblemFunction.Symbolics.gradient(item,vars))
    end
    return resp
end

"""
Calcula la derivada de F con respecto x,y  y lo evalua
"""
function calculate_diff_F_xy(opt_problem::Optimization_Problem,problem_vars::Vector{Num})
    # Obtener la struct Func del lider
    leader_fun=opt_problem.leader_fun
    # Obtener la expr de la funcion del lider
    leader_expr=leader_fun.expr
    # Hallar el gradiente de F
    grad_F=gradient_from_vector_func([leader_expr],problem_vars)[1]
    # Sustituir el gradiente en el punto
    grad_val=MyParser.substitute_point_in_vector(grad_F,opt_problem.point)
    return grad_val

end

"""
Devuelve el vector resultante de la suma de la suma de (diff g_i por miu_i)
"""
function calculate_g_s_active_mui_factor(opt_problem::Optimization_Problem,problem_vars::Vector{Num})::Vector{Num}
    vector_value=zeros(length(problem_vars))
    for g in opt_problem.leader_restrictions
        # Ahora debe sacar su expresion
        g_expr=g.expr
        grad_g=ProblemFunction.Symbolics.gradient(g_expr,problem_vars)
        vector_result=MyParser.substitute_point_in_vector(grad_g,opt_problem.point)
        vector_result=vector_result*g.miu
        vector_value+=vector_result
    end
    return vector_value

end

"""
Dada la expr de una funcion, las variables del problema y las del nivel inferior calcula la derivada de esto
respecto a las ys y despues vector gradiente respecto a las xs y ys
"""

function Calculate_diff_ys_xsys(func_expr::Num,vars::Vector{Num},vars_y::Vector{Num},point::Dict)
    A=Symbolics.gradient(func_expr,vars_y)
    # Calcular el gradiente de cada expresión en la matriz
    grad_matrix = [Symbolics.gradient(A[i, j], vars) for i in 1:size(A, 1), j in 1:size(A, 2)]
    concat_matrix= hcat(grad_matrix...)
    return MyParser.substitute_point_in_vector(concat_matrix,opt_problem.point)
end

function calculate_select_vi_der_xy_of_x_dot_lambda_alpha(opt_problem::ProblemFunction.Optimization_Problem,index_vi::Int64,problems_vars::Vector{Num},ys_vars::Vector{Num},alpha::Vector)
    # Ver si la cant de variables y coincide con la dimension de alpha
    ys_len=length(ys_vars)
    alpha_len=length(alpha)
    @assert ys_len==alpha_len "El length de alpha es $alpha_len y el de las ys es $ys_len y deben ser iguales"
    # Tomar la restriccion que se quiere
    vi=opt_problem.follower_restrictions[index_vi]
    # Tomar la expresion de la funcion de restriccion
    vi_expr=vi.expr
    println(vi_expr)
    # Tomar el punto a evaluar
    point=opt_problem.point
    # Calcular y evaluar el gradiente 
    vi_grad_val=Calculate_diff_ys_xsys(vi_expr,problems_vars,ys_vars,point)
    # Tomar el lambda de ese restriccion
    lambda_i=vi.lambda
    # Multiplicar el gradiente evaluado por lambda
    vi_lambda=vi_grad_val*lambda_i
    # Multiplicar Todo por alpha
    return vi_lambda*alpha
    
    
    end

function Make_BF(lider_vars_str::Vector{String},leader_func_str::String,leader_restrictions::Vector{Def_Restriction},follower_vars_str::Vector{String},follower_func_str::String,follower_restrictions::Vector{Def_Restriction},point::Dict,alpha::Vector,index_vi::Int64)
    # Concatenar las variables del lider y las del follower en un vector de str
    problem_vars_str::Vector{String}=vcat(lider_vars_str,follower_vars_str)
    # Hacer las variables del problema simbolicas
    problem_vars=map(ProblemFunction.convert_Symbol_to_symbolic_num,problem_vars_str)
    # Hacer simbolicas las variables del follower
    follower_vars=map(ProblemFunction.convert_Symbol_to_symbolic_num,follower_vars_str)
    # Ajustar las restricciones para que el punto sea factible
    opt_problem=Fix_Restrictions(leader_func_str,leader_restrictions,follower_func_str,follower_restrictions,point)
    # Calcular y evaluar la F
    f_grad=calculate_diff_F_xy(opt_problem,problem_vars)
    # Calcular la sumatoria de los gradientes de las gs mult por su miu 
    g_s_sum=calculate_g_s_active_mui_factor(opt_problem,problem_vars)
    # Calcular f der por y y despues por xy multiplicado por su lambda y despues por alpha
    vi_val=calculate_select_vi_der_xy_of_x_dot_lambda_alpha(opt_problem,index_vi,problem_vars,follower_vars,alpha)
    # Calcular la sumatoria de vector de vj 
    
end