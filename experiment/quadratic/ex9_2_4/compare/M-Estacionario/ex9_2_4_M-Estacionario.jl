
include("../../../../experiment.jl")
        
using BilevelJuMP
using Random

# Introducir semilla

Random.seed!(14)

# Crear Modelo Base
model = BilevelModel()

# Crear Variables

# Variables del Lider 
 BilevelJuMP.@variable(Upper(model), x) 

# Variables del follower 
 BilevelJuMP.@variable(Lower(model), y_1) 
 BilevelJuMP.@variable(Lower(model), y_2) 


# Definir Nivel Superior

BilevelJuMP.@objective(Upper(model),Min, 0.50((-2 + y_1)^2 + (-2 + y_2)^2) + 0.40x +-8.20y_1 +-4.83y_2) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, y_2 + 0.50(y_1^2) +-8.46y_1 +-2.89y_2) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,-x + y_1 + y_2<=0  
 c1,-14.69 + 1.63y_1 + 1.45y_2<=0  
 c2,-7.63 + 1.63y_1 - 0.11y_2<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x ],[ y_1, y_2 ],"ex9_2_4_M-Estacionario")


# Valor de la función objetivo
-53.06
         
 # Evaluacion en el punto 
 -53.06