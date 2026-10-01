describe("atlas_registry", {
  it("has one row per atlas with the expected columns", {
    expect_true(nrow(atlas_registry) > 0)
    expect_named(
      atlas_registry,
      c("package", "object", "atlas", "type", "n_regions", "n_labels",
        "hemispheres", "views", "has_2d", "has_3d", "id", "label")
    )
  })

  it("gives every atlas a unique id", {
    expect_equal(anyDuplicated(atlas_registry$id), 0L)
  })

  it("only lists types the app knows how to label", {
    expect_true(all(atlas_registry$type %in% names(type_labels)))
  })

  it("only lists atlases with 2D geometry", {
    expect_true(all(atlas_registry$has_2d))
  })
})

describe("atlas_choices()", {
  it("groups atlases under their type label", {
    choices <- atlas_choices()
    expect_true(all(names(choices) %in% type_labels))
    expect_equal(length(unlist(choices)), nrow(atlas_registry))
  })

  it("drops types that no installed atlas uses", {
    one <- atlas_registry[atlas_registry$type == "tract", ]
    expect_equal(names(atlas_choices(one)), unname(type_labels[["tract"]]))
  })
})

describe("atlas_meta()", {
  it("looks an atlas up by id", {
    expect_equal(atlas_meta("ggseg.formats::dk")$object, "dk")
  })
})

describe("get_atlas()", {
  it("returns the atlas object the registry points at", {
    atlas <- get_atlas("ggseg.formats::dk")
    expect_true(is_ggseg_atlas(atlas))
    expect_equal(atlas_type(atlas), "cortical")
  })
})

describe("atlas_views_for()", {
  it("splits the stored view string", {
    expect_equal(atlas_views_for("ggsegCerebellum::buckner7"), "flatmap")
    expect_true(length(atlas_views_for("ggseg.formats::aseg")) > 1)
  })
})

describe("atlas_hemis_for()", {
  it("splits the stored hemisphere string", {
    expect_setequal(atlas_hemis_for("ggseg.formats::dk"), c("left", "right"))
  })
})
