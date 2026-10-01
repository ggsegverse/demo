# R/aaa-utils.R resolves the app root from the working directory at source
# time, so the app's files have to be sourced from the app directory -- in the
# same alphabetical order Shiny uses.
app_dir <- normalizePath(file.path(testthat::test_path(), "..", ".."))

withr::with_dir(app_dir, {
  suppressMessages({
    library(shiny)
    library(ggseg)
    library(ggseg3d)
    library(ggplot2)
    library(ggseg.formats)
  })

  for (f in sort(list.files("R", pattern = "[.]R$", full.names = TRUE))) {
    source(f, local = globalenv())
  }
})
