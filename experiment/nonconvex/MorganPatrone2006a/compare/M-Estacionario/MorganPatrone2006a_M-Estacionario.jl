
using JuMP, Ipopt, Complementarity
using Random
include("../../../../experiment_non_convex.jl")
# Introducir semilla

Random.seed!(5)
    
# Crear el modelo
model = Model(Ipopt.Optimizer)


        # Definir variables 

         
  @variable(model,x)  
 
  @variable(model,y)  
  
  @variable(model,l_1) 
  
  @variable(model,l_2) 


# Definir la funcion objetivo

@objective(model,Min,-x - y + 0.49x +1.00y)

# Definir KKT


        # Make KKT
        

         @NLconstraint(model,x+(l_1*(-16))+(l_2*(-16))==0)  
  


# Definir restricciones


        
# Restricciones
        @constraints(model,begin
        
        
 2.85 - x<=0 

 -2.85 + x<=0 

 4.44e-16 - 1.11e-16y<=0 

 -4.44e-16 + 1.11e-16y<=0 

 end)

# Definir variables de complementariedad


        
         
 @complements(model,0<=-(4.44e-16 - 1.11e-16y),l_1>=0) 
 
 @complements(model,0<=-(-4.44e-16 + 1.11e-16y),l_2>=0) 



# Resolver el modelo

make_experiment(model,[ x ],[ y ],"Reformulacion_KKT","MorganPatrone2006a_M-Estacionario")

println("Se Finalizo el experimento MorganPatrone2006a")

        
        