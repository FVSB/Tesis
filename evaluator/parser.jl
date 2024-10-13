module MyParser

using Symbolics

export parse_expression, separate_equation, extract_variable_names,add_to_symbolics,convert_Symbol_to_symbolic_num,eval_point

"""
 Función para parsear una expresión matemática
"""
function parse_expression(expr::AbstractString)::Num
    # Convertimos a String si es un SubString
    if isa(expr, SubString{String})
        expr = String(expr)
    end
    parsed_expr = Meta.parse(expr)  # Parseamos la cadena a una expresión
    return eval(parsed_expr)         # Evaluamos la expresión
end

 """
 Función para separar la ecuación

 Devuelve las expresiones: left,rigth
 """
function separate_equation(equation::String)
    parts = split(equation, "==")  # Cambiar "==" por ">" o "<" si es necesario
    left_part = parse_expression(parts[1])
    right_part = parse_expression(parts[2])
    return left_part, right_part
end


"""
    is_operator(symbol::Symbol) -> Bool

Determina si un símbolo dado es un operador en Julia.

# Parámetros
- `symbol::Symbol`: El símbolo que se desea verificar.

# Retorno
- Devuelve `true` si el símbolo es un operador, de lo contrario devuelve `false`.

# Ejemplo
```jldoctest
julia> is_operator(:+)
true

julia> is_operator(:foo)
false
```
"""
function is_operator(symbol::Symbol)
    return symbol in (:+, :-, :*, :/, :^, :<, :>, :<=, :>=, :(==), :!=, :&&, :||, :|, :&, :<<, :>>, :%, :÷)
end

"""
Función para extraer los nombres de las variables
"""
function extract_variable_names(expr::AbstractString)::Vector{Symbol}
    # Convertimos a String si es un SubString
    if isa(expr, SubString{String})
        expr = String(expr)
    end
    
    parsed_expr = Meta.parse(expr)  # Parseamos la cadena a una expresión
    
    # Extraemos los nombres de las variables
    variable_names = Set{Symbol}()
    
    # Función recursiva para analizar el árbol de sintaxis
    function extract_variables(ex)
        if ex isa Symbol && !is_operator(ex)  # Ignoramos los operadores
            push!(variable_names, ex)  # Si es un símbolo válido, lo añadimos
        elseif ex isa Expr
            # Recorremos los argumentos de la expresión
            for arg in ex.args
                extract_variables(arg)
            end
        end
    end
    
    extract_variables(parsed_expr)  # Extraemos las variables del árbol
    
    return collect(variable_names)  # Convertimos el conjunto a una lista
end


"""
Función para añadir nuevas variables a Symbolics
"""
function add_to_symbolics(variables::Vector{Symbol})
    for var in variables
        @eval @variables $var
    end
end


"""
Dado un Symbol devuelve la variable Num que es necesaria para operar en
 Symbolics por ejemplo en Differencial()
"""
function convert_Symbol_to_symbolic_num(symbol::Symbol)::Symbolics.Num
    # Devuelve una lista de Symbolics.Num y solo quiero devolver el primer elemento
    return Symbolics.variables(symbol)[1]

end

function convert_Symbol_to_symbolic_num(symbol::String)::Num
    return Symbolics.variables(symbol)[1]
    
end

"""
Dado un punto y una expresion devuelve la evaluación de esta
"""
function eval_point(expr,point::Dict)
    # Convertir el diccionario desde strings a Symbolos
    new_dicc=Dict(convert_Symbol_to_symbolic_num(key) => point[key] for key in keys(point))
    # Sustituir la expresion por el punto Para substitute se tiene que enviar en forma de tupla
    return substitute.(expr,(new_dicc,))[1]
    
end
function substitute_point_in_vector(expr,point::Dict)::Union{Vector, Matrix}
    # Convertir el diccionario desde strings a Symbolos
    new_dicc=Dict(convert_Symbol_to_symbolic_num(key) => point[key] for key in keys(point))
    # Sustituir la expresion por el punto Para substitute se tiene que enviar en forma de tupla
    return substitute.(expr,(new_dicc,))
    
end

end
