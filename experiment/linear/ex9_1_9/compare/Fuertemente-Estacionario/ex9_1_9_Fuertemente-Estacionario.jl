
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

BilevelJuMP.@objective(Upper(model),Min, x + y + -11.07x +-81.17y) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, -5x - y) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,-15.45 - x + 3.28y<=0  
 c1,-21.03 - 0.25x + 3.60y<=0  
 c2,-4.78 + x<=0  
 c3,-28.19 + x + 3.76y<=0  
 c4,-17.56 + 2.74y<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x ],[ y ],"ex9_1_9_Fuertemente-Estacionario")


# Valor de la función objetivo
-542.78
         
 # Evaluacion en el punto 
 -542.78