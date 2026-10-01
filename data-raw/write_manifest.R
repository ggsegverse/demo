# Regenerate manifest.json, the dependency file Posit Connect Cloud reads.
# Connect Cloud requires it to sit next to app.R. Run after changing the
# packages the app uses, or after rebuilding the atlas registry.

# Connect Cloud supports R 4.0.0-4.6.0, so a newer local R has to be recorded
# as the highest version it will accept.
# https://docs.posit.co/connect-cloud/user/platform/r.html
max_connect_cloud_r <- "4.6.0"

options(repos = c(
  ggsegverse = "https://ggsegverse.r-universe.dev",
  CRAN = "https://cloud.r-project.org"
))

rsconnect::writeManifest(
  appDir = ".",
  appPrimaryDoc = "app.R",
  appFiles = c(
    "app.R",
    list.files("R", full.names = TRUE),
    list.files("www", full.names = TRUE),
    "data/atlas_registry.rds"
  )
)

manifest <- jsonlite::fromJSON("manifest.json", simplifyVector = FALSE)
if (package_version(manifest$platform) > package_version(max_connect_cloud_r)) {
  message(
    "Pinning manifest platform from ", manifest$platform,
    " to ", max_connect_cloud_r, " (Connect Cloud's maximum)."
  )
  manifest$platform <- max_connect_cloud_r
  jsonlite::write_json(
    manifest,
    "manifest.json",
    auto_unbox = TRUE,
    pretty = TRUE,
    null = "null"
  )
}

packages <- manifest$packages
sources <- unique(vapply(packages, function(p) p$Source, character(1)))
message(length(packages), " packages from: ", toString(sources))
