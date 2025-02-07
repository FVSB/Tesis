
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

BilevelJuMP.@objective(Upper(model),Min, -x - 3y + 1.00x +3.00y) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, y) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,8.95 - y<=0  
 c1,-1.95 - x + y<=0  
 c2,-24.90 + x + 2y<=0  
 c3,-19.13 + 4x - y<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x ],[ y ],"ex9_1_2_Alpha-Zero")

         
 # Evaluacion en el punto 
 0.00