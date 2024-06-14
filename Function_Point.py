import sympy as sp


class Function:
    def __init__(self,
                 var_lider: list[str],
                 var_follower:list[str],
                 function_atomic: str
                 ):
        #Definir las variables del lider o nivel superior
        self._vars_lider=var_lider
        #Definir las variables del follower o nivel inferior
        self._vars_follower=var_follower


        # Definir las variables simbólicas
        self.vars_ = sp.symbols(var_names)

        # Definir la función como un string
        self.func_str:str = function_atomic

        self.func_atomic = sp.sympify(self.func_str)

    def eval(self, values: list[float]):
        # Asegurarse de que hay el mismo número de valores que de variables
        assert len(values) == len(self.vars_)

        # Crear un diccionario de sustituciones
        subs = {var: val for var, val in zip(self.vars_, values)}

        return self.func_atomic.subs(subs)


class EqualsRestrictionFunction(Function):
    def __init__(self,
                 var_names: list[str],
                 function_atomic: str,
                 equals_expression: str
                 ):
        super().__init__(var_names, function_atomic)
        self.equals_expression = equals_expression
        """ expresión de cuanto debe ser igual """
        self._right_restriccion_part=sp.sympify(self.equals_expression)
        """Parte derecha de la restriccion pasada por simpy"""
        self._all_restriction_str=f'Eq({self.func_atomic},{self.equals_expression})'
        """Restriccion completa"""
        self.func_atomic=sp.sympify(self._all_restriction_str)
        """Restriccion a evaluar"""
        self._atomic_function_str:str=self.func_str
        """El str de la parte izquierda de la igualdad"""
        self._atomic_function_to_eval=sp.sympify(self._atomic_function_str)
        """ Función de la parte izquierda para evaluar """






#class GtRestrictionFunction(Function):





atomic = Function(['x_1', 'x_2', 'X_3'],[], 'Eq(log(x_1, 2) * x_2**Y_1,X_3)')


# print(atomic.eval([2, 3, 9]))  # Debería imprimir 12, porque log2(2) * 3^2 = 1 * 9 = 9


class Solver:
    def __init__(self, objetive_function: Function, restricctions: list[Function]):
        self.objective_func: Function = objetive_function
        """Funcion objetivo"""
        self.restricctions: list[Function] = restricctions
        """Cjt de restricciones"""

    def evaluate_point(self, point: list[float]):
        obj_func_value: float = self.objective_func.eval(point)

        set_not_good: list[Function]

        for i, restricction in enumerate(self.restricctions, 0):
            if not restricction.eval(point):
                set_not_good.append(restricction)
