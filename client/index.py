import streamlit as st
from sympy import symbols, sympify,Lt, Le, Gt, Ge, Eq
import json
import os
from enum import Enum,auto

#class ActiveIndex(Enum):
#    Normal=auto()
#    
#    def __str__(self):
#        return f"{self.name}"
#
#class LeaderActiveIndex(ActiveIndex):
#    J_G_0=auto()
#    
#class FollowerActiveIndex(ActiveIndex):
#    J_0_LP_v=auto()
#    J_0_L0_v=auto()
#    J_Ne_L0_v=auto()
    
def is_strict_inequality(expression_str: str) -> bool:
    # Convertir la expresión de string a una expresión simbólica
    expression = sympify(expression_str)

    # Verificar si la expresión es una desigualdad estricta
    return isinstance(expression, (Lt, Le, Gt, Ge))

def is_equation(expression_str: str) -> bool:
    
    
    # Convertir la expresión de string a una expresión simbólica
    expression = sympify(expression_str)

    # Verificar si la expresión es una ecuacion
    return isinstance(expression, (Lt, Le, Gt, Ge, Eq))

class Restriction:
    def __init__(self,expression,active_index:str):
        self.expression=expression
        self.active_index=active_index
    def __repr__(self):
        return self.expression
    def __str__(self):
        return self.expression
class LeaderRestriction(Restriction):
    def __init__(self, expression,active_index:str,miu):
        super().__init__(expression,active_index)
        self.miu=miu

class FollowerRestriction(Restriction):
    def __init__(self, expression, active_index,_lambda:float,_beta:float,_gamma:float):
        super().__init__(expression, active_index)
        self._lambda=_lambda
        self._beta=_beta
        self._gamma=_gamma
