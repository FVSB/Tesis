from experiments import *
from pick import pick

# Definición de los tipos de problemas
LINEAL = "Lineal"
CUADRATICO = "Cuadrático"
NOCONVEXO = "No Convexo"

def solicitar_parametros_personalizados():
    print("\nConfiguración de un experimento personalizado:")
    
    # Solicitar la carpeta raíz
    root_folder = input("Ingrese la ruta de la carpeta raíz (ejemplo: D:\\GitHub\\Tesis\\experiment\\kk): ")
    
    # Solicitar las semillas aleatorias
    try:
        start_random_seed = int(input("Ingrese la semilla inicial (entero): "))
        end_random_seed = int(input("Ingrese la semilla final (entero): "))
    except ValueError:
        print("Error: Las semillas deben ser números enteros.")
        return None
    
    # Solicitar si es no convexo
    non_convex_input = input("¿El problema es no convexo? (s/n): ").strip().lower()
    non_convex = True if non_convex_input == 's' else False
    
    # Solicitar el nombre del tipo de problema
    problem_type_name = input("Ingrese el nombre del tipo de problema (ejemplo: Personalizado): ")
    
    return {
        "root_folder": root_folder,
        "start_random_seed": start_random_seed,
        "end_random_seed": end_random_seed,
        "non_convex": non_convex,
        "problem_type_name": problem_type_name
    }

def main():
    # Opciones del menú
    opciones = [LINEAL, CUADRATICO, NOCONVEXO,"kk" ,"Construir uno distinto"]
    
    # Mostrar el menú interactivo con flechas
    titulo = "Seleccione el tipo de experimento (use las flechas):"
    opcion_seleccionada, indice = pick(opciones, titulo)
    
    # Configurar y ejecutar el experimento
    if opcion_seleccionada == "Construir uno distinto":
        parametros = solicitar_parametros_personalizados()
        if parametros is None:
            print("Error en la configuración del experimento personalizado.")
            return
        
        experimento = Experiment(
            root_folder=parametros["root_folder"],
            start_random_seed=parametros["start_random_seed"],
            end_random_seed=parametros["end_random_seed"],
            non_convex=parametros["non_convex"],
            problem_type_name=parametros["problem_type_name"]
        )
        print(f"\nIniciando experimento personalizado de tipo: {parametros['problem_type_name']}")
    else:
        # Configurar experimento predefinido
        start_random_seed = 1
        end_random_seed = 6
        root_folder = ""
        if opcion_seleccionada==NOCONVEXO:
            start_random_seed=1
            end_random_seed=6
            root_folder="D:\\GitHub\\Tesis\\experiment\\nonconvex"
        elif opcion_seleccionada=="kk":
            start_random_seed=1
            end_random_seed=6
            root_folder="/workspaces/Tesis/experiment/kk"
        elif opcion_seleccionada==LINEAL:
            start_random_seed=6            
            end_random_seed=11
            root_folder=""
        elif opcion_seleccionada==CUADRATICO:
            start_random_seed=11            
            end_random_seed=16
            root_folder="/workspaces/Tesis/experiment/quadratic"
        
        non_convex = (opcion_seleccionada == NOCONVEXO)  # Solo es True si es No Convexo
        
        experimento = Experiment(
            root_folder=root_folder,
            start_random_seed=start_random_seed,
            end_random_seed=end_random_seed,
            non_convex=non_convex,
            problem_type_name=opcion_seleccionada
        )
        print(f"Iniciando experimento de tipo: {opcion_seleccionada}")
    
    # Ejecutar el experimento
    experimento.start()

if __name__ == "__main__":
    main()