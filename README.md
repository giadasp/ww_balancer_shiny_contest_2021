# ww_balancer
Shiny app for balancing wherewolf villages.

The roles used in the default dataset are taken from the original game "Wherewolf" by Christian Zoli: http://www.wherewolf.it/.

The balancer can be adapted to any type of scenario in a deception game.

Click Generate! to generate a list of 10 balanced villages.

In R run:
```
library(shiny)
runGitHub( "ww_balancer", "giadasp")
``` 
or go to:
https://giadaspaccapanico.shinyapps.io/ww_balancer/

## Customizable settings:

### In the sidebar:
- Upload a **custom `roles and interactions` dataframe** by csv file, use `;` as separator.
- **Number of players**.
- **Minimum and maximum number of players per faction**: write the name of the faction you want to constrain, click on "add" to add the constraint set. 0 is the default and neutral value (not applied). Write the name of the faction again and click "remove" to remove the related constraints.
- **Balancing index**: from 0 to +Inf, close to 0 for full balancing. In case the solver cannot find feasible solutions you can increase this index. 

### In the "roles and interaction" dataframe you can:
- **Edit** the cells of the dataframe directly in the Shiny app (adding or removing columns and rows is not allowed, upload your file instead).

- **Download** the roles and interactions dataframe by clicking on the "csv" or "excel" buttons.

- Impose **mandatory roles** and **exclude** some by putting a 1 in the `obbligatorio` and `escluso` columns (these columns are required in your custom dataframe). <br/> 
*Ex: the role `capo branco` is mandatory so it has a 1 in the column `obbligatorio`.*

- Impose **enemy sets**, i.e. roles which cannot be selected together. <br/>
*Ex: `oste` and `bardo` are extremely strong if chosen together, so you can create a `oste-bardo` role with `n=2` (also the column `n` is required in the custom dataframe) and put weights higher than the sum of the weights of oste and bardo separately. These 3 roles (oste, bardo and oste-bardo) are all in the `enemy_set_2` because you can only choose one of them.* <br/> 
*Ex: `sensitiva` and `veggente` are both in the `enemy_set_1`. You can add how many enemy sets you like, these new columns must have names starting by `enemy_set_`.*

- Customize the **weights** of each role wrt to a `<faction>` by editing the column with name `w_<faction>`. Positive weights means positive effect of the role on the faction, negative otherwise. 0 is neutral. <br/> 
*Ex: The `capo branco` has a positive weights wrt the faction `lupi` and negative wrt the faction `villaggio`.*

