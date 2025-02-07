import re
from typing import Type, List, Any
import os
import pandas as pd
import shutil
import subprocess
from sympy import symbols, sympify
import copy
from typing import Type, List, Any
import os
import pandas as pd
import shutil
import subprocess
from sympy import symbols, sympify
import copy
from sympy import symbols, diff, sympify


import re


import re

def convertir_expresion_a_julia(expresion: str) -> str:
    """
    Convierte todas las ocurrencias de '**' en la expresión dada por '^'.
    Además, limita los números decimales a dos cifras después del punto.

    Args:
        expresion (str): La expresión matemática o string original.

    Returns:
        str: La expresión modificada con '^' en lugar de '**' y números redondeados.
    """
    # Paso 1: Reemplazar '**' por '^'
    expresion_modificada = re.sub(r'\*\*', '^', expresion)
    
    # Paso 2: Redondear números decimales a dos cifras
    def redondear_decimal(match):
        numero = match.group()  # Captura el número completo (e.g., "3.14159")
        return f"{float(numero):.2f}"  # Redondea a dos cifras decimales
    
    # Usamos una expresión regular para encontrar números decimales
    expresion_modificada = re.sub(r'\d+\.\d+', redondear_decimal, expresion_modificada)
    
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
    
    return expr_str
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



def derivar_expresion(expr_str, variables_str: list[str]):
    """
    Deriva una expresión con respecto a una lista de variables y devuelve las derivadas en formato string.
    Parámetros:
    - expr_str (str): Expresión matemática en formato string.
    - variables_str (list of str): Lista de variables con respecto a las cuales se derivará.
    Retorna:
    - dict: Un diccionario donde las claves son las variables y los valores son las derivadas en formato string.
    """
    # Validar que variables_str no esté vacío ni contenga cadenas inválidas
    if not variables_str or any(not var.strip() for var in variables_str):
        raise ValueError("La lista de variables no puede estar vacía ni contener cadenas vacías.")
    
    # Fix expr
    expr_str = fix_expression(expr_str)
    
    # Convertir las variables en símbolos de SymPy
    try:
        variables = symbols(variables_str)  # Esto crea una tupla si hay múltiples variables
    except Exception as e:
        raise ValueError(f"Error al crear símbolos SymPy: {e}")
    
    
  
    # Convertir la expresión string en una expresión simbólica de SymPy
    try:
        expr = sympify(expr_str)
    except Exception as e:
        raise ValueError(f"Error al convertir la expresión a SymPy: {e}")
    
    # Calcular las derivadas parciales y almacenarlas en un diccionario
    derivadas = {}
    for var_name, var in zip(variables_str, variables):
        try:
           # print(f"Se va a derivar {expr} and {var}")
            derivada = diff(expr, var)  # Calcular la derivada
            derivadas[var_name] = str(derivada)  # Convertir la derivada a string
        except Exception as e:
            raise ValueError(f"Error al calcular la derivada respecto a '{var_name}': {e}")
    
    return derivadas


def procesar_y_ejecutar_archivo_julia(root_path, file_content, point_type:str,filename:str="datos"):
    """
    ACA SE AÑADE AL FILENAME el .jl
    devuelve la ruta al excel generado por el archivo
    """
    _filename=f"{filename}.jl"
    # Construir rutas de directorios
    compare_dir = os.path.join(root_path, "compare")
    type_estacionario_dir = os.path.join(compare_dir, point_type)
    
    # Crear directorio compare si no existe
    os.makedirs(compare_dir, exist_ok=True)
    
    # Eliminar y recrear c_estacionario
    if os.path.exists(type_estacionario_dir):
        shutil.rmtree(type_estacionario_dir)
    os.makedirs(type_estacionario_dir)
    
    # Crear y escribir el archivo .jl
    file_path = os.path.join(type_estacionario_dir, _filename)
    with open(file_path, "w", encoding="utf-8") as archivo:
        archivo.write(file_content)
    
    # Ejecutar el archivo .jl con Julia
    try:
        # Llamar a Julia desde el directorio c_estacionario
        resultado = subprocess.run(
            ["julia", _filename],  # Nombre del archivo (sin ruta absoluta)
            check=True,
            text=True,
            capture_output=True,
            cwd=type_estacionario_dir  # Ejecutar en este directorio
        )
        print("Salida de Julia:")
        print(resultado.stdout)
        if resultado.stderr:
            print("Errores de Julia:")
            print(resultado.stderr)
    except subprocess.CalledProcessError as e:
        print(f"Error al ejecutar el archivo de Julia: {e}")
        print("Salida de error:", e.stderr)
    except FileNotFoundError:
        print("Julia no está instalado o no está en el PATH.")
    except Exception as e:
        print(f"Error inesperado: {e}")
    return os.path.join(type_estacionario_dir,f"{filename}.xlsx")


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

