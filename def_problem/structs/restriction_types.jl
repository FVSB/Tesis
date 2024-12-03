
    ##################################################
    #   	                                         #
    #                   Enums                        #
    #                                                #
    ##################################################


# Definition of RestrictionType enum
@enum RestrictionType begin
    Eq
    Gt
    Lt
    GtEq
    LtEq
end
export RestrictionType, Eq, Gt, Lt, GtEq, LtEq

# Definition of RestrictionSetType enum
@enum RestrictionSetType begin
    Normal
    J_0_g
    J_0_LP_v
    J_0_L0_v
    J_Ne_L0_v
end

"""
Get the description of a restriction set type.

# Arguments
- `rst::RestrictionSetType`: The restriction set type.

# Returns
- `String`: A description of the restriction type.
"""
function description(rst::RestrictionSetType)
    descriptions = Dict(
        Normal => "Normal restriction",
        J_0_g => "Active in Leader",
        J_0_LP_v => "Active in Follower Lambda Positive",
        J_0_L0_v => "Active in Follower Lambda Zero",
        J_Ne_L0_v => "Negative in Follower Lambda Zero"
    )
    return get(descriptions, rst, "Unknown restriction")
end

export RestrictionType,RestrictionSetType,description