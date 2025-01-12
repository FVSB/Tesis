
include("../def_problem/MiModulo.jl")
using Symbolics
mutable struct Experiment
    model_alpha_non_zero::OptimizationModel
    model_alpha_zero::OptimizationModel
end

function CreateExperiment()
    alpha_::Vector{Number} = [1]
    return Experiment(GeneratorModel(alpha_), GeneratorModel())

end


macro leader_vars(experiment, args...)
    begin


        # Crear una expresión para evaluar la macro @variables con los argumentos proporcionados
        vars_expr = esc(:(@myvariables Upper(experiment.model_alpha_non_zero) $(args...)))
        vars_expr_2 = esc(:(@myvariables Upper(experiment.model_alpha_zero) $(args...)))
    end
    # Devolver una expresión para agregar las variables a vector_to_add
    quote
        new_vars = $vars_expr
        new_vars_2 = $vars_expr_2
        #append!($problem.vars, new_vars)  # Agregar las variables al vector

        new_vars  # Retornar las nuevas variables creadas
    end
end

macro follower_vars(experiment, args...)
    begin


        # Crear una expresión para evaluar la macro @variables con los argumentos proporcionados
        vars_expr = esc(:(@myvariables Lower(experiment.model_alpha_non_zero) $(args...)))
        vars_expr_2 = esc(:(@myvariables Lower(experiment.model_alpha_zero) $(args...)))
    end
    # Devolver una expresión para agregar las variables a vector_to_add
    quote
        new_vars = $vars_expr
        new_vars_2 = $vars_expr_2
        #append!($problem.vars, new_vars)  # Agregar las variables al vector

        new_vars  # Retornar las nuevas variables creadas
    end

end

function SetLeaderFunction(experiment::Experiment, expr::Symbolics.Num)
    SetObjectiveFunction(Upper(experiment.model_alpha_non_zero), expr)
    SetObjectiveFunction(Upper(experiment.model_alpha_zero), expr)
end

function SetLeaderRestriction(experiment::Experiment, expr::Symbolics.Num)
    _miu = get_rand()
    SetLeaderRestriction(experiment.model_alpha_non_zero, expr, J_0_g, _miu)
    SetLeaderRestriction(experiment.model_alpha_zero, expr, J_0_g, _miu)
end

function SetFollowerFunction(experiment::Experiment, expr::Symbolics.Num)
    SetObjectiveFunction(Lower(experiment.model_alpha_non_zero), expr)
    SetObjectiveFunction(Lower(experiment.model_alpha_zero), expr)
end

function SetFollowerRestriction(experiment::Experiment, expr::Symbolics.Num)
    _beta = get_rand()
    _lambda = get_rand()
    _gamma = get_rand()
    SetFollowerRestriction(experiment.model_alpha_non_zero, expr, J_0_LP_v, _beta, _lambda, _gamma)
end


function SetPoint(experiment::Experiment, point::Dict)
    SetPoint(experiment.model_alpha_non_zero, point)
    SetPoint(experiment.model_alpha_zero, point)
end


function RunExperiment(experiment::Experiment)
    length_y_vars::Int = length(experiment.model_alpha_non_zero.follower_problem.vars)
    SetAlpha(experiment.model_alpha_non_zero, get_rand_vect(length_y_vars))
    println("LLEgue aca")
    # Inicializar ambos experimentos
    CreateProblem(experiment.model_alpha_non_zero)
    CreateProblem(experiment.model_alpha_zero)
end