
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

BilevelJuMP.@objective(Upper(model),Min, (-5 + x)^2 + (1 + 2y)^2 + 19.95x +-114.54y) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, -1.50x*y + (-1 + y)^2 +-6.02y) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,-26.48 - 3x + 6.89y<=0  
 c1,-1.62 + x - 0.05y<=0  
 c2,-9.05 + x + 0.67y<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x ],[ y ],"ex9_2_1_Fuertemente-Estacionario")


# Valor de la función objetivo
-379.69
         
 # Evaluacion en el punto 
 -379.69