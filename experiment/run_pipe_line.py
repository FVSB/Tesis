
# Correr el pipe line
# PRimero ir por todas las subcarpetas de una carpeta

import os
import pandas as pd
import shutil
import subprocess
from sympy import symbols, sympify
import copy
CESTACIONARIO="C-Estacionario"
MESTACIONARIO="M-Estacionario"
FUERTEMENTEESTACIONARIO="Fuertmente-Estacionario"
ALPHAZERO="Alpha-Zero"

import re

def fix_expression(expr_str):
    # 1. Agregar '*' entre números y variables (ej: '3y_1' → '3*y_1')
    expr_str = re.sub(
        r'([-+]?\d+\.?\d*)(?=[a-zA-Z_])',  # Busca números (incluyendo decimales y negativos)
        r'\1*',                             # Inserta '*' después del número
        expr_str
    )
    
    # 2. Corregir dobles signos (ej: '+ -63.4x' → '-63.4x')
    expr_str = re.sub(r'\+\s*\-', '-', expr_str)  # Reemplaza '+ -' por '-'
    
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

# Ejemplo de uso
#if __name__ == "__main__":
#    # Expresión matemática como string
#    expresion_str = "x**2 + y*z + w"
#    
#    # Lista de nombres de variables
#    nombres_variables = ['x', 'y', 'z', 'w']
#    
#    # Punto de evaluación (diccionario)
#    punto = {'x': 1.0, 'y': 2.0, 'z': 3.0, 'w': 4.0}
#    
#    # Evaluar la función
#    resultado = eval_function(expresion_str, nombres_variables, punto)
#    
#    # Mostrar el resultado
#    print(f"El valor de la expresión '{expresion_str}' en el punto {punto} es: {resultado}")

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
        
        file=self.write_archivo()
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

class ExperimentResultAtomic:
    def __init__(self,method_name:str,estatus_primal:str,estatus_termination:str,val_obj:float,time_:float,leaders_vars:list[str],follower_vars:list[str],point:dict[str,float]):
        self.method_name:str=method_name
        self.estatus_primal:str=estatus_primal
        self.estatus_termination:str=estatus_termination
        self.val_obj:float=round(val_obj,2)
        self.time_:float=time_
        self.point:dict[str,float]=point
        self.leaders_vars:list[str]=leaders_vars
        self.follower_vars:list[str]=follower_vars
        
class ExperimentsResult:
    def __init__(self,problem_name:str,original_evaluation_val:float):
        self.problem_name:str=problem_name
        self.original_evaluation_val:float=round(original_evaluation_val, 2)
        
        self.results:list[ExperimentResultAtomic]=[]
    def push_result(self,result:ExperimentResultAtomic):
        self.results.append(result)
        
    def compute_winner(self)->ExperimentResultAtomic:
        # Primero si hay solo uno se devuelve ese mismo
        if len(self.results)==1:
            return self.results[0]
        
        results=copy.deepcopy(self.results)
        
        # Despues descartar los que no sean FEASIBLE_POINT
        # Filtrar la lista para incluir solo los elementos con estatus_primal igual a "FEASIBLE_POINT"
        filtered_results:list[ExperimentResultAtomic]= list(filter(lambda result: result.estatus_primal == "FEASIBLE_POINT", results))
        # Priorizar los que su diferencia con el valor objetivo inicial es mayor
        filtered_results= sorted(filtered_results,key=lambda result:self.original_evaluation_val-result.val_obj,reverse=True)
        
        if len(filtered_results)==1:
            return filtered_results[0]
        
        first,second,*_=filtered_results
        
        if  first.val_obj==second.val_obj:
            if first.estatus_termination!="OPTIMAL":
                return second
            return first if first.time_<=second.time_ else second
            
            
    
        
            
        
        

