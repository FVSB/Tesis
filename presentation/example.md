---
theme: gaia
_class: lead
paginate: true
backgroundColor: #fff
marp: true
backgroundImage: url('https://marp.app/assets/hero-background.jpg')
---

# Generador de problemas binivel para  probar funcionamiento de algoritmos




---

# Qué es la optimización binivel?
$$
\begin{align*}
\text{minimizar} & \quad F(x, y) \\
\text{sujeto a} & \quad G(x, y) \leq 0 \quad (\text{restricciones de desigualdad}) \\
& \quad H(x, y) = 0 \quad (\text{restricciones de igualdad}) \\
& \quad y \in S(x) = \arg \min_{y} \{ f(x, y) \mid g(x, y) \leq 0, h(x, y) = 0 \}
\end{align*}
$$

---
# Aplicaciones de la optimización Binivel:
---

## En el Mercados Eléctricos

- **Multi-leader disjoint-follower game: formulation as a bilevel optimization problem (2018)**.

-  **Some remarks about existence of equilibria, and the validity of the EPCC reformulation for multi-leader-follower games. J. Nonlinear Convex. 19(7), 1141–1162 (2018)**.

- **Nash equilibrium in a pay-as-bid electricity market: Part 2—best response of a producer. Optimization 66, 1027–1053 (2017)**.
.

 <!-- Empezar EPI -->
---

## En Parques Ecoindustriales



- **Ramos, M.A., Boix, M., Aussel, D., Montastruc, L., Domenech, S. (2016a). Optimal design of water exchanges in eco-industrial parks through a game theory approach**.
- **Ramos, M.A., Rocafull, M., Boix, M., Aussel, D., Montastruc, L., Domenech, S. (2018). Utility network optimization in eco-industrial parks by a multi-leader follower game methodology**.
- **Gu, H., Li, Y., Yu, J., Wu, C., Song, T., Xu, J. (2020). Bi-level optimal low-carbon economic dispatch for an industrial park with consideration of multi-energy price incentives**.

<!-- Empezar Machine Learning -->
---

## En Machine Learning



- **(Springer Optimization and Its Applications 161) Stephan Dempe, Alain Zemkoho - Bilevel Optimization_ Advances and Next Challenges-Springer International Publishing_Springer (2020).pdf - Capítulo 6: Bilevel Optimization of Regularization Hyperparameters in Machine Learning**.
---
## Los biniveles son díficles: 

Dado que los problemas de optimización binivel son inherentemente difíciles de resolver debido a su naturaleza. 
- NP-hard:  **Stephan Dempe, Alain Zemkoho (2020). *Bilevel Optimization: Advances and Next Challenges*. Springer Optimization and Its Applications 161**. 

-  ΣP2-hard: **Martina Cerulli (2016). *Bilevel Optimization and Applications*. Tesis Doctoral, Universidad de Pisa**. 
 <!-- Continuar los bilevels son dificiles-->
---

- Algoritmos metaheurísticos, como los evolutivos, han ganado relevancia al proporcionar aproximaciones eficientes en casos no lineales o no convexos: **A Review on Bilevel Optimization: From Classical to Evolutionary Approaches and Applications**. 
- Dividir el problema en subproblemas más manejables que pueden resolverse iterativamente: **A Collection of Test Problems for Constrained Global Optimization Algorithms**. 
- Problemas escalabilidad: **Stephan Dempe, Alain Zemkoho (2020). *Bilevel Optimization: Advances and Next Challenges*. Springer Optimization and Its Applications 161**.
<!-- Presentación del modelo -->
---

# Ejemplo básico

 $${min } F(x, y) = x^2 + (y - 10)^2$$

 $$st:$$
 $$-x+y<=0 $$
 $${min } f(x, y) =(x+2y-30)^2  $$

$$x+y<=20 $$
$$-y<=0$$
$$y<=20$$
<!-- Continuación Presentación del modelo -->
--- 



$$0<=x<=15$$
$$0<=y<=20$$
---
### Usando el módulo de BilvelJuMP
- Valor de la función del líder $99.9$
- $x=9.999$
- $y=9.999$

