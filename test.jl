#using Pkg
#Pkg.add("PyCall")
using PyCall

# Importa el módulo de Python
@pyimport mi_modulo

# Usa las funciones del módulo
a = 5
b = 3

suma = mi_modulo.sumar(a, b)
resta = mi_modulo.restar(a, b)

println("La suma de $a y $b es: $suma")
println("La resta de $a y $b es: $resta")
