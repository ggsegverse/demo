# 3D view ----------------------------------------------------------------

brain_surfaces <- c(
  "Inflated" = "inflated",
  "Semi-inflated" = "semi-inflated",
  "White matter" = "white",
  "Pial" = "pial"
)

camera_presets <- c(
  "left lateral", "left medial", "left superior", "left inferior",
  "left anterior", "left posterior",
  "right lateral", "right medial", "right superior", "right inferior",
  "right anterior", "right posterior"
)

brand_backgrounds <- function() {
  c(
    "White" = "white",
    "Brand light" = brand_colour("background", "light"),
    "Brand dark" = brand_colour("background", "dark"),
    "Black" = "black"
  )
}

view_3d_controls_ui <- function(id) {
  ns <- NS(id)
  tagList(
    uiOutput(ns("type_controls")),
    selectInput(ns("camera"), "Camera", camera_presets, selected = "left lateral"),
    selectInput(ns("background"), "Background", brand_backgrounds()),
    checkboxInput(ns("legend"), "Show legend", value = TRUE)
  )
}

view_3d_main_ui <- function(id) {
  ns <- NS(id)
  tagList(
    card(
      full_screen = TRUE,
      card_header("3D brain"),
      uiOutput(ns("widget_or_message"))
    ),
    code_panel_ui(ns("code"))
  )
}

view_3d_server <- function(id, atlas_id, dark_mode = reactive(FALSE)) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    observeEvent(dark_mode(), {
      updateSelectInput(
        session, "background",
        selected = brand_colour("background", if (dark_mode()) "dark" else "light")
      )
    })

    meta <- reactive(atlas_meta(atlas_id()))
    atlas_kind <- reactive(meta()$type)
    available <- reactive(isTRUE(meta()$has_3d))

    output$type_controls <- renderUI({
      if (!available()) return(NULL)
      switch(
        atlas_kind(),
        cortical = tagList(
          selectInput(ns("surface"), "Surface", brain_surfaces),
          checkboxGroupInput(
            ns("hemisphere"), "Hemispheres",
            choices = c("left", "right"), selected = c("left", "right"),
            inline = TRUE
          ),
          checkboxInput(ns("glassbrain"), "Add glass brain", value = FALSE),
          conditionalPanel(
            condition = "input.glassbrain",
            ns = ns,
            radioButtons(
              ns("glass_hemi"), "Glass brain hemisphere",
              c("left", "right"), selected = "right", inline = TRUE
            ),
            sliderInput(ns("opacity"), "Glass brain opacity", 0.05, 1, 0.3, 0.05)
          )
        ),
        tract = radioButtons(
          ns("tract_color"), "Tract colour",
          c("Atlas palette" = "palette", "Orientation (RGB)" = "orientation"),
          inline = TRUE
        ),
        NULL
      )
    })

    output$widget_or_message <- renderUI({
      if (available()) {
        ggseg3d::ggseg3dOutput(ns("brain"), height = "460px")
      } else {
        tags$p(
          class = "no-3d",
          sprintf(
            "%s has no 3D geometry — it ships 2D polygons only.",
            meta()$object
          )
        )
      }
    })

    code <- reactive({
      req(available())
      is_cortical <- identical(atlas_kind(), "cortical")
      hemis <- input$hemisphere
      code_3d(atlas_id(), list(
        surface = if (is_cortical) input$surface %||% "inflated",
        hemisphere = if (is_cortical && length(hemis) == 1) hemis,
        tract_color = if (identical(atlas_kind(), "tract")) input$tract_color,
        camera = input$camera %||% "left lateral",
        background = if (!identical(input$background, "white")) input$background,
        legend = isTRUE(input$legend),
        glassbrain = is_cortical && isTRUE(input$glassbrain),
        glassbrain_hemi = input$glass_hemi %||% "right",
        glassbrain_opacity = input$opacity %||% 0.3
      ))
    })

    output$brain <- ggseg3d::renderGgseg3d(run_code(code()))

    code_panel_server("code", code)
  })
}
