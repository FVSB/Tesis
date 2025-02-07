
include("../../../../experiment.jl")
        
using BilevelJuMP
using Random

# Introducir semilla

Random.seed!(12)

# Crear Modelo Base
model = BilevelModel()

# Crear Variables

# Variables del Lider 
 BilevelJuMP.@variable(Upper(model), x) 

# Variables del follower 
 BilevelJuMP.@variable(Lower(model), y) 


# Definir Nivel Superior

BilevelJuMP.@objective(Upper(model),Min, x^2 + (-10 + y)^2 + -28.50x +-16.10y) 

              # Restricciones del Nivel Superior
              BilevelJuMP.@constraints(Upper(model),begin 

         a1,0.05 - x + y<=0  

 end) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, (-30 + x + 2y)^2) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,-28.85 + x + y<=0  
 c1,14.40 - y<=0  
 c2,-25.60 + y<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x ],[ y ],"ex9_2_2_Alpha-Zero")


# Valor de la función objetivo
-415.50
         
 # Evaluacion en el punto 
 -415.50