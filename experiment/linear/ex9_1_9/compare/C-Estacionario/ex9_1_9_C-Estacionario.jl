
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

BilevelJuMP.@objective(Upper(model),Min, x + y + -10.80x +-51.74y) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, -5x - y +6.91y) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,30.03 - x - 4.09y<=0  
 c1,1.20 - 0.25x<=0  
 c2,-4.78 + x<=0  
 c3,-5.60 + x<=0  
 c4,-16.40 - 2.66y<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x ],[ y ],"ex9_1_9_C-Estacionario")


# Valor de la función objetivo
-359.91
         
 # Evaluacion en el punto 
 -359.91