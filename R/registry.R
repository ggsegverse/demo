# Atlas registry ---------------------------------------------------------
# data/atlas_registry.rds is built by data-raw/build_registry.R and lists
# every atlas exported by the installed ggsegverse packages.

atlas_registry <- local({
  reg <- readRDS(app_file("data/atlas_registry.rds"))
  reg$id <- paste(reg$package, reg$object, sep = "::")
  reg$label <- sprintf("%s  —  %d regions", reg$object, reg$n_regions)
  reg
})

type_labels <- c(
  cortical = "Cortical surface",
  subcortical = "Subcortical volume",
  cerebellar = "Cerebellar flatmap",
  tract = "White matter tracts"
)

atlas_choices <- function(registry = atlas_registry) {
  by_type <- split(registry, factor(registry$type, names(type_labels)))
  by_type <- Filter(function(x) nrow(x) > 0, by_type)
  choices <- lapply(by_type, function(x) stats::setNames(x$id, x$label))
  stats::setNames(choices, type_labels[names(choices)])
}

atlas_meta <- function(id, registry = atlas_registry) {
  registry[match(id, registry$id), ]
}

# R's lazy-load database caches package data after the first access, so
# repeated calls are free; no cache of our own is needed.
get_atlas <- function(id) {
  meta <- atlas_meta(id)
  get(meta$object, envir = asNamespace(meta$package))()
}

atlas_views_for <- function(id) {
  strsplit(atlas_meta(id)$views, ",", fixed = TRUE)[[1]]
}

atlas_hemis_for <- function(id) {
  strsplit(atlas_meta(id)$hemispheres, ",", fixed = TRUE)[[1]]
}

atlas_pkgdown_url <- function(package) {
  sprintf("https://ggsegverse.github.io/%s/", package)
}
