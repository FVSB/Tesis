using JSON

json_string = """
{
    "vars":{
        "leader":[1],
        "follower":[1]
    },
    "objective_function":{
        "leader":"",
        "follower":""
    },
    "restrictions":{
        "leader":[{
           "expresion":"",
            "active_index_type":"",
            "miu":0.4
        }],
        "follower":[{
            "expresion":"",
            "active_index_type":"",
            "lambda":0.1,
            "beta":0.9,
            "gamma":0.4
        }]
    },
    "alpha_vec":[2.3,293]
}
"""

# Intentar parsear el JSON
try
    diccionario = JSON.parse(json_string)
    println("JSON parseado correctamente:")
    println(diccionario)
catch e
    println("Error al parsear JSON: ", e)
end
