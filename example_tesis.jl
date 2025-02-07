# Importar dependencias necesarias
#using ProblemGenerator
include("def_problem/MiModulo.jl")
# Crear el modelo base del generador alpha=0
model=GeneratorModel()
#Declaracion de variables
# Se declara en el nivel superior las variables x_1, x_2
@myvariables Upper(model) x_1, x_2
# Se declara en el nivel inferior las variables y_1, y_2
@myvariables Lower(model) y_1,y_2
# Declarar la funcion objetivo del nivel superior
# Min de ((x_1^2)*(y_1^2)*(y_2))+x_2
SetObjectiveFunction(Upper(model),((x_1^2)*(y_1^2)*(y_2))+x_2)
# Ejemplo de restriccion del nivel superior
SetLeaderRestriction(model,x_1+y_2-y_1>9,J_0_g,0.3)
# Declarar la funcion objetivo del nivel inferior
# Min de ((x_2^2)*(y_1^2)*(y_2))+x_1
SetObjectiveFunction(Lower(model),((x_2^2)*(y_1^2)*(y_2))+x_1)
# Para caso lamda_j!=0
SetFollowerRestriction(model,((x_1^2)*(y_1^2))+x_2==0,J_Ne_L0_v,0.1,0,0.4)
# Introducir el punto (1,1,1,1)
SetPoint(model,Dict(x_1=>1,x_2=>1,y_1=>1,y_2=>1))
# Llamar para generar el problema
problem=CreateProblem(model)