using Symbolics
@variables x y
z = x^2 + y

A = [x^2 + y 0 2x
     0       0 2y
     y^2 + x 0 0]

using Latexify
a=latexify(A)
println(a)