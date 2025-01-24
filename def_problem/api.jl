using HTTP
using JSON3

# Fabricar una api 

function handle_request(req)
    if req.target == "/hola" && req.method == "GET"
        response = Dict("message" => "¡Hola! Esta es la subdirección /hola")
        return HTTP.Response(200, JSON3.write(response))
    elseif req.method == "POST"
        data = JSON3.read(String(req.body))
        response = Dict("received_data" => data)
        return HTTP.Response(200, JSON3.write(response))
    else
        return HTTP.Response(404, "No se encontró el recurso")
    end
end

server = HTTP.serve(handle_request, "127.0.0.1", 8080)
println("Servidor en funcionamiento en http://127.0.0.1:8080")
function handle_request(req::HTTP.Request)
    println("Método: ", req.method)
    println("URL: ", req.target)
    println("Encabezados: ", req.headers)
    println("Cuerpo: ", String(req.body))

    if req.target == "/hola" && req.method == "GET"
        response = Dict("message" => "¡Hola! Esta es la subdirección /hola")
        return HTTP.Response(200, JSON3.write(response))
    elseif req.method == "POST"
        data = JSON3.read(String(req.body))
        response = Dict("received_data" => data)
        return HTTP.Response(200, JSON3.write(response))
    else
        return HTTP.Response(404, "No se encontró el recurso")
    end
end
