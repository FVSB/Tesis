Definir en latex que es un mpec:
```latex
\documentclass{article}
\usepackage{amsmath}
\begin{document}

\section*{MPEC (Mathematical Programs with Equilibrium Constraints)}

Un problema de MPEC se puede formular de la siguiente manera:

\begin{align*}
\text{minimizar} \quad & f(x, y) \\
\text{sujeto a} \quad & g(x, y) \leq 0, \\
& h(x, y) = 0, \\
& y \in S(x),
\end{align*}

donde:
\begin{itemize}
  \item $x$ son las variables de decisión.
  \item $y$ son las variables de estado.
  \item $f(x, y)$ es la función objetivo.
  \item $g(x, y)$ y $h(x, y)$ son las funciones de restricciones.
  \item $S(x)$ es el conjunto de equilibrio que depende de $x$. Este conjunto generalmente se define a través de un problema de equilibrio, como un problema de complementariedad mixta (MCP) o un problema de programación lineal.
\end{itemize}

\section*{MPCC (Mathematical Programs with Complementarity Constraints)}

Un problema de MPCC se puede formular de la siguiente manera:

\begin{align*}
\text{minimizar} \quad & f(x) \\
\text{sujeto a} \quad & g(x) \leq 0, \\
& h(x) = 0, \\
& 0 \leq x_i \perp x_j \geq 0, \quad \forall (i,j) \in \mathcal{C},
\end{align*}

donde:
\begin{itemize}
  \item $x$ son las variables de decisión.
  \item $f(x)$ es la función objetivo.
  \item $g(x)$ y $h(x)$ son las funciones de restricciones.
  \item $0 \leq x_i \perp x_j \geq 0$ es una condición de complementariedad que indica que al menos uno de los dos términos en cada par $(i,j)$ en el conjunto de complementariedad $\mathcal{C}$ debe ser cero.
\end{itemize}

\end{document}

```