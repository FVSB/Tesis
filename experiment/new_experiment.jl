
include("../def_problem/MiModulo.jl")
using Symbolics
using Random
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

########################
#
#  CRear los puntos estacioarios
#
############################
"""
Retorna el valor de Beta y Gamma
"""
function get_multiplicadores_c_estacionario()
    # Genera los Beta y Gammas para que el punto sea C-Estacionario
    # Generar un numero entre 1-4 para seleccionar que valores seleccionar
    rand_value=rand(1:4)
    if rand_value==1 # Entonces Los 2 son mayores que creo
        return (rand(),rand())
    elseif rand_value==2
        return (-rand(),-rand())
    elseif  rand_value==3
        return (0,rand())
    else 
        return (rand(),0)
    end
    return (0,0)
end
"""
Betai, gammai>0,
Betai libre gammai=0
Gammai libre , betai=0
"""
function get_multiplicadores_m_estacionario()
    # Generar los Beta y Gamma para que sean punto M-Estacionario
    # Generar un numero entre 1:3 para ver como va
    rand_value=rand(1:3)
    if rand_value==1 # Entonces Los 2 son mayores que cero
        return (get_rand(),get_rand())
    elseif rand_value==2 # Beta libre, gamma 0
        return (rand(),0)
    else #Gamma libre, beta 0
        return (0,rand())
    end
    return (0,rand())
end

"""

"""
function get_multiplicadores_strong_estacionario()
# Retorna Beta y Gamma mayores que cero
return (get_rand(),get_rand())
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
   # Define el nombre de la carpeta que quieres crear
    nombre_carpeta = "Experimentos_Generador"

    # Construye la ruta relativa al directorio de trabajo actual
    ruta_carpeta = joinpath(pwd(), nombre_carpeta)

    # Verifica si la carpeta existe
    if !isdir(ruta_carpeta)
        # Si la carpeta no existe, la crea
        mkdir(ruta_carpeta)
        println("Carpeta creada: $ruta_carpeta")
    else
        println("La carpeta ya existe: $ruta_carpeta")
    end

    
    ruta_archivo = joinpath(ruta_carpeta, all_name)
    if !isfile(ruta_archivo) # Si no existe creo y lo guardo
        
        XLSX.writetable(ruta_archivo, sheet_names[1] =>dfs[1],sheet_names[2] =>dfs[2],sheet_names[3] =>dfs[3],sheet_names[4] =>dfs[4],sheet_names[5] =>dfs[5],sheet_names[6] =>dfs[6],sheet_names[7] =>dfs[7]; overwrite=true )
        return all_name
    end
    
        # Eliminamos el archivo y volvemos a llamar al programa
       
        rm(ruta_archivo)
        return serialize_in_xlsx(dfs,file_name)
        
end
# Se manda a serializar el experimento  is_alpha_zero si es true es pq alpha es el vector Nulo
# caso contrario false no lo es
function serialize_Experiment(opt_problem::Optimization_Problem,_alpha::Vector{Number}, BF::Vector{Number},x_s_vars::Vector,y_vars_Vector::Vector,experiment_name::String,is_alpha_zero::Bool)
# Mandar a hacer los dfs
    dfs=create_dataframe(opt_problem,_alpha,BF,x_s_vars,y_vars_Vector)
    # Ahora mandar a serializar
    file_name=experiment_name * "generator_alpha_non_zero"
    if is_alpha_zero
        file_name=experiment_name * "generator_alpha_zero"
    end
    serialize_in_xlsx(dfs,file_name)
end


"""
Seleccionar el tipo de punto estacionario que se quiere
""" 
@enum StationaryType begin
    C_Stationary
    M_Stationary
    Strong_Stationary
