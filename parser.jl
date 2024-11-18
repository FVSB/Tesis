

    
    using Symbolics
    
    export parse_expression, separate_equation, extract_variable_names, add_to_symbolics, convert_Symbol_to_symbolic_num, eval_point, substitute_point_in_vector
    
    """
        parse_expression(expr::AbstractString) -> Num
    
    Parses a mathematical expression from a string.
    
    # Parameters
    - `expr::AbstractString`: The string containing the mathematical expression.
    
    # Returns
    - A `Num` object representing the parsed and evaluated expression.
    
    # Example
    ```julia
    julia> parse_expression("2 + 3")
    5
    ```
    """
    function parse_expression(expr::AbstractString)::Num
        if isa(expr, SubString{String})
            expr = String(expr)
        end
        parsed_expr = Meta.parse(expr)
        return eval(parsed_expr)
    end
    
    """
        separate_equation(equation::String) -> Tuple{Num, Num}
    
    Splits an equation string into its left-hand and right-hand sides.
    
    # Parameters
    - `equation::String`: The string containing the equation. Use `==` as separator.
    
    # Returns
    - A tuple `(left_part, right_part)` where each part is parsed as a `Num`.
    
    # Example
    ```julia
    julia> separate_equation("x + 2 == 3")
    (x + 2, 3)
    ```
    """
    function separate_equation(equation::String)
        parts = split(equation, "==")
        left_part = parse_expression(parts[1])
        right_part = parse_expression(parts[2])
        return left_part, right_part
    end
    
    """
        is_operator(symbol::Symbol) -> Bool
    
    Determines if a given symbol is an operator in Julia.
    
    # Parameters
    - `symbol::Symbol`: The symbol to check.
    
    # Returns
    - `true` if the symbol is an operator, otherwise `false`.
    
    # Example
    ```julia
    julia> is_operator(:+)
    true
    
    julia> is_operator(:foo)
    false
    ```
    """
    function is_operator(symbol::Symbol)
        return symbol in (:+, :-, :*, :/, :^, :<, :>, :<=, :>=, :(==), :!=, :&&, :||, :|, :&, :<<, :>>, :%, :÷)
    end
    
    """
        extract_variable_names(expr::AbstractString) -> Vector{Symbol}
    
    Extracts variable names from a mathematical expression.
    
    # Parameters
    - `expr::AbstractString`: The string containing the expression.
    
    # Returns
    - A vector of symbols representing the variable names in the expression.
    
    # Example
    ```julia
    julia> extract_variable_names("x + y^2 + z")
    [:x, :y, :z]
    ```
    """
    function extract_variable_names(expr::AbstractString)::Vector{Symbol}
        if isa(expr, SubString{String})
            expr = String(expr)
        end
    
        parsed_expr = Meta.parse(expr)
        variable_names = Set{Symbol}()
    
        function extract_variables(ex)
            if ex isa Symbol && !is_operator(ex)
                push!(variable_names, ex)
            elseif ex isa Expr
                for arg in ex.args
                    extract_variables(arg)
                end
            end
        end
    
        extract_variables(parsed_expr)
        return collect(variable_names)
    end
    
    """
        add_to_symbolics(variables::Vector{Symbol})
    
    Adds variables to the Symbolics.jl environment.
    
    # Parameters
    - `variables::Vector{Symbol}`: A vector of symbols to add as symbolic variables.
    
    # Example
    ```julia
    julia> add_to_symbolics([:x, :y])
    ```
    """
    function add_to_symbolics(variables::Vector{Symbol})
        for var in variables
            @eval @variables $var
        end
    end
    
    """
        convert_Symbol_to_symbolic_num(symbol::Union{Symbol, String}) -> Symbolics.Num
    
    Converts a `Symbol` or `String` to a `Symbolics.Num` variable.
    
    # Parameters
    - `symbol::Union{Symbol, String}`: The symbol or string to convert.
    
    # Returns
    - The corresponding `Symbolics.Num` variable.
    
    # Example
    ```julia
    julia> convert_Symbol_to_symbolic_num(:x)
    x
    ```
    """
    function convert_Symbol_to_symbolic_num(symbol::Symbol)::Symbolics.Num
        return Symbolics.variables(symbol)[1]
    end
    
    function convert_Symbol_to_symbolic_num(symbol::String)::Num
        return Symbolics.variables(symbol)[1]
    end
    
    """
        eval_point(expr, point::Dict) -> Num
    
    Evaluates an expression at a given point.
    
    # Parameters
    - `expr`: The symbolic expression.
    - `point::Dict`: A dictionary mapping variable names (strings) to values.
    
    # Returns
    - The evaluated result.
    
    # Example
    ```julia
    julia> eval_point(x^2 + y, Dict("x" => 2, "y" => 3))
    7
    ```
    """
    function eval_point(expr, point::Dict)
        new_dicc = Dict(convert_Symbol_to_symbolic_num(key) => point[key] for key in keys(point))
        return substitute.(expr, (new_dicc,))[1]
    end
    
    """
        substitute_point_in_vector(expr, point::Dict) -> Union{Vector, Matrix}
    
    Substitutes a point into a vector of expressions.
    
    # Parameters
    - `expr`: The vector of symbolic expressions.
    - `point::Dict`: A dictionary mapping variable names (strings) to values.
    
    # Returns
    - A vector or matrix of results.
    
    # Example
    ```julia
    julia> substitute_point_in_vector([x + y, x * y], Dict("x" => 2, "y" => 3))
    [5, 6]
    ```
    """
    function substitute_point_in_vector(expr, point::Dict)::Union{Vector, Matrix}
        new_dicc = Dict(convert_Symbol_to_symbolic_num(key) => point[key] for key in keys(point))
        return substitute.(expr, (new_dicc,))
    end
    

    