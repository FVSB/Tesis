
# Correr el pipe line
# PRimero ir por todas las subcarpetas de una carpeta
from typing import Type, List, Any
import os
import pandas as pd
import shutil
import subprocess
from sympy import symbols, sympify
import copy
from sympy import symbols, diff, sympify
from utils import *
import pickle

CESTACIONARIO="C-Estacionario"
MESTACIONARIO="M-Estacionario"
FUERTEMENTEESTACIONARIO="Fuertemente-Estacionario"
ALPHAZERO="Alpha-Zero"

#Problem Type
LINEAL="Lineal"
CUADRATICO="Cuadrático"
NOCONVEXO="No Convexo"

import os


def guardar_string_en_archivo(nombre_archivo: str, contenido: str, subcarpeta: str):
    """
    Guarda un string en un archivo con el nombre especificado dentro de una subcarpeta.
    Si la subcarpeta existe, se elimina y se crea una nueva. Si no existe, se crea una nueva.
    """
    # Asegúrate de que el nombre del archivo tenga la extensión .tex
    if not nombre_archivo.endswith(".tex"):
        nombre_archivo += ".tex"
    
    # Verificar si la subcarpeta existe
    if os.path.exists(subcarpeta):
        print(f"La subcarpeta '{subcarpeta}' ya existe. Eliminándola...")
        # Eliminar la subcarpeta y todo su contenido
        for root, dirs, files in os.walk(subcarpeta, topdown=False):
            for file in files:
                os.remove(os.path.join(root, file))
            for dir in dirs:
                os.rmdir(os.path.join(root, dir))
        os.rmdir(subcarpeta)
    
    # Crear la subcarpeta
    os.makedirs(subcarpeta, exist_ok=True)
    print(f"Subcarpeta '{subcarpeta}' creada exitosamente.")
    
    # Construir la ruta completa del archivo
    ruta_completa = os.path.join(subcarpeta, nombre_archivo)
    
    # Verificar si el archivo ya existe
    if os.path.exists(ruta_completa):
        print(f"El archivo '{ruta_completa}' ya existe. Eliminándolo...")
        os.remove(ruta_completa)  # Elimina el archivo existente
    
    # Crear un nuevo archivo y escribir el contenido
    with open(ruta_completa, "w", encoding="utf-8") as archivo:
        archivo.write(contenido)
    
    print(f"Archivo '{ruta_completa}' creado exitosamente.")



def create_string_tuple_from_dic(dic:dict,keys:list):
    temp=f"("
    for key in keys:
        val=dic[key]
        temp+=f" {str(val)},"
        
    temp+=f")"
    return temp
class ExperimentResultAtomic:
    def __init__(self,problem_name:str,method_name:str,estatus_primal:str,estatus_termination:str,val_obj:float,original_leader_value:float,time_:float,leaders_vars:list[str],follower_vars:list[str],point:dict[str,float],point_list:list[float]):
        self.problem_name:str=problem_name
        self.method_name:str=method_name
        self.estatus_primal:str=estatus_primal
        self.estatus_termination:str=estatus_termination
        self.val_obj:float=round(val_obj,2)
        self.original_leader_value:float=round(original_leader_value,2)
        self.time_:float=time_
        self.point:dict[str,float]=point
        self.point_list:list[float]=point_list
        self.leaders_vars:list[str]=leaders_vars
        self.follower_vars:list[str]=follower_vars
        
    def get_point_tupple_string(self)->str:
        """
        Devuelve el punto en forma de string
        """
        temp=f"("
        for key in self.point_list:
            val=round(key,2)
            temp+=f" {str(val)},"
        temp+=f")"
        return temp
    def compute_val(self):
        """
        Computa la diferencia que existe entre el el valor del problema modificado y el optimo de este obtenido en caso del supuesto optimo
        ser mayor que el valor original se penaliza esto sumando -1000000000000 a esa diferencia
        """
        diference=self.original_leader_value-self.val_obj
        if self.original_leader_value<self.val_obj:
            return -100000000000000+diference
        return diference
    
    def __lt__(self,other):
        if not isinstance(other,ExperimentResultAtomic):
            raise Exception(f"other es de clase {type(other)} no de clase ExperimentResultAtomic")
        
        return self.compute_val()<other.compute_val()
    
