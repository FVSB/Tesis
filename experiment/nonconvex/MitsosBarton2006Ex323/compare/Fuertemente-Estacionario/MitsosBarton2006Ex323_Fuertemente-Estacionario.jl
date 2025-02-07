
using JuMP, Ipopt, Complementarity
using Random
include("../../../../experiment_non_convex.jl")
# Introducir semilla

Random.seed!(4)
    
# Crear el modelo
model = Model(Ipopt.Optimizer)


        # Definir variables 

         
  @variable(model,x)  
 
  @variable(model,y)  
  
  @variable(model,l_1) 
  
  @variable(model,l_2) 
  
  @variable(model,l_3) 


# Definir la funcion objetivo

@objective(model,Min,x^2 + -35.51x +-96.21y)

# Definir KKT


        # Make KKT
        

         @NLconstraint(model,1+(l_1*(2*y*(x - 0.50) + 3.63))+(l_2*(0))+(l_3*(8.57))==0)  
  


# Definir restricciones


         # Restricciones no lineales 
 @NLconstraint(model,-33.14 + 3.63y + (-0.50 + x)*(y^2)<=0)
# Restricciones
        @constraints(model,begin
        
        
 1.94 - x<=0 

 -1.94 + x<=0 

 35.63 + x - y - 9(x^2)<=0 

 0<=0 

 -32.20 + 8.57y<=0 

 end)

# Definir variables de complementariedad


        
         
 @complements(model,0<=-(-33.14 + 3.63y + (-0.50 + x)*(y^2)),l_1>=0) 
 
 @complements(model,0<=-(0),l_2>=0) 
 
 @complements(model,0<=-(-32.20 + 8.57y),l_3>=0) 



# Resolver el modelo

make_experiment(model,[ x ],[ y ],"Reformulacion_KKT","MitsosBarton2006Ex323_Fuertemente-Estacionario")

println("Se Finalizo el experimento MitsosBarton2006Ex323")

        
         
 # Evaluacion en el punto 
 -421.10