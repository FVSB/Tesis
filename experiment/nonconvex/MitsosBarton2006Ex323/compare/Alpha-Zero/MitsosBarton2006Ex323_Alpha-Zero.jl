
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

@objective(model,Min,x^2 + 11.34x +9.44y)

# Definir KKT


        # Make KKT
        

         @NLconstraint(model,1+(l_1*(2*y*(x - 0.50)))+(l_2*(1))+(l_3*(-1))==0)  
  


# Definir restricciones


         # Restricciones no lineales 
 @NLconstraint(model,-19.71 + (-0.50 + x)*(y^2)<=0)
# Restricciones
        @constraints(model,begin
        
        
 1.94 - x<=0 

 -1.94 + x<=0 

 35.63 + x - y - 9(x^2)<=0 

 -3.70 + y<=0 

 -5.70 - y<=0 

 end)

# Definir variables de complementariedad


        
         
 @complements(model,0<=-(-19.71 + (-0.50 + x)*(y^2)),l_1>=0) 
 
 @complements(model,0<=-(-3.70 + y),l_2>=0) 
 
 @complements(model,0<=-(-5.70 - y),l_3>=0) 



# Resolver el modelo

make_experiment(model,[ x ],[ y ],"Reformulacion_KKT","MitsosBarton2006Ex323_Alpha-Zero")

println("Se Finalizo el experimento MitsosBarton2006Ex323")

        
        