
include("../def_problem/MiModulo.jl")
using Symbolics

using XLSX
using DataFrames

mutable struct Experiment
    model_alpha_non_zero::OptimizationModel
    model_alpha_zero::OptimizationModel
    leader_vars::Vector
    follower_vars::Vector
end

function CreateExperiment()
    alpha_::Vector{Number} = [1]
    return Experiment(GeneratorModel(alpha_), GeneratorModel(),Vector(),Vector())

end


macro leader_vars(experiment, args...)
    begin


        # Crear una expresión para evaluar la macro @variables con los argumentos proporcionados
        vars_expr = esc(:(@myvariables Upper(experiment.model_alpha_non_zero) $(args...)))
        vars_expr_2 = esc(:(@myvariables Upper(experiment.model_alpha_zero) $(args...)))
    end
    # Devolver una expresión para agregar las variables a vector_to_add
    quote
        new_vars = $vars_expr
        new_vars_2 = $vars_expr_2
        append!($experiment.leader_vars, new_vars)  # Agregar las variables al vector

        new_vars  # Retornar las nuevas variables creadas
    end
end

macro follower_vars(experiment, args...)
    begin


        # Crear una expresión para evaluar la macro @variables con los argumentos proporcionados
        vars_expr = esc(:(@myvariables Lower(experiment.model_alpha_non_zero) $(args...)))
        vars_expr_2 = esc(:(@myvariables Lower(experiment.model_alpha_zero) $(args...)))
    end
    # Devolver una expresión para agregar las variables a vector_to_add
    quote
        new_vars = $vars_expr
        new_vars_2 = $vars_expr_2
        append!($experiment.follower_vars, new_vars)  # Agregar las variables al vector

        new_vars  # Retornar las nuevas variables creadas
    end

end

function SetLeaderFunction(experiment::Experiment, expr::Symbolics.Num)
    SetObjectiveFunction(Upper(experiment.model_alpha_non_zero), expr)
    SetObjectiveFunction(Upper(experiment.model_alpha_zero), expr)
end

function SetLeaderRestriction(experiment::Experiment, expr::Symbolics.Num)
    _miu = get_rand()
    SetLeaderRestriction(experiment.model_alpha_non_zero, expr, J_0_g, _miu)
    SetLeaderRestriction(experiment.model_alpha_zero, expr, J_0_g, _miu)
end

function SetFollowerFunction(experiment::Experiment, expr::Symbolics.Num)
    SetObjectiveFunction(Lower(experiment.model_alpha_non_zero), expr)
    SetObjectiveFunction(Lower(experiment.model_alpha_zero), expr)
end

function SetFollowerRestriction(experiment::Experiment, expr::Symbolics.Num)
    _beta = get_rand()
    _lambda = get_rand()
    _gamma = get_rand()
    SetFollowerRestriction(experiment.model_alpha_non_zero, expr, J_0_LP_v, _beta, _lambda, _gamma)
    SetFollowerRestriction(experiment.model_alpha_zero, expr, J_0_LP_v, _beta, _lambda, _gamma)
end

"""
Funcion que dado un punto añade a cada componente un epsilon devuelve un nuevo diccionario
"""
function modify_point(point::Dict)::Dict
    _keys = keys(point)
    new_dict = Dict()
    for key in _keys
        temp = point[key]
        temp = temp + get_rand()
        new_dict[key] = temp
    end
    return new_dict
end

"""
Añades un punto para el experimento
"""
function SetPoint(experiment::Experiment, point::Dict)
    new_point = modify_point(point)
    SetPoint(experiment.model_alpha_non_zero, new_point)
    SetPoint(experiment.model_alpha_zero, new_point)
