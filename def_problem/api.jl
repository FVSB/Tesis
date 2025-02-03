using HTTP
using JSON3  # Usamos JSON3 en lugar de JSON
using XLSX
using DataFrames
using ArgParse
include("solver.jl")
include("serialize_date.jl")

# Desde el diccionario pasar al problema
"""
{
    "vars":{
        "leader":[],
        "follower":[]
    },
    "objective_function":{
        "leader":"",
        "follower":""
    },
    "restrictions":{
        "leader":[{
           "expresion":"",
            "restriction_type":"",
            "active_index_type":"",
            "miu":0.4

        }],
        "follower":[{
            "expresion":"",
            "restriction_type":"",
            "active_index_type":"",
            "lambda":0.1,
            "beta":0.9,
            "gamma":0.4
        }]
    },
    "is_alpha_zero":false,
    "alpha_vec":[2.3,293],
    "point":{
        "x_1":2.2
    }
    
}

"""
function _to_def_restrictions(restrictions_vec,is_leader::Bool)
    response::Vector{Def_Restriction}=Vector{Def_Restriction}()
    println("Imprimeinto los vectores",restrictions_vec)
    for res in restrictions_vec
        expr=res["expresion"]
        restriction_type_set=to_restriction_set_type(res["active_index_type"])
        restriction_type=to_restriction_type(res["restriction_type"])
        println("Impreso todo ")
        # Definirlo todo en cero y en dependencia del tipo de rango convertirlo
        __miu=0
        __lambda=0
        __beta=0
        __gamma=0
        if is_leader
            println("llego aca")
            __miu=res["miu"]
            println("Extrajo miu $__miu")
        else
            __lambda=res["lambda"]
            __beta=res["beta"]
            __gamma=res["gamma"]
        end
        println("Se extrajeron las variables")
        temp=Def_Restriction_init(expr,restriction_type_set,restriction_type,is_leader,__miu,__beta,__lambda,__gamma)
        println("Se creo temp")
        push!(response,temp)
        println("Se añdio correctamente")
        
    end
    if isempty(response)
        return nothing
    end

    return response
end

function _get_restrictions(request)
    # restrictions
restrictions=request["restrictions"]
println("leaidas las restricciones")
leader_restrictions=restrictions["leader"]
follower_restrictions=restrictions["follower"]
println("Leaer restricciones del lider")
leader_solve=_to_def_restrictions(leader_restrictions,true)
println("Leer restricciones follower")
follower_solve=_to_def_restrictions(follower_restrictions,false)
return leader_solve,follower_solve
end
function _to_dict_point(request,x_s_vars,y_s_vars)
    point=request["point"]
    dic=Dict()
    for x in x_s_vars
        dic[x]=point[x]
    end
    for y in y_s_vars
        dic[y]=point[y]
    end
    return dic
end
function to_vector_from_json(vec_json,is_string::Bool)
    if is_string
        res=Vector{String}()
    else
        res=Vector()
    end
    for val in vec_json
        push!(res,val)
    end
    return res
end
function solver_problem(request,file_name::String)
# 
vars=request["vars"]
leader_vars=to_vector_from_json(vars["leader"],true)
follower_vars=to_vector_from_json(vars["follower"],true)
# Objective
objectives=request["objective_function"]
leader_obj=objectives["leader"]
follower_obj=objectives["follower"]
# restrictions
println("LLegando a las restricciones")
leader_restrictions,follower_restrictions=_get_restrictions(request)
println("Las restricciones")
# alpha
is_alpha_zero=request["is_alpha_zero"]
alpha_vec=to_vector_from_json(request["alpha_vec"],false)
if is_alpha_zero
    alpha_vec=zeros(length(follower_vars))
end
#point
point=_to_dict_point(request,leader_vars,follower_vars)
println("Generando problema ...")

tt=typeof(leader_vars)

opt_problem=Fix_Restrictions(leader_obj,leader_restrictions,follower_obj,follower_restrictions,point,leader_vars,follower_vars,alpha_vec,is_alpha_zero)
println("Problema generado")

BF_vector=Make_BF(opt_problem,leader_vars,follower_vars,alpha_vec)
println("Vector BF generador")
return serialize_Experiment(opt_problem,alpha_vec,BF_vector,leader_vars,follower_vars,file_name,is_alpha_zero)

end

function handle_request(req::HTTP.Request)
    println("Método: ", req.method)
    println("URL: ", req.target)
    println("Encabezados: ", req.headers)
    body = String(req.body)
    println("Cuerpo: ", body)  # Imprime el cuerpo para depuración

    if req.target == "/hola" && req.method == "GET"
        response = Dict("message" => "¡Hola! Esta es la subdirección /hola")
        return HTTP.Response(200, JSON3.write(response))
    elseif req.method == "POST" && req.target == "/generate"
        println("Intentando leer el JSON...")
        try
            # Parsea el JSON solo para POST
            data = JSON3.read(body)
            println("Diccionario obtenido:")
            println(data)
            println("Contenido de 'objective_function':")
            println(data["objective_function"])
            println(typeof(data))
            xlsx_data, filename =solver_problem(data,"response/test__")
            println("Se va a devolver ok")
            HTTP.Response(
                200,
                [
                    "Content-Type" => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                    "Content-Disposition" => "attachment; filename=$filename"
                ],
                xlsx_data
            )
        catch e
            println("Error al analizar JSON: ", e)
            println("Stacktrace:")
            for frame in stacktrace(catch_backtrace())
                println(frame)
            end
            return HTTP.Response(400, "Error en el formato JSON")  # Respuesta clara para errores
        end
    else
        return HTTP.Response(404, "Ruta no encontrada")
    end
end

#server = HTTP.serve(handle_request, "127.0.0.1", 8080)
#println("Servidor activo en http://127.0.0.1:8080")




function parse_arguments()
    settings = ArgParseSettings(
        description = "Servidor HTTP en Julia",
        version = "1.0",
        add_help = true
    )

    @add_arg_table! settings begin
        "--ip", "-i"
            help = "Dirección IP para escuchar"
            default = "127.0.0.1"
        "--port", "-p"
            help = "Puerto para el servidor"
            arg_type = Int
            default = 8080
    end

    return parse_args(settings)
end

function main()
    args = parse_arguments()
    
    println("Iniciando servidor en:")
    println("IP:   $(args["ip"])")
    println("Puerto: $(args["port"])")
    
    server = HTTP.serve(handle_request, args["ip"], args["port"])
    println("\n✅ Servidor activo en http://$(args["ip"]):$(args["port"])")
    
    try
        wait(server)
    catch e
        e isa InterruptException || rethrow(e)
        println("\n🛑 Servidor detenido")
    end
end

main()