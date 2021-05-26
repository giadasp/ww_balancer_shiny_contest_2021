import::here(R6Class, .from = R6)
WWModel <- R6Class(
  "WWModel",
  portable = FALSE,
  class = TRUE,
  cloneable = FALSE,
  public = list(
    data = data.frame(),
    n_players = 0,
    n_factions = 2,
    constraints = list(),
    faction_constraints = list(),
    villages = data.frame(),
    factions = c(""),
    weights = c()
  )
)