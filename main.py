from Function_Point import  *

#Funciones a ver

l_1='Eq(((x_1--2)),3)'



solver=Solver(
    ProblemFunction(["x_1"],[], "x_1**2",True),
    [RestrictionFunction(["x_1"], "Eq(((x_1--2)),3)", RestrictionSetType.J_0_g)],
    ProblemFunction(["x_1"],[], "x_1**2",False),
    [RestrictionFunction(["x_1"], "Gt(((x_1--2)),3)", RestrictionSetType.J_Ne_L0_v)])




solver.evaluate_point([22])

solver.show_changes()