end
####################################
#                                  #
# Zona para serializar la data     #
#                                  #
####################################
"""
Crea un dataframe con el valor de las restricciones del lider
"""
function extract_data_from_leader_restriction(leader_restrictions::Vector{Restriction_Func})
    vec_expr::Vector{String} = Vector()
    vec_value::Vector{String} = Vector()
    vect_restr_set_type::Vector{String} = Vector()
    vect_miu::Vector{String} = Vector()

    for leader_restr in leader_restrictions
        # Extraer la info de cada Restricciones
        # La expresion modificada
        expr_modify = string(leader_restr.expr)
        push!(vec_expr, expr_modify)
        # Valor de la evaluacio
        value = string(leader_restr.evaluation_value)
        push!(vec_value, value)
        # Tipo de cjt de indice activo
        restriction_type_set = string(leader_restr.restriction_set_type)
        pushfirst!(vect_restr_set_type, restriction_type_set)
        # miu 
        _miu = string(leader_restr.miu)
        push!(vect_miu, _miu)
    end
    #Devolver el dataframe de las restricciones del lider
    println("Se va a crear el DataFrame")
    return DataFrame(
        Expression=vec_expr,
        Function_Evaluation=vec_value,
        Restriction_Set_Type=vect_restr_set_type,
        MIU_value=vect_miu
    )
end
"""
Se extrae el dataframe de las restriccioens del follower
"""
function  extract_data_from_follower_restriction(follower_restrictions::Vector{Restriction_Func})
    vec_expr::Vector{String} = Vector()
    vec_value::Vector{String} = Vector()
    vect_restr_set_type::Vector{String} = Vector()
    vect_lambda::Vector{String} = Vector()
    vect_beta::Vector{String}= Vector()
    vect_gamma::Vector{String}=Vector()
    for follower_restr in follower_restrictions
        # Extraer la info de cada Restricciones
        # La expresion modificada
        expr_modify = string(follower_restr.expr)
        push!(vec_expr, expr_modify)
        # Valor de la evaluacio
        value = string(follower_restr.evaluation_value)
        push!(vec_value, value)
        # Tipo de cjt de indice activo
        restriction_type_set = string(follower_restr.restriction_set_type)
        push!(vect_restr_set_type, restriction_type_set)
        # lambda
        _lambda=string(follower_restr.lambda)
        push!(vect_lambda,_lambda)
        #beta
        _beta=string(follower_restr.beta)
        push!(vect_beta,_beta)
        #_gamma
        _gamma=string(follower_restr.gamma)
        push!(vect_gamma,_gamma)

    end 
    return DataFrame(
        Expression=vec_expr,
        Function_Evaluation=vec_value,
        Restriction_Set_Type=vect_restr_set_type,
        Lambda_value=vect_lambda,
        Beta_value=vect_beta,
        Gamma_value=vect_gamma
    )
end

"""
Dado un Optimization Problem devuelve un Dataframe con las
expresiones de las funciones objetivo del nivel inferior y Superior

"""
function create_dataframe_obj_functions(opt_problem::Optimization_Problem)
    # Tomar el valor del leader
    leader_func=string(opt_problem.leader_fun.expr)
    # Tomar la expresion del Seguidor
    follower_func=string(opt_problem.follower_fun.expr)

   return DataFrame(
        Leader_Expr=leader_func,
        Follower_Expr=follower_func
    )

end
"""
 Funcion para expandir el dataframe un columna Debe pasarsed el nombre de la 
 variable y el vector
"""
function create_dataframe_by_add_colum(df,var_name::String,vector_to_add::Vector)
df[:, var_name]=vector_to_add
return df
end


"""
Se lleva a dataframe el valor del punto modificado,
"""
function create_dataframe_point(opt_problem::Optimization_Problem,x_s_vars::Vector,y_vars_Vector)
    df=DataFrame()
    # Tomar el punto
    point=opt_problem.point

    for x_s in x_s_vars
        # Convertir a string
       x_s= Num_to_String(x_s)
       df=create_dataframe_by_add_colum(df,x_s,[string(point[x_s])])
    end

    for x_s in y_vars_Vector
        # Convertir a string
       x_s= Num_to_String(x_s)
       df=create_dataframe_by_add_colum(df,x_s,[string(point[x_s])])
    end

    
    return df
