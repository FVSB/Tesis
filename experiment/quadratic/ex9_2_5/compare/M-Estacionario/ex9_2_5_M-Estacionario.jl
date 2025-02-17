
include("../../../../experiment.jl")
        
using BilevelJuMP
using Random

# Introducir semilla

Random.seed!(15)

# Crear Modelo Base
model = BilevelModel()

# Crear Variables

# Variables del Lider 
 BilevelJuMP.@variable(Upper(model), x) 

# Variables del follower 
 BilevelJuMP.@variable(Lower(model), y) 


# Definir Nivel Superior

BilevelJuMP.@objective(Upper(model),Min, (-3 + x)^2 + (-2 + y)^2 + -3.30x +-28.30y) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, (-5 + y)^2 +0.12y) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,-9.75 + x + 1.23y<=0  
 c1,-9.77 + x + 1.24y<=0  
 c2,-5.07 - 2x + 3.58y<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x ],[ y ],"ex9_2_5_M-Estacionario")


# Valor de la función objetivo
-123.02
         
 # Evaluacion en el punto 
 -123.02