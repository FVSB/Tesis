
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
CESTACIONARIO="C-Estacionario"
MESTACIONARIO="M-Estacionario"
FUERTEMENTEESTACIONARIO="Fuertmente-Estacionario"
ALPHAZERO="Alpha-Zero"


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
    def __init__(self,root_folder:str,start_random_seed:int,end_random_seed:int,non_convex:bool=False):
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
        self.experiment_class:Type[ExperimentLinearQuadratic|ExperimentNonConvex]=ExperimentNonConvex if non_convex else ExperimentLinearQuadratic
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
                    self.C_Estacionarios.append(self.experiment_class(problem,CESTACIONARIO,file_path,problem_path,random_seed=seed))
                elif "C_Stationarygenerator_alpha_zero" in file_path:
                    self.alpha_zero.append(self.experiment_class(problem,ALPHAZERO,file_path,problem_path,random_seed=seed))
                elif "M_Stationarygenerator_alpha_non_zero" in file_path:
                    self.M_Estacionario.append(self.experiment_class(problem,MESTACIONARIO,file_path,problem_path,random_seed=seed))
                elif "Strong_Stationarygenerator_alpha_non_zero" in file_path:
                    self.Strong_Estacionario.append(self.experiment_class(problem,FUERTEMENTEESTACIONARIO,file_path,problem_path,random_seed=seed))
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

print("Hola")
a=Experiment("D:\GitHub\Tesis\experiment\kk",1,6,True)
a.start()
#print(a.C_Estacionarios[0].run())

