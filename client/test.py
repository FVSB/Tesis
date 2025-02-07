#from sympy import sympify, Lt, Le, Gt, Ge
#from sympy.core.relational import Relational
#
#def _get_vars_from_expression(self, expression_str: str) -> list[str]:
#    # Convertir la expresión de string a una expresión simbólica
#    expression = sympify(expression_str)
#    
#    # Encontrar las variables de la expresión
#    variables = expression.free_symbols
#    vars_list = list(map(str, variables))
#    
#    return vars_list
#
#def is_strict_inequality(expression_str: str) -> bool:
#    # Convertir la expresión de string a una expresión simbólica
#    expression = sympify(expression_str)
#    
#    # Verificar si la expresión es una desigualdad estricta
#    return isinstance(expression, (Lt, Le, Gt, Ge))
#
## Ejemplo de uso
#expresion_str = "x < y"
#print(_get_vars_from_expression(None, expresion_str))  # ['x', 'y']
#print(is_strict_inequality(expresion_str))  # True
#
#expresion_str = "x == y"
#print(_get_vars_from_expression(None, expresion_str))  # ['x', 'y']
#print(is_strict_inequality(expresion_str))  # False


#from sympy import symbols, sympify
#
## Expresión matemática en forma de string
#expresion_str = "a * x_1**2 + b * x + c==0"
#
## Convertir la expresión de string a una expresión simbólica
#expresion = sympify(expresion_str)
#
## Encontrar las variables de la expresión
#variables:set = expresion.free_symbols
#lis=list(variables)
#vars_list=list(map(str,lis))
#print(type(vars_list[1]))
## Imprimir las variables
#print("Las variables en la expresión son:", variables)
#

#from sympy import symbols, Eq, sympify
#
## Definir las variables simbólicas
#a, x_1, b, c = symbols('a x_1 b c')
#
## Expresión matemática en forma de string
#expresion_str = "a * x_1**2 + b * x_1 + c == 0"
#
## Convertir la expresión de string a una expresión simbólica
#expresion = sympify(expresion_str)
#
## Verificar si la expresión es una igualdad
#if isinstance(expresion, Eq):
#    miembro_izquierdo = expresion.lhs
#    miembro_derecho = expresion.rhs
#    print("La expresión es una igualdad.")
#    print("Miembro izquierdo:", miembro_izquierdo)
#    print("Miembro derecho:", miembro_derecho)
#else:
#    print("La expresión no es una igualdad.")
#



import re

def encontrar_indices(texto):
    # Expresión regular para encontrar substrings que empiezan con == o =
    patron = r'==\w+|=\w+'
    
    # Buscar todas las coincidencias en el texto
    coincidencias = re.finditer(patron, texto)
    
    # Obtener los índices de las coincidencias
    indices = [(coincidencia.start(), coincidencia.end()) for coincidencia in coincidencias]
    
    return indices

# Ejemplo de uso
#texto = "Aquí tenemos algunas expresiones: a ==b, c=d, y e==f."
texto="a==b"
indices = encontrar_indices(texto)
print("Índices encontrados:", indices)

cadena = "a==b "
indice = cadena.find("==")
print("El índice del primer '==' es:", indice)
print(cadena[:indice])
print(cadena[indice+2:])


def change(a):
    a+="1"
    
print(change(" "))
expresion="a==3"
if "=" in expresion and "==" not in expresion:
    expresion=expresion.replace("=","==")
    
print(expresion)