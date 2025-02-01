# Documentación de la API

La API de `ProblemGenerator` permite generar un archivo Excel a partir de la definición de un problema binivel. La API se comunica mediante peticiones HTTP y acepta un objeto JSON con la estructura necesaria para definir variables, funciones objetivo, restricciones y otros parámetros del problema. A continuación se detalla el uso de los endpoints y se dan ejemplos prácticos.

---

## Endpoints Disponibles

### 1. **GET `/test`**

- **Descripción:**  
  Este endpoint sirve para realizar una prueba rápida y verificar que la API se encuentra activa.  
- **Respuesta:**  
  Devuelve un objeto JSON con el siguiente formato:
  
  ```json
  {
      "message": "¡Hola! Esta es la subdirección /test"
  }
  ```
  
- **Ejemplo de uso con cURL:**

  ```bash
  curl -X GET http://<dominio_o_ip>/test
  ```

---

### 2. **POST `/problemgenerator`**

- **Descripción:**  
  Este endpoint procesa una petición POST que contiene la definición del problema en formato JSON. La API procesa la información, genera el problema MPEC y devuelve un archivo Excel con los datos resultantes.

- **Cuerpo de la Petición (JSON):**

  El JSON que se envía debe tener la siguiente estructura:

  ```json
  {
      "vars": {
          "leader": [],
          "follower": []
      },
      "objective_function": {
          "leader": "",
          "follower": ""
      },
      "restrictions": {
          "leader": [
              {
                  "expresion": "",
                  "restriction_type": "",
                  "active_index_type": "",
                  "miu": 0.4
              }
          ],
          "follower": [
              {
                  "expresion": "",
                  "restriction_type": "",
                  "active_index_type": "",
                  "lambda": 0.1,
                  "beta": 0.9,
                  "gamma": 0.4
              }
          ]
      },
      "is_alpha_zero": false,
      "alpha_vec": [2.3, 293],
      "point": {
          "x_1": 2.2
      }
  }
  ```

  **Descripción de los campos principales:**

  - **`vars`**:  
    - **`leader`**: Lista de variables de nivel superior (líder).  
    - **`follower`**: Lista de variables de nivel inferior (seguidor).

  - **`objective_function`**:  
    - **`leader`**: Expresión de la función objetivo del líder.  
    - **`follower`**: Expresión de la función objetivo del seguidor.

  - **`restrictions`**:  
    Contiene las restricciones tanto para el líder como para el seguidor.
    - **Para el líder**: Cada restricción es un objeto con los campos `expresion`, `restriction_type`, `active_index_type` y `miu`.
    - **Para el seguidor**: Cada restricción es un objeto con los campos `expresion`, `restriction_type`, `active_index_type`, `lambda`, `beta` y `gamma`.

  - **`is_alpha_zero`**:  
    Valor booleano que indica si el vector `alpha` es cero.

  - **`alpha_vec`**:  
    Vector de parámetros de regularización.

  - **`point`**:  
    Diccionario con la asignación inicial de valores a las variables.

- **Respuesta:**  
  La API procesa el JSON y, en caso de éxito, devuelve un archivo Excel que contiene la representación del problema MPEC generado. La respuesta HTTP incluye las cabeceras:

  - `Content-Type`: `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`
  - `Content-Disposition`: `attachment; filename=<nombre_del_archivo>`

- **Ejemplo de uso con cURL:**

  Supongamos que el JSON se encuentra en un archivo llamado `problem.json`:

  ```bash
  curl -X POST http://<dominio_o_ip>/ \
       -H "Content-Type: application/json" \
       -d @problem.json --output problem.xlsx
  ```

  Con esta petición, se envía el contenido del archivo `problem.json` a la API y se guarda la respuesta (el Excel) en `problem.xlsx`.

---

## Explicación del Funcionamiento Interno

El código del servidor en Julia sigue la siguiente lógica:

1. **Lectura y Registro:**  
   Se imprime por consola el método, la URL, los encabezados y el cuerpo de la petición para facilitar la depuración.

2. **Rutas y Métodos:**
   - **GET `/test`:**  
     Si la URL es `/test` y el método es `GET`, se devuelve un mensaje de bienvenida en formato JSON.
   - **POST:**  
     Para la petición POST si la url es `\problemgenerator`, se intenta leer y parsear el JSON recibido. Si la estructura es válida, se procede a generar el problema llamando a la función `solver_problem`, que procesa los datos y genera el archivo Excel.

3. **Manejo de Errores:**  
   Si se produce algún error al analizar el JSON, se devuelve una respuesta con el código 400 y un mensaje de error indicando que el formato del JSON es incorrecto.

---

## Buenas Prácticas

- **Validación del JSON:**  
  Asegúrate de que el JSON enviado cumpla exactamente con la estructura esperada para evitar errores en el parseo.

- **Uso de Content-Type:**  
  Al enviar peticiones POST, especifica el encabezado `Content-Type: application/json` para que el servidor sepa cómo interpretar el cuerpo de la petición.

- **Depuración:**  
  Durante el desarrollo, revisa los logs del servidor (por ejemplo, los `println`) para verificar que los datos se reciben correctamente.

- **Seguridad:**  
  Si la API se va a exponer en producción, considera agregar autenticación y validación adicional para proteger los endpoints.

- **Documentación:**  
  Mantén la documentación actualizada para reflejar cambios en la estructura del JSON o en el comportamiento de los endpoints.

---

## Otras Formas de Consumir la API

Además de utilizar `cURL`, puedes integrar la API en tus proyectos usando diferentes lenguajes. Por ejemplo, en **Python** puedes utilizar el módulo `requests`:

```python
import requests
import json

# Definición del JSON a enviar
data = {
    "vars": {
        "leader": [],
        "follower": []
    },
    "objective_function": {
        "leader": "",
        "follower": ""
    },
    "restrictions": {
        "leader": [{
            "expresion": "",
            "restriction_type": "",
            "active_index_type": "",
            "miu": 0.4
        }],
        "follower": [{
            "expresion": "",
            "restriction_type": "",
            "active_index_type": "",
            "lambda": 0.1,
            "beta": 0.9,
            "gamma": 0.4
        }]
    },
    "is_alpha_zero": False,
    "alpha_vec": [2.3, 293],
    "point": {
        "x_1": 2.2
    }
}

# Envío de la petición POST
url = "http://<dominio_o_ip>/"
headers = {"Content-Type": "application/json"}
response = requests.post(url, data=json.dumps(data), headers=headers)

if response.status_code == 200:
    # Guarda el archivo Excel recibido
    with open("problem.xlsx", "wb") as f:
        f.write(response.content)
    print("Archivo Excel descargado correctamente.")
else:
    print("Error:", response.text)
```

---

Esta documentación permite a los desarrolladores comprender cómo interactuar con la API de `ProblemGenerator` y generar el archivo Excel con la representación del problema MPEC definido.  
Recuerda reemplazar `<dominio_o_ip>` por la dirección correspondiente donde se encuentre desplegada la API.

¡Con esto ya estás listo para comenzar a integrar y utilizar la API en tus proyectos!


