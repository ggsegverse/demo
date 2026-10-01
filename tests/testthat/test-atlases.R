# Renders every registered atlas from its generated snippet. Slow, so it is
# opt-in locally and always on in CI.
skip_unless_full_run <- function() {
  testthat::skip_if_not(
    nzchar(Sys.getenv("GGSEGDEMO_FULL_TESTS")),
    "set GGSEGDEMO_FULL_TESTS=1 to render every atlas"
  )
}

default_position <- function(id) {
  switch(
    atlas_meta(id)$type,
    cerebellar = NULL,
    cortical = "position_brain(hemi ~ view)",
    'position_brain("horizontal")'
  )
}

describe("every registered atlas", {
  it("renders in 2D from its generated snippet", {
    skip_unless_full_run()
    for (id in atlas_registry$id) {
      plot <- run_code(code_2d(id, list(
        fill = "atlas", position = default_position(id), hemi = NULL,
        theme = "theme_void", legend = FALSE
      )))
      expect_no_error(ggplot_build(plot))
    }
  })

  it("renders in 3D from its generated snippet when it has 3D geometry", {
    skip_unless_full_run()
    has_3d <- atlas_registry[atlas_registry$has_3d, ]
    for (i in seq_len(nrow(has_3d))) {
      id <- has_3d$id[i]
      widget <- run_code(code_3d(id, list(
        surface = if (has_3d$type[i] == "cortical") "inflated",
        hemisphere = NULL,
        tract_color = if (has_3d$type[i] == "tract") "palette",
        camera = "left lateral", background = NULL, legend = TRUE,
        glassbrain = FALSE
      )))
      expect_s3_class(widget, "htmlwidget")
    }
  })
})
