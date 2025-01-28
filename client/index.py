import streamlit as st
from sympy import symbols, sympify,Lt, Le, Gt, Ge, Eq
import json
import os
from enum import Enum,auto
import random
import uuid

def get_guid():
    # Generar un GUID
    nuevo_guid = uuid.uuid4()
    return nuevo_guid

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
    return isinstance(expression, (Lt, Le, Gt, Ge, Eq))  or "==" in expression_str

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
        
        # Point
        self._point:list[float]=[]
        
        # Alpha
        self._alpha:list[float]=[]
        self._alpha_zero:bool=True
        # Leader Zone
        self.leader_obj:str=""
        self.leader_restrictions:list[LeaderRestriction]=[]

        # Follower Zone
        self.follower_obj:str=""
        self.follower_restrictions:list[FollowerRestriction]=[]
    
        # Si no hay errores
        self._errors_count:int=0
        #self._ok=True
        
    @property 
    def ok(self)->bool:
        return self._errors_count==0
    
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
        self._errors_count+=1
        
    def set_ok(self):
        if self._errors_count==0:
            return
           # raise Exception("El valor de la cant de errores no puede ser negativo")
        self._errors_count-=1
        
    
    def pagina_inicio(self):
        st.title("Problems Generator")
        st.write("¡Bienvenido al generador de problemas!")
    def _gen_random_vector(self,_len:int,msg:str,key:str,min_value:int=0,max_value:int=1):
        max_key=f"min_value_{key}"
        min_range:float=st.number_input("Valor mínimo",value=min_value,key=max_key)
        min_key=f"max_value_{key}"
        max_range:float=st.number_input("Valor máximo",value=max_value,key=min_key)
        lis_key=f"lis_{key}"
        lis:list[float]=[]
        # Si los rangos han cambiado, regenerar la lista
        current_min = st.session_state[min_key]
        current_max = st.session_state[max_key]
        if current_min != min_range or current_max != max_range:
            st.session_state[lis_key] = [random.uniform(min_range, max_range) for _ in range(_len)]
            lis=st.session_state[lis_key]
        else:      
                
            if lis_key not in st.session_state:
                st.session_state[lis_key]=[random.uniform(min_range,max_range) for _ in range(_len)]
                lis=st.session_state[lis_key]
            else: # Ahora si esta usar la que estaba
                lis=st.session_state[lis_key]
                if len(lis)!=_len: #Entonces crear otra vez
                    del st.session_state[lis_key]
                    st.session_state[lis_key]=[random.uniform(min_range,max_range) for _ in range(_len)]
                    lis=st.session_state[lis_key]
   
            
        st.text(f"{msg}: \n {lis}")
        return lis
    def _set_alpha(self):
        # Entrada de texto del usuario
        option=st.checkbox("Desea que alpha sea el vector nulo",value=True)
        
        if option:
            # Entonces ahora se dice qu el vector es nulo
            self._alpha_zero=True
            return
        # Poner que alpha no es el vector nulo
        self._alpha_zero=False
        alpha_length=len(self.y_s)
        # Preguntar si desea generarlo aleatorio
        random_alpha:bool=None
        random_alpha=st.checkbox("Generar alpha aleatoriamente",value=True)
        if random_alpha: #Preguntar los rangos
           
            # Generar la el vector
            self._alpha=self._gen_random_vector(alpha_length,"El valor de alpha generado es",key="set_alpha")
            
        else: # Si no es valor random entonces es otro
            numeros_texto = st.text_area("Ingresa una lista de números, separados por comas:")
            # Procesar el texto ingresado en una lista de números
            if numeros_texto:
                try:
                    numeros = [float(num.strip()) for num in numeros_texto.split(',')]
                    st.write("Lista de números ingresada:", numeros)
                    if len(numeros)!=alpha_length:
                        #Lanzar error 
                        st.error(f"La cantidad de componente de alpha es {alpha_length} no {len(numeros)}")
                        self.set_error()
                    else:
                        self.set_ok()
                        self._alpha=numeros
                        self._alpha_zero=False
                        st.text(f"El vector alpha es \n {self._alpha}")
                        
                except ValueError:
                    st.error("Por favor, asegúrate de ingresar números válidos, separados por comas.")
    def set_point(self):
        random_point=st.checkbox("Desea que el punto sea generado aleatoriamente",value=True)
        point_len=len(self.x_s)+len(self.y_s)
        if random_point: # Se genera un punto aleatorioc de length(x+y) valores
            self._point=self._gen_random_vector(point_len,"El punto que se desea hacer estacionario es",key="set_point")
            return
        else: # Si no es valor random entonces es otro
            numeros_texto = st.text_area("Ingresa una lista de números, separados por comas:")
            # Procesar el texto ingresado en una lista de números
            if numeros_texto:
                try:
                    numeros = [float(num.strip()) for num in numeros_texto.split(',')]
                    st.write("Lista de números ingresada:", numeros)
                    if len(numeros)!=point_len:
                        #Lanzar error 
                        st.error(f"La cantidad de componente del punto es {point_len} no {len(numeros)}")
                        self.set_error()
                    else:
                        self.set_ok()
                        self._point=numeros
                        st.text(f"El punto es: \n {self._point}")
                        
                except ValueError:
                    st.error("Por favor, asegúrate de ingresar números válidos, separados por comas.") 
        
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
        if leader_count_vars==1:# Si es uno se llamara x
            x_s=["x"]
        else: # Si hay mas de una variable se llamara x_{i}
            x_s=[f"x_{i}" for i in range(1, leader_count_vars+1)]
        st.write(f"Las variables del nivel superior son {x_s}")
        follower_count_vars=st.number_input("Cantidad de variables del nivel inferior",min_value=1)
        if follower_count_vars==1: # Si la cant de variables del follower es 1
            # Se escribe como y
            y_s=["y"]
        else: # Se escribe como y_{i}
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
    def _input_expresion(self,msg_input:str,key:str="",is_expr_required:bool=False):
        # Entrada de texto para la expresión matemática
        expresion = st.text_input(f"Introduce {msg_input}:",key=f"_input_expresion_{key}")
        if is_expr_required: # Si la expresion es requerida 
            if expresion in [None,""," "]: # si la expresion no se ha puesto por hay que añadirla
                # Entonces no se ha introducido nada por tanto entonces
                st.error("Se tiene que introducir una expresión")
                self.set_error()
            else:
                # No hay error
                self.set_ok()
            
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
        """
        

        Args:
            key (str, optional): _description_. Defaults to "".

        Returns:
            str: _description_
        """
        obj_expresion=self._input_expresion("la función objectivo",key=key,is_expr_required=True)
        # Si es una ecuacion mandar error
        if obj_expresion  not in [None,""," "] and is_equation(obj_expresion):
            st.error(f"La función objetivo {obj_expresion} no puede ser una ecuación")
            self.set_error()
      
        return obj_expresion  
    
   

    def _save_expresion_and_active_index_restrictions(self,count:int,is_leader:bool)->tuple[str,str,bool]:
        """
        Devuelve la expresion de la restriccion y el indice activo y devuelve True si es una inecuacion estricta, False si es una igualdad
        Recibe el numero de la expresion y el booleano si es lider o no True si es el nivel del lider False si no lo es

        Args:
            count (int): Numero de restriccion que es
            is_leader (bool): True si es una restriccion del lider False si es del follower

        Returns:
            tuple[str,str]: Devuelve una tupla con la expresion, el indice activo y un booleano para saber si es una inequacion True o una igualdad False
        """
        
         # Guardar la expresion
        key=f"Leader_restriction_{count}" if is_leader else f"Follower_restriction_{count}"
        
        # Ahora extraer la expresion
        s="líder" if is_leader else "seguidor"
        rest_expr=self._input_expresion(f"la restricción del {s}",key=key,is_expr_required=True)
        # Guardar los tipos de indices activos del lider
        active_index=self.normal_active_index
        if rest_expr not in [None,""," "] and is_strict_inequality(rest_expr):
            # Si es una inecuacion entonces se dice que tipo de indice activo seleccionar
            temp=self.leader_active_index if is_leader else self.follower_active_index
            active_index=st.selectbox("Indices activos a seleccionar",temp,key=key)
            return rest_expr,active_index,True
        return rest_expr,active_index,False
    def _input_leader_restriction(self,count:int):
        # Decir en que restricciones estamos
        rest_expr,active_index,is_inequality= self._save_expresion_and_active_index_restrictions(count,True)
        # Ahora se da la seleccion que se pueda
        # Inicializar el indice activo en zero
        _miu=0
        if  is_inequality:
            # Si es una inecuacion se annade 
            _miu=st.number_input("Valor de miu",key=f"miu_{count}")
        self.leader_restrictions.append(LeaderRestriction(rest_expr,active_index,_miu))
        
    
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
        rest_expr,active_index,is_inequality= self._save_expresion_and_active_index_restrictions(count,False)
        # Ahora por los multiplicadores
        # inicializarlos en zero
        _beta,_lambda,_gamma=0,0,0
        if is_inequality:
            # Si es una inecuacion se necesitan los multiplicadores
            _beta=st.number_input("Valor de Beta",key=f"beta_{count}")
            _lambda=st.number_input("Valor de lambda",key=f"lambda_{count}",value=0)
            if _lambda ==0:      
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



        st.title("Generar un Problema")
        st.write("Introduce los siguientes datos")
        # Declarar las variables
        with st.expander("Introducir Variables:"):
            x_s,y_s=self._input_vars()
        # Declarar el valor del vector alpha
        with st.expander("Introducir el valor del vector alpha"):
            self._set_alpha()
        # Declarar el punto 
        with st.expander("Introducir el punto el cual se desee que el problema generado sea estacionario"):
            self.set_point()
        # Declarar nivel superior 
        with st.expander("Introducir el nivel superior:"):
            self._input_leader_problem()
        # Declarar nivel inferior
        with st.expander("Introducir el nivel inferior"):
            self._input_follower_problem()

        if self.ok: #Entonces se puede mandar ha hacer el problema
            st.button("Generar Problema")
        print(f"Esta ok:{self.ok}")
    
    def pagina_acerca_de(self):
        st.title("Acerca de")
        st.write("Esta es una aplicación de ejemplo creada con Streamlit.")


#TODO: Poner forma que se pueda generar sin poner valores osea solo con seleccionar los puntos
#TODO: Añadir el punto. 
Page().run()