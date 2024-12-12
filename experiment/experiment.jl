using BenchmarkTools
using XLSX
using DataFrames
using BilevelJuMP, HiGHS, Ipopt, SCIP,Gurobi
using BenchmarkTools

function serialize_in_xlsx(df,file_name::String)
    sheet_name="Data"
    all_name="$file_name.xlsx"
    if !isfile(all_name) # Si no existe creo y lo guardo
        
        XLSX.writetable(all_name, sheet_name =>df; overwrite=true )
        return all_name
    end
    
        # Si existe el archivo
        # Leer la tabla desde el archivo Excel
        tabla = XLSX.readtable(all_name,sheet_name)
        # Convertir en un DataFrame
        old_df=DataFrame(tabla)
        # Concatenar los Dataframes
        new_df=vcat(old_df, df)
        # Reescribir y guardar el nuevo xlsx
        XLSX.writetable(all_name, sheet_name => new_df; overwrite=true )
        return all_name
        
end

function add_to_dataframe_vars_value(df,var_vector::Vector,var_name::String)
    # Insertar una nueva columna al final
    for i in 1:length(var_vector)
        insertcols!(df, ncol(df) + 1,"$var_name: $i"=>BilevelJuMP.value(var_vector[i]) )
    end
    return df
end



function create_dataframe(model,x,y,name_optimize_method::String)
    println("optimize Method: $name_optimize_method")
    # Escribir el resultado de la solucion primal
    p_s=string(BilevelJuMP.primal_status(model))
    println("Primal Status: $p_s")
    # Escribir el codigo y tipo de terminacion
    t_s=string(BilevelJuMP.termination_status(model))
    println("Termination Status: $t_s")
    # Objetive value
    o_v=BilevelJuMP.objective_value(model)
    # Objetive value Upper Level
    o_v_u=BilevelJuMP.objective_value(Upper(model))
    
    println("Objetive Value $o_v")
    # Lider Vars Value
    l_vars=BilevelJuMP.value.(x)
    println("Lider Vars: $l_vars")
    # Follower Vars Value
    f_vars=BilevelJuMP.value.(y)
    println("Followers Vars Value $f_vars")

    resultado=@benchmark optimize!(model)
    # Extraer los tiempos y otros datos relevantes
    tiempos = resultado.times  # Tiempos en nanosegundos
    min_tiempo = minimum(tiempos) / 1e9  # Tiempo mínimo en segundos
    max_tiempo = maximum(tiempos) / 1e9  # Tiempo máximo en segundos
    promedio_tiempo = mean(tiempos) / 1e9  # Tiempo promedio en segundos
    
    # Extraer el uso de recursos
    num_asignaciones = sum(resultado.allocs)  # Total de asignaciones de memoria
    memoria_usada = maximum(resultado.memory) / (1024^2)  # Memoria máxima usada en MB

    # Crear un DataFrame para almacenar los resultados
    df_resultados = DataFrame(
    Optimize_Method=name_optimize_method,
    Estatus_Primal=p_s,
    Estatus_Terminación=t_s,
    Valor_Objetivo=o_v,
    
    Tiempo_Mínimo=min_tiempo,
    Tiempo_Máximo=max_tiempo,
    Tiempo_Promedio=promedio_tiempo,
    Asignaciones_Memoria=num_asignaciones,
    Memoria_MB=memoria_usada
    )
    # Añadir el valor de las x_s 
    df_resultados=add_to_dataframe_vars_value(df_resultados,x,"X_s")
    # Anadir el valor de las y_s
    df_resultados=add_to_dataframe_vars_value(df_resultados,y,"Y_s")

    return df_resultados

end



function make_experiment(model_with_optimizer,x_s,y_s,optimizer_name::String,problem_name::String)
    # Mandar a optimizar el modelo 
    optimize!(model)
    # Crear el dataframe de respuesta
    df= create_dataframe(model,x_s,y_s,optimizer_name)
    # Ahora serializar en un xlxs los datos con el nombre del modelo
    # Guardar el DataFrame en un archivo Excel
    file_name=serialize_in_xlsx(df,problem_name)

 

    # Mostrar mensaje de confirmación
    println("El DataFrame ha sido guardado en $file_name en la hoja $problem_name.")
end


function start_experiment(model,x_s,y_s,problem_name::String)
    # La entrada será el modelo sin el optimizador
    # Los vectores con las variables x_s y y_s
    # El nombre del problema a resolver
    

    ##############
    #Resolviendo con HiGHS
    try
    println("Resolviendo el problema con HiGHS")
    BilevelJuMP.set_optimizer(model, HiGHS.Optimizer)

    BilevelJuMP.set_mode(model,
        BilevelJuMP.BigMMode(primal_big_M = 100, dual_big_M = 100))

     make_experiment(model,x_s,y_s,"Highs-BigM (100,100)",problem_name)
    catch e
        println("Ocurrió un error: ", e)  # Imprime el mensaje del error
    end

     #################
    #Resolviendo con SOS1
    try
    println("Resolviendo el problema con SOS1")
    set_optimizer(model, SCIP.Optimizer)

    BilevelJuMP.set_mode(model, BilevelJuMP.SOS1Mode())
    make_experiment(model,x_s,y_s,"SOS1",problem_name)
    catch e
        println("Ocurrió un error: ", e)  # Imprime el mensaje del error
    end
    #############
    # Resolviendo con Product mode
    try
    println("Resolviendo el problema con Product Mode")

    #set_optimizer(model, Ipopt.Optimizer)
    set_optimizer(model,Gurobi.Optimizer)

    BilevelJuMP.set_mode(model, BilevelJuMP.ProductMode())
    set_optimizer_attribute(model, "NonConvex", 2)
    make_experiment(model,x_s,y_s,"Product_Mode",problem_name)
    catch e
        println("Ocurrió un error: ", e)  # Imprime el mensaje del error
    end
end

export start_experiment

