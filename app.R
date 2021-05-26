library(shiny)

if (!require(remotes)){
  install.packages("remotes")
}
if (!require(rcbc)){
  remotes::install_github("dirkschumacher/rcbc")
}
if (!require(dutchmasters)){
  remotes::install_github("EdwinTh/dutchmasters")
}

source("ui.R")
source("server.R")
# Run the application 

shinyApp(ui = ui, server = server)
