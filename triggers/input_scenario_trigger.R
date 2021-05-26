input_scenario_trigger <- function(input, output, session){
  cat("\ninput_scenario_trigger")
  import::here(WWModelPairs, .from = "components/modules/WWModelPairs.R")
  
  file_name = ""
  if (input$inputScenario == "Wherewolf - 1 Moon") {
    file_name = "0_1_moon.csv"
  } else if (input$inputScenario == "Wherewolf - 2 Moons") {
    file_name = "1_2_moons.csv"
  }
  cat("\nremove_faction_constraints")
  for (fac in session$userData$ww_model$faction_constraints) {
    removeUI(selector = paste0(c("#", fac, "Constraints"),
                               collapse = ''))
  }
  cat("\nnew_ww_model")
  session$userData$ww_model <-
    WWModelPairs$new()
  session$userData$ww_model$set_data(
    read.csv(
      file_name,
      sep = ";",
      stringsAsFactors = FALSE,
      fileEncoding = "UTF-8-BOM"
    )
  )
  update_output(input, output, session)
}