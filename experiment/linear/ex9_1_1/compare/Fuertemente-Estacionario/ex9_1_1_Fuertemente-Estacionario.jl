
include("../../../../experiment.jl")
        
using BilevelJuMP
using Random

# Introducir semilla

Random.seed!(6)

# Crear Modelo Base
model = BilevelModel()

# Crear Variables

# Variables del Lider 
 BilevelJuMP.@variable(Upper(model), x) 

# Variables del follower 
 BilevelJuMP.@variable(Lower(model), y_1) 
 BilevelJuMP.@variable(Lower(model), y_2) 


# Definir Nivel Superior

BilevelJuMP.@objective(Upper(model),Min, -x - 3y_1 + 2y_2 + 2.60x +-15.05y_1 +-28.32y_2) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, -y_1 +-0.32y_1 +-3.89y_2) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,-14.23 + 0.69y_1 + 3.06y_2<=0  
 c1,-19.79 + 2.04y_1 + 1.88y_2<=0  
 c2,16.88 - 2x - 0.93y_1 + 0.52y_2<=0  
 c3,-54.94 + 8x + 0.92y_1 - 0.15y_2<=0  
 c4,2.42 - 2x - 0.16y_1 + 3.31y_2<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x ],[ y_1, y_2 ],"ex9_1_1_Fuertemente-Estacionario")


# Valor de la función objetivo
-195.55
         
 # Evaluacion en el punto 
 -195.55