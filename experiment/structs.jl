mutable struct Experiment
    model_alpha_non_zero::OptimizationModel
    model_alpha_zero::OptimizationModel
    leader_vars::Vector
    follower_vars::Vector
end

struct ProblemResult
    opt_problem::Optimization_Problem
    bf_vector::Vector
end

struct ExperimentResult 
    alpha_zero::ProblemResult
    alpha_non_zero::ProblemResult

end