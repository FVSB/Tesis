
using JuMP, Ipopt, Complementarity
using Random
include("../../../../experiment_non_convex.jl")
# Introducir semilla

Random.seed!(1)
    
# Crear el modelo
model = Model(Ipopt.Optimizer)


        # Definir variables 

         
  @variable(model,x)  
 
  @variable(model,y)  
  
  @variable(model,l_1) 
  
  @variable(model,l_2) 


# Definir la funcion objetivo

@objective(model,Min,-x + x*y + 10(y^2) + 2.19x +-0.35y)

# Definir KKT


        # Make KKT
        

         @NLconstraint(model,-2*x*y + 2.00*y^3+(l_1*(2.00))+(l_2*(0))==0)  
  


# Definir restricciones


        
# Restricciones
        @constraints(model,begin
        
        
 1.90 - x<=0 

 -1.90 + x<=0 

 -0.30 + 2.00y<=0 

 0<=0 

 end)

# Definir variables de complementariedad


        
         
 @complements(model,0<=-(-0.30 + 2.00y),l_1>=0) 
 
 @complements(model,0<=-(0),l_2>=0) 



# Resolver el modelo

make_experiment(model,[ x ],[ y ],"Reformulacion_KKT","MitsosBarton2006Ex312_Fuertemente-Estacionario")

println("Se Finalizo el experimento MitsosBarton2006Ex312")

        
        