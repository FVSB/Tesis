
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

BilevelJuMP.@objective(Upper(model),Min, -60 + 2x_1 + 2x_2 - 3y_1 - 3y_2 + -2.86x_1 + -2.86x_2 +-0.76y_1 +-3.18y_2) 

              # Restricciones del Nivel Superior
              BilevelJuMP.@constraints(Upper(model),begin 

         a1,-16.45 + x_1 + x_2 + y_1 - 2y_2<=0  

 end) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, (20 - x_1 + y_1)^2 + (20 - x_2 + y_2)^2) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,18.85 - x_1 + 2y_2<=0  
 c1,20.00 - x_2 + 2y_2<=0  
 c2,-5.10 - y_1<=0  
 c3,5.10 + y_1<=0  
 c4,-11.35 - y_2<=0  
 c5,-48.65 + y_2<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x_1, x_2 ],[ y_1, y_2 ],"ex9_2_3_Alpha-Zero")

         
 # Evaluacion en el punto 
 8.98