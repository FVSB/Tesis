
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

BilevelJuMP.@objective(Upper(model),Min, -x - 3y_1 + 2y_2 + 1.00x +3.00y_1 +-2.00y_2) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, -y_1) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,1.42 - 0.49y_1 + 0.50y_2<=0  
 c1,-1.42 + 0.49y_1 - 0.50y_2<=0  
 c2,20.58 - 2x - 1.51y_1 + 1.55y_2<=0  
 c3,-67.02 + 8x + 0.49y_1 - 0.50y_2<=0  
 c4,4.97 - 2x - 0.98y_1 + 1.00y_2<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x ],[ y_1, y_2 ],"ex9_1_1_C-Estacionario")

         
 # Evaluacion en el punto 
 0.00