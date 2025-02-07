
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

BilevelJuMP.@objective(Upper(model),Min, (-5 + x)^2 + (1 + 2y)^2 + 27.00x +-58.55y) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, -1.50x*y + (-1 + y)^2) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,0.90 - 3x + y<=0  
 c1,0.47 + x - 0.50y<=0  
 c2,-7.50 + x + y<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x ],[ y ],"ex9_2_1_Alpha-Zero")

         
 # Evaluacion en el punto 
 -106.29