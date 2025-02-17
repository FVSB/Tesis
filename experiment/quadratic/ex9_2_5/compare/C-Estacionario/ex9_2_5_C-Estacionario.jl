
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

BilevelJuMP.@objective(Upper(model),Min, (-3 + x)^2 + (-2 + y)^2 + -4.20x +-7.43y) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, (-5 + y)^2 +3.13y) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,-4.75 + x<=0  
 c1,-13.90 + x + 2.26y<=0  
 c2,-28.80 - 2x - 4.27y<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x ],[ y ],"ex9_2_5_C-Estacionario")


# Valor de la función objetivo
-42.78
         
 # Evaluacion en el punto 
 -42.78