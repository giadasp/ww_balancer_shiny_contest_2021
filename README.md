---
title: "ww_balancer"
header-includes:
   - \usepackage{amsmath}
output: html_document
---

Shiny app for balancing wherewolf villages.

The roles used in the default dataset are taken from the original game
"Wherewolf" by Christian Zoli: <http://www.wherewolf.it/>.

The balancer can be adapted to any scenario in a deception game such as
Mafia, or Avalon.

Click Generate! to generate (likely) 10 new balanced villages.

In R run:

```
library(shiny)
runGitHub( "ww_balancer_shiny_contest_2021", "giadasp")
```

## Customizable settings:

### In the sidebar:
- **Number of players**.
- **Minimum and maximum number of players per faction**: write the name of the faction you want to constrain, click on "add" to add the constraint set. 0 is the default and neutral value (not applied). Write the name of the faction again and click "remove" to remove the related constraints.
- **Balancing index**: from 0 to +Inf, close to 0 for full balancing. In case the solver cannot find feasible solutions you can increase this index. 

### In the "roles and interaction" dataframe you can:
- Upload a **custom `roles and interactions` dataframe** by csv file, use `;` as separator.

- **Edit** the cells of the dataframe directly in the Shiny app (adding or removing columns and rows is not allowed, upload your file instead).

\begin{alignat}{2}
\text{minimize} \quad & \max_{f, f' > f} \mathbb{I}_{\sum_{r \in S_f}{ x_r }>0 \bigwedge \sum_{r \in S_{f'}}{x_r >0} } | \sum_{r=1}^R{ x_r \left( w_{rf} - w_{rf'}\right) } | &\quad \text{(objective)}\\
\text{subject to} \quad & &\quad & \\
 &\sum_{r=1}^R{ x_r n_r } = n_P, &\quad & \quad \text{(number of players)} \\
 &\sum_{r=1}^R{ \mathbb{I}_{\sum_{r \in S_f}} x_r } = n_F, &\quad & \quad \text{(number of factions)} \\
 &\text{min}_f \leq \sum_{r \in S_f}{ x_r n_r } \leq \text{max}_f, &\quad \forall f & \quad \mbox{(faction constraints)}\\
 &\sum_{r \in E}{ x_r } \leq 1, &\quad \forall E & \quad \mbox{(enemy sets)}\\
 &\sum_{r=1}^R{ x_r m_r} = 1, &\quad  & \quad \mbox{(mandatory roles)}\\
 &\sum_{r=1}^R{ x_r e_r} = 0, &\quad  & \quad \mbox{(excluded roles)}\\
\nonumber
 & x_r \in \{0,1\} \ \forall r,  &\quad &\quad \mbox{(role decision variables)}
\end{alignat}

where:

-   $n_P$ is the number of players, $n_F$ is the number of factions, $R$ is the number of roles, and $F$ is
the number of available factions. Thus, $p=1,\ldots,n_P$, $r=1,\ldots,R$, and $f=1,\ldots,F$.\
-   $n_1, \ldots, n_R$ are the values in column `n` (number of roles in group $r$).
-   $S_f$ is the set of roles which has the faction $f$.\
-   $\text{min}_f$ ($\text{max}_f$) is the minimum (maximum) number of players in the village with faction $f$.\
-   $E \in \mathbb{E}$ are the enemy sets.\
-   $m_1,\ldots,m_R$ ($e_1,\ldots,e_R$) are the values in column `mandatory` (`excluded`).

The indicator functions in the objective impose that the weights of a faction $f$ must be active only if at least one role belonging to $S_f$ has been chosen to be in the village. The model has been linearized using common MILP linearization tricks.

