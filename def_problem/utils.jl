# Utils script 

"""
Generates a random number greater than zero and less than one.

# Returns
- `Float64`: A random number slightly greater than zero.
"""
function get_rand()
    epsilon = 1e-10
    rand() + epsilon
end

export get_rand



# Definir la función para transformar las llaves del diccionario
function transformar_llaves(diccionario::Dict, transformacion::Function)
    # Crear un nuevo diccionario vacío
    nuevo_diccionario = Dict{Any, Any}()
    
    # Iterar sobre cada par llave-valor en el diccionario original
    for (llave, valor) in diccionario
        # Aplicar la transformación a la llave y añadir al nuevo diccionario
        nueva_llave = transformacion(llave)
        nuevo_diccionario[nueva_llave] = valor
    end
    
    return nuevo_diccionario
end
