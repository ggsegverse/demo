# Code panel -------------------------------------------------------------
# Shows the snippet that produced the figure above it, with a copy button.

code_panel_ui <- function(id, title = "The code behind this figure") {
  ns <- NS(id)
  card(
    class = "code-card",
    card_header(
      class = "d-flex justify-content-between align-items-center",
      title,
      actionButton(
        ns("copy"),
        "Copy",
        icon = bsicons::bs_icon("clipboard"),
        class = "btn-sm btn-outline-secondary"
      )
    ),
    uiOutput(ns("code"))
  )
}

code_panel_server <- function(id, code) {
  moduleServer(id, function(input, output, session) {
    output$code <- renderUI({
      tags$pre(
        class = "r-code",
        id = session$ns("code_text"),
        .noWS = "inside",
        tags$code(.noWS = "outside", paste(code(), collapse = "\n"))
      )
    })

    observeEvent(input$copy, {
      session$sendCustomMessage(
        "copy-code",
        list(id = session$ns("code_text"))
      )
    })
  })
}
