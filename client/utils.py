import random
import pandas as pd
import re
from sympy import symbols, diff, sympify, latex
def get_random(epsilon=1e-2):
    # Generar un número aleatorio entre 0 y 1
    numero_aleatorio = random.random()
    
    # Si el número aleatorio es menor que epsilon, sumar epsilon
    if numero_aleatorio < epsilon:
        numero_aleatorio += epsilon
    
    return numero_aleatorio


def get_multiplicadores_c_estacionario():
    """
    Retorna el valor de Beta y Gamma.
    Genera los Beta y Gammas para que el punto sea C-Estacionario.
    """
    # Generar un número entre 1 y 4 para seleccionar que valores utilizar
    rand_value = random.randint(1, 4)
    
    if rand_value == 1:  # Entonces los dos son mayores que cero
     
        return (-get_random() , -get_random() )
   
    
    return (0, 0) 

def get_multiplicadores_m_estacionario():
    """
     Retorna el valor de Beta y Gamma.
    Genera los Beta y Gammas para que el punto sea M-Estacionario.
    """
    rand_value = random.randint(1, 2)
    
    if rand_value == 1:  # Entonces los dos son mayores que cero
     
        return (0, get_random() )
    else:
        return (get_random() , 0)
   
    
def get_multiplicadores_strong_estacionario():

    return (get_random() , get_random() )

#################################
#
#   Read the Problem
#
###################################
class Restrictions:
    def __str__(self):
        return f"Expr: {self.expr}, evaluation: {self.evaluation}, restriction_type_set: {self.restriction_Set_Type}"
    def __init__(self,expr:str,evaluation:float,restriction_Set_Type:str):
        self.expr:str=expr
        self.evaluation:float=evaluation
        self.restriction_Set_Type:str=restriction_Set_Type
        
class LeaderRestrictions(Restrictions):
    def __str__(self):
        return f"{super().__str__()} Mu: {self.miu}"
    def __init__(self, expr, evaluation, restriction_Set_Type,miu:float):
        super().__init__(expr, evaluation, restriction_Set_Type)
        self.miu:float=miu
        
class FollowerRestrictions(Restrictions):
    def __str__(self):
        return f"{super().__str__()} Lambda: {self._lambda} Beta: {self._beta} Gamma: {self._gamma}"
    def __init__(self, expr, evaluation, restriction_Set_Type,_lambda:float,_beta:float,_gamma:float):
        super().__init__(expr, evaluation, restriction_Set_Type)
        self._lambda:float=_lambda
        self._beta:float=_beta
        self._gamma:float=_gamma
        
def expresion_a_latex(expresion_str: str, variables: list[list]) -> str:
    """
    Convierte una expresión matemática dada como string en su representación LaTeX.
    
    Args:
        expresion_str (str): La expresión matemática como string (ejemplo: "x**2 + sin(y)").
        variables (list[str]): Lista de variables involucradas en la expresión (ejemplo: ["x", "y"]).
    
    Returns:
        str: El código LaTeX correspondiente a la expresión.
    """
    # Arreglar la expresion 
    expresion_str=fix_expression(expr_str=expresion_str)
    # Convertir las variables en símbolos de SymPy
    simbolos = symbols(" ".join(variables))
    
    # Si hay solo una variable, asegurarse de que sea una tupla
    if len(variables) == 1:
        simbolos = (simbolos,)
    else:
        simbolos = tuple(simbolos)
    
    try:
        # Interpretar la expresión como una expresión simbólica de SymPy
        expresion = sympify(expresion_str)
        
        # Convertir la expresión a LaTeX
        latex_code = latex(expresion)
        return latex_code
    except Exception as e:
        raise ValueError(f"Error al procesar la expresión: {e}")


