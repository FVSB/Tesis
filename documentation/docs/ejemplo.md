## Caso de Estudio: Generación de Punto Fuertemente Estacionario

### Problema de Referencia
$$
\begin{aligned}
&\min_{x_1,x_2} x_1^2y_1^2y_2 + x_2 \\
&\ \text{s.t.}\ x_1 + y_2 - y_1 \leq 9 \\
&\ \ \ \ \min_{y_1,y_2} x_2^2y_1^2y_2 + x_1 \\
&\ \ \ \ \text{s.t.}\ x_1^2y_1^2 + x_2 \leq 0
\end{aligned}
$$

**Componentes del problema:**
1. **Nivel Superior**  
   - Variables: $x_1, x_2$  
   - Objetivo: Minimizar $x_1^2 y_1^2 y_2 + x_2$  
   - Restricción: $x_1 + y_2 - y_1 \leq 9$
2. **Nivel Inferior**  
   - Variables: $y_1, y_2$  
   - Objetivo: Minimizar $x_2^2 y_1^2 y_2 + x_1$  
   - Restricción: $x_1^2 y_1^2 + x_2 \leq 0$

---

### Implementación en Julia
```julia
using ProblemGenerator
using Symbolics

# 1. Configuración inicial
model = GeneratorModel()

# 2. Declaración de variables con alcance jerárquico
@variables Upper(model) x_1 x_2  # Variables líder
@variables Lower(model) y_1 y_2  # Variables seguidor

# 3. Objetivo del líder (función no convexa)
SetObjectiveFunction(Upper(model), x_1^2 * y₁^2 * y_2 + x_2)

# 4. Restricción líder activa con μ=0.3
SetLeaderRestriction(model, x_1 + y_2 - y_1 ≤ 9, J_0_g, 0.3)

# 5. Objetivo del seguidor (acoplamiento cruzado)
SetObjectiveFunction(Lower(model), x_2^2 * y_1^2 * y_2 + x_1)

# 6. Restricción seguidor con parámetros para fuerte estacionariedad
SetFollowerRestriction(
    model,
    x_1^2 * y_1^2 + x_2 ≤ 0,
    J_Ne_L0_v,  # Tipo de restricción
    0.1,        # β > 0
    0.4,        # λ > 0 
    0           # γ = 0
)

# 7. Fijación del punto estacionario deseado
SetPoint(model, Dict(
    x_1 => 1.0,
    x_2 => 1.0,
    y_1 => 1.0,
    y_2 => 1.0
))

# 8. Generación del problema MPEC
problem = CreateProblem(model)
```

---

### Explicación Paso a Paso
1. **Inicialización del Modelo**: Creamos un modelo vacío con `GeneratorModel()`.
2. **Declaración de Variables**:
   - `x₁, x₂` como variables de decisión del líder.
   - `y₁, y₂` como variables del seguidor.
3. **Función Objetivo del Líder**: Se establece minimizar $x_1^2 y_1^2 y_2 + x_2$.
4. **Restricción del Líder**: 
   - Expresión: $x_1 + y_2 - y_1 \leq 9$.
   - Usa el tipo de restricción `J_0_g` con $\mu=0.3$.
5. **Función Objetivo del Seguidor**: Minimizar $x_2^2 y_1^2 y_2 + x_1$.
6. **Restricción del Seguidor**:
   - Expresión: $x_1^2 y_1^2 + x_2 \leq 0$.
   - Parámetros: $\beta=0.1$, $\lambda=0.4$, $\gamma=0$.
7. **Punto Inicial**: Todas las variables se inicializan en $1.0$.
8. **Generación Final**: Crea la estructura completa del problema binivel.

---

## Flujo de Trabajo Recomendado
1. Definir estructura básica del problema binivel.
2. Especificar punto estacionario objetivo.
3. Seleccionar tipo de estacionariedad requerida.
4. Asignar multiplicadores según clasificación deseada.
5. Generar y validar problema MPEC resultante.
6. Exportar para análisis con solvers externos.

---

Esta documentación permanece estable ante cambios en la estructura de la tesis al enfocarse en conceptos matemáticos fundamentales en lugar de referencias específicas a secciones.

---

