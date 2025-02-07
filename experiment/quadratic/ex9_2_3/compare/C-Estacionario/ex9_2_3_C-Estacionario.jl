
include("../../../../experiment.jl")
        
using BilevelJuMP
using Random

# Introducir semilla

Random.seed!(13)

# Crear Modelo Base
model = BilevelModel()

# Crear Variables

# Variables del Lider 
 BilevelJuMP.@variable(Upper(model), x_1) 
 BilevelJuMP.@variable(Upper(model), x_2) 

# Variables del follower 
 BilevelJuMP.@variable(Lower(model), y_1) 
 BilevelJuMP.@variable(Lower(model), y_2) 


# Definir Nivel Superior

BilevelJuMP.@objective(Upper(model),Min, -60 + 2x_1 + 2x_2 - 3y_1 - 3y_2 + -10.96x_1 + 4.88x_2 +-16.87y_1 +-33.74y_2) 

              # Restricciones del Nivel Superior
              BilevelJuMP.@constraints(Upper(model),begin 

         a1,-16.45 + x_1 + x_2 + y_1 - 2y_2<=0  

 end) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, (20 - x_1 + y_1)^2 + (20 - x_2 + y_2)^2) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,-18.85 - x_1 - 1.38y_1 - 1.54y_2<=0  
 c1,1.53 - x_2 - 0.68y_1 + 0.26y_2<=0  
 c2,-1.49 - 0.87y_1 + 0.34y_2<=0  
 c3,-2.33 + 0.73y_1 - 0.70y_2<=0  
 c4,-40.78 + 1.08y_1 + 1.77y_2<=0  
 c5,-60.58 + 0.44y_1 + 2.12y_2<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x_1, x_2 ],[ y_1, y_2 ],"ex9_2_3_C-Estacionario")


# Valor de la función objetivo
363.83
         
 # Evaluacion en el punto 
 363.83