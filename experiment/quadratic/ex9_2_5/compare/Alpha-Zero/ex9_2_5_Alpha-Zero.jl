
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

BilevelJuMP.@objective(Upper(model),Min, (-3 + x)^2 + (-2 + y)^2 + -6.10x +6.20y) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, (-5 + y)^2) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,-12.85 + x + 2y<=0  
 c1,3.35 + x - 2y<=0  
 c2,-7.45 - 2x + y<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x ],[ y ],"ex9_2_5_Alpha-Zero")

         
 # Evaluacion en el punto 
 3.40