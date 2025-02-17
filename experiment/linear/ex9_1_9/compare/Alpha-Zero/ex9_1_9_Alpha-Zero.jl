
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

BilevelJuMP.@objective(Upper(model),Min, x + y + -1.20x +-0.20y) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, -5x - y +2.21y) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,7.87 - x - 0.50y<=0  
 c1,-4.97 - 0.25x + y<=0  
 c2,-7.87 + x + 0.50y<=0  
 c3,-11.56 + x - 2y<=0  
 c4,-6.17 - y<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x ],[ y ],"ex9_1_9_Alpha-Zero")


# Valor de la función objetivo
3.98
         
 # Evaluacion en el punto 
 3.98