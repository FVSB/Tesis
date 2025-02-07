
include("../../../../experiment.jl")
        
using BilevelJuMP
using Random

# Introducir semilla

Random.seed!(11)

# Crear Modelo Base
model = BilevelModel()

# Crear Variables

# Variables del Lider 
 BilevelJuMP.@variable(Upper(model), x) 

# Variables del follower 
 BilevelJuMP.@variable(Lower(model), y) 


# Definir Nivel Superior

BilevelJuMP.@objective(Upper(model),Min, (-5 + x)^2 + (1 + 2y)^2 + 14.13x +-39.51y) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, -1.50x*y + (-1 + y)^2) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,5.55 - 3x + 1.11e-16y<=0  
 c1,0.27 + x - 0.46y<=0  
 c2,-12.15 + x + 1.11e-16y<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x ],[ y ],"ex9_2_1_M-Estacionario")

         
 # Evaluacion en el punto 
 -41.57