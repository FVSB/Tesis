---
theme: gaia
_class: lead
paginate: true
backgroundColor: #fff
marp: true
backgroundImage: url('https://marp.app/assets/hero-background.jpg')
---

# Título de la Presentación

Autor: Franciso Vicente Suárez Bellón


---

# Qué es la optimización binivel?
La optimización binivel es un problema de optimización donde un subconjunto de variables está restringido a ser la solución óptima de otro problema de optimización, el cual está parametrizado por las variables restantes. El problema de optimización externo se conoce como problema de nivel superior o del líder, mientras que el problema interno es el problema de nivel inferior o del seguidor

--- 
La optimización binivel, en su forma abstracta, busca **minimizar una función objetivo de nivel superior,** `F(x, y)`, donde `x` son las variables de decisión del líder y `y` son las variables del seguidor. Esta minimización está sujeta a dos tipos de restricciones :
 
 *   **Restricciones explícitas** para el líder: `x ∈ X`, donde `X` es el conjunto de valores factibles para las variables del líder .
*   **Restricciones implícitas** impuestas por el seguidor: `y` debe pertenecer al conjunto de soluciones óptimas del problema de optimización del seguidor `argmin{f(x, y) : y ∈ Y(x)}`.

    Aquí, `f(x, y)` es la función objetivo del nivel inferior, y `Y(x)` representa las restricciones del nivel inferior, que pueden depender de la variable de decisión del líder, `x` . 
--- 
En otras palabras, el problema se centra en que el **líder (nivel superior)**  debe tomar decisiones (`x`) que optimicen su objetivo `F(x, y)`, anticipando que **el seguidor (nivel inferior)** responderá de manera óptima con respecto a su propio objetivo `f(x,y)`, dado el valor de `x` elegido por el líder . Esta interacción jerárquica entre los dos niveles hace que la optimización binivel sea más compleja que la optimización de un solo nivel.

--- 
 
 **Puntos clave:**
 
 *   El problema del nivel inferior **actúa como una restricción para el problema del nivel superior** .
 *   La solución del nivel inferior depende del valor de las variables del nivel superior, creando una **interdependencia** entre los dos niveles .
 *   El líder debe **anticipar la respuesta óptima del seguidor** al tomar sus decisiones .
 
    	Un problema de optimización binivel tiene dos niveles de   	decisión: un líder y un seguidor. El líder toma decisiones    	primero, y el seguidor reacciona a esas decisiones de forma    	óptima .
 ---

### Formulación General

$$
\begin{align*}
\text{minimizar} & \quad F(x, y) \\
\text{sujeto a} & \quad G(x, y) \leq 0 \quad (\text{restricciones de desigualdad}) \\
& \quad H(x, y) = 0 \quad (\text{restricciones de igualdad}) \\
& \quad y \in S(x) = \arg \min_{y} \{ f(x, y) \mid g(x, y) \leq 0, h(x, y) = 0 \}
\end{align*}
$$

---
### Elementos Clave: 
1. **Funciones Objetivo**:
   - $F(x, y)$: función objetivo del líder que se busca minimizar.
   - $f(x, y)$: función objetivo del seguidor que también se busca minimizar.
2. **Restricciones**:
   - $G(x, y) \leq 0$: conjunto de restricciones de desigualdad que deben cumplirse tanto para el líder como para el seguidor.
   - $H(x, y) = 0$: conjunto de restricciones de igualdad que también deben ser satisfechas.
---
3. **Conjunto de Soluciones del Seguidor**:
   - $S(x)$: representa el conjunto de soluciones óptimas del nivel inferior (seguidor), dado el valor de las decisiones del líder (x). Aquí, el seguidor minimiza su función objetivo bajo las restricciones impuestas.

   

Para incluir las referencias en la presentación Marp, las añadiré en una diapositiva final dedicada exclusivamente a citarlas. Aquí tienes el contenido actualizado:

---

# Aplicaciones de la Optimización Binivel

---

## En el Mercado Eléctrico

