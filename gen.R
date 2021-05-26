gen <- function(input, session) {
  cat("\ngen")
  ww_model <- session$userData$ww_model
  input_list <- reactiveValuesToList(input)
  toggle_inputs(input_list, F)
  old_constraints <- ww_model$constraints
  ww_model$set_constraints(input)
  if (any(
    c(
      !identical(ww_model$constraints, old_constraints),
      ww_model$n_players != input$nPlayers,
      ww_model$n_factions != input$nFactions
    )
  )) {
    ww_model$initialize_internal_model()
    ww_model$set_n_players(input$nPlayers)
    ww_model$set_n_factions(input$nFactions)
  }
  ww_model$generate_villages()
  
  if (ww_model$get_n_generated_solutions() > 0) {
    cat("\nvillages have been generated")
    updateSelectizeInput(session,
                         inputId = "village_ids",
                         choices = seq(1:length(ww_model$villages)))
    shinyjs::enable("plot_var")
    shinyjs::enable("village_ids")
    showNotification(
      paste0("Wow! ", ww_model$get_n_generated_solutions(), " new villages have been generated. Just select them in the Village Comparator to inspect their features."),
      duration = Inf,
      closeButton = TRUE,
      type = "message"
    )
  } else{
    cat("\nno new villages have been generated")
    showNotification(
      "No new villages can be generated. Check your constraints.",
      duration = Inf,
      closeButton = TRUE,
      type = "error"
    )
  }
  session$userData$ww_model <- ww_model
  if (length(ww_model$villages) == 0) {
    toggle_inputs(input_list, T, all_but_id=c("village_ids", "plot_var"))
  } else{
    toggle_inputs(input_list, T)
    #js$refocus("village_ids_row")
    
  }
  
}