def convertir_expresion_2_decimales(expression:str)->str:
     # Paso 1: Redondear números decimales a dos cifras
    def redondear_decimal(match):
        numero = match.group()  # Captura el número completo (e.g., "3.14159")
        return f"{float(numero):.2f}"  # Redondea a dos cifras decimales
    
    # Usamos una expresión regular para encontrar números decimales
    expresion_modificada = re.sub(r'\d+\.\d+', redondear_decimal, expression)
    
    return expresion_modificada
def fix_expression(expr_str):
    # 1. Agregar '*' entre números y variables (ej: '3y_1' → '3*y_1')
    expr_str = re.sub(
        r'([-+]?\d+\.?\d*)(?=[a-zA-Z_])',  # Busca números (incluyendo decimales y negativos)
        r'\1*',                             # Inserta '*' después del número
        expr_str
    )
    
    # 2. Agregar '*' entre números y paréntesis (ej: '10(y^2)' → '10*(y^2)')
    expr_str = re.sub(
        r'([-+]?\d+\.?\d*)\s*\(',           # Busca números seguidos de '('
        r'\1*(',                            # Inserta '*' entre el número y el paréntesis
        expr_str
    )
    
    # 3. Corregir dobles signos (ej: '+ -63.4x' → '-63.4x')
    expr_str = re.sub(r'\+\s*\-', '-', expr_str)  # Reemplaza '+ -' por '-'
    expr_str = re.sub(r'-\s*\+', '-', expr_str)  # Reemplaza '- +' por '-'
    expr_str = re.sub(r'-\s*-', '+', expr_str)   # Reemplaza '- -' por '+'
    
    return convertir_expresion_2_decimales(expr_str)

def eval_function(expresion_str:str, nombres_variables:list[str], punto:dict[str,float])->float:
    """
    Evalúa una expresión matemática dada como string en un punto específico.

    Parámetros:
    - expresion_str (str): Expresión matemática como string.
    - nombres_variables (list): Lista de nombres de las variables en la expresión.
    - punto (dict): Diccionario que mapea cada variable a su valor (float).

    Retorna:
    - float: El valor evaluado de la expresión en el punto dado.
    """
    # Modificar la expresion si hace hacer
    expresion_str=fix_expression(expr_str=expresion_str)
    # Paso 1: Crear dinámicamente los símbolos a partir de la lista de nombres de variables
    variables = symbols(nombres_variables)
    
    # Paso 2: Convertir el string a una expresión simbólica
    expresion = sympify(expresion_str)
    
    # Paso 3: Crear un diccionario para sustituir los valores en la expresión
    diccionario_valores = {variables[nombres_variables.index(var)]: valor for var, valor in punto.items()}
    
    # Paso 4: Evaluar la expresión
    valor_evaluado = expresion.subs(diccionario_valores)
    
    # Retornar el resultado
    return float(valor_evaluado)


