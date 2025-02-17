
include("../../../../experiment.jl")
        
using BilevelJuMP
using Random

# Introducir semilla

Random.seed!(9)

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

BilevelJuMP.@objective(Upper(model),Min, -2x_1 + x_2 + 0.50y_1 + -1.80x_1 + -9.80x_2 +-24.87y_1 +-27.42y_2) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, x_1 + x_2 - 4y_1 + y_2 +0.72y_1 +-4.08y_2) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,-6.90 - 2x_1 + 2.36y_1 + 0.96y_2<=0  
 c1,2.65 + x_1 - 3x_2 - 0.47y_1 + 0.33y_2<=0  
 c2,-20.71 + x_1 + x_2 + 1.68y_1 + 2.41y_2<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x_1, x_2 ],[ y_1, y_2 ],"ex9_1_8_Fuertemente-Estacionario")


# Valor de la función objetivo
-222.34
         
 # Evaluacion en el punto 
 -222.34