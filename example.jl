__precompile__(false)
using BilevelJuMP, HiGHS, Ipopt, SCIP


function write_response(name,model,x,y)
    # Escribir el nombre del experimento
    println(name)
    # Escribir el resultado de la solucion primal
    p_s=BilevelJuMP.primal_status(model)
    println("Primal Status: $p_s")
    # Escribir el codigo y tipo de terminacion
    t_s=BilevelJuMP.termination_status(model)
    println("Termination Status: $t_s")
    # Objetive value
    o_v=BilevelJuMP.objective_value(model)
    println("Objetive Value $o_v")
    # Lider Vars Value
    l_vars=BilevelJuMP.value.(x)
    println("Lider Vars: $l_vars")
    # Follower Vars Value
    f_vars=BilevelJuMP.value.(y)
    println("Followers Vars Value $f_vars")
    
end

model = BilevelModel()


BilevelJuMP.@variable(Lower(model), x)
BilevelJuMP.@variable(Upper(model), y)

BilevelJuMP.BigMMode(primal_big_M = 100, dual_big_M = 100)