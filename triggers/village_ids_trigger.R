village_ids_trigger <- function(input, data_plot, var_plot, ww_model, output) {
  cat("\nvillage_ids_trigger")
  input_list <- reactiveValuesToList(input)
  toggle_inputs(input_list, F, "village_ids")
  
  village_ids <-
    input$village_ids
  if (length(village_ids) > 0) {
    cat("\nset village ids")
    roles <-
      lapply(village_ids, function(id) {
        y <- ww_model$villages[, as.integer(id)]
        return(y[!is.na(y)])
      })
    data_plot[["roles"]] <-
      roles
    output$plots <- renderPlot({
      create_plot(ww_model$data,
                  village_ids,
                  data_plot$roles,
                  var_plot$var)
    })
  
  output$villages_roles <-
    DT::renderDataTable({
      convert_list_of_roles_in_dt(data_plot$roles,
                                  village_ids,
                                  ww_model$n_players)
    },
    selection = 'none',
    editable = FALSE,
    rownames = FALSE,
    extensions = 'Buttons',
    options = list(
      paging = FALSE,
      fixedColumns = TRUE,
      autoWidth = TRUE,
      dom = 'Bfrtip',
      buttons = c('csv', 'excel')
    ),
    class = "display")
  }
  toggle_inputs(input_list, T)
  
}