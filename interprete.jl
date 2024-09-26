using Symbolics

# Declarar variables simbólicas
@variables x y z

# Crear una expresión simbólica
expr = x + y^2 + z

# Definir valores para las variables
subs = Dict(x => 2, y => 3, z => 4)

# Sustitución de valores en la expresión
resultado = substitute(expr, subs)

# Imprimir el resultado
println("Resultado: ", resultado)  # Debería imprimir: Resultado: 15