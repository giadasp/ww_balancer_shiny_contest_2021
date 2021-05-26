roles_file_trigger <- function(input, output, session){
  cat("\nroles_file_trigger")
  import::here(WWModelPairs, .from = "components/modules/WWModelPairs.R")
  roles_file <- input$rolesFile
  ext <-
    tools::file_ext(roles_file$datapath)
  req(roles_file)
  cat("\nnew file inserted")
  
  validate(need(ext == "csv", "Please upload a valid ';' separated csv file"))
    cat("\nremove_faction_constraints")
    for (fac in session$userData$ww_model$faction_constraints) {
      removeUI(selector = paste0(c("#", fac, "Constraints"),
                                 collapse = ''))
    }
    cat("\nnew_ww_model")
    ww_model <- WWModelPairs$new()
    
    ww_model$set_data(
      read.csv(
        roles_file$datapath,
        header = TRUE,
        sep = ";",
        stringsAsFactors = FALSE,
        fileEncoding = "UTF-8-BOM"
      )
    )
    ww_model$factions <-
      setdiff(unique(ww_model$data$faction), c(""))
    session$userData$ww_model <- ww_model
    update_output(input, output, session)
    
}