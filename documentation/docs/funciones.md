

# Módulo Generador de Problemas Binivel



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

