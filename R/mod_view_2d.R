# 2D view ----------------------------------------------------------------

cortical_layouts <- c(
  "Hemispheres as rows" = "hemi ~ view",
  "Views as rows" = "view ~ hemi",
  "All in one row" = ". ~ hemi + view",
  "All in one column" = "hemi + view ~ ."
)

slice_layouts <- c(
  "Horizontal" = "horizontal",
  "Vertical" = "vertical",
  "Grid" = "grid"
)

brain_themes <- c(
  "theme_void" = "theme_void",
  "theme_brain" = "theme_brain",
  "theme_brain2" = "theme_brain2",
  "theme_darkbrain" = "theme_darkbrain"
)

fill_scales <- c(
  "Viridis" = "scale_fill_viridis_c()",
  "Magma" = 'scale_fill_viridis_c(option = "magma")',
  "Cividis, reversed" = 'scale_fill_viridis_c(option = "cividis", direction = -1)',
  "Red-blue diverging" = 'scale_fill_distiller(palette = "RdBu")',
  "Grey" = 'scale_fill_gradient(low = "grey90", high = "grey20")'
)

view_2d_controls_ui <- function(id) {
  ns <- NS(id)
  tagList(
    radioButtons(
      ns("fill"),
      "Colour regions by",
      c("Atlas colours" = "atlas", "Example values" = "data"),
      inline = TRUE
    ),
    conditionalPanel(
      condition = "input.fill == 'data'",
      ns = ns,
      selectInput(ns("scale"), "Colour scale", fill_scales),
      sliderInput(ns("seed"), "Example data seed", 1, 100, 42, step = 1)
    ),
    uiOutput(ns("layout_controls")),
    selectInput(ns("theme"), "Theme", brain_themes),
    checkboxInput(ns("legend"), "Show legend", value = FALSE)
  )
}

view_2d_main_ui <- function(id) {
  ns <- NS(id)
  tagList(
    card(
      full_screen = TRUE,
      card_header(
        class = "d-flex justify-content-between align-items-center",
        "2D brain",
        downloadButton(ns("png"), "PNG", class = "btn-sm btn-outline-secondary")
      ),
      plotOutput(ns("plot"), height = "460px")
    ),
    code_panel_ui(ns("code"))
  )
}

view_2d_server <- function(id, atlas_id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    atlas_kind <- reactive(atlas_meta(atlas_id())$type)

    output$layout_controls <- renderUI({
      switch(
        atlas_kind(),
        cortical = tagList(
          selectInput(ns("layout"), "Layout", cortical_layouts),
          checkboxGroupInput(
            ns("hemi"), "Hemispheres",
            choices = atlas_hemis_for(atlas_id()),
            selected = atlas_hemis_for(atlas_id()),
            inline = TRUE
          )
        ),
        cerebellar = helpText(
          "Cerebellar atlases are drawn on the SUIT flatmap, which has a",
          "single fixed view."
        ),
        tagList(
          radioButtons(ns("layout"), "Layout", slice_layouts, inline = TRUE),
          conditionalPanel(
            condition = "input.layout == 'grid'",
            ns = ns,
            numericInput(ns("nrow"), "Rows", value = 2, min = 1, max = 6)
          ),
          selectInput(
            ns("views"), "Views",
            choices = atlas_views_for(atlas_id()),
            selected = atlas_views_for(atlas_id()),
            multiple = TRUE
          )
        )
      )
    })

    position_code <- reactive({
      switch(
        atlas_kind(),
        cerebellar = NULL,
        cortical = {
          layout <- input$layout %||% "hemi ~ view"
          paste0("position_brain(", layout, ")")
        },
        {
          layout <- input$layout %||% "horizontal"
          views <- input$views
          all_views <- atlas_views_for(atlas_id())
          args <- c(
            if (layout != "grid") deparse(layout),
            if (layout == "grid") paste0("nrow = ", input$nrow %||% 2),
            if (!is.null(views) && !setequal(views, all_views)) {
              paste0("views = ", chr_vec(views))
            }
          )
          call_text("position_brain", as.list(args))
        }
      )
    })

    hemi_code <- reactive({
      if (!identical(atlas_kind(), "cortical")) return(NULL)
      all_hemis <- atlas_hemis_for(atlas_id())
      if (is.null(input$hemi) || setequal(input$hemi, all_hemis)) NULL else input$hemi
    })

    code <- reactive({
      req(atlas_id())
      code_2d(atlas_id(), list(
        fill = input$fill %||% "atlas",
        scale = input$scale %||% fill_scales[[1]],
        seed = input$seed %||% 42,
        position = position_code(),
        hemi = hemi_code(),
        theme = input$theme %||% "theme_void",
        legend = isTRUE(input$legend)
      ))
    })

    plot_obj <- reactive(run_code(code()))

    output$plot <- renderPlot(plot_obj(), res = 96)

    output$png <- downloadHandler(
      filename = function() paste0(atlas_meta(atlas_id())$object, "-2d.png"),
      content = function(file) {
        ggplot2::ggsave(file, plot_obj(), width = 10, height = 5, dpi = 300)
      }
    )

    code_panel_server("code", code)
  })
}
