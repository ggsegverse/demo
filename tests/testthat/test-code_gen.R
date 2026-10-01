describe("format_args()", {
  it("renders named and unnamed arguments", {
    expect_equal(format_args(list(a = "1", "x")), c("a = 1", "x"))
  })

  it("drops NULL arguments", {
    expect_equal(format_args(list(a = "1", b = NULL)), "a = 1")
  })

  it("returns nothing when every argument is NULL", {
    expect_equal(format_args(list(a = NULL)), character())
  })
})

describe("call_text()", {
  it("writes a one-line call", {
    expect_equal(call_text("f", list(x = "1", "y")), "f(x = 1, y)")
  })

  it("writes an empty call when there is nothing to pass", {
    expect_equal(call_text("f", list(x = NULL)), "f()")
  })
})

describe("call_lines()", {
  it("breaks a call over lines and commas all but the last argument", {
    expect_equal(
      call_lines("f", list(a = "1", b = "2")),
      c("f(", "  a = 1,", "  b = 2", ")")
    )
  })

  it("collapses to an empty call when there is nothing to pass", {
    expect_equal(call_lines("f", list(a = NULL)), "f()")
  })
})

describe("chr_vec()", {
  it("quotes a single string bare", {
    expect_equal(chr_vec("left"), '"left"')
  })

  it("wraps several strings in c()", {
    expect_equal(chr_vec(c("left", "right")), 'c("left", "right")')
  })
})

describe("join_layers()", {
  it("puts a trailing + on all but the last layer", {
    expect_equal(join_layers(list("a", "b", "c")), c("a +", "b +", "c"))
  })

  it("adds the + to the last line of a multi-line layer", {
    expect_equal(join_layers(list(c("a(", ")"), "b")), c("a(", ") +", "b"))
  })

  it("ignores empty layers", {
    expect_equal(join_layers(list("a", NULL, "b")), c("a +", "b"))
  })
})

describe("atlas_expr()", {
  it("calls an atlas package's atlas bare", {
    expect_equal(atlas_expr("ggsegGlasser::glasser"), "glasser()")
  })

  it("calls a re-exported core atlas bare", {
    expect_equal(atlas_expr("ggseg.formats::dk", "ggseg"), "dk()")
  })

  it("qualifies a core atlas the plotting package does not re-export", {
    expect_equal(
      atlas_expr("ggseg.formats::suit", "ggseg3d"),
      "ggseg.formats::suit()"
    )
  })
})

describe("atlas_libraries()", {
  it("attaches the plotting package and the atlas package", {
    expect_equal(
      atlas_libraries("ggsegGlasser::glasser", "ggseg"),
      c("library(ggseg)", "library(ggsegGlasser)")
    )
  })

  it("attaches only the plotting package for core atlases", {
    expect_equal(atlas_libraries("ggseg.formats::dk", "ggseg3d"),
                 "library(ggseg3d)")
  })
})

describe("code_2d()", {
  it("maps label and supplies the palette in atlas-colour mode", {
    code <- code_2d("ggseg.formats::dk", list(
      fill = "atlas", position = "position_brain(hemi ~ view)",
      hemi = NULL, theme = "theme_void", legend = FALSE
    ))
    expect_true(any(grepl("aes(fill = label)", code, fixed = TRUE)))
    expect_true(any(grepl("scale_fill_brain_manual", code, fixed = TRUE)))
    expect_false(any(grepl("set.seed", code, fixed = TRUE)))
  })

  it("builds an example data frame in value mode", {
    code <- code_2d("ggseg.formats::dk", list(
      fill = "data", seed = 7, scale = "scale_fill_viridis_c()",
      position = NULL, hemi = NULL, theme = "theme_brain", legend = TRUE
    ))
    expect_true(any(grepl("set.seed(7)", code, fixed = TRUE)))
    expect_true(any(grepl("ggplot(values)", code, fixed = TRUE)))
    expect_true(any(grepl("aes(fill = value)", code, fixed = TRUE)))
  })

  it("only asks for a subset of hemispheres when one was dropped", {
    opts <- list(fill = "atlas", position = NULL, theme = "theme_void",
                 legend = FALSE)
    expect_false(any(grepl("hemi =", code_2d("ggseg.formats::dk", opts))))
    opts$hemi <- "left"
    expect_true(any(grepl('hemi = "left"', code_2d("ggseg.formats::dk", opts),
                          fixed = TRUE)))
  })

  it("suppresses the legend only when asked", {
    opts <- list(fill = "atlas", position = NULL, hemi = NULL,
                 theme = "theme_void", legend = TRUE)
    expect_false(any(grepl("show.legend", code_2d("ggseg.formats::dk", opts))))
  })
})

describe("code_3d()", {
  it("pipes the camera onto the widget", {
    code <- code_3d("ggseg.formats::dk", list(
      surface = "inflated", hemisphere = NULL, tract_color = NULL,
      camera = "left lateral", background = NULL, legend = TRUE,
      glassbrain = FALSE
    ))
    expect_true(any(grepl('pan_camera("left lateral")', code, fixed = TRUE)))
    expect_false(any(grepl("set_background", code, fixed = TRUE)))
  })

  it("adds each optional step it is asked for", {
    code <- code_3d("ggseg.formats::dk", list(
      surface = "pial", hemisphere = "left", tract_color = NULL,
      camera = "right medial", background = "black", legend = FALSE,
      glassbrain = TRUE, glassbrain_hemi = "right", glassbrain_opacity = 0.3
    ))
    expect_true(any(grepl('surface = "pial"', code, fixed = TRUE)))
    expect_true(any(grepl('hemisphere = "left"', code, fixed = TRUE)))
    expect_true(any(grepl('set_background("black")', code, fixed = TRUE)))
    expect_true(any(grepl("set_legend(FALSE)", code, fixed = TRUE)))
    expect_true(any(grepl("add_glassbrain", code, fixed = TRUE)))
  })

  it("passes the tract colouring mode for tract atlases", {
    code <- code_3d("ggseg.formats::tracula", list(
      surface = NULL, hemisphere = NULL, tract_color = "orientation",
      camera = "left lateral", background = NULL, legend = TRUE,
      glassbrain = FALSE
    ))
    expect_true(any(grepl('tract_color = "orientation"', code, fixed = TRUE)))
  })
})

describe("run_code()", {
  it("builds a plot from the generated 2D snippet", {
    p <- run_code(code_2d("ggseg.formats::dk", list(
      fill = "atlas", position = "position_brain(hemi ~ view)",
      hemi = NULL, theme = "theme_void", legend = FALSE
    )))
    expect_s3_class(p, "ggplot")
    expect_no_error(ggplot_build(p))
  })

  it("builds a widget from the generated 3D snippet", {
    w <- run_code(code_3d("ggseg.formats::dk", list(
      surface = "inflated", hemisphere = "left", tract_color = NULL,
      camera = "left lateral", background = NULL, legend = TRUE,
      glassbrain = FALSE
    )))
    expect_s3_class(w, "htmlwidget")
  })

  it("drops library() calls so it does not reattach packages", {
    expect_equal(run_code(c("library(nonexistentpkg)", "1 + 1")), 2)
  })
})
