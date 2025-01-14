using Symbolics
# Definition of RestrictionSetType enum
#@enum RestrictionSetType begin
#    Normal
#    J_0_g
#    J_0_LP_v
#    J_0_L0_v
#    J_Ne_L0_v
#end
include("restriction_types.jl")
mutable struct Problem
    vars::Vector{Any}
    expr::Union{Symbolics.Num,Nothing}
end

struct LeaderRestrictionProblem
    expr::Symbolics.Num
    _miu::Number
    restriction_set_type::RestrictionSetType
end

mutable struct FollowerRestrictionProblem

    expr::Symbolics.Num
    restriction_set_type::RestrictionSetType
    _beta::Number
    _lambda::Number
    _gamma::Number

end

mutable struct OptimizationModel
    leader_problem::Problem
    leaders_restriction::Vector{LeaderRestrictionProblem}
    follower_problem::Problem
    follower_restriction_problem::Vector{FollowerRestrictionProblem}
    point::Dict
    _alpha::Vector{Number}
    is_alpha_zero::Bool

end