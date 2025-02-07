
using JuMP, Ipopt, Complementarity
using Random
include("../../../../experiment_non_convex.jl")
# Introducir semilla

Random.seed!(2)
    
# Crear el modelo
model = Model(Ipopt.Optimizer)


        # Definir variables 

         
  @variable(model,x)  
 
  @variable(model,y)  
  
  @variable(model,l_1) 
  
  @variable(model,l_2) 


# Definir la funcion objetivo

@objective(model,Min,x - y + -1.48x +1.00y)

# Definir KKT


        # Make KKT
        

         @NLconstraint(model,-x^3 + 1.00*x*y+(l_1*(1))+(l_2*(-1))==0)  
  


# Definir restricciones


        
# Restricciones
        @constraints(model,begin
        
        
 1.05 - x<=0 

 -1.05 + x<=0 

 -2.85 + y<=0 

 2.85 - y<=0 

 end)

# Definir variables de complementariedad


        
         
 @complements(model,0<=-(-2.85 + y),l_1>=0) 
 
 @complements(model,0<=-(2.85 - y),l_2>=0) 



# Resolver el modelo

make_experiment(model,[ x ],[ y ],"Reformulacion_KKT","MitsosBarton2006Ex313_Alpha-Zero")

println("Se Finalizo el experimento MitsosBarton2006Ex313")

        
         
 # Evaluacion en el punto 
 -0.50