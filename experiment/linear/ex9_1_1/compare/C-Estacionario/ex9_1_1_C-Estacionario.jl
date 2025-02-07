
include("../../../../experiment.jl")
        
using BilevelJuMP
using Random

# Introducir semilla

Random.seed!(6)

# Crear Modelo Base
model = BilevelModel()

# Crear Variables

# Variables del Lider 
 BilevelJuMP.@variable(Upper(model), x) 

# Variables del follower 
 BilevelJuMP.@variable(Lower(model), y_1) 
 BilevelJuMP.@variable(Lower(model), y_2) 


# Definir Nivel Superior

BilevelJuMP.@objective(Upper(model),Min, -x - 3y_1 + 2y_2 + 37.80x +-10.41y_1 +-20.01y_2) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, -y_1) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,1.87 - 0.50y_1 + 0.50y_2<=0  
 c1,-1.88 + 0.50y_1 - 0.50y_2<=0  
 c2,17.73 - 2x - 1.50y_1 + 1.50y_2<=0  
 c3,-79.70 + 8x - 2.91y_1 - 3.91y_2<=0  
 c4,8.15 - 2x - y_1 + y_2<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x ],[ y_1, y_2 ],"ex9_1_1_C-Estacionario")


# Valor de la función objetivo
74.95
         
 # Evaluacion en el punto 
 74.95