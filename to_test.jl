# Install Modules
import Pkg;
#Pkg.add("Symbolics")
#Pkg.add("LinearAlgebra")



# Import Generator Modules

include("def_problem/solver.jl")
# Import Symbolics declare the problmes
using  Symbolics

# Definir la variables del lider 

lider_vars=["x_1","x_2"]

# Definir las variables del seguidor

follower_vars=["y_1","y_2"]

# Definir las variables del problema con Symbolics
# Esto lo hace el modulo pero sin compilar puede dar problemas

follower_vars_symbolic=map(convert_Symbol_to_symbolic_num,follower_vars)

# Variables del problemas
problem_vars_str=vcat(lider_vars,follower_vars)

# Convertir las variables del problema a Symbolicas
problem_vars=map(convert_Symbol_to_symbolic_num,problem_vars_str)

# Definir el lider 

leader_func_str::String="((x_1^2)*(y_1^2)*(y_2))+x_2"

# Definir las restricciones del lider  
#  Normal, J_0_g, J_0_LP_v, J_0_L0_v, J_Ne_L0_v ( Escribe asi mismo cual desea)
Normal
J_0_g
J_0_LP_v
J_0_L0_v
J_Ne_L0_v

# Se define la restriccion del lider (Puede tener varias)
# Se entra en string la restriccion con == El tipo de indice activo
# Y el tipo de restriccion
# Tipo de restricciones 
Eq
Gt
Lt
GtEq
LtEq
# Entra:
# String con la restriccion, Tipo de indice activo, Tipo de restriccion , Si es restriccion del lider, True si lo es
# miu, beta, Lambda, gamma
g_1=Def_Restriction_init("x_1+y_2-y_1==9",J_0_g,Gt,true,0.3,0,0,0)

# Como puede ver varias restricciones pues se lleva a una lista

g_s=[g_1]

# Definimos el nivel inferior

Follower_str_expr="((x_2^2)*(y_1^2)*(y_2))+x_1"

# Definir restriccion del nivel inferior
# Analogo con Beta = 1 y Lambda = 0 gamma=1
v_1=Def_Restriction_init("((x_1^2)*(y_1^2))+x_2==0",J_Ne_L0_v,Eq,false,0,1,0,1)

#  Beta=0.5 Lambda=0 gamma=1
v_2=Def_Restriction_init("((x_1^2)*(y_1^2)*(y_2))+x_2==0",J_0_LP_v,LtEq,false,0,0.5,1,1)

v_s=[v_1,v_2]

# Declarar alpha debe ser de la dim de las YS

alpha=[1,2]

# Declarar el pto:

point=Dict("x_1"=>1,"x_2"=>1,"y_1"=>1,"y_2"=>1)

# Crear el problema de optimizacion modificado, Aca es donde se ajustan las restricciones
# para hacer factible el pto, se modican ademas estas haciendo el KKT del nivel inferior y las transformacion para hallar los b_j

opt_problem=Fix_Restrictions(leader_func_str,g_s,Follower_str_expr,v_s,point,lider_vars,follower_vars,alpha,false)

# Se halla el vector BF haciendo el KKT del MPEC
BF_1=Make_BF(opt_problem,lider_vars,follower_vars,alpha)