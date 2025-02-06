
# Correr el pipe line
# PRimero ir por todas las subcarpetas de una carpeta

import os
import pandas as pd
#def find_problem_files(root_folder):
#    problem_files = []
#    for dirpath, dirnames, filenames in os.walk(root_folder):
#        sub_folder='Experimentos_Generador'
#        if sub_folder in dirnames:
#            problem_folder = os.path.join(dirpath, sub_folder)
#            for root, dirs, files in os.walk(problem_folder):
#                for file in files:
#                    file_path = os.path.join(root, file)
#                    problem_files.append(file_path)
#    return problem_files
#
## Ejemplo de uso
#root_folder = "D:\GitHub\Tesis\experiment\linear"
#
#files = find_problem_files(root_folder)
#for file in files:
#    print(file)
#

# Tomar el dataframe de una xlsx
import os
import shutil

import os
import shutil
import subprocess

def procesar_y_ejecutar_archivo_julia(root_path, file_content, filename="datos.jl"):
    # Construir rutas de directorios
    compare_dir = os.path.join(root_path, "compare")
    c_estacionario_dir = os.path.join(compare_dir, "c_estacionario")
    
    # Crear directorio compare si no existe
    os.makedirs(compare_dir, exist_ok=True)
    
    # Eliminar y recrear c_estacionario
    if os.path.exists(c_estacionario_dir):
        shutil.rmtree(c_estacionario_dir)
    os.makedirs(c_estacionario_dir)
    
    # Crear y escribir el archivo .jl
    file_path = os.path.join(c_estacionario_dir, filename)
    with open(file_path, "w", encoding="utf-8") as archivo:
        archivo.write(file_content)
    
    # Ejecutar el archivo .jl con Julia
    try:
        # Llamar a Julia para ejecutar el archivo
        resultado = subprocess.run(
            ["julia", file_path],  # Comando para ejecutar Julia
            check=True,            # Lanza una excepción si el comando falla
            text=True,             # Captura la salida como texto
            capture_output=True    # Captura la salida estándar y de error
        )
        print("Salida de Julia:")
        print(resultado.stdout)    # Mostrar la salida estándar de Julia
        if resultado.stderr:
            print("Errores de Julia:")
            print(resultado.stderr)  # Mostrar errores de Julia
    except subprocess.CalledProcessError as e:
        print(f"Error al ejecutar el archivo de Julia: {e}")
    except FileNotFoundError:
        print("Julia no está instalado o no está en el PATH.")
    
    return file_path


CESTACIONARIO="C-Estacionario"
MESTACIONARIO="M-Estacionario"
FUERTEMENTEESTACIONARIO="Fuertmente-Estacionario"
ALPHAZERO="Alpha-Zero"
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
            
    def read_from_excel(self):
        self._objectives_functions()
        self._extract_leader_restrictions()
        self._extract_follower_restrictions()
        self._extract_punto()
        self._extract_BF_and_fix_obj_leader()
    
    def crear_variables(self):
        temp="\n"
        temp+="# Variables del Lider \n"
        for val in self.follower_vars:
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
        temp=f"start_experiment(model,{x_s},{y_s},\"{self.name}\")"
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
        procesar_y_ejecutar_archivo_julia(self.dir_path,file,"Prueba.jl")
        
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
    def __init__(self,name:str,point_name:str,path:str,dir_path:str,ramdom_seed:int):
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
        
        
        self.random_seed:int=ramdom_seed
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
        
        self.read_from_excel()

class Experiment:
    
    def start(self):
        self.find_problem_in_folder()
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
                    self.C_Estacionarios.append(ExperimentLinearQuadratic(problem,CESTACIONARIO,file_path,problem_path,ramdom_seed=seed))
                elif "C_Stationarygenerator_alpha_zero" in file_path:
                    self.alpha_zero.append(ExperimentLinearQuadratic(problem,ALPHAZERO,file_path,problem_path,ramdom_seed=seed))
                elif "M_Stationarygenerator_alpha_non_zero" in file_path:
                    self.M_Estacionario.append(ExperimentLinearQuadratic(problem,MESTACIONARIO,file_path,problem_path,ramdom_seed=seed))
                elif "Strong_Stationarygenerator_alpha_non_zero" in file_path:
                    self.Strong_Estacionario.append(ExperimentLinearQuadratic(problem,FUERTEMENTEESTACIONARIO,file_path,problem_path,ramdom_seed=seed))
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






a=Experiment("D:\GitHub\Tesis\experiment\kk",1,6)
a.start()
print(a.C_Estacionarios[0].write_archivo())