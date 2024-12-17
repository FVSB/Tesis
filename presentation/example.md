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

