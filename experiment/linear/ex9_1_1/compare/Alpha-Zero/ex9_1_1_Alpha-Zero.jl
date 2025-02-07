
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

BilevelJuMP.@objective(Upper(model),Min, -x - 3y_1 + 2y_2 + 1.00x +8.50y_1 +-2.00y_2) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, -y_1) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,5.00 - y_1<=0  
 c1,-5.00 + y_1<=0  
 c2,3.00 - 2x + y_1 + 4y_2<=0  
 c3,-70.46 + 8x + y_1<=0  
 c4,-2.20 - 2x - 2y_1<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x ],[ y_1, y_2 ],"ex9_1_1_Alpha-Zero")

         
 # Evaluacion en el punto 
 27.50