
# **ProblemGenerator**

`ProblemGenerator` es un módulo de Julia diseñado para facilitar la creación y manipulación de problemas de optimización binivel. Este módulo proporciona herramientas para generar estructuras jerárquicas de optimización, definir funciones objetivo y restricciones, y configurar puntos estacionarios específicos.

## **¿Qué es un problema binivel?**
Un problema binivel es un tipo de problema de optimización jerárquica que involucra dos niveles de toma de decisiones:

- **Nivel superior (líder)**: Toma decisiones que influyen en el nivel inferior.
- **Nivel inferior (seguidor)**: Responde a las decisiones del líder, optimizando sus propios objetivos.

Estos problemas son comunes en campos como economía, ingeniería y ciencias de la decisión, donde las interacciones entre diferentes actores deben modelarse matemáticamente.

## **Características principales de ProblemGenerator**
- **Transformación MPEC**: Convierte problemas binivel en programas matemáticos con restricciones de complementariedad (MPEC) que sean estacionarios en el punto dado.
    - **Clasificación de puntos estacionarios**:
      - **Fuertemente estacionario**:   Multiplicadores estrictamente positivos.
      - **M-estacionario**: Multiplicadores no  negativos con condiciones de     complementariedad.
      - **C-estacionario**: Relación    multiplicativa no negativa entre parámetros.
- **Interfaz intuitiva**: Define variables, funciones objetivo y restricciones de manera sencilla utilizando la sintaxis de Julia y Symbolics.jl.
- **Personalización avanzada**: Control total sobre los parámetros de regularización, perturbación y multiplicadores duales.

## **Primeros pasos**

### Instalación
Para instalar `ProblemGenerator`, asegúrate de tener Julia instalado y ejecuta el siguiente comando en tu entorno:

```julia
using Pkg
Pkg.add("ProblemGenerator")
```

### Ejemplo básico
Aquí tienes un ejemplo rápido para crear un problema binivel simple:

```julia
using ProblemGenerator
using Symbolics

# 1. Crear un modelo base
model = GeneratorModel()

# 2. Declarar variables
@variables Upper(model) x₁ x₂  # Variables del líder
@variables Lower(model) y₁ y₂  # Variables del seguidor

# 3. Configurar función objetivo del líder
SetObjectiveFunction(Upper(model), x₁^2 * y₁^2 * y₂ + x₂)

# 4. Añadir restricción del líder
SetLeaderRestriction(model, x₁ + y₂ - y₁ ≤ 9, J_0_g, 0.3)

# 5. Configurar función objetivo del seguidor
SetObjectiveFunction(Lower(model), x₂^2 * y₁^2 * y₂ + x₁)

# 6. Añadir restricción del seguidor
SetFollowerRestriction(
    model,
    x₁^2 * y₁^2 + x₂ ≤ 0,
    J_Ne_L0_v,  # Tipo de restricción
    0.1,        # β > 0
    0.4,        # λ > 0 
    0           # γ = 0
)

# 7. Establecer punto inicial
SetPoint(model, Dict(
    x₁ => 1.0,
    x₂ => 1.0,
    y₁ => 1.0,
    y₂ => 1.0
))

# 8. Generar el problema final
problem = CreateProblem(model)
```

## **Documentación completa**
Para obtener más detalles sobre las funciones y características del módulo, consulta las siguientes secciones:
- [Fundamentos teóricos](fundamentos.md): Conceptos matemáticos detrás de los problemas binivel.
- [Especificación técnica de funciones](funciones.md): Descripción detallada de las funciones principales.
- [Ejemplo completo](ejemplo.md): Un caso práctico paso a paso.

## **Contribuciones**
¡Contribuciones son bienvenidas! Si deseas colaborar o reportar problemas, visita el repositorio oficial de `ProblemGenerator` en GitHub.

[Enlace al repositorio](https://github.com/FVSB/Tesis)
