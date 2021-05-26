init_ui <- function(input, output, session){
  cat("\ninit_ui")
  disable("village_ids")
  disable("plot_var")
  # solar_theme <- bs_theme(
  #   bg = "#FFFFFF",
  #   fg = "#221c1c",
  #   primary = "#727D71",
  #   version = "4",
  #   # bootswatch= "superhero",
  #   # version = "4",
  #   # bg = "#281313",
  #   # fg = "#EFEFEF",
  #   # primary = "#BC0A04",
  #   success = "#1D7874",
  #   # warning = "#F5E625",
  #   danger = "#BB8588",
  #   # base_font = font_google("Open Sans")
  #   #base_font = font_google("Special Elite"),
  #   heading_font = font_google("Oswald")
  # )

  # rmarkdown::render("help.Rmd",
  #                   output_file = "www/help.html",
  #                   output_options = list(theme = solar_theme, self_contained=TRUE))
  import::here(WWModelPairs, .from = "components/modules/WWModelPairs.R")
  
  output$renderedHelp <- renderUI({
    tags$iframe(
      seamless = "seamless",
      src = "help.html",
      width = "100%",
      height = "3000px",
      frameborder = "0",
      scrolling = "no"
    )
  })
  cat("\nnew_ww_model")
  ww_model <- WWModelPairs$new()

  ww_model$set_data(
    read.csv(
      "0_1_moon.csv",
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