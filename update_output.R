update_output <- function(input, output, session) {
  cat("\nupdate_output")
  ww_model <- session$userData$ww_model
  ww_model$data[is.na(ww_model$data)] <- 0
  ww_model$factions <-
    setdiff(unique(ww_model$data$faction), c(""))
  
  cat("\nupdate_output - update_customFactionName")
  updateSelectInput(
    session,
    "customFactionName",
    choices = ww_model$factions,
    selected = ww_model$factions[1]
  )
  cat("\nupdate_output - update_nFactions")
  updateNumericInput(
    session,
    "nFactions",
    max = length(ww_model$factions),
    value = 2
  )
  cat("\nupdate_output - mandatory_print")
  output$mandatory_print <- renderPrint({
    cat(ww_model$data$role[ww_model$data$mandatory == 1], sep = ", ")
  })
  cat("\nupdate_output - excluded_print")
  output$excluded_print <- renderPrint({
    cat(ww_model$data$role[ww_model$data$excluded == 1], sep = ", ")
  })
  cat("\nupdate_output - render_data2_table")
  output$data2_table <- DT::renderDataTable({
    ww_model$data
  },
  selection = 'none',
  editable = TRUE,
  rownames = TRUE,
  extensions = 'Buttons',
  options = list(
    paging = FALSE,
    searching = TRUE,
    fixedColumns = TRUE,
    autoWidth = TRUE,
    ordering = TRUE,
    dom = 'Bfrtip',
    buttons = c('csv', 'excel')
  ),
  class = "display")
  session$userData$ww_model <- ww_model
  cat("\nupdate_output - end")
}
