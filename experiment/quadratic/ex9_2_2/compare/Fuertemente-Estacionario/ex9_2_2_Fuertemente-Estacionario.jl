
include("../../../../experiment.jl")
        
using BilevelJuMP
using Random

# Introducir semilla

Random.seed!(12)

# Crear Modelo Base
model = BilevelModel()

# Crear Variables

# Variables del Lider 
 BilevelJuMP.@variable(Upper(model), x) 

# Variables del follower 
 BilevelJuMP.@variable(Lower(model), y) 


# Definir Nivel Superior

BilevelJuMP.@objective(Upper(model),Min, x^2 + (-10 + y)^2 + -38.94x +-183.46y) 

              # Restricciones del Nivel Superior
              BilevelJuMP.@constraints(Upper(model),begin 

         a1,0.05 - x + y<=0  

 end) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, (-30 + x + 2y)^2 +-65.01y) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,-230.45 + x + 15.00y<=0  
 c1,4.90 - 0.34y<=0  
 c2,-103.32 + 7.12y<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x ],[ y ],"ex9_2_2_Fuertemente-Estacionario")


# Valor de la función objetivo
-2976.34
         
 # Evaluacion en el punto 
 -2976.34