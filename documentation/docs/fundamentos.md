# Fundamentos Teóricos
Este módulo implementa un generador de problemas binivel con puntos estacionarios específicos, basado en los siguientes conceptos fundamentales:

1. **Transformación MPEC**: Conversión de problemas binivel en programas matemáticos con restricciones de complementariedad.
2. **Clasificación de puntos estacionarios**:
   - **Fuertemente estacionario**: Multiplicadores estrictamente positivos.
   - **M-estacionario**: Multiplicadores no negativos con condiciones de complementariedad.
   - **C-estacionario**: Relación multiplicativa no negativa entre parámetros.
3. **Condiciones KKT**: Manejo de multiplicadores para restricciones activas/inactivas.

Estos conceptos permiten generar problemas binivel con propiedades específicas, facilitando su análisis y resolución mediante solvers externos.

---

### Estrategias de Parametrización
Las siguientes condiciones definen los diferentes tipos de estacionariedad en función de los parámetros $\beta_i$ y $\gamma_i$:

$$
\begin{aligned}
&\textbf{C-estacionario:} && \beta_i \cdot \gamma_i \geq 0 \\
&\textbf{M-estacionario:} &&
\begin{cases}
\beta_i > 0, \gamma_i = 0 & \text{(multiplicador $\beta_i$ licbre, $\gamma_i$ fijo)} \\
\gamma_i > 0, \beta_i = 0 & \text{(multiplicador $\gamma_i$ libre, $\beta_i$ fijo)}
\end{cases} \\
&\textbf{Fuertemente estacionario:} && \beta_i > 0, \gamma_i > 0
\end{aligned}
$$