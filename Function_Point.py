import random
from abc import ABC
from enum import Enum

import sympy as sp


class RestrictionType(Enum):
    Eq = "equality",
    Gt = "greater_than",
    Lt = "less_than",
    GtEq = "greater_than_or_equal",
    LtEq = "less_than_or_equal"


class RestrictionSetType(Enum):
    """
    Conjunto de indices activos donde se encuentra J_i_0
    """
    Normal = 'Normal restriction',
    J_0_g = "Active in Leader",
    J_0_LP_v = "Active in Follower Lambada Positive",
    J_0_L0_v = "Active in Follower Lambada Zero",
    J_Ne_L0_v = "Negative in Follower Lambada Zero",

    def __eq__(self, other):
        if isinstance(other, RestrictionSetType):
            return self.value == other.value
        if isinstance(other, str):
            return self.value == other
        return False

class Function(ABC):

    def __init__(self, var_names: list[str], function_atomic: str):
        # Definir las variables simbólicas
        self.vars_ = sp.symbols(var_names)
        """
         Variables simbólicas
        """

        # Definir la función como un string
        self.func_str = function_atomic
        self.func_atomic = sp.sympify(self.func_str)

    def eval(self, values: list[float]):
        # Asegurarse de que hay el mismo número de valores que de variables
        assert len(values) == len(self.vars_)

        # Crear un diccionario de sustituciones
        subs = {var: val for var, val in zip(self.vars_, values)}

        return self.func_atomic.subs(subs)


class ProblemFunction(Function):
    def __init__(
            self,
            var_lider: list[str],
            var_follower: list[str],
            function_atomic: str,
            leader_level: bool = True,
    ):
        super().__init__(var_lider + var_follower, function_atomic)
        # Definir las variables del lider o nivel superior
        self._vars_lider = var_lider
        # Definir las variables del follower o nivel inferior
        self._vars_follower = var_follower

        self.leader_level = leader_level
        """
        True:is the leader level, False: is the follower level
        """


class RestrictionFunction(Function):

    def refactor_restriction(self, restriction: str):
        """
        Refactor the restriction
        :param restriction:
        :return:
        """
        start = restriction.find('(')
        relation = restriction[:start]
        temp = restriction[start + 1:len(restriction) - 1]
        temp = temp.split(',')
        left = temp[0]
        right = temp[1]
        return f'{relation}(({left})-({right})-({self.const_add_value}),0)'

    def __init__(
            self, var_names: list[str], restriction: str,
            restriction_set_type: RestrictionSetType = RestrictionSetType.Normal
    ):
        self._const_add: float = 0
        """
        The value of the const to add 
        """
        self._original_str_restriction = restriction
        super().__init__(var_names, self.refactor_restriction(restriction))

        self.restriction_type: RestrictionSetType = restriction_set_type
        """
        The set of the restriction
        """



        self.left_part = self.func_atomic.lhs
        """
        The left part 
        """

        self.right_part = self.func_atomic.rhs
        """
        The right part
        """

    @property
    def const_add_value(self):
        return self._const_add

    @const_add_value.getter
    def const_add_value(self):
        return self._const_add
    @const_add_value.setter
    def const_add_value(self, value: float):
        self._const_add = value

    def _get_type(self) -> RestrictionType:
        dic = {
            "Eq": RestrictionType.Eq,
            "Gt": RestrictionType.Gt,
            "Lt": RestrictionType.Lt,
            "Ge": RestrictionType.GtEq,
            "Le": RestrictionType.LtEq,
        }

        start = self.func_str[:2]

        if start not in dic:
            raise Exception(f"{start} is not a comparer")

        return dic[start]

    @property
    def type(self) -> RestrictionType:
        return self._get_type()

    def eval_to_number(self, values: list[float], ):
        """
        Devuelve el valor dado osea si es una igualdad lo iguala a 0
        análogo para desigualdades osea lo deja todo en la parte izquierda
        :param values:
        :return:
        """
        # Asegurarse de que hay el mismo número de valores que de variables
        assert len(values) == len(self.vars_)

        # Crear un diccionario de sustituciones
        subs = {var: val for var, val in zip(self.vars_, values)}

        # obtener el lado izquierdo de la relación
        lhs = self.func_atomic.lhs

        return lhs.subs(subs)

    def __str__(self):
        return self.refactor_restriction(self._original_str_restriction)



def _fix_eq0(restrictions: list[RestrictionFunction], point: list[float]):
    """
    Fix the restrictions to need going to be equal 0
    :param restrictions:
    :param point:
    :return:
    """
    for restriction in restrictions:
        if restriction.type == RestrictionSetType.Normal:
            # Si las restricciones no están obligadas se continua
            continue
        if restriction.restriction_type not in [RestrictionSetType.J_0_g, RestrictionSetType.J_0_L0_v,
                                    RestrictionSetType.J_0_LP_v]:
             continue
        val = restriction.eval_to_number(point)
        if val == 0:
            continue

        restriction.const_add_value = val * -1


def _fix_lt0(restrictions: list[RestrictionFunction], point: list[float]):
    for restriction in restrictions:
        if restriction.type == RestrictionSetType.Normal:
            continue
        if restriction.restriction_type not in [RestrictionSetType.J_Ne_L0_v]:
            continue
        val = restriction.eval_to_number(point)
        if val < 0:
            continue

        restriction.const_add_value = (val + random.random()) * -1


class Solver:
    def __init__(
            self,
            leader_function: ProblemFunction,
            leader_restrictions: list[RestrictionFunction],
            follower_function: ProblemFunction,
            follower_restrictions: list[RestrictionFunction],
            seed: int = 123

    ):
        self.leader_function: ProblemFunction = leader_function
        self.leader_restrictions: list[RestrictionFunction] = leader_restrictions
        self.follower_function: ProblemFunction = follower_function
        self.follower_restrictions: list[RestrictionFunction] = follower_restrictions
        self.seed: int = seed

    def evaluate_point(self, point: list[float]):
        # obj_func_value: float = self.objective_func.eval(point)

        leader_val = self.leader_function.eval(point)

        follower_val = self.follower_function.eval(point)

        _fix_eq0(self.leader_restrictions, point)

        _fix_eq0(self.follower_restrictions, point)

        _fix_lt0(self.follower_restrictions, point)

        return leader_val, follower_val

    def show_changes(self):
        print('Printing the changes')
        print('Leader restrictions')

        for l_res in self.leader_restrictions:
            if l_res.const_add_value != 0:
                print(f'{l_res} the constant is {l_res.const_add_value}')

        print('Follower restrictions')
        for f_res in self.follower_restrictions:
            if f_res.const_add_value != 0:
                print(f' {f_res} the constant is {f_res.const_add_value}')







