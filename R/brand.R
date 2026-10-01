# ggsegverse brand ------------------------------------------------------
# brand/ggsegverse-brand.yml is the ggsegverse brand definition, shared with
# the website and the pkgdown sites, and synced here by data-raw/sync_brand.R.
#
# It is written in the Quarto flavour of brand.yml, where a colour role can
# carry separate `light:` and `dark:` values. bslib's brand reader only accepts
# a single value per role, so this file resolves the roles itself and hands
# bslib the light theme, with the dark values emitted as Bootstrap colour-mode
# overrides.
#
# It is deliberately not named _brand.yml: bslib auto-discovers that filename
# in the app directory, in a brand/ subdirectory, and up to 20 parents above,
# then errors on the light/dark roles before this code gets a chance to run.

ggsegverse_brand <- yaml::read_yaml(app_file("brand/ggsegverse-brand.yml"))

#' Resolve a brand colour role to a hex value for one colour mode
#'
#' A role the brand does not name falls back to the palette swatch of the same
#' name, which is how `warning` resolves -- the brand lists the swatch but no
#' role for it, and the pkgdown sites use it as an accent all the same.
brand_colour <- function(role, mode = c("light", "dark"),
                         brand = ggsegverse_brand) {
  mode <- match.arg(mode)
  value <- brand$color[[role]] %||% role
  if (is.list(value)) value <- value[[mode]]
  resolved <- brand$color$palette[[value]] %||% value
  if (!grepl("^#", resolved)) {
    cli::cli_abort(c(
      "Cannot resolve brand colour {.val {role}}.",
      "i" = "{.file brand/ggsegverse-brand.yml} has no such role and no palette swatch named {.val {value}}."
    ))
  }
  resolved
}

#' Every palette entry, as hex
brand_palette <- function(brand = ggsegverse_brand) {
  unlist(brand$color$palette)
}

#' The font family for a typography role (base, headings, monospace)
brand_font <- function(role, brand = ggsegverse_brand) {
  family <- brand$typography[[role]]
  if (is.list(family)) family <- family$family
  family
}

#' Turn a brand font role into the bslib font object its source implies
brand_font_spec <- function(role, brand = ggsegverse_brand) {
  family <- brand_font(role, brand)
  sources <- vapply(
    brand$typography$fonts,
    function(f) if (identical(f$family, family)) f$source %||% "" else "",
    character(1)
  )
  source <- sources[nzchar(sources)][1]
  if (identical(unname(source), "google")) {
    bslib::font_google(family)
  } else {
    bslib::font_face(
      family = family,
      src = sprintf("url('fonts/%s.woff2') format('woff2')", family)
    )
  }
}

#' The Sass variables scss/ggsegverse.scss expects
brand_sass_variables <- function(brand = ggsegverse_brand) {
  palette <- brand_palette(brand)
  roles <- c("primary", "secondary", "tertiary", "foreground", "background")
  dark <- vapply(roles, brand_colour, character(1), mode = "dark",
                 brand = brand)
  c(
    stats::setNames(
      as.list(unname(palette)),
      paste0("ggseg-", gsub("[^a-z0-9]+", "-", names(palette)))
    ),
    stats::setNames(as.list(unname(dark)), paste0("ggseg-dark-", roles))
  )
}

#' The app theme: brand colours and fonts, plus the ggsegverse styling the
#' pkgdown sites use.
ggsegverse_theme <- function(brand = ggsegverse_brand) {
  theme <- bslib::bs_theme(
    version = 5,
    brand = FALSE,
    bg = brand_colour("background", "light", brand),
    fg = brand_colour("foreground", "light", brand),
    primary = brand_colour("primary", "light", brand),
    secondary = brand_colour("secondary", "light", brand),
    success = brand_colour("success", "light", brand),
    danger = brand_colour("danger", "light", brand),
    warning = brand_colour("warning", "light", brand),
    base_font = brand_font_spec("base", brand),
    heading_font = brand_font_spec("headings", brand),
    code_font = brand_font_spec("monospace", brand)
  )

  bslib::bs_add_rules(
    theme,
    c(
      sass::as_sass(brand_sass_variables(brand)),
      list(sass::sass_file(app_file("scss/ggsegverse.scss")))
    )
  )
}

# The brand file's logo roles are inverted: logo.medium.light points at
# logo_dark.png, which is the pale-ink artwork meant for dark backgrounds. The
# website does not hit this because its hero hardcodes the other pairing
# (ggsegverse.github.io/index.qmd). Set to FALSE once the brand file is fixed
# upstream; brand_logo_contrast_ok() is the test that will catch it.
brand_logo_roles_inverted <- TRUE

#' Path to a brand logo, as served from www/
#'
#' Keyed by the colour mode the logo is shown *on*: light mode wants the
#' dark-ink artwork.
brand_logo <- function(size = c("medium", "small"),
                       mode = c("light", "dark"),
                       brand = ggsegverse_brand) {
  size <- match.arg(size)
  mode <- match.arg(mode)
  if (brand_logo_roles_inverted) {
    mode <- if (mode == "light") "dark" else "light"
  }
  brand$logo[[size]][[mode]]
}

#' The ggsegverse footer the pkgdown sites carry
ggsegverse_footer <- function(brand = ggsegverse_brand) {
  tags$div(
    class = "ggsegverse-footer d-flex justify-content-between align-items-center flex-wrap gap-2",
    tags$span(
      tags$img(src = brand_logo("small", "dark", brand), alt = "ggsegverse"),
      " Part of the ",
      tags$a(href = brand$meta$link, target = "_blank", rel = "noopener",
             tags$strong(brand$meta$name)),
      " — Gross Geometry Brain Segmentation Universe"
    ),
    tags$span(
      tags$a(href = "https://github.com/ggsegverse", target = "_blank",
             rel = "noopener", "Source on GitHub")
    )
  )
}
