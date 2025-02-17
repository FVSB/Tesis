
include("../../../../experiment.jl")
        
using BilevelJuMP
using Random

# Introducir semilla

Random.seed!(7)

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

BilevelJuMP.@objective(Upper(model),Min, -2x_1 + x_2 + 0.50y_1 + -6.00x_1 + 23.00x_2 +1.81y_1 +-7.26y_2) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, x_1 + x_2 - 4y_1 + y_2 +0.45y_1 +-0.68y_2) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,-266.23 - 2x_1 + 3.61y_1 - 0.17y_2<=0  
 c1,32.10 + x_1 - 3x_2 - 0.29y_1 + 0.91y_2<=0  
 c2,9.34 - 0.09y_1 + 0.29y_2<=0  
 c3,-50.92 + 0.50y_1 - 0.84y_2<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x_1, x_2 ],[ y_1, y_2 ],"ex9_1_10_M-Estacionario")


# Valor de la función objetivo
256.63
         
 # Evaluacion en el punto 
 256.63