class ExperimentsResult:
    def __init__(self,problem_name:str,original_evaluation_val:float,point_type:str):
        self.problem_name:str=problem_name
        self.original_evaluation_val:float=round(original_evaluation_val, 2)
        self.point_type:str=point_type
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
        if len(filtered_results)<1:
            filtered_results=copy.deepcopy(self.results)
        # Priorizar los que su diferencia con el valor objetivo inicial es mayor
        filtered_results= sorted(filtered_results,key=lambda result:result.val_obj,reverse=False)
        
        if len(filtered_results)==1:
            return filtered_results[0]
        if len(filtered_results)<3:
            first,second=filtered_results
        else:
            first,second,*_=filtered_results
        
        if  first.val_obj==second.val_obj:
            if first.estatus_termination!="OPTIMAL":
                return second
            return first if first.time_<=second.time_ else second
             
        return first




class Experiment:
  

    @classmethod
    def deserializar_desde_archivo(cls, nombre_archivo: str, subcarpeta: str):
        """
        Deserializa una instancia de la clase desde un archivo binario usando pickle.
        El archivo se busca dentro de la subcarpeta especificada.
        """
        # Construir la ruta completa del archivo
        ruta_completa = os.path.join(subcarpeta, nombre_archivo)
        
        # Asegurarse de que el nombre del archivo tenga la extensión .pkl
        if not ruta_completa.endswith(".pkl"):
            ruta_completa += ".pkl"
        
        # Verificar si el archivo existe
        if not os.path.exists(ruta_completa):
            raise FileNotFoundError(f"El archivo '{ruta_completa}' no existe.")
        
        # Cargar la instancia desde el archivo binario
        with open(ruta_completa, "rb") as archivo:
            instancia = pickle.load(archivo)
        
        print(f"Instancia deserializada desde el archivo '{ruta_completa}'.")
        return instancia

    def serializar_en_archivo(self, subcarpeta: str):
        """
        Serializa la instancia actual de la clase en un archivo binario usando pickle.
        Si el archivo ya existe, lo elimina antes de crear uno nuevo.
        Si la subcarpeta no existe, la crea.
        """
        # Construir el nombre del archivo
        nombre_archivo = f"Resultados_{self.problem_type_name}"
        if not nombre_archivo.endswith(".pkl"):
            nombre_archivo += ".pkl"
        
        # Construir la ruta completa del archivo
        ruta_completa = os.path.join(subcarpeta, nombre_archivo)
        
        # Crear la subcarpeta si no existe
        os.makedirs(subcarpeta, exist_ok=True)
        print(f"Subcarpeta '{subcarpeta}' creada o ya existía.")
        
        # Eliminar el archivo si ya existe
        if os.path.exists(ruta_completa):
            print(f"El archivo '{ruta_completa}' ya existe. Eliminándolo...")
            os.remove(ruta_completa)
        
        # Guardar la instancia en un archivo binario
        with open(ruta_completa, "wb") as archivo:
            pickle.dump(self, archivo)
        
        print(f"Instancia serializada en el archivo '{ruta_completa}'.")
    def _push_in_Experiment_Result(self,lis:list,handle:ExperimentsResult,index_start_x:int,index_end_x:int,index_star_y:int,index_end_y:int,leader_vars:list[str],follower_vars:list[str]):
        """
        Dada la lista que contine la fila
        """
        point:dict[str,float]={}
        point_list:list[float]=[]
        len_vars_leader=len(leader_vars)
        len_vars_follower=len(follower_vars)
        len_all=len_vars_leader+len_vars_follower
        j=0
        k=0
        #print(f"La lista es {lis}")
        #print(f"El len es {len(lis)}")
        
        for i in range(index_start_x,len(lis)):
            val=lis[i]
            val=round(float(val),2)
            point_list.append(val)
            if j<len_vars_leader:
                point[leader_vars[j]]=val
                j=+1
            else:
                point[follower_vars[k]]=val
                k+=1
          
    
        handle.push_result(ExperimentResultAtomic(problem_name=handle.problem_name,method_name=lis[0],estatus_primal=lis[1],estatus_termination=lis[2],val_obj=lis[3],original_leader_value=handle.original_evaluation_val,time_=lis[6],leaders_vars=leader_vars,follower_vars=follower_vars,point=point,point_list=point_list))
        # Apartir del indice 9 incluyendoilo son las variables
        return handle
    def  _push_into_dict(self,problem_name:str,point_type:str,handle:ExperimentsResult):
        if not problem_name in self.results_modify_problems:
            self.results_modify_problems[problem_name]={point_type:handle}
            return
        dic=self.results_modify_problems[problem_name]
        
        dic[point_type]=handle
        
        return
            
        
    def _analize_excel(self,output_excel_path:str,original_leader_value:float,problem_name:str,leader_vars:list[str],follower_vars:list[str],point_type:str)->ExperimentResultAtomic:
          # Leer el excel y después extraer la data importante
            df:pd.DataFrame = pd.read_excel(output_excel_path, sheet_name="Data")
        	# Tomar los que son Feasible y Optimos
            # Guardar el mejor en cuanto Valor objectivo y Tiempo y el punto
            #Optimize_Method,Estatus_Primal,Estatus_Terminacion,Valor_Objetivo,Tiempo_Minimo,Tiempo_Maximo,Tiempo_Promedio,Asignaciones_Memoria,
            # Hacerlo por hoja
            # Crear el handle de experientos
            handle=ExperimentsResult(problem_name=problem_name,original_evaluation_val=original_leader_value,point_type=point_type)
            
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
            
            self._push_into_dict(problem_name,point_type,handle)
            
            return handle.compute_winner()

    
            
    def _run_experiment_from_type(self,experiments:list[ExperimentLinearQuadratic],type_problem:str)->ExperimentResultAtomic:
        # Por cada tipo de punto mandar a crear el .jl y ejecutar el archivo tomar el path para el excel y guardar data
        #if len(experiments)<1: # Descomentar solo para testear
        #    return
        results_lis:list[ExperimentResultAtomic]=[]
        for experiment in experiments:
            output_excel_path=experiment.run()
            # Mandar a analizar el excel
            result:ExperimentResultAtomic=self._analize_excel(output_excel_path=output_excel_path,original_leader_value=experiment.leader_obj_value,problem_name=experiment.name,leader_vars=experiment.leader_vars,follower_vars=experiment.leader_vars,point_type=type_problem)
            results_lis.append(result)
        results_lis=sorted(results_lis,reverse=True )

        if len(results_lis)<1:
            raise Exception(f"La lista de ganadores en la categoria {type_problem} es de len 0")
        
        return results_lis[0]

    def _get_correct_list(self,point_type:str):
        """
        Devuelve la lista de problemas generados en dependencia del tipo de puntos
        """
        if point_type==CESTACIONARIO:
            return self.C_Estacionarios
        elif point_type==MESTACIONARIO:
            return self.M_Estacionario
        elif point_type==FUERTEMENTEESTACIONARIO:
            return self.Strong_Estacionario
        elif point_type==ALPHAZERO:
            return self.alpha_zero
        
        raise Exception(f"El point_type es invalido: {point_type}")
    
    
    def _get_original_point_string(self,problem_name:str,point_type:str)->tuple[str,float]:
        lis_problems=self._get_correct_list(point_type=point_type)
        
        for problem in lis_problems:
            if problem.name==problem_name:
                all_vars=problem.leader_vars+problem.follower_vars
                return create_string_tuple_from_dic(problem.point,all_vars),round(problem.leader_obj_value,2)
            
        raise Exception(f"Para el problema {problem_name} del tipo {point_type} no existe punto")
          
    
    def _make_result_table(self,best_c:ExperimentResultAtomic,best_m:ExperimentResultAtomic,best_strong:ExperimentResultAtomic,best_alpha_zero:ExperimentResultAtomic):
        
        c_orig_point,c_orig_val=self._get_original_point_string(best_c.problem_name,CESTACIONARIO)
        m_orig_point,m_orig_val=self._get_original_point_string(best_m.problem_name,MESTACIONARIO)
        strong_orig_point,strong_orig_val=self._get_original_point_string(best_strong.problem_name,FUERTEMENTEESTACIONARIO)
        alpha_zero_orig_point,alpha_zero_orig_val=self._get_original_point_string(best_alpha_zero.problem_name,ALPHAZERO)
        
        ##
        #all_vars=best_c.leaders_vars+best_c.follower_vars
        #c_optimal_point=create_string_tuple_from_dic(best_c.point,all_vars)
        #m_optimal_point=create_string_tuple_from_dic(best_m.point,all_vars)
        #strong_optimal_point=create_string_tuple_from_dic(best_strong.point,all_vars)
        #alpha_zero_optimal_point=create_string_tuple_from_dic(best_alpha_zero.point,all_vars)
        c_optimal_point=best_c.get_point_tupple_string()
        m_optimal_point=best_m.get_point_tupple_string()
        strong_optimal_point=best_strong.get_point_tupple_string()
        alpha_zero_optimal_point=best_alpha_zero.get_point_tupple_string()
        temp:str=f"""
        \\begin{{resultstable}}{{Problemas {self.problem_type_name} Seleccionados}}
        \\resultrow{{$\alpha=0$}}{{{best_alpha_zero.problem_name}}}{{{alpha_zero_orig_point}}}{{{alpha_zero_orig_val}}}{{{alpha_zero_optimal_point}}}{{{round(best_alpha_zero.val_obj,2)}}}{{{best_alpha_zero.method_name}}}
        \\resultrow{{C-Estacionario}}{{{best_c.problem_name}}}{{{c_orig_point}}}{{{c_orig_val}}}{{{c_optimal_point}}}{{{round(best_c.val_obj,2)}}}{{best_c.method_name}}
        \\resultrow{{M-Estacionario}}{{{best_m.problem_name}}}{{{m_orig_point}}}{{{m_orig_val}}}{{{m_optimal_point}}}{{{round(best_m.val_obj,2)}}}{{{best_m.method_name}}}
        \\resultrow{{Fuertemente-Estacionario}}{{{best_strong.problem_name}}}{{{strong_orig_point}}}{{{strong_orig_val}}}{{{strong_optimal_point}}}{{{round(best_strong.val_obj,2)}}}{{{best_strong.method_name}}}
        \\end{{resultstable}}
        """
        return temp
        
    def run_experiments(self):
        # Analizar los C-Estacionarios
        best_c=self._run_experiment_from_type(self.C_Estacionarios,CESTACIONARIO)
        # M-Estacionarios
        best_m=self._run_experiment_from_type(self.M_Estacionario,MESTACIONARIO)
        # Strong
        best_strong=self._run_experiment_from_type(self.Strong_Estacionario,FUERTEMENTEESTACIONARIO)
        # Alpha_zero
        best_alpha_zero=self._run_experiment_from_type(self.alpha_zero,ALPHAZERO)
        
        # Ahora hacer las tablitas
        table_str=self._make_result_table(best_c=best_c,best_m=best_m,best_alpha_zero=best_alpha_zero,best_strong=best_strong)
        #
        guardar_string_en_archivo(f"Resultados_{self.problem_type_name}",table_str,self.sub_folder_name)
        
        self.serializar_en_archivo(self.sub_folder_name)
        
        print(f"Se realizo el experimento de {self.problem_type_name} con resultados \n")
        
          
    def start(self):
        self.find_problem_in_folder()
        self.run_experiments()
    def __init__(self,root_folder:str,start_random_seed:int,end_random_seed:int,problem_type_name:str,non_convex:bool=False):
        #"D:\GitHub\Tesis\experiment\linear"
        self.root_folder:str=root_folder
        self.sub_folder:list[str]=[]
        self.problems_name:list[str]=[]
        self.problem_type_name:str=problem_type_name
        """
        Si el problema es Lineal, Cuadrático o No convexo
        """
        
        self.sub_folder_name:str=f"Resultados_{self.problem_type_name}"
        """
        Nombre de la carpeta donde se van a guardar las cosas
        """
        self.start_random_seed:int=start_random_seed
        """
        Inicio de la semilla random (Inclusivo)
        """
        self.end_random_seed:int=end_random_seed
        """
        Fin de la semilla Random Exclusivo
        """
        self.experiment_class:Type[ExperimentLinearQuadratic|ExperimentNonConvex]=ExperimentNonConvex if non_convex else ExperimentLinearQuadratic
        self.C_Estacionarios:list[ExperimentLinearQuadratic]=[]
        self.alpha_zero:list[ExperimentLinearQuadratic]=[]
        self.M_Estacionario:list[ExperimentLinearQuadratic]=[]
        self.Strong_Estacionario:list[ExperimentLinearQuadratic]=[]
        
        self.results_modify_problems:dict[str,dict[str,ExperimentsResult]]={}
        """
        Valores optimos de los problemas modificados nombre problema, tipo punto resultados
        """
    def find_problem_in_folder(self):
        """
        Encuenta en una carpeta todos los problemas
        """
        # Caminar por todas las subcarpetas
        #de ahi extraer el nombre
        
        for dirpath, dirnames, filenames in os.walk(self.root_folder):
            self.problems_name=dirnames
            break
        for i,problem in enumerate(self.problems_name):
            # Entonces ahora tomar todas las posibilidades
            problem_path=os.path.join(self.root_folder,problem)
            files=self.find_problem_files(problem_path,'Experimentos_Generador', '.xlsx')
            #Numero de la semilla
            seed=self.start_random_seed+i
            # Ahora tomar los que son c-estacionarios
            for file_path in files:
                try:
                    if "C_Stationarygenerator_alpha_non_zero" in file_path:
                        self.C_Estacionarios.append(self.experiment_class(problem,CESTACIONARIO,file_path,problem_path,random_seed=seed))
                    elif "C_Stationarygenerator_alpha_zero" in file_path:
                        self.alpha_zero.append(self.experiment_class(problem,ALPHAZERO,file_path,problem_path,random_seed=seed))
                    elif "M_Stationarygenerator_alpha_non_zero" in file_path:
                        self.M_Estacionario.append(self.experiment_class(problem,MESTACIONARIO,file_path,problem_path,random_seed=seed))
                    elif "Strong_Stationarygenerator_alpha_non_zero" in file_path:
                        self.Strong_Estacionario.append(self.experiment_class(problem,FUERTEMENTEESTACIONARIO,file_path,problem_path,random_seed=seed))
                    else:
                        print(f"El archivo {file_path} no tiene clase identificada")
                except Exception as e:
                    print(f"Error en el archivo {problem}")
                    raise Exception(e)
                    
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

#print("Hola")
#a=Experiment(root_folder="D:\GitHub\Tesis\experiment\kk",start_random_seed=1,end_random_seed=6,non_convex=True,problem_type_name=NOCONVEXO)
#a.start()
#print(a.C_Estacionarios[0].run())

