
include("../../../../experiment.jl")
        
using BilevelJuMP
using Random

# Introducir semilla

Random.seed!(10)

# Crear Modelo Base
model = BilevelModel()

# Crear Variables

# Variables del Lider 
 BilevelJuMP.@variable(Upper(model), x) 

# Variables del follower 
 BilevelJuMP.@variable(Lower(model), y) 


# Definir Nivel Superior

BilevelJuMP.@objective(Upper(model),Min, x + y + -1.00x +-1.00y) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, -5x - y +-2.15y) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,-2.67 - x + 1.21y<=0  
 c1,-19.02 - 0.25x + 3.28y<=0  
 c2,-4.78 + x<=0  
 c3,-16.69 + x + 1.90y<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x ],[ y ],"ex9_1_9_M-Estacionario")


# Valor de la función objetivo
0.00
         
 # Evaluacion en el punto 
 0.00