class Page:
    
    def run(self):
        st.sidebar.title("Navegación")
        seleccion = st.sidebar.selectbox("Selecciona una página:", list(self.paginas.keys()))

        # Mostrar la página seleccionada
        pagina = self.paginas[seleccion]
        pagina()

    def __init__(self):
         # Selector de páginas
        self.paginas = {
            "Inicio": self.pagina_inicio,
            "Generador del problema": self.problem_generator,
            "Acerca de": self.pagina_acerca_de
        }

        
        self.x_s:list[str]=[]
        self.y_s:list[str]=[]
        
        # Leader Zone
        self.leader_obj:str=""
        self.leader_restrictions:list[LeaderRestriction]=[]

        # Follower Zone
        self.follower_obj:str=""
        self.follower_restrictions:list[FollowerRestriction]=[]
    
        # Si no hay errores
        self._ok=True
        
    @property 
    def ok(self):
        self._ok
    
    @property
    def all_vars(self):
        return self.x_s+self.y_s
    
    @property
    def leader_active_index(self)->list[str]:
        return["Normal","J_0_g"]
    
    @property
    def follower_active_index(self)->list[str]:
        return["Normal","J_0_LP_v","J_0_L0_v","J_Ne_L0_v"]
   
    @property
    def normal_active_index(self)->str:
        return "Normal"
   
    
    # PAra notificar que hay un problema
    def set_error(self):
        self._ok=False
        
    def set_ok(self):
        self._ok=True
        
    
    def pagina_inicio(self):
        st.title("Problems Generator")
        st.write("¡Bienvenido al generador de problemas!")


    def _get_vars_from_expresion(self,expresion_str:str)->list[str]:
        # Primero ver si es una igualdad pq esta dan problemas
        
        if "==" in expresion_str: # Entonces quitar ==
            index=expresion_str.find("==")
            temp=expresion_str[:index]
            temp+=f" - {expresion_str[index+2:]} "
            expresion_str=temp
        
        # Convertir la expresión de string a una expresión simbólica
        expresion = sympify(expresion_str)
        # Encontrar las variables de la expresión
        variables:set = expresion.free_symbols
        vars_list=list(map(str,variables))
        return  vars_list
    
   

    # Retorna , False si no es correcta 
    def _check_ok_expresion(self,expresion_str:str)->bool:
        # Tomar las variables de la expresion
        vars_lis=self._get_vars_from_expresion(expresion_str)
        # # Verificar si todas las variables de la expresion son admisibles
        if all(elemento in self.all_vars for elemento in vars_lis):
            # Poner en false pq no hay errores
            self.set_ok()
            return True
        # En caso que haya errores
        errors=[elemento for elemento in vars_lis if elemento not in self.all_vars ]
        st.error(f"Las variables {errors} no han sido declaradas")
        # Poner que es en False pq hay errores
        self.set_error()
        return False
    #Conocer la declaraciones de las variables x_s y y_s 
    #en ese orden se retorna
    def _input_vars(self)->tuple[int,int]:

        leader_count_vars=st.number_input("Cantidad de variables del nivel superior",min_value=1)
        x_s=[f"x_{i}" for i in range(1, leader_count_vars+1)]
        st.write(f"Las variables del nivel superior son {x_s}")
        follower_count_vars=st.number_input("Cantidad de variables del nivel inferior",min_value=1)
        y_s=[f"y_{i}" for i in range(1,follower_count_vars+1)]
        st.write(f"Las variables del nivel inferior son {y_s}")
        self.x_s=x_s
        self.y_s=y_s
        return (x_s,y_s)

    def _show_in_latex(self,expresion:str,name:str="",key:str=""):
        if expresion:
            if name !="":
                st.write(f"La expresion {name}:",key=f"_show_in_latex_{key}")  
            else :
                st.write(f"La expresion:",key=f"_show_in_latex_{key}")

            st.latex(expresion)
    def _input_expresion(self,msg_input:str,key:str=""):
        # Entrada de texto para la expresión matemática
        expresion = st.text_input(f"Introduce {msg_input}:",key=f"_input_expresion_{key}")
        self._show_in_latex(expresion,key)
        # Entrada de las funciones 
        # Chequear que sean las variables correctas
        operators=["==", "<=", "=>",">="]
        if "=" in expresion and not any(op in expresion for op in operators):
            # Entonces cambio una por la otra
            expresion=expresion.replace("=","==")
        
        if expresion:
            self._check_ok_expresion(expresion)

        return expresion
   
    # manda a preguntar por una funcion objetivo
    def _input_objetive_function(self,key:str="")->str:
        obj_expresion=self._input_expresion("la función objectivo",key=key)
        # Si es una ecuacion mandar error
        if obj_expresion  not in [None,""," "] and is_equation(obj_expresion):
            st.error(f"La función objetivo {obj_expresion} no puede ser una ecuación")
            self.set_error()
        return obj_expresion  
    
    # Devuelve la expresion de la restriccion y el indice activo, True si es el nivel del lider False si no lo es
    def _save_expresion_and_active_index_restrictions(self,count:int,is_leader:bool)->tuple[str,str]:
         # Guardar la expresion
        key=f"Leader_restriction_{count}" if is_leader else f"Follower_restriction_{count}"
        
        # Ahora extraer la expresion
        s="líder" if is_leader else "seguidor"
        rest_expr=self._input_expresion(f"la restricción del {s}",key=key)
        # Guardar los tipos de indices activos del lider
        active_index=self.normal_active_index
        if rest_expr not in [None,""," "] and is_strict_inequality(rest_expr):
            # Si es una inecuacion entonces se dice que tipo de indice activo seleccionar
            temp=self.leader_active_index if is_leader else self.follower_active_index
            active_index=st.selectbox("Indices activos a seleccionar",temp)
            
        return rest_expr,active_index
    def _input_leader_restriction(self,count:int):
        # Decir en que restricciones estamos
        rest_expr,active_index= self._save_expresion_and_active_index_restrictions(count,True)
        # Ahora se da la seleccion que se pueda 
        miu=st.number_input("Valor de miu",key=f"miu_{count}")
        self.leader_restrictions.append(LeaderRestriction(rest_expr,active_index,miu))
        
    
    def _input_leader_problem(self):
        # Introducir la funcion objetivo del leader
        obj_expresion=self._input_objetive_function("leader_obj")
        self.leader_obj=obj_expresion
        # Introducir las restricciones 
         # Introducir las restricciones del lider
        count_leader_rest=st.number_input("Cantidad restricciones del líder",min_value=0)
        
        for count in range(1,count_leader_rest+1):
          self._input_leader_restriction(count)
        
        
    def _input_follower_restriction(self,count:int):
        # Decir en que restriccion estamos
        st.write(F"Introducir la restriccion del seguidor {count}")
         # Guardar la expresion
          # Decir en que restricciones estamos
        rest_expr,active_index= self._save_expresion_and_active_index_restrictions(count,False)
        # Ahora por los multiplicadores
        _lambda=st.number_input("Valor de lambda",key=f"lambda_{count}")
        _beta=st.number_input("Valor de Beta",key=f"beta_{count}")
        _gamma=st.number_input("Valor de gamma",key=f"gamma_{count}")
        self.follower_restrictions.append(FollowerRestriction(
            expression=rest_expr,
            active_index=active_index,
            _lambda=_lambda,
            _beta=_beta,
            _gamma=_gamma
        ))
    def _input_follower_problem(self):
        # INtroducir la funcion del follower
        obj_expresion=self._input_objetive_function("follower_obj")
        self.follower_obj=obj_expresion
        # Introducir las restricciones
        count_follower_rest=st.number_input("Cantidad restricciones del seguidor",min_value=0)
        
        for count in range(1,count_follower_rest+1):
            self._input_follower_restriction(count)
        
    def problem_generator(self):

        # Reiniciar el flag de error al actualizar el texto
        self.set_ok()

        st.title("Generar un Problema")
        st.write("Introduce los siguientes datos")
        # Declarar las variables
        with st.expander("Introducir Variables:"):
            x_s,y_s=self._input_vars()
        # Declarar nivel superior 
        with st.expander("Introducir el nivel superior:"):
            self._input_leader_problem()
        # Declarar nivel inferior
        with st.expander("Introducir el nivel inferior"):
            self._input_follower_problem()
        print(self.ok)
    
    def pagina_acerca_de(self):
        st.title("Acerca de")
        st.write("Esta es una aplicación de ejemplo creada con Streamlit.")

#TODO: False poder añadir el valor de alpha.
#TODO: Poner forma que se pueda generar sin poner valores osea solo con seleccionar los puntos
#TODO: Añadir el punto. 
Page().run()