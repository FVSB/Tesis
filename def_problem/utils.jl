# Utils script 

"""
Generates a random number greater than zero and less than one.

# Returns
- `Float64`: A random number slightly greater than zero.
"""
function get_rand()
    epsilon = 1e-10
    rand() + epsilon
end

export get_rand

