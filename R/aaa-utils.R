# Named to sort first: Shiny sources R/ in alphabetical order, and the helpers
# here are used by the files that follow.

`%||%` <- function(x, y) if (is.null(x) || length(x) == 0) y else x

# Resolved once, when Shiny sources R/ with the app directory as the working
# directory. Everything that reads a file off disk goes through app_file(), so
# it keeps working under testthat, which runs with a different working
# directory.
app_root <- normalizePath(".", mustWork = TRUE)

app_file <- function(...) file.path(app_root, ...)
