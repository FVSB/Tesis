
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

BilevelJuMP.@objective(Upper(model),Min, -2x_1 + x_2 + 0.50y_1 + 0.80x_1 + 29.00x_2 +-180.45y_1 +-56.82y_2) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, x_1 + x_2 - 4y_1 + y_2) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,-534.10 - 2x_1 + 6.23y_1 + 0.74y_2<=0  
 c1,-853.08 + x_1 - 3x_2 + 8.37y_1 + 3.79y_2<=0  
 c2,10.16 - 0.10y_1 + 0.30y_2<=0  
 c3,-883.47 + 8.63y_1 + 1.88y_2<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x_1, x_2 ],[ y_1, y_2 ],"ex9_1_10_Fuertemente-Estacionario")


# Valor de la función objetivo
-17921.11
         
 # Evaluacion en el punto 
 -17921.11