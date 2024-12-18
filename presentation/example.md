---
theme: gaia
_class: lead
paginate: true
backgroundColor: #fff
marp: true
backgroundImage: url('https://marp.app/assets/hero-background.jpg')
---

# Título de la Presentación

Autor: Franciso Vicente Suárez Bellón


---

# Qué es la optimización binivel?
La optimización binivel es un problema de optimización donde un subconjunto de variables está restringido a ser la solución óptima de otro problema de optimización, el cual está parametrizado por las variables restantes. El problema de optimización externo se conoce como problema de nivel superior o del líder, mientras que el problema interno es el problema de nivel inferior o del seguidor

---
# Aplicaciones de la optimización Binivel:
---

## En el Mercado Eléctrico

La optimización binivel se utiliza ampliamente para modelar y analizar mercados eléctricos debido a su capacidad para capturar la interacción estratégica entre diferentes agentes económicos. Algunos ejemplos destacados incluyen:

- **Nash equilibrium in a pay-as-bid electricity market: Part 2—best response of a producer. Optimization 66, 1027–1053 (2017)**.
- **Deregulated electricity markets with thermal losses and production bounds: models and optimality conditions. RAIRO Oper. Res. 50(1), 19–38 (2016)**.
<!-- Continuar mercado electrico -->
--- 
- **Electricity spot market with transmission losses. J. Ind. Manag. Optim. 9(2), 275–290 (2013)**.
- **Multi-leader disjoint-follower game: formulation as a bilevel optimization problem (2018). Preprint 2018-10, TU Bergakademie Freiberg, Fakultät für Mathematik und Informatik**.
-  **Some remarks about existence of equilibria, and the validity of the EPCC reformulation for multi-leader-follower games. J. Nonlinear Convex Anal. 19(7), 1141–1162 (2018)**.

 <!-- Empezar EPI -->
---

## En Parques Ecoindustriales

La optimización binivel es una herramienta clave en el diseño y operación de redes industriales sostenibles. Ejemplos notables incluyen:

- **Gang, J., Tu, Y., Lev, B., Xu, J., Shen, W., Yao, L. (2015). A multi-objective bi-level location planning problem for stone industrial parks**.
- **Ramos, M.A., Boix, M., Aussel, D., Montastruc, L., Domenech, S. (2016b). Water integration in eco-industrial parks using a multi-leader-follower approach**.
 <!-- Continuar EPI -->
---
- **Ramos, M.A., Boix, M., Aussel, D., Montastruc, L., Domenech, S. (2016a). Optimal design of water exchanges in eco-industrial parks through a game theory approach**.
- **Ramos, M.A., Rocafull, M., Boix, M., Aussel, D., Montastruc, L., Domenech, S. (2018). Utility network optimization in eco-industrial parks by a multi-leader follower game methodology**.
- **Gu, H., Li, Y., Yu, J., Wu, C., Song, T., Xu, J. (2020). Bi-level optimal low-carbon economic dispatch for an industrial park with consideration of multi-energy price incentives**.

<!-- Empezar Machine Learning -->
---

## En Machine Learning

La optimización binivel también tiene aplicaciones fundamentales en la selección de hiperparámetros en aprendizaje automático, como lo demuestra el trabajo de *Dempe y Zemkoho (2020)*:

- **(Springer Optimization and Its Applications 161) Stephan Dempe, Alain Zemkoho - Bilevel Optimization_ Advances and Next Challenges-Springer International Publishing_Springer (2020).pdf - Capítulo 6: Bilevel Optimization of Regularization Hyperparameters in Machine Learning**
.
---
## Los biniveles son díficles: 

Dado que los problemas de optimización binivel son inherentemente difíciles de resolver debido a su naturaleza - - - **NP-hard**:  **Stephan Dempe, Alain Zemkoho (2020). *Bilevel Optimization: Advances and Next Challenges*. Springer Optimization and Its Applications 161**. 
 <!-- Continuar los bilevels son dificiles-->
---

-  ΣP2-hard: **Martina Cerulli (2016). *Bilevel Optimization and Applications*. Tesis Doctoral, Universidad de Pisa**.  


- Algoritmos metaheurísticos, como los evolutivos, han ganado relevancia al proporcionar aproximaciones eficientes en casos no lineales o no convexos: **A Review on Bilevel Optimization: From Classical to Evolutionary Approaches and Applications**. 
- Dividir el problema en subproblemas más manejables que pueden resolverse iterativamente: **A Collection of Test Problems for Constrained Global Optimization Algorithms**. 
- Problemas escalabilidad: **Stephan Dempe, Alain Zemkoho (2020). *Bilevel Optimization: Advances and Next Challenges*. Springer Optimization and Its Applications 161**.







