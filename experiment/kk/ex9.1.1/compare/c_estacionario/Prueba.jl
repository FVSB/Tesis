
include("../../../../experiment.jl")
        
using BilevelJuMP
using Random

# Introducir semilla

Random.seed!(1)

# Crear Modelo Base
model = BilevelModel()

# Crear Variables

# Variables del Lider 
 BilevelJuMP.@variable(Upper(model), y_1) 
 BilevelJuMP.@variable(Upper(model), y_2) 

# Variables del follower 
 BilevelJuMP.@variable(Lower(model), y_1) 
 BilevelJuMP.@variable(Lower(model), y_2) 


# Definir Nivel Superior

BilevelJuMP.@objective(Upper(model),Min, -x - 3y_1 + 2y_2 + -63.39999999999999x +31.596635705782617y_1 +22.2015343561485y_2) 


# Crear el Nivel Inferior

BilevelJuMP.@objective(Lower(model),Min, -y_1) 

                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin 

         c0,-2.0847668467443836 - 0.09833191166714061y_1 + 1.105819353615771y_2<=0  
 c1,5.3586508387830545 - 0.17794521846270506y_1 - 1.444649796227846y_2<=0  
 c2,65.31672418109892 - 2x - 4.93390077477628y_1 - 3.277425478499212y_2<=0  
 c3,-61.25774950241683 + 8x + 0.6006539664486779y_1 - 0.4897640034119989y_2<=0  
 c4,-27.698080750639754 - 2x - 3.7129182068050426y_1 - 2.1007487441948633y_2<=0  

 end) 


# Iniciar experimento
start_experiment(model,[ x ],[ y_1, y_2 ],"ex9.1.1")

        