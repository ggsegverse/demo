describe("ggsegverse_brand", {
  it("carries the shared palette", {
    expect_true(all(
      c("teal-dark", "teal-light", "plum", "mauve", "slate-900", "white") %in%
        names(ggsegverse_brand$color$palette)
    ))
  })
})

describe("brand_colour()", {
  it("resolves a role through the palette", {
    expect_equal(brand_colour("primary", "light"), "#29393e")
    expect_equal(brand_colour("primary", "dark"), "#a8c5cb")
  })

  it("flips foreground and background between modes", {
    expect_equal(
      brand_colour("background", "light"),
      brand_colour("foreground", "dark")
    )
  })

  it("falls back to a palette swatch when no role is named", {
    expect_false("warning" %in% setdiff(names(ggsegverse_brand$color), "palette"))
    expect_equal(brand_colour("warning"), "#e5a663")
  })

  it("errors on a colour the brand does not define", {
    expect_error(brand_colour("chartreuse"), "Cannot resolve brand colour")
  })
})

describe("brand_font()", {
  it("reads the typography roles", {
    expect_equal(brand_font("base"), "Source Serif 4")
    expect_equal(brand_font("headings"), "Montserrat")
    expect_equal(brand_font("monospace"), "Fira Code")
  })
})

describe("brand_font_spec()", {
  it("uses a google font when the brand says so", {
    spec <- brand_font_spec("headings")
    expect_s3_class(spec, "font_collection")
    expect_equal(spec$families, "Montserrat")
  })
})

describe("brand_sass_variables()", {
  it("exposes every palette swatch to the stylesheet", {
    vars <- brand_sass_variables()
    expect_true(all(paste0("ggseg-", c("teal-dark", "plum", "mauve")) %in%
                      names(vars)))
  })

  it("exposes the dark roles the colour-mode overrides need", {
    vars <- brand_sass_variables()
    expect_equal(vars[["ggseg-dark-background"]], "#1a2a2e")
    expect_equal(vars[["ggseg-dark-foreground"]], "#f2f0ef")
  })
})

describe("brand_logo()", {
  it("serves the dark-ink artwork on light backgrounds", {
    expect_equal(brand_logo("medium", "light"), "images/logo_light.png")
    expect_equal(brand_logo("medium", "dark"), "images/logo_dark.png")
  })

  it("still needs the inversion workaround", {
    # Fails once the brand file names its logo roles the right way round, which
    # is the signal to drop brand_logo_roles_inverted.
    expect_equal(ggsegverse_brand$logo$medium$light, "images/logo_dark.png")
  })

  it("points at files the app actually serves", {
    for (mode in c("light", "dark")) {
      for (size in c("small", "medium")) {
        expect_true(file.exists(app_file("www", brand_logo(size, mode))))
      }
    }
  })
})

describe("ggsegverse_theme()", {
  it("compiles the brand stylesheet", {
    theme <- ggsegverse_theme()
    expect_s3_class(theme, "bs_theme")
    expect_no_error(bslib::bs_theme_dependencies(theme))
  })
})

describe("ggsegverse_footer()", {
  it("links back to the ggsegverse", {
    html <- as.character(ggsegverse_footer())
    expect_match(html, ggsegverse_brand$meta$link, fixed = TRUE)
  })
})

describe("embedded mode", {
  it("is triggered by ?embed= in the query string", {
    js <- readLines(app_file("www/app.js"), warn = FALSE)
    expect_match(
      paste(js, collapse = "\n"),
      'URLSearchParams(window.location.search).has("embed")',
      fixed = TRUE
    )
  })

  it("hides the app's own title bar and footer", {
    css <- readLines(app_file("scss/ggsegverse.scss"), warn = FALSE)
    block <- paste(css, collapse = "\n")
    expect_match(block, "html.ggsegverse-embedded", fixed = TRUE)
    expect_match(block, ".ggsegverse-footer", fixed = TRUE)
  })
})
