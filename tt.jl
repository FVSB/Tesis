struct MiTipo
    x::Int
end

function (a::MiTipo)()  # Definimos el método para la instancia
    println("Hola desde MiTipo con x = $(a.x)")
end

a = MiTipo(10)