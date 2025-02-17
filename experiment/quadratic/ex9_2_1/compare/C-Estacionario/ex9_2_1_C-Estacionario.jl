
include("../../../../experiment.jl")
        
using BilevelJuMP
using Random

# Introducir semilla

Random.seed!(11)

# Crear Modelo Base
model = BilevelModel()

# Crear Variables

# Variables del Lider 
 BilevelJuMP.@variable(Upper(model), x) 

# Variables del follower 
 BilevelJuMP.@variable(Lower(model), y) 


# Definir Nivel Superior

BilevelJuMP.@objective(Upper(model),Min, (-5 + x)^2 + (1 + 2y)^2 + 46.92x +-47.48y) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, -1.50x*y + (-1 + y)^2 +-3.77y) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,5.55 - 3x<=0  
 c1,-4.20 + x + 0.51y<=0  
 c2,-16.55 + x - 0.95y<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x ],[ y ],"ex9_2_1_C-Estacionario")


# Valor de la función objetivo
-17.97
         
 # Evaluacion en el punto 
 -17.97