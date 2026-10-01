# Pull the ggsegverse brand assets out of the website repo, which is where the
# brand is defined for the website, the pkgdown sites and this app. Re-run to
# pick up a brand change; everything it writes is committed so that a
# deployment never depends on the network.

brand_repo <- "https://raw.githubusercontent.com/ggsegverse/ggsegverse.github.io/main"

assets <- c(
  "_brand.yml" = "brand/ggsegverse-brand.yml",
  "fonts/Nelphim.woff2" = "www/fonts/Nelphim.woff2",
  "fonts/Nelphim.woff" = "www/fonts/Nelphim.woff",
  "images/logo_light.png" = "www/images/logo_light.png",
  "images/logo_dark.png" = "www/images/logo_dark.png",
  "images/submark_light.png" = "www/images/submark_light.png",
  "images/submark_dark.png" = "www/images/submark_dark.png"
)

for (i in seq_along(assets)) {
  remote <- file.path(brand_repo, names(assets)[i])
  local <- assets[[i]]
  dir.create(dirname(local), showWarnings = FALSE, recursive = TRUE)
  utils::download.file(remote, local, mode = "wb", quiet = TRUE)
  message("wrote ", local, " (", file.size(local), " bytes)")
}

# Fail loudly if the brand gains a colour role the app does not map.
brand <- yaml::read_yaml("brand/ggsegverse-brand.yml")
known <- c("palette", "primary", "secondary", "tertiary", "foreground",
           "background", "success", "danger", "warning", "info")
unknown <- setdiff(names(brand$color), known)
if (length(unknown) > 0) {
  warning("Unmapped brand colour roles: ", toString(unknown), call. = FALSE)
}
