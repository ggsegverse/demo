# Code generation --------------------------------------------------------
# The app renders its plots by evaluating the very code it shows the user,
# so the snippet in the "R code" panel can never drift from the figure.

#' Drop NULL arguments and render each as `name = value`, or bare when unnamed
format_args <- function(args) {
  args <- Filter(Negate(is.null), args)
  if (length(args) == 0) return(character())
  values <- unlist(args, use.names = FALSE)
  nms <- names(args)
  if (is.null(nms)) nms <- rep("", length(args))
  ifelse(nzchar(nms), paste0(nms, " = ", values), values)
}

#' Render a call as `fn(\n  arg = value,\n  ...\n)`, dropping NULL arguments
call_lines <- function(fn, args, indent = "  ") {
  named <- format_args(args)
  if (length(named) == 0) return(paste0(fn, "()"))
  c(
    paste0(fn, "("),
    paste0(indent, named, c(rep(",", length(named) - 1), "")),
    ")"
  )
}

#' Inline a call when it is short, otherwise break it over several lines
call_text <- function(fn, args) {
  named <- format_args(args)
  if (length(named) == 0) return(paste0(fn, "()"))
  paste0(fn, "(", paste(named, collapse = ", "), ")")
}

chr_vec <- function(x) {
  if (length(x) == 1) deparse(x) else paste0("c(", toString(deparse_each(x)), ")")
}

deparse_each <- function(x) vapply(x, deparse, character(1))

#' How to refer to an atlas: bare `dk()` when the plotting package exports it,
#' otherwise namespace-qualified.
atlas_expr <- function(id, via = c("ggseg", "ggseg3d")) {
  via <- match.arg(via)
  meta <- atlas_meta(id)
  reexported <- meta$package == "ggseg.formats" &&
    meta$object %in% getNamespaceExports(via)
  if (meta$package == "ggseg.formats" && !reexported) {
    paste0("ggseg.formats::", meta$object, "()")
  } else {
    paste0(meta$object, "()")
  }
}

atlas_libraries <- function(id, via = c("ggseg", "ggseg3d")) {
  via <- match.arg(via)
  meta <- atlas_meta(id)
  pkgs <- if (meta$package == "ggseg.formats") via else c(via, meta$package)
  paste0("library(", pkgs, ")")
}

#' Example data frame, one random value per region
example_data_lines <- function(id, seed) {
  atlas <- atlas_expr(id)
  n <- atlas_meta(id)$n_regions
  c(
    paste0("set.seed(", seed, ")"),
    "values <- data.frame(",
    paste0("  region = ggseg.formats::atlas_regions(", atlas, "),"),
    paste0("  value = stats::runif(", n, ")"),
    ")"
  )
}

#' Indent every line of a block
indent_lines <- function(x, n = 2) paste0(strrep(" ", n), x)

#' Concatenate ggplot2 layers, putting a trailing ` +` on all but the last
join_layers <- function(layers) {
  layers <- Filter(function(x) length(x) > 0, layers)
  last <- length(layers)
  joined <- lapply(seq_along(layers), function(i) {
    block <- layers[[i]]
    if (i < last) block[length(block)] <- paste0(block[length(block)], " +")
    block
  })
  unlist(joined, use.names = FALSE)
}

#' Full, runnable 2D snippet
#'
#' Two fill modes. `"atlas"` paints each region in the atlas's own colours,
#' which since ggseg 2.0 means mapping `label` and supplying the palette
#' explicitly. `"data"` maps a value column, the usual research use.
code_2d <- function(id, opts) {
  atlas <- atlas_expr(id, "ggseg")
  by_data <- identical(opts$fill, "data")

  geom_args <- c(
    list(if (by_data) "aes(fill = value)" else "aes(fill = label)"),
    list(
      atlas = atlas,
      position = opts$position,
      hemi = if (!is.null(opts$hemi)) chr_vec(opts$hemi),
      show.legend = if (!opts$legend) "FALSE"
    )
  )

  fill_scale <- if (by_data) {
    opts$scale
  } else {
    call_text(
      "scale_fill_brain_manual",
      list(paste0("ggseg.formats::atlas_plot_palette(", atlas, ")"))
    )
  }

  body <- join_layers(list(
    if (by_data) "ggplot(values)" else "ggplot()",
    indent_lines(call_lines("geom_brain", geom_args)),
    indent_lines(fill_scale),
    indent_lines(paste0(opts$theme, "()"))
  ))

  c(
    c(atlas_libraries(id, "ggseg"), "library(ggplot2)"),
    "",
    if (by_data) c(example_data_lines(id, opts$seed), ""),
    body
  )
}

#' Full, runnable 3D snippet
code_3d <- function(id, opts) {
  atlas <- atlas_expr(id, "ggseg3d")
  libs <- atlas_libraries(id, "ggseg3d")

  main <- call_lines("ggseg3d", Filter(Negate(is.null), list(
    atlas = atlas,
    surface = if (!is.null(opts$surface)) deparse(opts$surface),
    hemisphere = if (!is.null(opts$hemisphere)) chr_vec(opts$hemisphere),
    tract_color = if (!is.null(opts$tract_color)) deparse(opts$tract_color)
  )))

  pipes <- c(
    call_text("pan_camera", list(deparse(opts$camera))),
    if (!is.null(opts$background)) {
      call_text("set_background", list(deparse(opts$background)))
    },
    if (!opts$legend) call_text("set_legend", list("FALSE")),
    if (isTRUE(opts$glassbrain)) {
      call_text("add_glassbrain", list(
        deparse(opts$glassbrain_hemi),
        opacity = format(opts$glassbrain_opacity)
      ))
    }
  )

  main[length(main)] <- paste0(main[length(main)], " |>")
  pipes <- paste0("  ", pipes, c(rep(" |>", length(pipes) - 1), ""))

  c(libs, "", main, pipes)
}

#' Evaluate a generated snippet, skipping its `library()` lines (the packages
#' are already attached in the app process).
run_code <- function(lines) {
  code <- paste(lines[!grepl("^library\\(", lines)], collapse = "\n")
  eval(parse(text = code), envir = new.env(parent = globalenv()))
}
