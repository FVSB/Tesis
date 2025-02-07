
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

BilevelJuMP.@objective(Upper(model),Min, x^2 + (-10 + y)^2 + -30.24x +-77.66y) 

              # Restricciones del Nivel Superior
              BilevelJuMP.@constraints(Upper(model),begin 

         a1,0.05 - x + y<=0  

 end) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, (-30 + x + 2y)^2) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,34.04 + x - 3.37y<=0  
 c1,-27.50 + 1.91y<=0  
 c2,-40.00 + 1.11e-16y<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x ],[ y ],"ex9_2_2_C-Estacionario")


# Valor de la función objetivo
-1327.11
         
 # Evaluacion en el punto 
 -1327.11