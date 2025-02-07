using BenchmarkTools
using XLSX
using DataFrames
using JuMP, Ipopt

"""
My retorno de dos digitos
"""
function my_round(value)
    return round(value,digits=2)
end

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
        insertcols!(df, ncol(df) + 1,"$var_name: $i"=>my_round(value(var_vector[i])) )
    end
    return df
end



function create_dataframe(resultado,model,x,y,name_optimize_method::String)

    
     # Extraer los tiempos y otros datos relevantes
    tiempos = resultado.times  # Tiempos en nanosegundos
    min_tiempo = minimum(tiempos) / 1e9  # Tiempo mínimo en segundos
    max_tiempo = maximum(tiempos) / 1e9  # Tiempo máximo en segundos
    promedio_tiempo = mean(tiempos) / 1e9  # Tiempo promedio en segundos
    # Extraer el uso de recursos
    num_asignaciones = sum(resultado.allocs)  # Total de asignaciones de memoria
    memoria_usada = maximum(resultado.memory) / (1024^2)  # Memoria máxima usada en MB

    println("optimize Method: $name_optimize_method")
    # Escribir el resultado de la solucion primal
    p_s=string(primal_status(model))
    println("Primal Status: $p_s")
    # Escribir el codigo y tipo de terminacion
    t_s=string(termination_status(model))
    println("Termination Status: $t_s")
    # Objetive value
    o_v=objective_value(model)
    # Objetive value Upper Level
    
    
    println("Objetive Value $o_v")
    # Lider Vars Value
    l_vars=value.(x)
    println("Lider Vars: $l_vars")
    # Follower Vars Value
    f_vars=value.(y)
    println("Followers Vars Value $f_vars")

    

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

function make_experiment(model,x_s,y_s,optimizer_name::String,problem_name::String)
    # Mandar a optimizar el modelo 
    resultado=@benchmark optimize!(model)
   
    # Crear el dataframe de respuesta
    df= create_dataframe(resultado,model,x_s,y_s,optimizer_name)
    # Ahora serializar en un xlxs los datos con el nombre del modelo
    # Guardar el DataFrame en un archivo Excel
    file_name=serialize_in_xlsx(df,problem_name)

 

    # Mostrar mensaje de confirmación
    println("El DataFrame ha sido guardado en $file_name en la hoja $problem_name.")
end
