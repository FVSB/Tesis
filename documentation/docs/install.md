# Instalar el módulo


Para instalar del modulo de julia es necesario instalar las siguientes dependencias:
```julia
using Pkg; 
Pkg.add("Symbolics"); 
Pkg.add("LinearAlgebra");

```

Desde el script a utilizar usar importa el siguiente codigo :

```julia
include("./def_problem/solver.jl")

```



