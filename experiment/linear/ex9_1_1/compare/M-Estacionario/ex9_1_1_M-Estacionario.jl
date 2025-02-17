
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

BilevelJuMP.@objective(Upper(model),Min, -x - 3y_1 + 2y_2 + -57.40x +4.33y_1 +-3.95y_2) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, -y_1 +2.02y_1 +-1.49y_2) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,0.73 - 0.32y_1 + 0.47y_2<=0  
 c1,-0.73 + 0.32y_1 - 0.47y_2<=0  
 c2,15.66 - 2x - 1.54y_1 + 2.26y_2<=0  
 c3,-49.83 + 8x + 0.32y_1 - 0.47y_2<=0  
 c4,10.43 - 2x - 0.64y_1 + 0.93y_2<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x ],[ y_1, y_2 ],"ex9_1_1_M-Estacionario")


# Valor de la función objetivo
-350.25
         
 # Evaluacion en el punto 
 -350.25