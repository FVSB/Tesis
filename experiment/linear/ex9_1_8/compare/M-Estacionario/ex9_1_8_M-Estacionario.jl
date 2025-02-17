
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

BilevelJuMP.@objective(Upper(model),Min, -2x_1 + x_2 + 0.50y_1 + -0.90x_1 + -3.90x_2 +-0.50y_1 +-0.00y_2) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, x_1 + x_2 - 4y_1 + y_2 +2.62y_1 +-2.87y_2) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,-3.58 - 2x_1 + 1.57y_1 + 1.93y_2<=0  
 c1,1.39 + x_1 - 3x_2 - 0.19y_1 + 0.04y_2<=0  
 c2,-6.60 + x_1 + x_2<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x_1, x_2 ],[ y_1, y_2 ],"ex9_1_8_M-Estacionario")


# Valor de la función objetivo
-17.69
         
 # Evaluacion en el punto 
 -17.69