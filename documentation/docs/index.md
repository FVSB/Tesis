
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


## **Primeros pasos**

### Instalación
Para instalar `ProblemGenerator`, asegúrate de tener Julia instalado y ejecuta el siguiente comando en tu entorno:

```julia
using Pkg
Pkg.add("ProblemGenerator")
```



## **Documentación completa**
Para obtener más detalles sobre las funciones y características del módulo, consulta las siguientes secciones:
- [Fundamentos teóricos](fundamentos.md): Conceptos matemáticos detrás de los problemas binivel.
- [Especificación técnica de funciones](funciones.md): Descripción detallada de las funciones principales.
- [Ejemplo completo](ejemplo.md): Un caso práctico paso a paso.

## **Contribuciones**
¡Contribuciones son bienvenidas! Si deseas colaborar o reportar problemas, visita el repositorio oficial de `ProblemGenerator` en GitHub.

[Enlace al repositorio](https://github.com/FVSB/Tesis)
