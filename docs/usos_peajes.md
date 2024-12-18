## Comparación de Documentos sobre Optimización de Peajes Binivel

Aquí hay una tabla comparativa de cada documento que aborda el problema de optimización de peajes binivel:

| Nombre del Documento | Problema que Resuelven | Técnicas de Optimización Binivel | Resultados |
|---|---|---|---|
| 2010.Kalashnikov.Camacho.Askin.Kalashnikova.IJICIC.pdf | Asignación de peajes óptimos a los arcos de una red de transporte multi-producto. El objetivo del nivel superior (la empresa) es maximizar los ingresos por peajes. El objetivo del nivel inferior (los usuarios) es minimizar el costo de viaje. |  * **Método de función de penalización:** Transforma el problema binivel en un problema de programación matemática estándar mediante la penalización de las restricciones del nivel inferior.  * **Método cuasi-Newton:** Utiliza aproximaciones de gradiente para actualizar la dirección de búsqueda de peajes óptimos.  * **Algoritmo de ascenso más pronunciado:** Busca iterativamente la dirección que maximiza la función objetivo del líder.  * **Método directo de Nelder-Mead:** Un método de búsqueda directa que no requiere el cálculo de gradientes. |  * El método de penalización y el método cuasi-Newton son los más precisos para instancias pequeñas y medianas.  * El algoritmo cuasi-Newton es el más rápido para la mayoría de las instancias y tamaños.  * El algoritmo de Nelder-Mead es el peor en términos del número de operaciones computadas. |
| Tristan.pdf | Establecer peajes óptimos en una red de transporte considerando el equilibrio de tráfico del usuario. El objetivo del líder es maximizar los ingresos por peajes. El objetivo de los seguidores es minimizar sus costos de viaje. |  * **Caracterización analítica de la solución del nivel inferior:** Se utiliza para determinar cuándo el problema está bien planteado.  * **Algoritmo de sub-gradiente:** Converge globalmente a la solución, utilizando la información de la solución del nivel inferior. |  * **Convergencia global del algoritmo:** El algoritmo propuesto converge a la solución óptima global.  * **Eficiencia computacional:** El algoritmo reduce el tiempo de cálculo en comparación con los métodos heurísticos. |
| brotcorne2001.pdf | Determinar un conjunto de peajes óptimos en los arcos de una red de transporte multi-producto. El objetivo del líder (la empresa) es maximizar los ingresos por peajes, considerando que los usuarios viajan por las rutas más cortas en función del costo generalizado de viaje. |  * **Heurística primal-dual:** Extiende un método anterior al caso multi-producto, reformulando el problema como un programa bilineal de un solo nivel mediante el uso de una función de penalización.  * **Heurística secuencial de arco:** Ajusta los peajes de forma iterativa, considerando un arco a la vez. |  * **Robustez del esquema algorítmico:** Los algoritmos pueden resolver problemas de peajes de tamaños significativos con una precisión cercana a la óptima.  * **Eficiencia de la heurística primal-dual:** Se desempeña bien en la mayoría de los casos de prueba, proporcionando soluciones de alta calidad rápidamente. |
| marcotte2004.pdf | Reformulación del problema del viajante de comercio (TSP) como un problema de optimización de peajes (TOP). El TSP se reduce a un TOP con un solo producto y luego a un TOP con múltiples productos. |  * **Reducción del TSP a un TOP:** Se introduce un nodo ficticio y se definen costos de viaje y peajes específicos para modelar el TSP como un TOP.  * **Extensión multi-producto:** Se divide el recorrido en caminos simples contiguos, cada uno asociado con un producto. |  * **Calidad de las formulaciones:** Las relajaciones de programación lineal de las formulaciones TOP–TSP y 3-TOP–TSP proporcionan límites inferiores de buena calidad.  * **Influencia del número de productos:** El aumento del número de productos en la formulación multi-producto mejora la calidad del límite inferior. |
| migdalas1995.pdf | Revisión de modelos y métodos de programación binivel en la planificación del tráfico. Aborda problemas de diseño de red, configuración de señales y ajuste de la matriz de origen/destino, todos utilizando el problema de equilibrio de red como segundo nivel. | Se describen varias técnicas de solución:  * **Métodos exactos:** Reemplazo del nivel inferior con las condiciones de Karush-Kuhn-Tucker (KKT), reformulación a un programa d.c. de un solo nivel y el uso de desigualdades variationales en el segundo nivel.  * **Heurísticas basadas en la optimización de un solo nivel:** Métodos de re-declaración y métodos de simulación de equilibrio.  * **Aproximaciones bicriterio:** Reemplazo del problema binivel por un problema de optimización de un solo nivel con una combinación ponderada de las funciones objetivo.  * **Aproximaciones lineales binivel:** Simplificación del problema no lineal a un problema lineal binivel.  * **Métodos de búsqueda local:** Búsqueda directa, métodos de función de penalización y métodos de búsqueda de descenso. |  * **Complejidad computacional:** Los problemas de planificación del tráfico binivel son complejos y requieren un esfuerzo computacional considerable para resolverse de forma óptima.  * **Necesidad de un desarrollo algorítmico:** Se necesitan algoritmos más eficientes para resolver problemas de planificación del tráfico binivel de manera eficaz para redes del mundo real. |
| sinha2015.pdf | Optimización multiobjetivo de peajes en una red vial. Se considera una situación en la que el gobierno (nivel superior) busca minimizar las emisiones de contaminación y maximizar los ingresos, mientras que los usuarios (nivel inferior) buscan minimizar el costo y el tiempo de viaje. |  * **Algoritmo evolutivo multiobjetivo binivel basado en aproximaciones cuadráticas (m-BLEAQ):**  Maneja el problema de nivel superior utilizando un algoritmo evolutivo multiobjetivo y el problema de nivel inferior con un método de programación cuadrática secuencial (SQP). |  * **Eficiencia computacional:** El algoritmo m-BLEAQ converge rápidamente a la frontera de Pareto del nivel superior, con un número menor de evaluaciones de funciones de nivel inferior en comparación con un enfoque anidado.  * **Conflicto de objetivos:** Los resultados numéricos muestran la naturaleza conflictiva de los objetivos del nivel superior y la necesidad de considerar métodos multiobjetivo binivel para la toma de decisiones políticas. |
| wang2014.pdf | Propone un modelo de optimización multiobjetivo binivel para el desarrollo sostenible del sistema de transporte. El modelo considera tres objetivos (tiempo de viaje del sistema, emisiones totales de los vehículos e impactos negativos en la salud) en el nivel superior y dos objetivos (tiempo de viaje y costo del peaje) en el nivel inferior. |  * **Algoritmo evolutivo multiobjetivo (NSGA-II):** Maneja el problema del nivel superior.  * **Método cuasi-Newton:** Resuelve el problema de complementariedad no lineal (NCP) que representa el equilibrio de usuario del nivel inferior. |  * **Conflicto de objetivos:** Los resultados de un pequeño problema de prueba muestran el conflicto entre los objetivos del nivel superior, lo que demuestra la necesidad de métodos multiobjetivo binivel para la toma de decisiones políticas.  * **Necesidad de pruebas en redes realistas:** Se requiere trabajo futuro para resolver el modelo en redes de tamaño real. |
| yin2002.pdf | Revisión de la necesidad de modelar problemas de planificación y gestión de sistemas de transporte como modelos de optimización binivel multiobjetivo. |  * **Algoritmo genético binivel (GAB):** Codifica las variables de decisión del problema del nivel superior y calcula la aptitud de cada cadena resolviendo el problema del nivel inferior.  * **Algoritmo 0-K:** Evalúa la aptitud de cada solución generada por el algoritmo genético. |  * **Eficiencia del algoritmo:** El algoritmo propuesto es eficaz para buscar simultáneamente las soluciones óptimas de Pareto para los modelos binivel multiobjetivo.  * **Simplicidad del algoritmo:** El algoritmo es fácil de implementar y entender para los profesionales del transporte. |

