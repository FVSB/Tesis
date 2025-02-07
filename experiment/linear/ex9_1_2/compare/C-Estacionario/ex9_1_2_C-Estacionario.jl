
include("../../../../experiment.jl")
        
using BilevelJuMP
using Random

# Introducir semilla

Random.seed!(8)

# Crear Modelo Base
model = BilevelModel()

# Crear Variables

# Variables del Lider 
 BilevelJuMP.@variable(Upper(model), x) 

# Variables del follower 
 BilevelJuMP.@variable(Lower(model), y) 


# Definir Nivel Superior

BilevelJuMP.@objective(Upper(model),Min, -x - 3y + 1.00x +-56.59y) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, y) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,63.49 - 7.09y<=0  
 c1,7.00 - x<=0  
 c2,-7.00 + x<=0  
 c3,-28.82 + 4x<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x ],[ y ],"ex9_1_2_C-Estacionario")

         
 # Evaluacion en el punto 
 -533.33