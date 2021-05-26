import::here(R6Class, .from = R6)
import::here(WWModel, .from = "WWModel.R")
import::here(WWModelPairsInternal, .from = "WWModelPairsInternal.R")

WWModelPairs <- R6Class(
  "WWModelPairs",
  portable = FALSE,
  class = FALSE,
  cloneable = FALSE,
  inherit = WWModel,
  private = list(
    internal_model = NULL,
    build_internal_model = function(){
      private$internal_model$build(self$data, self$n_players, self$n_factions, self$faction_constraints, self$constraints)
    },
    append_new_solutions = function(){
      private$int_solutions <- private$internal_model$int_solutions
    },
    append_villages = function(new_villages){
      if(length(self$villages)>0){
      villages <<- cbind(self$villages, new_villages)
      }else{
        villages <<- new_villages
      }
    }
  ),
  public = list(
    initialize = function() {
      cat("\ninitialize_WWModelPairs")
      private$internal_model <- WWModelPairsInternal$new()
      data <<- data.frame()
      n_players <<- 0
      n_factions <<- 2
      constraints <<- list()
      faction_constraints <<- c()
      villages <<- data.frame()
      factions <<- c()
      weights <<- c()
      invisible(self)
    },
    initialize_internal_model = function() {
      cat("\ninitialize_internal_model")
      private$internal_model <- WWModelPairsInternal$new()
      cat("\nempty_villages")
      villages <<- data.frame()
    },
    set_n_players = function(n_players_new){
      cat("\nset_n_players")
      n_players <<- n_players_new
    },
    set_n_factions = function(n_factions_new){
      cat("\nset_n_factions")
      n_factions <<- n_factions_new
    },
    set_data = function(data_new){
      cat("\nset_data")
      data <<- data_new
    },
    generate_villages = function() {
        cat("\ngenerate_villages")
      if(!private$internal_model$is_built()){
        private$internal_model$build(self$data, self$n_players, self$n_factions, self$faction_constraints, self$constraints)
      }else{
        private$internal_model$add_rows(10)
      }
        new_villages <- private$internal_model$generate_villages(10)
        if(self$get_n_generated_solutions()>0){
          private$append_villages(new_villages)
        }
    },
    set_constraints = function(input){
      for (fac in self$faction_constraints) {
        constraints[[fac]][["min"]] <<-
          input[[paste(c('min', fac), collapse = '')]]
        constraints[[fac]][["max"]] <<-
          input[[paste(c('max', fac), collapse = '')]]
      }
    },
    get_n_generated_solutions = function(){
      return(private$internal_model$get_n_generated_solutions())
    }
  )
)