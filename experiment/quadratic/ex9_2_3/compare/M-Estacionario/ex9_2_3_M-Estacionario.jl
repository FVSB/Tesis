
include("../../../../experiment.jl")
        
using BilevelJuMP
using Random

# Introducir semilla

Random.seed!(13)

# Crear Modelo Base
model = BilevelModel()

# Crear Variables

# Variables del Lider 
 BilevelJuMP.@variable(Upper(model), x_1) 
 BilevelJuMP.@variable(Upper(model), x_2) 

# Variables del follower 
 BilevelJuMP.@variable(Lower(model), y_1) 
 BilevelJuMP.@variable(Lower(model), y_2) 


# Definir Nivel Superior

BilevelJuMP.@objective(Upper(model),Min, -60 + 2x_1 + 2x_2 - 3y_1 - 3y_2 + 8.72x_1 + 12.18x_2 +-14.40y_1 +-34.25y_2) 

              # Restricciones del Nivel Superior
              BilevelJuMP.@constraints(Upper(model),begin 

         a1,-16.45 + x_1 + x_2 + y_1 - 2y_2<=0  

 end) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, (20 - x_1 + y_1)^2 + (20 - x_2 + y_2)^2 +-26.89y_1 +-18.93y_2) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,20.13 - x_1 + 0.09y_1 + 2.10y_2<=0  
 c1,5.16 - x_2 - 0.99y_1 + 0.87y_2<=0  
 c2,24.47 + 0.98y_1 + 2.25y_2<=0  
 c3,-17.99 - 0.54y_1 - 1.76y_2<=0  
 c4,-41.56 + 2.02y_1 + 1.30y_2<=0  
 c5,-41.79 - 0.46y_1 + 0.48y_2<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x_1, x_2 ],[ y_1, y_2 ],"ex9_2_3_M-Estacionario")


# Valor de la función objetivo
405.85
         
 # Evaluacion en el punto 
 405.85