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
  title = tags$span(
    class = "ggsegverse-title",
    tags$img(src = brand_logo("medium", "light"), alt = "ggsegverse"),
    "brain atlas demo"
  ),
  theme = ggsegverse_theme(),
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
    ),
    tags$div(
      class = "mode-switch d-flex align-items-center gap-2",
      input_dark_mode(id = "mode"),
      tags$span("Colour mode")
    )
  ),
  tags$head(tags$script(src = "app.js")),
  useBusyIndicators(),
  busyIndicatorOptions(spinner_type = "dots", spinner_delay = "0.1s"),
  navset_card_underline(
    id = "view",
    nav_panel("2D", view_2d_main_ui("plot2d")),
    nav_panel("3D", view_3d_main_ui("plot3d")),
    nav_panel("Regions", regions_main_ui("regions")),
    nav_panel("About", about_ui())
  ),
  ggsegverse_footer()
)

server <- function(input, output, session) {
  atlas_id <- atlas_picker_server("picker")
  dark_mode <- reactive(identical(input$mode, "dark"))

  view_2d_server("plot2d", atlas_id, dark_mode)
  view_3d_server("plot3d", atlas_id, dark_mode)
  regions_server("regions", atlas_id)

  observe({
    session$sendCustomMessage(
      "brand-logo",
      list(src = brand_logo("medium", if (dark_mode()) "dark" else "light"))
    )
  })
}

shinyApp(ui, server)