end
"""
Dado un Vector de FollowerRestrictionProblem ajusta esten en la proporcion adecuada 
los tipos de indices activos
"""
function split_correcto_type_set!(restrictions::Vector{FollowerRestrictionProblem})
    #Tomar las restricciones
    # La mitad J_0_L0_v
    # El 25% J_Ne_L0_v
    # El 25% J_0_LP_v
    # Despues modificar los valores de Beta y Gamma
   
    # Cant de V_s
    count_v_s=length(restrictions)
    # La mitad J_0_L0_v
    count_l_0_v_0=max(1,div(count_v_s,2))
    vect_l_0_v_0=restrictions[1:count_l_0_v_0]
    #Trasformar A ese conjunto
    for to_l_0_v_0::FollowerRestrictionProblem in vect_l_0_v_0
        to_l_0_v_0.restriction_set_type=J_0_L0_v
    end
    # Ahora si el indice mas uno es menor que la longitud del array continuo
    #  v=0, lambda>0
    if count_l_0_v_0+1>=count_v_s # Entonces retorno pq ya no hay nada que hacer
        return 
    end
    # Calcular las restantes para dividirlo entre 2
    restantes=count_v_s-count_l_0_v_0
    # Despues dividirlo entre dos asegurando que quede uno
    count_l_0_v_positivo=max(1,div(restantes,2)) 
    # Despues termino
    # Es lo que quite antes mas la cantidad que debo de tomar es el final de donde tomar
    finish_l_0_v_positivo=count_l_0_v_0+count_l_0_v_positivo 
    # Tomo desde el sgt desde donde tome anteiormente hasta el final asignado
    vect_l_0_v_positivo=restrictions[count_l_0_v_0+1:finish_l_0_v_positivo]
    for to_l_0_v_positivo::FollowerRestrictionProblem  in vect_l_0_v_positivo
        # Modifico para que ese sea el cjt de indices
        to_l_0_v_positivo.restriction_set_type=J_0_LP_v
    end
    # Ahora ver si quedi para J_Ne_L0_v retorno pq no quedan mas
    if finish_l_0_v_positivo>=count_v_s
        return
    end
    # Como quedan mas entonces hasta el final
    vect_l_o_v_neg=restrictions[finish_l_0_v_positivo+1:end]
    for to_l_o_v_neg in vect_l_o_v_neg
        to_l_o_v_neg.restriction_set_type=J_Ne_L0_v
    end


end 
"""
Dadas las restricciones llama al metodo para cambiar el valor de beta y gamma
"""
function _modify_beta_and_gamma(restrictions::Vector{FollowerRestrictionProblem},function_call)
    for rest::FollowerRestrictionProblem in restrictions
        _beta,_gamma=function_call()
        rest._beta=_beta
        rest._gamma=_gamma
    end

end
"""
modifica las restricciones para que cumplan 
todas con ser de ese tipo de punto estacionario
"""
function modify_restriction_to_create_stationary_point(restrictions::Vector{FollowerRestrictionProblem},stationary_type::StationaryType)
    if stationary_type==C_Stationary
        _modify_beta_and_gamma(restrictions,get_multiplicadores_c_estacionario)
    elseif stationary_type==M_Stationary
        _modify_beta_and_gamma(restrictions,get_multiplicadores_m_estacionario)
    else
        _modify_beta_and_gamma(restrictions,get_multiplicadores_strong_estacionario)
    end
end
"""
Para entrar el tipo de punto que se quiere generar, metodo privado
"""
function _RunExperimets_to_all_stationary(experiment::Experiment,experiment_name::String,stationary_type::StationaryType)

    restrictions::Vector{FollowerRestrictionProblem}=experiment.model_alpha_zero.follower_restriction_problem    
    # Hacer que esten en los indices activos correctos
    split_correcto_type_set!(restrictions)
    # ahora en dependencia del tipo de punto estacionario modificar las constantes
    modify_restriction_to_create_stationary_point(restrictions,stationary_type)


    experiment_name=experiment_name*"__"*string(stationary_type)
    RunExperiment(experiment,experiment_name)
end

"""
Correr el experimento y guardar en un excel
"""
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
   # return dfs
   println("Experimento Completado")
end

"""
Crea un experimento de todos los tipos de puntos estacionarios habidos
"""
function RunExperiment(experiment::Experiment,experiment_name::String,all_stationarys::Bool)
    if !all_stationarys
         RunExperiment(experiment,experiment_name)
    end
    # Crear uno C_Stationary
    _RunExperimets_to_all_stationary(experiment,experiment_name,C_Stationary)
    # Crear uno M_Stationary
    _RunExperimets_to_all_stationary(experiment,experiment_name,M_Stationary)
    # Crear uno Strong Stationary
    _RunExperimets_to_all_stationary(experiment,experiment_name,Strong_Stationary)

    println("Finilizado el experimento completo")
    
end