La optimización binivel se utiliza ampliamente para modelar y analizar mercados eléctricos debido a su capacidad para capturar la interacción estratégica entre diferentes agentes económicos. Algunos ejemplos destacados incluyen:

- **Equilibrio de Nash en mercados de electricidad de pago por oferta**  
  Según *Aussel et al. (2017)*, se analiza cómo un productor ajusta su estrategia considerando las acciones de sus competidores. Este estudio aplica conceptos de **equilibrio de Nash** y técnicas de mejor respuesta para optimizar la participación de un productor en el mercado.
<!-- Continuacion de mercado eléctrico -->
--- 
- **Mercados desregulados con pérdidas térmicas y límites de producción**  
  *Aussel et al. (2016)* investigan mercados de electricidad desregulados, incorporando restricciones de producción y pérdidas térmicas. Este enfoque permite modelar la eficiencia del mercado en escenarios más realistas, utilizando herramientas como **modelado de mercados y análisis de condiciones de optimalidad**.

- **Mercados spot de electricidad con pérdidas de transmisión**  
  En el trabajo de *Aussel et al. (2013)*, se introducen las pérdidas de transmisión en los modelos de mercado. Este enfoque mejora la representación del sistema eléctrico y su equilibrio estratégico mediante **optimización de mercado**.
<!-- Empezar Machine Learning -->
---

## En Machine Learning

La optimización binivel también tiene aplicaciones fundamentales en la selección de hiperparámetros en aprendizaje automático, como lo demuestra el trabajo de *Dempe y Zemkoho (2020)*:

- **Ajuste de hiperparámetros**  
  El capítulo 6 del libro aborda la optimización de hiperparámetros en problemas de clasificación y regresión. Se presentan algoritmos innovadores para manejar funciones objetivo no suaves y no convexas.  
<!-- Continuación de ML -->
---
  **Razón de uso:** La optimización binivel permite minimizar errores en modelos complejos, mejorando la precisión general del aprendizaje automático.  
  **Técnicas:** Se implementan algoritmos especializados para problemas no convexos.

---

## En Parques Ecoindustriales

La optimización binivel es una herramienta clave en el diseño y operación de redes industriales sostenibles. Ejemplos notables incluyen:

- **Redes de agua industrial**  
  En los estudios de *Ramos et al. (2016a, 2016b)*, se optimizan redes de agua industrial mediante juegos de múltiples líderes-seguidores, priorizando objetivos ambientales y económicos.  
  **Resultados:** Las empresas participantes lograron beneficios significativos en escenarios con formulaciones KKT.
<!-- Continuacion EPI -->
---
- **Redes de intercambio de calor**  
  *Ramos et al. (2018)* introducen el concepto de autoridad ambiental en el diseño de redes de servicios públicos, utilizando juegos de múltiples líderes-seguidores y reformulaciones KKT.

- **Despacho energético bajo restricciones de carbono**  
  *Gu et al. (2020)* modela incentivos de precios de energía en un parque industrial. Los resultados muestran que un enfoque binivel puede simultáneamente mejorar el impacto ambiental y los beneficios económicos.  
  **Técnicas:** Procedimiento iterativo primal-dual.
---
Aquí está el texto revisado con las referencias integradas directamente en el párrafo:  

---
## Los biniveles son díficles: 

Dado que los problemas de optimización binivel son inherentemente difíciles de resolver debido a su naturaleza **NP-hard** o incluso **ΣP2-hard** (Dempe y Zemkoho, 2020; Cerulli, 2016), se han desarrollado diversos enfoques para abordar su complejidad computacional. Entre los métodos exactos más utilizados se encuentran las reformulaciones basadas en las condiciones KKT (Karush-Kuhn-Tucker), que permiten transformar el problema binivel en un problema mononivel resoluble mediante técnicas tradicionales de programación matemática. Sin embargo, estos enfoques suelen ser computacionalmente intensivos para problemas de gran escala (Cerulli, 2016).  
<!-- Coninuacion binivel dificil -->
---

