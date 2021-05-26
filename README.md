---
title: "ww_balancer"
header-includes:
   - \usepackage{amsmath}
output: html_document
---

# WW_balancer

A Shiny app for generating balanced villages for deception games.

The roles used in the default dataset are taken from the original game
"Wherewolf" by Christian Zoli: <http://www.wherewolf.it/>.

The balancer can be adapted to any scenario in a deception game such as
Mafia, or Avalon.

Click Generate! to generate (likely) 10 new balanced villages.

In `R` run:

```
library(shiny)
runGitHub( "ww_balancer_shiny_contest_2021", "giadasp")
```

## Customizable settings:

### Village Generator tab

In this tab you can:

-   Upload a **custom `roles and interactions` data frame** by csv file,
use `;` as separator.
-   Select the **Number of players**.
-   Select the **Number of factions**. Select "0" if you do not want to impose this constraint.

    *Ex. I want a village with exactly 3 factions (e.g. wolfs, village, and city), so I select '3' in the select input field "Number of factions".*
-   Impose **Constraints** on the minimum or maximum number of players
per faction. A constraint can be added to the generator by selecting
the name of the faction you want to constrain, and clicking on
"add". 0 is the default and neutral value (not applied). Select or
write the name of the faction again and click "remove" to remove the
related constraints.

-   Click the **Generate 10 new villages!** button to generate 10 new villages
and wait for the model to be built and solved. If the options remains the same,
by clicking this button again, other 10 villages are generated without waiting for
the model to be built. The villages are generated in a non-strictly decreasing 
order of balancedness (e.g. village 1 can have the same balancing index of village 2).

-   Once the villages have been generated, select those you want to compare in the
**Village comparator** section.

-   The **plots** show the properties of the generated villages: the 
faction composition, the total weight per faction, and the aura and mystic
distributions. By looking at the weight plot it is possible to understand how 
a village is balanced or how strong a faction is. Thus, if the bars have all the 
same height, the factions have the same weights, i.e. the village is balanced.
While, the taller the bars, the stronger the factions are.
Thus, to create a challenging game, just select a village with the tallest bars.
On the other hand, for an easy game, select a village with the shortest bars.

-   In the **datatable** below the plots, the role composition of each selected village
is displayed. 

-   Just select one of the generated village and start mastering your game!


### Roles and Interactions tab

In this tab you can:

-   **Edit** the cells of the data frame directly in the Shiny app.
However, rows and columns cannot be added or removed.
Upload your customized dataset, instead.

-   Impose **mandatory roles** or **exclude roles** by putting a 1 in
the `mandatory` or `excluded` columns (these columns are required in
your custom data frame).

    *Ex: the role `pack leader` is mandatory so it has a 1 in the column
`mandatory`.*

-   Customize the **weights** of each role wrt to a `<faction>` by
editing the column with name `w_<faction>`. Positive weights means
positive effect of the role on the faction, negative otherwise. 0 is
neutral.

    *Ex: The `pack leader` has a positive weights wrt the faction
`wolfs` and negative wrt the faction `village`.*

-   Impose **enemy sets**, i.e. roles which cannot be selected together.
You can add how many enemy sets you like, these new columns must
have names starting by `enemy_set_`.

    *Ex: `innkeeper` and `bard` are extremely strong if chosen together,
so you can create a `innkeeper-bard` role with `n=2` (also the
column `n` is required in the custom data frame) and put weights
higher than the sum of the weights of innkeeper and bard separately.
These 3 roles (`innkeeper`, `bard` and `innkeeper-bard`) are all in
the `enemy_set_2` because you can only choose one of them.*

    *Ex: `psychic` and `seer` are both in the `enemy_set_1`.*
    
-   Impose **friend sets**, i.e. roles which interact in a peculiar way.
You can add how many friend sets you like, these new columns must
have names starting by `friend_set_`. The roles in a friend set either cannot be 
selected to be in the village or they can be in the village but the sum of their
values in the `friend_set_` column must be greater or equal than 1.

    *Ex: the `guard` and `other guard` must be selected only if criminals are in
    play. Thus, I put them in the friend set with the criminals. Guards have a 0.4
    value in the column `friend_set_1`, criminals, instead have a 0.1.
    This means that, either the model does not choose any criminal or guard to
    be put in the village, or to achieve a sum of the values `friend_set_1` higher
    or equal than 1, it will choose at least 2 guards (0.4+0.4=0.8) together with,
    at least, 2 criminals (0.1+0.1=0.2), so that the sum is equal to 1.it extremely strong if chosen together,
so you can create a `innkeeper-bard` role with `n=2` (also the
column `n` is required in the custom data frame) and put weights
higher than the sum of the weights of innkeeper and bard separately.
These 3 roles (`innkeeper`, `bard` and `innkeeper-bard`) are all in
the `enemy_set_2` because you can only choose one of them.*

    *Ex: `psychic` and `seer` are both in the `enemy_set_1`.*


-   **Download** the roles and interactions data frame by clicking on
the "csv" or "excel" buttons.

-   **Upload** a **custom `roles and interactions` dataframe** by csv file, use `;` as separator.

## Instructions tab

This tab contains the instructions to use the app (same as above) and the math used for the balancing internal model.