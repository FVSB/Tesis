
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

BilevelJuMP.@objective(Upper(model),Min, -60 + 2x_1 + 2x_2 - 3y_1 - 3y_2 + 9.32x_1 + 4.70x_2 +-17.60y_1 +-21.61y_2) 

              # Restricciones del Nivel Superior
              BilevelJuMP.@constraints(Upper(model),begin 

         a1,-16.45 + x_1 + x_2 + y_1 - 2y_2<=0  

 end) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, (20 - x_1 + y_1)^2 + (20 - x_2 + y_2)^2) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,18.96 - x_1 + 0.01y_1 + 2.01y_2<=0  
 c1,13.09 - x_2 - 0.60y_1 + 1.55y_2<=0  
 c2,19.73 + 1.14y_1 + 1.61y_2<=0  
 c3,-19.37 - 1.11y_1 - 1.58y_2<=0  
 c4,-37.14 + 2.23y_1 + 0.67y_2<=0  
 c5,-56.29 + 0.66y_1 + 1.49y_2<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x_1, x_2 ],[ y_1, y_2 ],"ex9_2_3_Fuertemente-Estacionario")


# Valor de la función objetivo
293.57
         
 # Evaluacion en el punto 
 293.57