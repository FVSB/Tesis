

| Nombre del Documento                                   | Enfoque Optimista                                                                                                                                                                                                                                                                                                                                                                       | Enfoque Pesimista                                                                                                                                                                                                                                                                                                                                                                                                                       |
| :----------------------------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Bilevel Optimization: Advances and Next Challenges** | El problema optimista de optimización binivel asume que el seguidor (nivel inferior) elegirá la solución que sea mejor para el líder (nivel superior) entre las múltiples soluciones óptimas del nivel inferior. Se le considera un enfoque más tratable. También se menciona que, en ciertas situaciones favorables, el problema optimista estándar puede convertirse en un programa convexo. | El problema pesimista de optimización binivel asume que el seguidor elegirá la solución que sea peor para el líder entre las múltiples soluciones óptimas del nivel inferior. Se considera más difícil de resolver, a menudo requiriendo reformulaciones o aproximaciones. Se indica que incluso puede no tener solución. |
| **A Review on Bilevel Optimization**                    | En el enfoque optimista, el líder espera que el seguidor escoja la solución que maximice su función objetivo. Este enfoque asume cooperación entre los dos niveles. Es más fácil de manejar que el enfoque pesimista.                                                                                                                                                   | El enfoque pesimista asume que el seguidor escogerá la solución que peor resulte para el líder. No asume ninguna forma de cooperación. Se menciona que este enfoque es menos tratable que el optimista, haciendo la resolución más compleja.                                                                                                                   |


**Puntos Clave:**

*   **Enfoque Optimista:**
    *   También se le llama enfoque *débil* o *semi-cooperativo*.
    *   El líder asume que el seguidor seleccionará la opción más favorable para el líder de entre las soluciones óptimas del problema del seguidor.
    *   Es considerado **más fácil de resolver**. En algunos casos, puede simplificarse a un problema convexo.
    *   En el contexto de múltiples objetivos, el enfoque optimista lleva al mejor frente de Pareto posible.

*   **Enfoque Pesimista:**
    *   También se le llama enfoque *fuerte*.
    *   El líder asume que el seguidor seleccionará la opción menos favorable para el líder de entre las soluciones óptimas del problema del seguidor.
    *   Es considerado **más complejo de resolver** y puede incluso no tener solución.
    *   A menudo requiere de reformulaciones para poder ser resuelto.
    *   En el contexto de múltiples objetivos, el enfoque pesimista lleva al peor frente de Pareto posible.

Es importante resaltar que, debido a su mayor tratabilidad, **la mayoría de la literatura sobre optimización binivel se centra en el enfoque optimista**, mientras que el enfoque pesimista, aunque útil para modelar situaciones de aversión al riesgo, plantea mayores desafíos teóricos y computacionales.

Además, se puede mencionar que en los documentos se usan los terminos "líder" y "seguidor" para denotar los que toman las decisiones en el problema de optimización. El líder toma decisiones teniendo en cuenta las posibles reacciones del seguidor. El seguidor reacciona a la decisión del líder eligiendo su mejor opción.