end
"""
Dado un opt_problem y el vector BF se crea el dataframe a serializar
retorna un Vector en este orden [objt_df,leader_rest_df,follower_rest_df,point_df,bf_df,BF_df,_alpha_df]
"""
function create_dataframe(opt_problem::Optimization_Problem,_alpha::Vector{Number}, BF::Vector{Number},x_s_vars::Vector,y_vars_Vector)
# Crear Dataframe con las Funciones del Nivel Superior e inf
objt_df=create_dataframe_obj_functions(opt_problem)
# Crear df de restricciones nivel Superior
leader_rest_df=extract_data_from_leader_restriction(opt_problem.leader_restrictions)
# Crear df de restricciones del nivel inferior
follower_rest_df=extract_data_from_follower_restriction(opt_problem.follower_restrictions)
# Crear Dataframe del punto
point_df=create_dataframe_point(opt_problem,x_s_vars::Vector,y_vars_Vector)
# Crear el DataFrame_de_bf

_bf::Vector{String}=Num_to_String.(opt_problem.bf)
bf_df=DataFrame(vec_bf=_bf)
# Crear el Dataframe de BF
_BF::Vector{String}=Num_to_String.(BF)
BF_df=DataFrame(vec_BF=_BF)
# Crear DataFrame de alpha
_alpha::Vector{Number}=_alpha
_alpha_df=DataFrame(vec_alpha=_alpha)

return [objt_df,leader_rest_df,follower_rest_df,point_df,bf_df,BF_df,_alpha_df]
end

"""
Funcion para serializar en un documento 

"""

function serialize_in_xlsx(dfs::Vector,file_name::String)
    # El Vector de df es [objt_df,leader_rest_df,follower_rest_df,point_df,bf_df,BF_df,_alpha_df]
    sheet_names=["Funciones_Objetivo","Restricciones_del_lider","Restricciones_del_follower","Punto_modificado","Vector_bf","Vector_BF","Vector_Alpha"]
    all_name="$file_name.xlsx"
    # Comprobar que los vectores tienen la misma longitud
   # @assert length(sheet_names) == length(dfs) "Los vectores de nombres de hojas y DataFrames deben tener la misma longitud."
   

    if !isfile(all_name) # Si no existe creo y lo guardo
        
        XLSX.writetable(all_name, sheet_names[1] =>dfs[1],sheet_names[2] =>dfs[2],sheet_names[3] =>dfs[3],sheet_names[4] =>dfs[4],sheet_names[5] =>dfs[5],sheet_names[6] =>dfs[6],sheet_names[7] =>dfs[7]; overwrite=true )
        return all_name
    end
    
        # Eliminamos el archivo y volvemos a llamar al programa
       
        rm(all_name)
        return serialize_in_xlsx(dfs,file_name)
        
end
# Se manda a serializar el experimento  is_alpha_zero si es true es pq alpha es el vector Nulo
# caso contrario false no lo es
function serialize_Experiment(opt_problem::Optimization_Problem,_alpha::Vector{Number}, BF::Vector{Number},x_s_vars::Vector,y_vars_Vector::Vector,experiment_name::String,is_alpha_zero::Bool)
# Mandar a hacer los dfs
    dfs=create_dataframe(opt_problem,_alpha,BF,x_s_vars,y_vars_Vector)
    # Ahora mandar a serializar
    file_name=experiment_name * "alpha_non_zero"
    if is_alpha_zero
        file_name=experiment_name * "alpha_zero"
    end
    serialize_in_xlsx(dfs,file_name)
end

function RunExperiment(experiment::Experiment,experiment_name::String)
    length_y_vars::Int = length(experiment.follower_vars)
    _alpha=get_rand_vect(length_y_vars)
    SetAlpha(experiment.model_alpha_non_zero,_alpha )
    # Inicializar ambos experimentos
    
    opt_problem_non_zero, BF_non_zero = CreateProblem(experiment.model_alpha_non_zero)
    opt_problem_zero, BF_zero = CreateProblem(experiment.model_alpha_zero)
    
    x_vars=experiment.leader_vars
    y_vars=experiment.follower_vars

    dfs=create_dataframe(opt_problem_zero,_alpha,BF_zero,x_vars,y_vars)
    
    # Serializar el que _alpha no Nulo
    serialize_Experiment(opt_problem_non_zero,_alpha,BF_non_zero,x_vars,y_vars,experiment_name,false)
    # Serializar _alpha Nulo
    # Serializar _alpha Nulo
    _alpha::Vector{Number}=zeros(length_y_vars)
    serialize_Experiment(opt_problem_zero,_alpha,BF_zero,x_vars,y_vars,experiment_name,true)
    return dfs
end