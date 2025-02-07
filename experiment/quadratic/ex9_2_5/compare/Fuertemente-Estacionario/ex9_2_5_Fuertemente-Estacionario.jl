
include("../../../../experiment.jl")
        
using BilevelJuMP
using Random

# Introducir semilla

Random.seed!(15)

# Crear Modelo Base
model = BilevelModel()

# Crear Variables

# Variables del Lider 
 BilevelJuMP.@variable(Upper(model), x) 

# Variables del follower 
 BilevelJuMP.@variable(Lower(model), y) 


# Definir Nivel Superior

BilevelJuMP.@objective(Upper(model),Min, (-3 + x)^2 + (-2 + y)^2 + 2.10x +-52.94y) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, (-5 + y)^2) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,-32.42 + x + 6.83y<=0  
 c1,-1.51 + x - 0.80y<=0  
 c2,-6.78 - 2x + 1.17y<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x ],[ y ],"ex9_2_5_Fuertemente-Estacionario")


# Valor de la función objetivo
-197.17
         
 # Evaluacion en el punto 
 -197.17