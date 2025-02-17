
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

BilevelJuMP.@objective(Upper(model),Min, -x - 3y + -5.10x +3.00y) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, y +-4.51y) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,-11.27 + 1.26y<=0  
 c1,-0.96 - x + 0.89y<=0  
 c2,-7.00 + x<=0  
 c3,-50.65 + 4x + 2.44y<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x ],[ y ],"ex9_1_2_M-Estacionario")


# Valor de la función objetivo
-42.70
         
 # Evaluacion en el punto 
 -42.70