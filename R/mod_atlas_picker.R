# Atlas picker -----------------------------------------------------------

atlas_picker_ui <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(
      ns("atlas"),
      "Atlas",
      choices = atlas_choices(),
      selected = "ggseg.formats::dk",
      selectize = TRUE
    ),
    uiOutput(ns("info"))
  )
}

atlas_picker_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    selected <- reactive({
      req(input$atlas)
      input$atlas
    })

    output$info <- renderUI({
      meta <- atlas_meta(selected())
      tags$div(
        class = "atlas-info",
        tags$span(class = "badge-type", type_labels[[meta$type]]),
        tags$dl(
          tags$dt("Regions"), tags$dd(meta$n_regions),
          tags$dt("Labels"), tags$dd(meta$n_labels),
          tags$dt("Views"), tags$dd(gsub(",", ", ", meta$views)),
          tags$dt("3D"), tags$dd(if (meta$has_3d) "yes" else "not available")
        ),
        tags$a(
          href = atlas_pkgdown_url(meta$package),
          target = "_blank",
          rel = "noopener",
          bsicons::bs_icon("box-arrow-up-right"),
          sprintf(" %s", meta$package)
        )
      )
    })

    selected
  })
}
