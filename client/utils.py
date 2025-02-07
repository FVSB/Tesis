import random

def get_random(epsilon=1e-10):
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
     
        return (-get_random() * 10, -get_random() * 10)
   
    
    return (0, 0) 

def get_multiplicadores_m_estacionario():
    """
     Retorna el valor de Beta y Gamma.
    Genera los Beta y Gammas para que el punto sea M-Estacionario.
    """
    rand_value = random.randint(1, 2)
    
    if rand_value == 1:  # Entonces los dos son mayores que cero
     
        return (0, get_random() * 10)
    else:
        return (get_random() * 10, 0)
   
    
def get_multiplicadores_strong_estacionario():

    return (get_random() * 10, get_random() * 10)