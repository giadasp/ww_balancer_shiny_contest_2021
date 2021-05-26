source("tab_generator.R")
library(bslib)
library(thematic)
library(showtext) 
library(DT)
library(shinyjs)
jscode <- "
shinyjs.refocus = function(e_id) {
  console.log(\'refocus\');
  var input = document.getElementById(e_id);
  input.focus();
  console.log(input.children[0].children[1].children[1].children[0].className);
  input.children[0].children[1].children[1].children[0].className += \" focus input-active\";
}"

solar_theme <- bs_theme(
  bg = "#ffffff",
  fg = "#221c1c",
  primary = "#000000",
  version = "4",
  # primary = "#BC0A04",
  success = "#1D7874",
  # warning = "#F5E625",
  danger = "#BB8588",
  # base_font = font_google("Open Sans")
  base_font = font_google("Special Elite"),
  heading_font = font_google("Oswald")
)
thematic_shiny(font = "auto")

ui <- fluidPage(
  useShinyjs(),
  tabsetPanel(
    type= "pills",
    tab_generator,
    tabPanel(tabName = "roles_and_interactions",
             "Roles and Interactions",
             h5("Upload your own \";\" separated csv file with roles and interactions"),
             fileInput(
               "rolesFile",
               "",
               multiple = FALSE,
               accept = c("text/csv",
                          "text/comma-separated-values,text/plain",
                          ".csv")
             ),
             h5("Download data:"),
             DT::dataTableOutput('data2_table')
    ),
    tabPanel(tabName = "instructions",
             "Instructions",
             htmlOutput("renderedHelp")#, output_options= list(theme = solar_theme)))
             #htmlOutput(rmarkdown::render("help.Rmd", runtime = "shiny", output_options=list(theme = solar_theme)))
             )
  ),
  extendShinyjs(text = jscode, functions = "refocus"),
  theme = solar_theme
)