class ProblemShow:
    """
    Class to show the generate problem
    """
    def __init__(self,dfs:dict[str, pd.DataFrame]):
        self.all_sheets:dict[str, pd.DataFrame]=dfs
        
        self.leader_obj:str=""
        
        self.follower_obj:str=""
        
        self.leader_vars:list[str]=[]
        
        self.follower_vars:list[str]=[]
        
        self.point:dict[str,float]={}
        
        # Restricciones del líder
        self.leader_rest:list[LeaderRestrictions]=[]

        # Restricciones del follower
        self.follower_rest:list[FollowerRestrictions]=[]
        
        self.read_from_excel()
    
    @property
    def get_all_vars(self)->list[str]:
        return self.leader_vars+self.follower_vars

    def read_from_excel(self):
        self._objectives_functions()
        self._extract_leader_restrictions()
        self._extract_follower_restrictions()
        self._extract_punto()
        self._extract_BF_and_fix_obj_leader()
        self._extract_bf_and_fix_obj_follower()
        self._compute_leader_obj_val()
        
        
    def _objectives_functions(self):
        leader_obj,follower_obj=self.all_sheets['Funciones_Objetivo'].iloc[0].tolist()
        self.leader_obj=leader_obj
        self.leader_obj=leader_obj
        self.follower_obj=follower_obj
    def _extract_leader_restrictions(self):
        # Conocer la cant de filas
        df=self.all_sheets["Restricciones_del_lider"]
        count_filas=df.shape[0]
        
        for i in range(count_filas):
            # Por cada fila extraer:
            expr,evaluation,restriction_type,miu=df.iloc[i].to_list()
            expr=str(expr)
            self.leader_rest.append(LeaderRestrictions(expr=expr,evaluation=evaluation,restriction_Set_Type=restriction_type,miu=miu))
 
    
    
    def _extract_follower_restrictions(self):
        df=self.all_sheets["Restricciones_del_follower"]
        count_filas=df.shape[0]
        
        for i in range(count_filas):
            expr,evaluation,restriction_type,_lambda,_beta,_gamma=df.iloc[i].to_list()
            expr=str(expr)
            self.follower_rest.append(FollowerRestrictions(expr=expr,evaluation=evaluation,restriction_Set_Type=restriction_type,_lambda=_lambda,_beta=_beta,_gamma=_gamma))
    
    def _extract_punto(self):
        # Extraer nombre de las columnas
        df=self.all_sheets["Punto_modificado"]
        # Obtén los nombres de las columnas
        nombres_columnas = df.columns.tolist()
        for val in nombres_columnas:
            if "x" in val:
                self.leader_vars.append(val)
            elif "y" in val:
                self.follower_vars.append(val)
            else:
                raise Exception(f"La variable {val} no es de x ni de y")
            
        count_x=len(self.leader_vars)
        count_y=len(self.follower_vars)
        point=df.iloc[0].to_list()
        i=0
        j=0
        for val in point:
            if i<count_x:
                self.point[self.leader_vars[i]]=val
                i+=1
            else:
                self.point[self.follower_vars[j]]=val
                j+=1
                       
            
    def _extract_BF_and_fix_obj_leader(self):
        df=self.all_sheets["Vector_BF"]
        count_filas=df.shape[0]
        count_x=len(self.leader_vars)
        count_y=len(self.follower_vars)
        j=0
        for i in range(count_filas):
            val=df.iloc[i].to_list()[0]
            print(f"El tipo de val es {type(val)} y es {val}")
            if i<count_x:
                self.leader_obj+=f" + {val}{self.leader_vars[i]}"
            else:
                self.leader_obj+=f" +{val}{self.follower_vars[j]}"
                j+=1
                
    def _extract_bf_and_fix_obj_follower(self):
        df=self.all_sheets["Vector_bf"]
        count_filas=df.shape[0]
        for j in range(count_filas):
            val=df.iloc[j].to_list()[0]
            self.follower_obj+=f" +{val}{self.follower_vars[j]}"
            
        
    def _compute_leader_obj_val(self):
        eval_value=eval_function(self.leader_obj,self.get_all_vars,self.point)
        print(f"El valor de la funcion del lider es {eval_value}")
        self.leader_obj_value=eval_value
    
    
    
    
########################
#
#   Crear string to latex
#
#######################
    def _leader_expr_to_latex(self)->str:
        return expresion_a_latex(self.leader_obj,self.get_all_vars)
    def _follower_expr_to_latex(self)->str:
        return expresion_a_latex(self.follower_obj,self.get_all_vars)
    def _create_restriction_to_latex(self,restrictions:list[Restrictions])->str:
        temp=f""
        for i,rest in enumerate(restrictions):
            expr=rest.expr
            expr=expresion_a_latex(expr,self.get_all_vars)
            temp+=f" {expr} \\leq 0"
            if i<len(restrictions)-1:
                temp+=f" {"\\"}{"\\"}"
                temp+=" \n"
        return temp
    def _create_leader_rest_latex(self)->str:
        return self._create_restriction_to_latex(self.leader_rest)
       
    def _create_follower_rest_latex(self)->str:
        return self._create_restriction_to_latex(self.follower_rest)
            
    