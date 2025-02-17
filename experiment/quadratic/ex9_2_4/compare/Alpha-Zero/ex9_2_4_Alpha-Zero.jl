
include("../../../../experiment.jl")
        
using BilevelJuMP
using Random

# Introducir semilla

Random.seed!(14)

# Crear Modelo Base
model = BilevelModel()

# Crear Variables

# Variables del Lider 
 BilevelJuMP.@variable(Upper(model), x) 

# Variables del follower 
 BilevelJuMP.@variable(Lower(model), y_1) 
 BilevelJuMP.@variable(Lower(model), y_2) 


# Definir Nivel Superior

BilevelJuMP.@objective(Upper(model),Min, 0.50((-2 + y_1)^2 + (-2 + y_2)^2) + -0.00x +-8.45y_1 +-12.40y_2) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, y_2 + 0.50(y_1^2) +-4.54y_1 +-0.74y_2) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,-x + y_1 + y_2<=0  
 c1,4.85 - y_1<=0  
 c2,-4.70 - y_2<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x ],[ y_1, y_2 ],"ex9_2_4_Alpha-Zero")


# Valor de la función objetivo
-91.56
         
 # Evaluacion en el punto 
 -91.56