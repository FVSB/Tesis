
include("../../../../experiment.jl")
        
using BilevelJuMP
using Random

# Introducir semilla

Random.seed!(14)

# Crear Modelo Base
model = BilevelModel()

# Crear Variables

# Variables del Lider 
 BilevelJuMP.@variable(Upper(model), x) 

# Variables del follower 
 BilevelJuMP.@variable(Lower(model), y_1) 
 BilevelJuMP.@variable(Lower(model), y_2) 


# Definir Nivel Superior

BilevelJuMP.@objective(Upper(model),Min, 0.50((-2 + y_1)^2 + (-2 + y_2)^2) + 5.20x +-1.80y_1 +-9.46y_2) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, y_2 + 0.50(y_1^2)) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,-x + y_1 + y_2<=0  
 c1,4.56 - 1.00y_1 + 0.06y_2<=0  
 c2,-1.90 + 0.04y_1 + 0.16y_2<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x ],[ y_1, y_2 ],"ex9_2_4_Fuertemente-Estacionario")


# Valor de la función objetivo
-23.39
         
 # Evaluacion en el punto 
 -23.39