# About panel ------------------------------------------------------------

about_ui <- function() {
  card(card_body(
    markdown(sprintf(
      "
## What this is

A live tour of the **ggsegverse**: %d brain atlases across %d packages,
plotted in 2D with [ggseg](https://ggsegverse.github.io/ggseg/) and in 3D
with [ggseg3d](https://ggsegverse.github.io/ggseg3d/).

Every control rewrites the R code below the figure, and the app renders the
figure by running that code. Copy it, paste it into your own session, and you
get the same picture.

## Installing

```r
install.packages(
  c(\"ggseg\", \"ggseg3d\", \"ggsegSchaefer\"),
  repos = c(
    ggsegverse = \"https://ggsegverse.r-universe.dev\",
    CRAN = \"https://cloud.r-project.org\"
  )
)
```

## Atlas types

- **Cortical** — surface parcellations, drawn as lateral/medial views in 2D
  and on an inflated, white or pial mesh in 3D.
- **Subcortical** — volumetric structures, drawn as axial, coronal and
  sagittal slices in 2D and as per-structure meshes in 3D.
- **Cerebellar** — drawn on the SUIT flatmap in 2D and the SUIT surface in 3D.
- **Tract** — white matter bundles, drawn as slices in 2D and as tubes in 3D,
  optionally coloured by orientation.

## Citing

Mowinckel, A.M. & Vidal-Piñeiro, D. (2020). Visualisation of Brain Statistics
with R-packages ggseg and ggseg3d. *Advances in Methods and Practices in
Psychological Science*. <https://doi.org/10.1177/2515245920928009>
",
      nrow(atlas_registry),
      length(unique(atlas_registry$package))
    ))
  ))
}
