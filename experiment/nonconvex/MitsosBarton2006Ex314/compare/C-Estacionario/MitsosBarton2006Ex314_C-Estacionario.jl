
using JuMP, Ipopt, Complementarity
using Random
include("../../../../experiment_non_convex.jl")
# Introducir semilla

Random.seed!(3)
    
# Crear el modelo
model = Model(Ipopt.Optimizer)


        # Definir variables 

         
  @variable(model,x)  
 
  @variable(model,y)  
  
  @variable(model,l_1) 
  
  @variable(model,l_2) 


# Definir la funcion objetivo

@objective(model,Min,(-0.25 + x)^2 + y^2 + -0.92x +-9.61y)

# Definir KKT


        # Make KKT
        

         @NLconstraint(model,-x + 0.99*y^2+(l_1*(0))+(l_2*(0))==0)  
  


# Definir restricciones


        
# Restricciones
        @constraints(model,begin
        
        
 -0.90 + x<=0 

 0.90 - x<=0 

 0<=0 

 0<=0 

 end)

# Definir variables de complementariedad


        
         
 @complements(model,0<=-(0),l_1>=0) 
 
 @complements(model,0<=-(0),l_2>=0) 



# Resolver el modelo

make_experiment(model,[ x ],[ y ],"Reformulacion_KKT","MitsosBarton2006Ex314_C-Estacionario")

println("Se Finalizo el experimento MitsosBarton2006Ex314")

        
        