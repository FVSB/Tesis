
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

BilevelJuMP.@objective(Upper(model),Min, -x - 3y_1 + 2y_2 + -54.40x +-36.65y_1 +-25.19y_2) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, -y_1) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,-11.54 + 1.48y_1 + 2.02y_2<=0  
 c1,-11.89 + 2.03y_1 + 0.84y_2<=0  
 c2,20.08 - 2x - 1.56y_1 + 1.91y_2<=0  
 c3,-77.60 + 8x + 2.11y_1 + 0.91y_2<=0  
 c4,6.27 - 2x + 0.91y_1 + 2.38y_2<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x ],[ y_1, y_2 ],"ex9_1_1_Fuertemente-Estacionario")

         
 # Evaluacion en el punto 
 -694.53