class Experiment:
    
 
    def _push_in_Experiment_Result(self,lis:list,handle:ExperimentsResult,index_start_x:int,index_end_x:int,index_star_y:int,index_end_y:int,leader_vars:list[str],follower_vars:list[str]):
        """
        Dada la lista que contine la fila
        """
        point:dict[str,float]={}
        len_vars_leader=len(leader_vars)
        len_vars_follower=len(follower_vars)
        len_all=len_vars_leader+len_vars_follower
        j=0
        k=0
        #print(f"La lista es {lis}")
        #print(f"El len es {len(lis)}")
        
        for i in range(index_start_x,len(lis)):
            val=lis[i]
            val=float(val)
            if j<len_vars_leader:
                point[leader_vars[j]]=val
                j=+1
            else:
                point[follower_vars[k]]=val
                k+=1
          
        

            
        handle.push_result(ExperimentResultAtomic(lis[0],lis[1],lis[2],val_obj=lis[3],time_=lis[6],leaders_vars=leader_vars,follower_vars=follower_vars,point=point))
        # APrtir del indice 9 incluyendoilo son las variables
        return handle
    
    def _analize_excel(self,output_excel_path:str,original_leader_value:float,problem_name:str,leader_vars:list[str],follower_vars:list[str])->ExperimentResultAtomic:
          # Leer el excel y después extraer la data importante
            df:pd.DataFrame = pd.read_excel(output_excel_path, sheet_name="Data")
        	# Tomar los que son Feasible y Optimos
            # Guardar el mejor en cuanto Valor objectivo y Tiempo y el punto
            #Optimize_Method,Estatus_Primal,Estatus_Terminacion,Valor_Objetivo,Tiempo_Minimo,Tiempo_Maximo,Tiempo_Promedio,Asignaciones_Memoria,
            # Hacerlo por hoja
            # Crear el handle de experientos
            handle=ExperimentsResult(problem_name=problem_name,original_evaluation_val=original_leader_value)
            
            # Contar filas usando shape
            num_filas = df.shape[0]
            nombres_columnas = df.columns.tolist()
            index_start_first_x=-1
            index_end_last_x=-1
            index_start_first_y=-1
            index_end_last_y=-1 # Esto significa qaue hya una sola variable
            for i,val in enumerate(nombres_columnas):
                if "X_s:" in val:
                    if index_start_first_x<0 :
                        index_start_first_x=i
                    if i>9:
                        index_end_last_x=i
                elif "Y_s:" in val:
                    if index_start_first_y<0:
                        index_start_first_x=i
                    if i>10:
                        index_end_last_y=i
                   
            for i in range(num_filas):
                lis=df.iloc[i].to_list()
                handle=self._push_in_Experiment_Result(lis,handle,index_start_x=index_start_first_x,index_end_x=index_end_last_x,index_star_y=index_start_first_x,index_end_y=index_end_last_y,leader_vars=leader_vars,follower_vars=follower_vars)
                
            return handle.compute_winner()

             
            
    def _run_experiment_from_type(self,experiments:list[ExperimentLinearQuadratic])->ExperimentResultAtomic:
        # Por cada tipo de punto mandar a crear el .jl y ejecutar el archivo tomar el path para el excel y guardar data
        #TODO: Quitar esto
        if len(experiments)<1:
            return
        results_lis:list[ExperimentResultAtomic]=[]
        for experiment in experiments:
            output_excel_path=experiment.run()
            # Mandar a analizar el excel
            result:ExperimentResultAtomic=self._analize_excel(output_excel_path=output_excel_path,original_leader_value=experiment.leader_obj_value,problem_name=experiment.name,leader_vars=experiment.leader_vars,follower_vars=experiment.leader_vars)
            results_lis.append(result)
        results_lis=sorted(results_lis,key=lambda x: experiment.leader_obj_value-x.val_obj,reverse=True )
       
        return results_lis[0]
    def run_experiments(self):
        # Analizar los C-Estacionarios
        best_c=self._run_experiment_from_type(self.C_Estacionarios)
        # M-Estacionarios
        best_m=self._run_experiment_from_type(self.M_Estacionario)
        # Strong
        best_strong=self._run_experiment_from_type(self.Strong_Estacionario)
        # Alpha_zero
        best_alpha_zero=self._run_experiment_from_type(self.alpha_zero)
        
          
    def start(self):
        self.find_problem_in_folder()
        self.run_experiments()
    def __init__(self,root_folder:str,start_random_seed:int,end_random_seed:int):
        #"D:\GitHub\Tesis\experiment\linear"
        self.root_folder:str=root_folder
        self.sub_folder:list[str]=[]
        self.problems_name:list[str]=[]
        
        self.start_random_seed:int=start_random_seed
        """
        Inicio de la semilla random (Inclusivo)
        """
        self.end_random_seed:int=end_random_seed
        """
        Fin de la semilla Random Exclusivo
        """
        
        self.C_Estacionarios:list[ExperimentLinearQuadratic]=[]
        self.alpha_zero:list[ExperimentLinearQuadratic]=[]
        self.M_Estacionario:list[ExperimentLinearQuadratic]=[]
        self.Strong_Estacionario:list[ExperimentLinearQuadratic]=[]
    def find_problem_in_folder(self):
        """
        Encuenta en una carpeta todos los problemas
        """
        # Caminar por todas las subcarpetas
        #de ahi extraer el nombre
        
        for dirpath, dirnames, filenames in os.walk(self.root_folder):
            self.problems_name=dirnames
            break
        for problem in self.problems_name:
            # Entonces ahora tomar todas las posibilidades
            problem_path=os.path.join(self.root_folder,problem)
            files=self.find_problem_files(problem_path,'Experimentos_Generador', '.xlsx')
            # Ahora tomar los que son c-estacionarios
            for i,file_path in enumerate(files):
                seed=self.start_random_seed+i
                if "C_Stationarygenerator_alpha_non_zero" in file_path:
                    self.C_Estacionarios.append(ExperimentLinearQuadratic(problem,CESTACIONARIO,file_path,problem_path,random_seed=seed))
                elif "C_Stationarygenerator_alpha_zero" in file_path:
                    self.alpha_zero.append(ExperimentLinearQuadratic(problem,ALPHAZERO,file_path,problem_path,random_seed=seed))
                elif "M_Stationarygenerator_alpha_non_zero" in file_path:
                    self.M_Estacionario.append(ExperimentLinearQuadratic(problem,MESTACIONARIO,file_path,problem_path,random_seed=seed))
                elif "Strong_Stationarygenerator_alpha_non_zero" in file_path:
                    self.Strong_Estacionario.append(ExperimentLinearQuadratic(problem,FUERTEMENTEESTACIONARIO,file_path,problem_path,random_seed=seed))
                else:
                    print(f"El archivo {file_path} no tiene clase identificada")
                    
    def find_problem_files(self,dirpath,sub_folder,extension:str):
        problem_files = []
        
        #sub_folder='Experimentos_Generador'
        # Verifica si la ruta existe
        problem_folder = os.path.join(dirpath, sub_folder)
        if not os.path.exists(problem_folder):
            raise Exception(f'La ruta "{problem_folder}" no existe.')
            
        for root, dirs, files in os.walk(problem_folder):
            for file in files:
                file_path = os.path.join(root, file)
                # Verifica si la ruta corresponde a un archivo y si tiene una extensión de Excel
                if os.path.isfile(file_path) and file_path.endswith(extension):
                    problem_files.append(file_path)
        return problem_files






a=Experiment("/workspaces/Tesis/experiment/kk",1,6)
a.start()
#print(a.C_Estacionarios[0].run())