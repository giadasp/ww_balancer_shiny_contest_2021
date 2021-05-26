rmv_constraints_trigger <- function(input, output, session){
  cat("\nrmv_constraints_trigger")
  ww_model <- session$userData$ww_model
  if (!is.null(ww_model$constraints[[input$customFactionName]])) {
    ww_model$faction_constraints <-
      setdiff(ww_model$faction_constraints,
              input$customFactionName)
    ww_model$constraints[[input$customFactionName]] <-
      NULL
    removeUI(selector = paste0(
      c("#", input$customFactionName, "Constraints"),
      collapse = ''
    ))
  }
  ww_model$initialize_internal_model()
  session$userData$ww_model <- ww_model
  update_output(input, output, session)
}