
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

BilevelJuMP.@objective(Upper(model),Min, 0.50((-2 + y_1)^2 + (-2 + y_2)^2) + 0.90x +-11.02y_1 +1.71y_2) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, y_2 + 0.50(y_1^2) +-6.78y_1 +-1.03y_2) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,-x + y_1 + y_2<=0  
 c1,-7.51 + 1.26y_1 + 0.30y_2<=0  
 c2,-3.99 + 0.13y_1 - 0.98y_2<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x ],[ y_1, y_2 ],"ex9_2_4_C-Estacionario")


# Valor de la función objetivo
-33.88
         
 # Evaluacion en el punto 
 -33.88