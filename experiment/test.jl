include("new_experiment.jl")

experiment=CreateExperiment()

@leader_vars experiment x

@follower_vars experiment y_1,y_2

SetLeaderFunction(experiment,-x-3y_1+2y_2)

SetFollowerFunction(experiment,-y_1)

SetFollowerRestriction(experiment,-y_1<=0)

SetFollowerRestriction(experiment,y_1<=4)

SetFollowerRestriction(experiment,-2x+y_1+4y_1<=16)

SetFollowerRestriction(experiment,8x+3y_1-2y_1<=48)

SetFollowerRestriction(experiment,-2x+y_1-3y_1<=-12)

SetPoint(experiment,Dict(x=>5,y_1=>4,y_2=>2))

RunExperiment(experiment,"probando")