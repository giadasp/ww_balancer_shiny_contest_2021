plot_var_trigger <- function(input, var_plot, data_plot,  ww_model, output){
  cat("\nplot_var_trigger")
  input_list <- reactiveValuesToList(input)
  toggle_inputs(input_list, F)
    cat("\nset plot var")
    var_plot$var <-
      input$plot_var
    output$plots <- renderPlot({
      create_plot(
        ww_model$data,
        input$village_ids,
        data_plot$roles,
        var_plot$var
      )
    })
    toggle_inputs(input_list, T)
  
}