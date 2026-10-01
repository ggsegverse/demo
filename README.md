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
  c("shiny", "bslib", "bsicons", "DT", "sass", "yaml",
    "ggseg", "ggseg3d", "ggseg.meshes"),
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
| `R/brand.R` | reads the ggsegverse brand and builds the bslib theme |
| `brand/` | the synced ggsegverse brand definition |
| `scss/ggsegverse.scss` | app styling, mirroring the pkgdown theme |
| `data/atlas_registry.rds` | generated index of every available atlas |
| `data-raw/` | the scripts that generate the two files above, and `manifest.json` |

## Theming

The app is themed from the ggsegverse brand, the same definition the website
and the pkgdown sites use. `data-raw/sync_brand.R` pulls `_brand.yml` and the
brand fonts and logos out of the website repo into `brand/` and `www/`; the
vendored copies are committed so a deployment never depends on the network.

`R/brand.R` turns that into a `bs_theme()`, and `scss/ggsegverse.scss` mirrors
`ggseg.docs/inst/pkgdown/extra.scss` so the demo reads as part of the same
family. No colour is hard-coded in either file — the palette reaches the
stylesheet as Sass variables generated from the brand.

Three things about the brand are worth knowing:

- The brand file is **not** named `_brand.yml` here. bslib auto-discovers that
  filename in the app directory, in a `brand/` subdirectory and up to 20
  parents above, and then errors on the brand's `light:`/`dark:` colour roles,
  which are a Quarto extension its reader does not accept. `R/brand.R` resolves
  those roles itself.
- The brand's logo roles are inverted upstream: `logo.medium.light` points at
  the pale-ink artwork meant for dark backgrounds. `brand_logo_roles_inverted`
  in `R/brand.R` works around it, and a test fails once it is fixed upstream.
- The brand lists a `warning` swatch but no `warning` role, so `brand_colour()`
  falls back to the palette entry of the same name.

Colour mode follows the system by default and can be switched in the sidebar.
Switching it changes the plot theme control rather than restyling the figure
behind your back, so the snippet on screen still reproduces what you see.

## Regenerating the registry

After installing or updating atlas packages:

```r
source("data-raw/build_registry.R")   # rebuilds data/atlas_registry.rds and R/atlas_packages.R
source("data-raw/sync_brand.R")       # re-pulls the brand assets
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
