
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

BilevelJuMP.@objective(Upper(model),Min, -x - 3y_1 + 2y_2 + 13.60x +3.98y_1 +-2.68y_2) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, -y_1) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,0.67 - 0.46y_1 + 0.79y_2<=0  
 c1,-2.42 + 0.68y_1 - 0.47y_2<=0  
 c2,20.48 - 2x - 1.20y_1 + 0.83y_2<=0  
 c3,-69.32 + 8x + 0.86y_1 - 0.21y_2<=0  
 c4,5.19 - 2x - 1.07y_1 + 1.34y_2<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x ],[ y_1, y_2 ],"ex9_1_1_M-Estacionario")

         
 # Evaluacion en el punto 
 105.57