class ExperimentLinearQuadratic:
    
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
            self.leader_rest.append(LeaderRestrictions(expr=expr,evaluation=evaluation,restriction_Set_Type=restriction_type,miu=miu))
    
    def _extract_follower_restrictions(self):
        df=self.all_sheets["Restricciones_del_follower"]
        count_filas=df.shape[0]
        
        for i in range(count_filas):
            expr,evaluation,restriction_type,_lambda,_beta,_gamma=df.iloc[i].to_list()
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
    def _compute_leader_obj_val(self):
        eval_value=eval_function(self.leader_obj,self.get_all_vars,self.point)
        print(f"El valor de la funcion del lider es {eval_value}")
        self.leader_obj_value=eval_value
    def read_from_excel(self):
        self._objectives_functions()
        self._extract_leader_restrictions()
        self._extract_follower_restrictions()
        self._extract_punto()
        self._extract_BF_and_fix_obj_leader()
        self._compute_leader_obj_val()
    def crear_variables(self):
        temp="\n"
        temp+="# Variables del Lider \n"
        for val in self.leader_vars:
            temp+=f" BilevelJuMP.@variable(Upper(model), {val}) \n"
        temp+="\n"
        temp+="# Variables del follower \n"
        for val in self.follower_vars:
            temp+=f" BilevelJuMP.@variable(Lower(model), {val}) \n"
        return temp
    def crear_nivel_superior(self):
        temp=f"BilevelJuMP.@objective(Upper(model),Min, {self.leader_obj}) \n"
        if len(self.leader_rest)==0:
            return temp
        temp+f"""
              # Restricciones del Nivel Superior
              BilevelJuMP.@constraints(Upper(model),begin \n
        """
        for i, rest in enumerate(self.leader_rest):
            temp+=f" a{i},{rest.expr}<=0  \n"
            
        temp+="\n end) \n"
        return temp
    def crear_nivel_inferior(self):
        temp=f"BilevelJuMP.@objective(Lower(model),Min, {self.follower_obj}) \n"
        if len(self.follower_rest)==0:
            return temp
        temp+=f"""
                # Restricciones Nivel Inferior
                BilevelJuMP.@constraints(Lower(model),begin \n
        """
        for i, rest in enumerate(self.follower_rest):
            temp+=f" c{i},{rest.expr}<=0  \n"
        temp+="\n end) \n"
        return temp
    def crear_array_string(self,array:list[str]):
        temp=f"[ "
        for i,val in enumerate(array):
            if i!=0:
                temp+=", "
            temp+=f"{val}"
        temp+=" ]"
        
        return temp
    def crear_start_experimento(self):
        """
        Devuelve el string apr crear el experimento
        """
        x_s=self.crear_array_string(self.leader_vars)
        y_s=self.crear_array_string(self.follower_vars)
        temp=f"start_experiment(model,{x_s},{y_s},\"{self.name}_{self.point_type}\")"
        return temp
    def write_archivo(self):
        file=f"""
include("../../../../experiment.jl")
        
using BilevelJuMP
using Random

# Introducir semilla

Random.seed!({self.random_seed})

# Crear Modelo Base
model = BilevelModel()

# Crear Variables
{self.crear_variables()}

# Definir Nivel Superior

{self.crear_nivel_superior()}

# Crear el Nivel Inferior

{self.crear_nivel_inferior()}

# Iniciar experimento
{self.crear_start_experimento()}

        """
        return file
    
    
    def save_file(self,file:str):
        """
        Serializar el archivo y devolver el excel después de ejecutar este
        """
        # Tomar el path del excel de salida
        print(f"mandar a procesar {file}")
        excel_output=procesar_y_ejecutar_archivo_julia(self.dir_path,file,self.point_type,f"{self.name}_{self.point_type}")
        return excel_output
    def __str__(self):
        return f"""
        Archivo: {self.ruta_archivo_excel}
        Leader:
        Funcion Objetivo:{self.leader_obj}
        Restricciones:{str(self.leader_rest)}
        Follower:
        Funcion Objetivo{self.follower_obj}
        Restricciones:{str(self.follower_rest)}
        
        """
    
    def run(self):
        """
        Mandar a ejecutar el archivo
        y devuelve el excel de salida
        """
        
        file=convertir_expresion_a_julia(self.write_archivo())
        # guardar el archivo y mandar a correr
        name=self.save_file(file)
        print(f"Finalizado el archivo {name}")
        return name
       
    def __init__(self,name:str,point_name:str,path:str,dir_path:str,random_seed:int):
        self.dir_path:str=dir_path
        """
        Ruta hasta la carpeta raíz del archivo para después montar ahi el experimento
        """
        self.name:str=name
        """
        Nombre del problema
        """
        self.point_type:str=point_name        
        self.ruta_archivo_excel:str = path
        self.all_sheets:dict[str, pd.DataFrame] = pd.read_excel(self.ruta_archivo_excel, sheet_name=None)
        #Funciones objetivo
        self.leader_obj:str=""
        self.follower_obj:str=""
        
        
        self.random_seed:int=random_seed
        """
        Semilla random 
        """
        # Restricciones del lider
        self.leader_rest:list[LeaderRestrictions]=[]

        # Restricciones del follower
        self.follower_rest:list[FollowerRestrictions]=[]
        
        
        # Vars
        #LEader vars
        self.leader_vars:list[str]=[]
        self.follower_vars:list[str]=[]
        
        # Punto
        self.point:dict[str,float]={}
        
        # Valor de la evaluación
        self.leader_obj_value:float=0
        
        self.read_from_excel()

    
    @property
    def get_all_vars(self)->list[str]:
        return self.leader_vars+self.follower_vars


