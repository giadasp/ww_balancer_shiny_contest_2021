server <-
  function(input, output, session) {
    import::here(.from = "helpers.R", create_plot, convert_list_of_roles_in_dt, plot_columns, plot_weights, toggle_inputs)
    import::here(.from = "gen.R", gen)
    import::here(.from = "update_output.R", update_output)
    import::here(.from = "init_ui.R", init_ui)
    import::here(.from = "triggers/village_ids_trigger.R", village_ids_trigger)
    import::here(.from = "triggers/plot_var_trigger.R", plot_var_trigger)
    import::here(.from = "triggers/add_constraints_trigger.R", add_constraints_trigger)
    import::here(.from = "triggers/rmv_constraints_trigger.R", rmv_constraints_trigger)
    import::here(.from = "triggers/roles_file_trigger.R", roles_file_trigger)
    import::here(.from = "triggers/input_scenario_trigger.R", input_scenario_trigger)
    import::here(WWModelPairs, .from = "components/modules/WWModelPairs.R")
    data_plot <-
      reactiveValues(roles = c())
    var_plot <-
      reactiveValues(var = "faction")

    init_ui(input, output, session)
    
    # session$onFlushed(function(){
    #   input_list <- reactiveValuesToList(input)
    #   toggle_inputs(input_list, F)
    #   toggle_inputs(input_list, T, all_but_id = c("village_ids","plot_var"))
    #   }
    # )
   
      
    #remove constraints
    observeEvent(input$rmv, {
      rmv_constraints_trigger(input, output, session)
    })
    
    #add session$userData$ww_model$constraints
    observeEvent(input$add, {
      add_constraints_trigger(input, output, session)
    })
    
    observeEvent(input$rolesFile, {
      roles_file_trigger(input, output, session)
    })
    
    observeEvent(input$inputScenario, {
      input_scenario_trigger(input, output, session)
    })
    
    # edit a single cell
    observeEvent(input$data2_table_cell_edit, {
      typevalue <-
        typeof(session$userData$ww_model$data[input$data2_table_cell_edit$row,
                                              input$data2_table_cell_edit$col])
      session$userData$ww_model$data[input$data2_table_cell_edit$row, input$data2_table_cell_edit$col] <-
        as(input$data2_table_cell_edit$value, typevalue)
      
      for (fac in session$userData$ww_model$faction_constraints) {
        removeUI(selector = paste0(c("#", fac, "Constraints"),
                                   collapse = ''))
      }
      session$userData$ww_model$initialize_internal_model()
      update_output(input, output, session)
      
    })
    
    # village generation by button reaction
    observeEvent(input$gen, {
      gen(input, session)
      data_plot <-
        reactiveValues(roles = c(""))
      var_plot <-
        reactiveValues(var = 0)
    })
    
    observeEvent(input$plot_var, {
      if(length(session$userData$ww_model$villages)>0){
      plot_var_trigger(input, var_plot, data_plot, session$userData$ww_model, output)
      }
    })
    
    observeEvent(input$village_ids, {
      if(length(session$userData$ww_model$villages)>0){
        
      village_ids_trigger(input, data_plot, var_plot, session$userData$ww_model, output)
      }
    })
    
  }