En paralelo, los algoritmos metaheurísticos, como los evolutivos, han ganado relevancia al proporcionar aproximaciones eficientes en casos no lineales o no convexos, donde las soluciones exactas son inalcanzables en tiempos razonables (Sinha et al., 2017). Otro enfoque destacado es el uso de métodos basados en descomposición, los cuales dividen el problema en subproblemas más manejables que pueden resolverse iterativamente (Floudas y Pardalos, 1990). Además, los avances recientes han explorado el uso de técnicas probabilísticas, como las aproximaciones de máxima entropía, para problemas con incertidumbre en parámetros clave. Estas técnicas son particularmente útiles en aplicaciones prácticas, como los mercados de energía o los modelos de sostenibilidad (Siddiqui y Gabriel, 2013).  

---

A pesar de estos avances, existen desafíos abiertos. La escalabilidad sigue siendo un problema crítico, ya que el crecimiento exponencial de las opciones posibles en problemas de gran tamaño limita la aplicabilidad de los métodos exactos (Dempe y Zemkoho, 2020). Asimismo, los problemas no convexos carecen de garantías de convergencia hacia el óptimo global, lo que los hace especialmente difíciles de abordar. Finalmente, la incorporación de incertidumbre en los modelos agrega una capa adicional de complejidad, lo que demanda nuevos enfoques híbridos que combinen algoritmos exactos y heurísticos para mejorar la eficiencia computacional sin sacrificar la calidad de las soluciones (Cerulli, 2016; Sinha et al., 2017).  

---

Estos avances y desafíos reflejan la importancia de diseñar algoritmos personalizados que aprovechen las estructuras particulares de cada problema binivel. Las aplicaciones industriales, como el diseño de redes ecoindustriales o la gestión de mercados energéticos, destacan la necesidad de enfoques que equilibren precisión y tiempo de cálculo, haciendo de la optimización binivel un área de investigación activa y con un impacto significativo en la práctica.  




---

## Referencias

1. D. Aussel, P. Bendotti, M. Pištěk (2017). *Nash equilibrium in a pay-as-bid electricity market: Part 2—best response of a producer*. Optimization 66, 1027–1053.  
2. D. Aussel, M. Červinka, M. Marechal (2016). *Deregulated electricity markets with thermal losses and production bounds: models and optimality conditions*. RAIRO Oper. Res. 50(1), 19–38.  
3. D. Aussel, R. Correa, M. Marechal (2013). *Electricity spot market with transmission losses*. J. Ind. Manag. Optim. 9(2), 275–290.  
4. Stephan Dempe, Alain Zemkoho (2020). *Bilevel Optimization: Advances and Next Challenges*. Springer Optimization and Its Applications 161. Capítulo 6. 
<!-- Continuacion Referencias -->
---
5. M.A. Ramos, M. Boix, D. Aussel, L. Montastruc, S. Domenech (2016a, 2016b). *Water integration in eco-industrial parks using a multi-leader-follower approach*.  
6. M.A. Ramos, M. Rocafull, M. Boix, D. Aussel, L. Montastruc, S. Domenech (2018). *Utility network optimization in eco-industrial parks by a multi-leader follower game methodology*.  
7. H. Gu, Y. Li, J. Yu, C. Wu, T. Song, J. Xu (2020). *Bi-level optimal low-carbon economic dispatch for an industrial park with consideration of multi-energy price incentives*.  


1. Stephan Dempe, Alain Zemkoho (2020). *Bilevel Optimization: Advances and Next Challenges*. Springer Optimization and Its Applications 161. 

---

9. Martina Cerulli (2016). *Bilevel Optimization and Applications*. Tesis Doctoral, Universidad de Pisa.  
10. Ankur Sinha, Pekka Malo, Kalyanmoy Deb (2017). *A Review on Bilevel Optimization: From Classical to Evolutionary Approaches and Applications*. IEEE Transactions on Evolutionary Computation.  
11. Christodoulos Floudas, Panos Pardalos (1990). *A Collection of Test Problems for Constrained Global Optimization Algorithms*. Springer-Verlag.  
12. Siddiqui, A. S., Gabriel, S. A. (2013). *An SOS1-based approach for solving MPECs with a natural gas market application*. Networks and Spatial Economics, 13(2), 205-227.

---