class ExperimentNonConvex(ExperimentLinearQuadratic):
    def crear_variables(self):
        temp=f"""
        # Definir variables \n
        """
        for val in self.get_all_vars:
            temp+=f" \n  @variable(model,{val})  \n"
            
        for i in range(1,len(self.follower_rest)+1):
            temp+=f"  \n  @variable(model,l_{i}) \n"
            
        return temp
    def make_kkt(self):
        # Hallar las derivadas del func obj inf
        foll_inf_obj:dict=derivar_expresion(self.follower_obj,self.follower_vars)
        # Derivar cada una de las restricciones
        rest_derivate_li:list[dict]=[]
        for rest in self.follower_rest:
            t=derivar_expresion(rest.expr,self.follower_vars)
            rest_derivate_li.append(t)
        temp=f"""
        # Make KKT
        \n
        """  
        
        # Construir la expresion
        for val_y in self.follower_vars:
            # la obj del follower
            expr=f"{foll_inf_obj[val_y]}"
            for i,rest in enumerate(rest_derivate_li):
                expr+=f"+(l_{i+1}*({rest[val_y]}))"
            expr+=f"==0"
            temp+=f" @NLconstraint(model,{expr})  \n  "
        return temp

    def _crear_restricciones(self):
        
        temp=f"""
# Restricciones
        @constraints(model,begin
        
        """
        all_restrictions=self.leader_rest+self.follower_rest
        for rest in all_restrictions:
            temp+=f"\n {rest.expr}<=0 \n"
    
        temp+="\n end)"
        return temp
    
    
    def _crear_restricciones_complementariedad(self):
        
        temp=f"""
        
        """
        for i,rest in enumerate(self.follower_rest):
            temp+=f" \n @complements(model,0<=-({rest.expr}),l_{i+1}>=0) \n"
            
        return temp
    def write_archivo(self):
        
        file=f"""
using JuMP, Ipopt, Complementarity
using Random
include("../../../../experiment_non_convex.jl")
# Introducir semilla

Random.seed!({self.random_seed})
    
# Crear el modelo
model = Model(Ipopt.Optimizer)

{self.crear_variables()}

# Definir KKT

{self.make_kkt()}


# Definir restricciones

{self._crear_restricciones()}

# Definir variables de complementariedad

{self._crear_restricciones_complementariedad()}


# Resolver el modelo

make_experiment(model,{self.crear_array_string(self.leader_vars)},{self.crear_array_string(self.follower_vars)},"Reformulacion_KKT","{self.name}_{self.point_type}")

println("Se Finalizo el experimento {self.name}")

        
        """
        return file