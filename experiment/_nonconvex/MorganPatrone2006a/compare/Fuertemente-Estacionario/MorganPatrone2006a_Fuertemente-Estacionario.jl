
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

@objective(model,Min,-x - y + -1.07x +-16.89y)

# Definir KKT


        # Make KKT
        

         @NLconstraint(model,x - 3.42+(l_1*(2.98))+(l_2*(-16))==0)  
  


# Definir restricciones


        
# Restricciones
        @constraints(model,begin
        
        
 2.85 - x<=0 

 -2.85 + x<=0 

 -13.27 + 2.98y<=0 

 -4.44e-16 + 1.11e-16y<=0 

 end)

# Definir variables de complementariedad


        
         
 @complements(model,0<=-(-13.27 + 2.98y),l_1>=0) 
 
 @complements(model,0<=-(-4.44e-16 + 1.11e-16y),l_2>=0) 



# Resolver el modelo

make_experiment(model,[ x ],[ y ],"Reformulacion_KKT","MorganPatrone2006a_Fuertemente-Estacionario")

println("Se Finalizo el experimento MorganPatrone2006a")

        
         
 # Evaluacion en el punto 
 -85.51