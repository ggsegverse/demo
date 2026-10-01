# ggsegverse demo

An interactive tour of the [ggsegverse](https://github.com/ggsegverse): every
brain atlas in the ecosystem, plotted in 2D with
[ggseg](https://ggsegverse.github.io/ggseg/) and in 3D with
[ggseg3d](https://ggsegverse.github.io/ggseg3d/).

It replaces the [original demo](https://athanasiamo.shinyapps.io/ggsegDemo/),
which covered seven atlases and two kinds of plot.

## What makes it a teaching tool

Every control rewrites the R snippet under the figure, and **the app renders
the figure by evaluating that snippet**. The code and the picture cannot drift
apart, so anything you copy out of the app runs unchanged in your own session.

## Running it locally

```r
install.packages(
  c("shiny", "bslib", "bsicons", "DT", "ggseg", "ggseg3d", "ggseg.meshes"),
  repos = c(
    ggsegverse = "https://ggsegverse.r-universe.dev",
    CRAN = "https://cloud.r-project.org"
  )
)

shiny::runApp()
```

The atlas packages the app needs are listed in `R/atlas_packages.R`.

## Layout

| Path | What it holds |
|------|---------------|
| `app.R` | UI and server wiring |
| `R/registry.R` | the atlas registry and lazy atlas loading |
| `R/code_gen.R` | snippet generation, and `run_code()` which evaluates it |
| `R/mod_*.R` | Shiny modules: atlas picker, 2D view, 3D view, regions, code panel |
| `R/atlas_packages.R` | generated `library()` calls, one per atlas package |
| `data/atlas_registry.rds` | generated index of every available atlas |
| `data-raw/` | the scripts that generate the two files above, and `manifest.json` |

## Regenerating the registry

After installing or updating atlas packages:

```r
source("data-raw/build_registry.R")   # rebuilds data/atlas_registry.rds and R/atlas_packages.R
source("data-raw/write_manifest.R")   # rebuilds manifest.json
```

`build_registry.R` only picks up atlas packages that are **published on the
ggsegverse r-universe**, since a locally-installed development build cannot be
restored on the deployment host.

## Tests

```r
testthat::test_dir("tests/testthat")
```

Set `GGSEGDEMO_FULL_TESTS=1` to additionally render every registered atlas in
both 2D and 3D. CI does this on every push.

## Deployment

The app deploys to [Posit Connect Cloud](https://connect.posit.cloud) from this
repository. Connect Cloud reads `manifest.json`, which must sit next to `app.R`
and must be regenerated whenever the package set changes.

Two constraints worth knowing:

- Connect Cloud supports R 4.0.0–4.6.0. `data-raw/write_manifest.R` pins the
  recorded platform to 4.6.0 when the local R is newer.
- Every ggsegverse package is served from r-universe rather than CRAN. The
  manifest records that repository per package.

## Citation

Mowinckel, A.M. & Vidal-Piñeiro, D. (2020). Visualisation of Brain Statistics
with R-packages ggseg and ggseg3d. *Advances in Methods and Practices in
Psychological Science*. <https://doi.org/10.1177/2515245920928009>
