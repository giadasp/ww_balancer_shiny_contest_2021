add_constraints_trigger <- function(input, output, session){
  cat("\nadd_constraints_trigger)
  ww_model <- session$userData$ww_model
  if (input$customFactionName != "") {
    if (is.null(ww_model$constraints[[input$customFactionName]])) {
      
      ww_model$faction_constraints <-
        c(ww_model$faction_constraints,
          input$customFactionName)
      ww_model$constraints[[input$customFactionName]] <-
        list(min = 0, max = 0)
      insertUI(
        selector = "#customFactionConstraintsButtons",
        where = "afterEnd",
        ui = fluidRow(
          id = paste0(input$customFactionName, "Constraints"),
          column(
            12,
            div(
              class = "form-group shiny-input-container",
              div(class =  "m-1",
                  h4(
                    paste0("   ", input$customFactionName,
                           " constraints:")
                  )),
              fluidRow(column(
                6,
                numericInput(
                  paste0("min", input$customFactionName),
                  h5("Minimum"),
                  value = 0,
                  min = 0,
                  max = 30
                )
              ),
              column(
                6,
                numericInput(
                  paste0("max", input$customFactionName),
                  h5("Maximum"),
                  value = 0,
                  min = 0,
                  max = 30
                )
              ))
            )
          )
        ),
        hr(),
      )
    }
  }
  ww_model$initialize_internal_model()
  session$userData$ww_model <- ww_model
}