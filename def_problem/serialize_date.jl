using XLSX
using DataFrames

####################################
#                                  #
# Zona para serializar la data     #
#                                  #
####################################

function Num_to_String(val::Symbolics.Num)

    return string(val)

end
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
       #x_s= Num_to_String(x_s)
       df=create_dataframe_by_add_colum(df,x_s,[string(point[x_s])])
    end

    for x_s in y_vars_Vector
        # Convertir a string
       #x_s= Num_to_String(x_s)
       df=create_dataframe_by_add_colum(df,x_s,[string(point[x_s])])
    end

    
    return df
end
"""
Dado un opt_problem y el vector BF se crea el dataframe a serializar
retorna un Vector en este orden [objt_df,leader_rest_df,follower_rest_df,point_df,bf_df,BF_df,_alpha_df]
"""
function create_dataframe(opt_problem::Optimization_Problem,_alpha::Vector, BF::Vector,x_s_vars::Vector,y_vars_Vector)
println("Guardar funciones objetivos")
    # Crear Dataframe con las Funciones del Nivel Superior e inf
objt_df=create_dataframe_obj_functions(opt_problem)
# Crear df de restricciones nivel Superior
println("extraer data del lider")
leader_rest_df=extract_data_from_leader_restriction(opt_problem.leader_restrictions)
# Crear df de restricciones del nivel inferior
println("Extraer data de la restriccion")
follower_rest_df=extract_data_from_follower_restriction(opt_problem.follower_restrictions)
# Crear Dataframe del punto
println("Guardar el punto")
point_df=create_dataframe_point(opt_problem,x_s_vars::Vector,y_vars_Vector)
# Crear el DataFrame_de_bf
tt=typeof(opt_problem.bf)
println("El tipo de bf es $tt")
_bf::Vector{String}=Num_to_String.(opt_problem.bf)
bf_df=DataFrame(vec_bf=_bf)
# Crear el Dataframe de BF
_BF::Vector{String}=Num_to_String.(BF)
BF_df=DataFrame(vec_BF=_BF)
# Crear DataFrame de alpha
println("Crear dataframe de alpha")
_alpha::Vector{Number}=_alpha
_alpha_df=DataFrame(vec_alpha=_alpha)
println("Se va a devolver el array")
return [objt_df,leader_rest_df,follower_rest_df,point_df,bf_df,BF_df,_alpha_df]
end

"""
Funcion para serializar en un documento 

"""
function serialize_in_xlsx(dfs::Vector, file_name::String)
    sheet_names = [
        "Funciones_Objetivo",
        "Restricciones_del_lider",
        "Restricciones_del_follower",
        "Punto_modificado",
        "Vector_bf",
        "Vector_BF",
        "Vector_Alpha"
    ]
    
    all_name = "$file_name.xlsx"
    
    # Crear un buffer en memoria
    buffer = IOBuffer()
    
    # Escribir los datos al buffer en formato XLSX
    XLSX.writetable(
        buffer,
        sheet_names[1] => dfs[1],
        sheet_names[2] => dfs[2],
        sheet_names[3] => dfs[3],
        sheet_names[4] => dfs[4],
        sheet_names[5] => dfs[5],
        sheet_names[6] => dfs[6],
        sheet_names[7] => dfs[7]
    )
    
    # Obtener los bytes del Excel
    xlsx_data = take!(buffer)
    
    return (xlsx_data, all_name)
end
# Se manda a serializar el experimento  is_alpha_zero si es true es pq alpha es el vector Nulo
# caso contrario false no lo es
function serialize_Experiment(opt_problem::Optimization_Problem,_alpha::Vector, BF::Vector,x_s_vars::Vector,y_vars_Vector::Vector,experiment_name::String,is_alpha_zero::Bool)
# Mandar a hacer los dfs
    println("Va a entrar a los DataFrames")
    dfs=create_dataframe(opt_problem,_alpha,BF,x_s_vars,y_vars_Vector)
    println("se va a serializar")
    # Ahora mandar a serializar
    file_name=experiment_name * "generator_alpha_non_zero"
    if is_alpha_zero
        file_name=experiment_name * "generator_alpha_zero"
    end
    return serialize_in_xlsx(dfs,file_name)
end