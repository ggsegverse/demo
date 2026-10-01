app_dir <- normalizePath(file.path(testthat::test_path(), "..", ".."))
withr::local_dir(app_dir, .local_envir = teardown_env())

suppressMessages({
  library(shiny)
  library(ggseg)
  library(ggseg3d)
  library(ggplot2)
  library(ggseg.formats)
})

for (f in list.files("R", pattern = "[.]R$", full.names = TRUE)) source(f)
