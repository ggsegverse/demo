describe("atlas_picker_server()", {
  it("returns the selected atlas id", {
    testServer(atlas_picker_server, {
      session$setInputs(atlas = "ggseg.formats::aseg")
      expect_equal(session$returned(), "ggseg.formats::aseg")
    })
  })
})

describe("view_2d_server()", {
  it("builds a formula layout for cortical atlases", {
    testServer(
      view_2d_server,
      args = list(atlas_id = reactive("ggseg.formats::dk")),
      {
        session$setInputs(
          fill = "atlas", theme = "theme_void", legend = FALSE,
          layout = "view ~ hemi", hemi = c("left", "right")
        )
        expect_equal(position_code(), "position_brain(view ~ hemi)")
        expect_null(hemi_code())
      }
    )
  })

  it("passes hemi through only when a hemisphere was dropped", {
    testServer(
      view_2d_server,
      args = list(atlas_id = reactive("ggseg.formats::dk")),
      {
        session$setInputs(
          fill = "atlas", theme = "theme_void", legend = FALSE,
          layout = "hemi ~ view", hemi = "left"
        )
        expect_equal(hemi_code(), "left")
      }
    )
  })

  it("builds a slice layout for subcortical atlases", {
    testServer(
      view_2d_server,
      args = list(atlas_id = reactive("ggseg.formats::aseg")),
      {
        session$setInputs(
          fill = "atlas", theme = "theme_void", legend = FALSE,
          layout = "vertical", views = atlas_views_for("ggseg.formats::aseg")
        )
        expect_equal(position_code(), 'position_brain("vertical")')

        session$setInputs(layout = "grid", nrow = 3)
        expect_equal(position_code(), "position_brain(nrow = 3)")

        session$setInputs(views = c("axial_3", "sagittal"))
        expect_equal(
          position_code(),
          'position_brain(nrow = 3, views = c("axial_3", "sagittal"))'
        )
      }
    )
  })

  it("omits positioning for cerebellar flatmaps", {
    testServer(
      view_2d_server,
      args = list(atlas_id = reactive("ggseg.formats::suit")),
      {
        session$setInputs(fill = "atlas", theme = "theme_void", legend = FALSE)
        expect_null(position_code())
        expect_false(any(grepl("position_brain", code())))
      }
    )
  })
})

describe("view_3d_server()", {
  it("reports when an atlas has no 3D geometry", {
    testServer(
      view_3d_server,
      args = list(atlas_id = reactive("ggsegChen::chenAr")),
      {
        expect_false(available())
      }
    )
  })

  it("only offers a surface for cortical atlases", {
    testServer(
      view_3d_server,
      args = list(atlas_id = reactive("ggseg.formats::aseg")),
      {
        session$setInputs(camera = "left lateral", background = "white",
                          legend = TRUE)
        expect_false(any(grepl("surface", code())))
      }
    )
  })
})
