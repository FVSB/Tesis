# Modulo para el problema
using Symbolics

include("structs/structs_declaration.jl")
include("structs/restriction_types.jl")
function Lower(opt_model::OptimizationModel)
    return opt_model.follower_problem
end

function Upper(opt_model::OptimizationModel)
    return opt_model.leader_problem
end

function SetObjectiveFunction(problem::Problem, expr::Symbolics.Num)
    problem.expr=expr
end


function SetLeaderRestriction(model::OptimizationModel, expr::Symbolics.Num,
    restriction_set_type::RestrictionSetType,
    miu::Number
    )
    rest = LeaderRestrictionProblem(expr, miu, restriction_set_type)
    push!(model.leaders_restriction, rest)
   
end

function SetFollowerRestriction(
    model::OptimizationModel,
    expr::Symbolics.Num,
    restriction_set_type::RestrictionSetType,
    beta::Number,
    lambda::Number,
    gamma::Number,
)
    rest = FollowerRestrictionProblem(expr, restriction_set_type, beta, lambda, gamma)
    push!(model.follower_restriction_problem, rest)

end

"""
Sobre carga en caso de que gamma no sea valor de entrada
"""
function SetFollowerRestriction(
    model::OptimizationModel,
    expr::Symbolics.Num,
    restriction_set_type::RestrictionSetType,
    beta::Number,
    lambda::Number
)
return SetFollowerRestriction(model,expr,restriction_set_type,beta,lambda,0)
end


function SetAlpha(model::OptimizationModel, alpha::Vector)
    #Añadir que si no es igual al length del level inf lanzar exepcion
    model.is_alpha_zero = false
    model._alpha = alpha
    
end



function SetPoint(model::OptimizationModel,point::Dict)
model.point=point
end

"""
Se debe llamar al metodo pasandole un vector de numeros con el valor de \alpha en caso de ser vacio este se tomara como que alpha es cero
"""
function GeneratorModel(_alpha::Vector{Number})



    leader = Problem([], nothing)

    follower = Problem([], nothing)


    return OptimizationModel(leader, Vector{LeaderRestrictionProblem}(), follower, Vector{FollowerRestrictionProblem}(), Dict(), _alpha, isempty(_alpha))
end
"""
Si llama al metodo si pasar un vector de Number entonces tomará que alpha es igual al vector Nulo
"""
function GeneratorModel()
    GeneratorModel(Vector{Number}())
end

