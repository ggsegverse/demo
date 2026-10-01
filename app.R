library(shiny)
library(bslib)
library(bsicons)
library(DT)
library(ggplot2)
library(ggseg)
library(ggseg3d)
library(ggseg.formats)

# The atlas packages themselves are attached by R/atlas_packages.R, which
# Shiny sources along with the rest of R/ before this file runs.

ui <- page_sidebar(
  title = "The ggsegverse",
  theme = bs_theme(
    version = 5,
    preset = "shiny",
    base_font = font_google("Inter"),
    code_font = font_google("JetBrains Mono")
  ),
  sidebar = sidebar(
    width = 330,
    atlas_picker_ui("picker"),
    conditionalPanel(
      condition = "input.view == '2D'",
      view_2d_controls_ui("plot2d")
    ),
    conditionalPanel(
      condition = "input.view == '3D'",
      view_3d_controls_ui("plot3d")
    )
  ),
  tags$head(
    tags$script(src = "app.js"),
    tags$link(rel = "stylesheet", href = "app.css")
  ),
  useBusyIndicators(),
  busyIndicatorOptions(spinner_type = "dots", spinner_delay = "0.1s"),
  navset_card_underline(
    id = "view",
    nav_panel("2D", view_2d_main_ui("plot2d")),
    nav_panel("3D", view_3d_main_ui("plot3d")),
    nav_panel("Regions", regions_main_ui("regions")),
    nav_panel("About", about_ui())
  )
)

server <- function(input, output, session) {
  atlas_id <- atlas_picker_server("picker")

  view_2d_server("plot2d", atlas_id)
  view_3d_server("plot3d", atlas_id)
  regions_server("regions", atlas_id)
}

shinyApp(ui, server)
