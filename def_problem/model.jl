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

function SetAlpha(model::OptimizationModel, alpha::Vector)
    #Añadir que si no es igual al length del level inf lanzar exepcion
    model.is_alpha_zero = false
    model._alpha = alpha
    
end

function SetAlphaZero(model::OptimizationModel, is_alpha_zero::Bool)
    model.is_alpha_zero = is_alpha_zero
end

function SetPoint(model::OptimizationModel,point::Dict)
model.point=point
end
function GeneratorModel()



    leader = Problem([], nothing)

    follower = Problem([], nothing)

    return OptimizationModel(leader, Vector{LeaderRestrictionProblem}(), follower, Vector{FollowerRestrictionProblem}(), Dict(), Vector{Number}(), false)
end

