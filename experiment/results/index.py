import streamlit
from results_handle import *
# Deserializar el nombre de todos
import json
import os
current_directory = os.path.dirname(os.path.abspath(__file__))
file_path = os.path.join(current_directory, 'problems_name.json')

deserialized:dict
with open(file_path, 'r') as file: 
    deserialized = json.load(file) 

#print(deserialized)

def str_to_float_tuple(string:str)->tuple[float]:

    # Divide la cadena en elementos separados por comas y elimina los espacios en blanco 
    elementos = string.split(", ") 
    # Convierte cada elemento a float y agrupa en una tupla 
    tupla = tuple(map(float, elementos))
    return tupla


def get_original_point(point_now:tuple[float])->tuple[float]:
    try:
        original_point=st.text_input("Punto Del problema Generado",value=str(point_now))
        return str_to_float_tuple(original_point)
    except Exception as e:
        print(f"La exepcion es {e}")
        return ""
def get_original_objective_value(value_now:float)->float:
    objective_original_value=st.text_input("Cual es el punto objetivo del problema generado",value=str(value_now))
    return float(objective_original_value)
import streamlit as st

def _get_count_vars(count_now:int,var_name:str)->int:
    count_xs=st.text_input(f"Cuantas {var_name} hay",value=str(count_now))
    return int(count_xs)
def get_count_xs(count_now:int)->int:
    return _get_count_vars(count_now,"xs")

def get_count_ys(count_now:int)->int:
    return _get_count_vars(count_now=count_now,var_name="ys")

def init_problem(problem_name:str)->Problem:
    st.text(f"Inicializar el problema: {problem_name}")
    original_point=get_original_point(tuple())
    objective_original_value=get_original_objective_value(0)
    init_problem:Problem=Problem(problem_name,original_point,objective_original_value,get_count_xs(0),get_count_ys(0))
    return init_problem

def modify_problems_static_point(problem:Problem)->Problem:
    categories_types=["Ninguno","C-Estacionario","M-Estacionario","Strong-Estacionario"]
    category=st.selectbox("Selecciona el tipo de punto a introducir",categories_types)
    if categories_types[0]==category:# Normal
        return Problem
    elif category==categories_types[1]:#C-Estacionario
        st.text("Modificar C-Estacionario")

def modify_problem(problem:Problem):
    st.text(f"Modificar el problema {problem.name}")
    problem.original_point=get_original_point(problem.original_point)
    problem.objetive_value_original=get_original_objective_value(problem.objetive_value_original)
    problem.count_x=get_count_xs(problem.count_x)
    problem.count_y=get_count_ys(problem.count_y)
    
    return modify_problems_static_point(problem)
    # Aca mandar a modificar lo de los puntos

"""
Dar aca para mandar a serializar la base de datos
"""
def to_serialize(db:dict):
    if st.button("Guardar cambios"):
        serialize(db)
        print(f"Se serializo {db}")

# Supongamos que tienes un diccionario
mi_diccionario =deserialized

# Para que el usuario seleccione una categoría
categoria = st.selectbox("Selecciona una categoría:", list(mi_diccionario.keys()))

# Mostrar opciones de la categoría seleccionada
if categoria:
    problem_name = st.selectbox(f"Selecciona una {categoria.lower()}:", mi_diccionario[categoria])
    st.write(f"Has seleccionado: {problem_name}")


# Ahora se debe extraer la db
db:dict[str,Problem]=deserialize()
# Si es None es que no se ha creado 
if db is None:
    # hay que crear inicialmente un problema
    
    db={problem_name:init_problem(problem_name)}
    to_serialize(db)
else:# Entonces ahora se debe de ver si el problema existe sino crearlo 
    # Si no existe el problema en la base de datos anadirlos
    if problem_name not in db: # Entonces mandar a inicializar
       db[problem_name]= init_problem(problem_name)
       to_serialize(db)
    else: # Entonces mandar a modificar
        problem=db[problem_name]
        problem=modify_problem(problem)
        db[problem_name]=problem
        to_serialize(db)
        print(db)
    