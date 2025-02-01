

# Módulo Generador de Problemas Binivel

## Fundamentos Teóricos
Este módulo implementa un generador de problemas binivel con puntos estacionarios específicos, basado en los siguientes conceptos fundamentales:

1. **Transformación MPEC**: Conversión de problemas binivel en programas matemáticos con restricciones de complementariedad.
2. **Clasificación de puntos estacionarios**:
   - **Fuertemente estacionario**: Multiplicadores estrictamente positivos.
   - **M-estacionario**: Multiplicadores no negativos con condiciones de complementariedad.
   - **C-estacionario**: Relación multiplicativa no negativa entre parámetros.
3. **Condiciones KKT**: Manejo de multiplicadores para restricciones activas/inactivas.

Estos conceptos permiten generar problemas binivel con propiedades específicas, facilitando su análisis y resolución mediante solvers externos.

---

## Especificación Técnica de Funciones

### 1. `GeneratorModel`
```julia
function GeneratorModel(alpha::Vector{Number} = [])
```
Inicializa un modelo binivel con parámetros de regularización.

**Descripción:**
- Construye una estructura de optimización jerárquica.
- Prepara almacenamiento para restricciones y multiplicadores.
- Si `alpha != []`, activa modo de perturbación para condiciones degeneradas.

**Uso típico:**
```julia
model = GeneratorModel()
```

---

### 2. `SetObjectiveFunction`
```julia
function SetObjectiveFunction(problem::Problem, expr::Symbolics.Num)
```
Define funciones objetivo para líder/seguidor manteniendo trazabilidad de variables.

**Relación con teoría:**
- Preserva la estructura no lineal original para análisis de convexidad.
- Permite verificación automática de dominios factibles.

**Parámetros:**
- `problem::Problem`: Problema (`Upper(model)` o `Lower(model)`).
- `expr::Symbolics.Num`: Expresión simbólica de la función objetivo.

---

### 3. `SetLeaderRestriction`
```julia
function SetLeaderRestriction(
    model::OptimizationModel,
    expr::Symbolics.Num,
    restriction_type::RestrictionSetType,
    miu::Number
)
```
Gestiona restricciones del nivel superior con multiplicadores asociados.

**Tipos de restricción:**

| **`RestrictionSetType`** | **Condición**                     | **Uso típico**                          |
|---------------------------|-----------------------------------|-----------------------------------------|
| `J_0_g`                   | Restricción activa ($g_i = 0$)    | Puntos fuertemente estacionarios        |
| `Normal`                  | Restricción inactiva              | Regiones factibles generales            |

**Parámetros:**
- `model::OptimizationModel`: Modelo a modificar.
- `expr::Symbolics.Num`: Expresión de la restricción.
- `restriction_set_type::RestrictionSetType`: Tipo de restricción.
- `miu::Number`: Parámetro de perturbación.

---

### 4. `SetFollowerRestriction`
```julia
function SetFollowerRestriction(
    model::OptimizationModel,
    expr::Symbolics.Num,
    restriction_type::RestrictionSetType,
    beta::Number,
    lambda::Number,
    gamma::Number = 0
)
```
Configura restricciones del seguidor con control de multiplicadores duales.

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

**Parámetros:**
- `model::OptimizationModel`: Modelo a modificar.
- `expr::Symbolics.Num`: Expresión de la restricción.
- `restriction_set_type::RestrictionSetType`: Tipo de restricción.
- `beta::Number`: Parámetro de regularización.
- `lambda::Number`: Parámetro dual.
- `gamma::Number`: Parámetro de perturbación (opcional).

---

### 5. `SetPoint`
```julia
function SetPoint(model::OptimizationModel, point::Dict)
```
Establece punto inicial para las variables.

**Parámetros:**
- `model::OptimizationModel`: Modelo a modificar.
- `point::Dict`: Diccionario con asignaciones variable-valor.

---

## Tipos de Restricciones (Implementación Interna)
```julia
@enum RestrictionSetType begin
    Normal     # Restricción no activa
    J_0_g      # Restricción líder en punto activo
    J_0_LP_v   # Restricción seguidor con multiplicador positivo
    J_0_L0_v   # Restricción seguidor activa con λ=0 
    J_Ne_L0_v  # Restricción seguidor inactiva con λ=0
end
```

**Relación con condiciones KKT:**
- `J_0_LP_v`: Corresponde a $\lambda_j > 0$ en condiciones de complementariedad.
- `J_Ne_L0_v`: Usado para perturbaciones que mantienen factibilidad.
- `J_0_g`: Fundamental para garantizar calificaciones de restricciones.

---

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
@variables Upper(model) x₁ x₂  # Variables líder
@variables Lower(model) y₁ y₂  # Variables seguidor

# 3. Objetivo del líder (función no convexa)
SetObjectiveFunction(Upper(model), x₁^2 * y₁^2 * y₂ + x₂)

# 4. Restricción líder activa con μ=0.3
SetLeaderRestriction(model, x₁ + y₂ - y₁ ≤ 9, J_0_g, 0.3)

# 5. Objetivo del seguidor (acoplamiento cruzado)
SetObjectiveFunction(Lower(model), x₂^2 * y₁^2 * y₂ + x₁)

# 6. Restricción seguidor con parámetros para fuerte estacionariedad
SetFollowerRestriction(
    model,
    x₁^2 * y₁^2 + x₂ ≤ 0,
    J_Ne_L0_v,  # Tipo de restricción
    0.1,        # β > 0
    0.4,        # λ > 0 
    0           # γ = 0
)

# 7. Fijación del punto estacionario deseado
SetPoint(model, Dict(
    x₁ => 1.0,
    x₂ => 1.0,
    y₁ => 1.0,
    y₂ => 1.0
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

