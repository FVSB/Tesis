
"""
    is_operator(symbol::Symbol) -> Bool

Determina si un símbolo dado es un operador en Julia.

# Parámetros
- `symbol::Symbol`: El símbolo que se desea verificar.

# Retorno
- Devuelve `true` si el símbolo es un operador, de lo contrario devuelve `false`.

# Ejemplo
```jldoctest
julia> is_operator(:+)
true

julia> is_operator(:foo)
false
```
"""
function is_operator(symbol::Symbol)
    return symbol in (:+, :-, :*, :/, :^, :<, :>, :<=, :>=, :(==), :!=, :&&, :||, :|, :&, :<<, :>>, :%, :÷)
end


