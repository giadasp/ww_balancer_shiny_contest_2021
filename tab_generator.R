#import::here(.from = shiny, tabPanel, mainPanel, fluidPage,  sidebarLayout, sidebarPanel, h5, hr, fluidRow, column, numericInput, selectInput, div, actionButton, textOutput, selectizeInput, plotOutput)
import::here(.from = DT, dataTableOutput)
tab_generator <- tabPanel(
  tabName = "village_generator",
  "Village Generator",
  class = "m-1",
  sidebarLayout(
    sidebarPanel(
      selectInput(
        "inputScenario",
        h5("Select a calibrated scenario:"),
        choices = c("Wherewolf - 1 Moon", "Wherewolf - 2 Moons"),
        selected = "Wherewolf - 1 Moon"
      ),
      hr(),
      fluidRow(id = 'numberplayers',
               column(
                 12,
                 numericInput(
                   "nPlayers",
                   h5("Number of players"),
                   value = 10,
                   min = 6,
                   max = 30
                 )
                 
               )),
      hr(),
      fluidRow(column(
        12,
        numericInput(
          "nFactions",
          h5("Number of factions"),
          value = 2,
          min = 0,
          max = Inf
        )
        
      )),
      hr(),
      fluidRow(id = 'customFaction',
               column(
                 12,
                 selectInput("customFactionName",
                             h5("Faction to constrain:"),
                             choices = c())
               )),
      
      fluidRow(id = "customFactionConstraintsButtons",
               class = "align-items-center",
               column(
                 width = 12,
                 div(
                   class = "btn-toolbar mx-auto text-center",
                   role = "toolbar",
                   div(
                     class = "btn-group mr-1",
                     role = "group",
                     actionButton("add", class = "btn btn-success", "Add")
                   ),
                   div(
                     class = "btn-group mr-1",
                     role = "group",
                     actionButton("rmv", class = "btn btn-danger",  "Remove")
                   )
                 )
               )),
      hr(),
      fluidRow(id = 'Generate',
               column(
                 12,
                 actionButton("gen", class = "btn btn-primary", "Generate 10 new villages!")
               )),
      hr(),
      fluidRow(id = 'obb',
               column(
                 12,
                 h5('Mandatory roles'),
                 textOutput("mandatory_print")
               )),
      hr(),
      fluidRow(id = 'esc',
               column(
                 12,
                 h5('Excluded roles'),
                 textOutput("excluded_print")
               ))
    ),
    mainPanel(
      fluidPage(
        fluidRow(h5("Village comparator"),  class = "text-center w-100"),
        fluidRow( id = "village_ids_row",
          selectizeInput(
            "village_ids",
            "Select villages to compare:",
            choices = c(),
            selected = NULL,
            multiple = TRUE,
            options = NULL
          )
        ),
        fluidRow(
          selectInput(
            "plot_var",
            "Select variable:",
            choices = list(
              `Faction` = "faction",
              `Weights` = "weights",
              `Aura` = "aura",
              `Mystic` = "mystic"
            ),
            selected = "faction"
          )
        ),
        fluidRow(plotOutput("plots")),
        fluidRow(dataTableOutput("villages_roles"))
        )
    )
  )
)