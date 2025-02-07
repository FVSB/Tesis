
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

BilevelJuMP.@objective(Upper(model),Min, -2x_1 + x_2 + 0.50y_1 + 2.00x_1 + -1.00x_2 +-0.50y_1 +-0.00y_2) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, x_1 + x_2 - 4y_1 + y_2) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,4.45 - 2x_1 + y_1 - y_2<=0  
 c1,-1.25 + x_1 - 3x_2 + y_2<=0  
 c2,-6.43 + x_1 + x_2<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x_1, x_2 ],[ y_1, y_2 ],"ex9_1_8_Alpha-Zero")


# Valor de la función objetivo
0.00
         
 # Evaluacion en el punto 
 0.00