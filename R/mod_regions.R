# Regions table ----------------------------------------------------------

regions_main_ui <- function(id) {
  ns <- NS(id)
  tagList(
    card(
      full_screen = TRUE,
      card_header(
        class = "d-flex justify-content-between align-items-center",
        "Regions",
        downloadButton(ns("csv"), "CSV", class = "btn-sm btn-outline-secondary")
      ),
      DT::DTOutput(ns("table"))
    ),
    code_panel_ui(ns("code"), "How to get this table yourself")
  )
}

regions_server <- function(id, atlas_id) {
  moduleServer(id, function(input, output, session) {
    regions <- reactive({
      atlas <- get_atlas(atlas_id())
      core <- as.data.frame(atlas$core)
      palette <- ggseg.formats::atlas_plot_palette(atlas)
      core$colour <- unname(palette[core$label])
      core[, c("hemi", "region", "label", "colour")]
    })

    output$table <- DT::renderDT(
      {
        df <- regions()
        df$colour <- swatch_html(df$colour)
        df
      },
      escape = FALSE,
      rownames = FALSE,
      options = list(pageLength = 15, scrollX = TRUE)
    )

    output$csv <- downloadHandler(
      filename = function() paste0(atlas_meta(atlas_id())$object, "-regions.csv"),
      content = function(file) utils::write.csv(regions(), file, row.names = FALSE)
    )

    code <- reactive({
      meta <- atlas_meta(atlas_id())
      atlas <- atlas_expr(atlas_id(), "ggseg")
      c(
        atlas_libraries(atlas_id(), "ggseg"),
        "",
        paste0("atlas <- ", atlas),
        "",
        "ggseg.formats::atlas_regions(atlas)",
        "ggseg.formats::atlas_labels(atlas)",
        "ggseg.formats::atlas_views(atlas)",
        "ggseg.formats::atlas_plot_palette(atlas)"
      )
    })

    code_panel_server("code", code)
  })
}

swatch_html <- function(colours) {
  shown <- ifelse(is.na(colours), "transparent", colours)
  sprintf(
    '<span class="swatch" style="background:%s"></span> %s',
    shown, ifelse(is.na(colours), "—", colours)
  )
}
