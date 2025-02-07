
include("../../../../experiment.jl")
        
using BilevelJuMP
using Random

# Introducir semilla

Random.seed!(8)

# Crear Modelo Base
model = BilevelModel()

# Crear Variables

# Variables del Lider 
 BilevelJuMP.@variable(Upper(model), x) 

# Variables del follower 
 BilevelJuMP.@variable(Lower(model), y) 


# Definir Nivel Superior

BilevelJuMP.@objective(Upper(model),Min, -x - 3y + -16.10x +-90.57y) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, y) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,-80.55 + 9.00y<=0  
 c1,-166.03 - x + 19.33y<=0  
 c2,-7.00 + x<=0  
 c3,-78.78 + 4x + 5.67y<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x ],[ y ],"ex9_1_2_Fuertemente-Estacionario")


# Valor de la función objetivo
-957.15
         
 # Evaluacion en el punto 
 -957.15