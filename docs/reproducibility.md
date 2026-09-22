# Reproducible R Environment

This project uses R. The analytical workflow is designed to be reproducible
from the repository root.

## Captured environment

The repository environment was captured from the local Windows machine used
for the manuscript workflow.

- R version: 4.4.1
- Platform: x86_64-w64-mingw32/x64
- Operating system: Windows 11 x64
- renv version: 1.2.4

The exact package versions are recorded in `renv.lock`. The commands used to
capture or refresh the environment from the repository root are:

```r
install.packages("renv")
renv::init()
renv::snapshot()
```

This creates the project lockfile `renv.lock` and the standard `renv`
activation files. Package libraries themselves should not be committed.

To record the runtime information used for the manuscript, run:

```r
sink("sessionInfo.txt")
sessionInfo()
sink()
```

The resulting `sessionInfo.txt` is committed together with
`renv.lock`.

## Restoring the environment

A third party can recreate the recorded package environment with:

```r
install.packages("renv")
renv::restore()
```

## Packages used by the workflow

Depending on the script, the workflow uses base R and the following packages:

- `terra`
- `sf`
- `dplyr`
- `ggplot2`
- `cowplot`
- `patchwork`
- `scales`

The authoritative package versions are those recorded in `renv.lock`.


## Core package versions

The captured lockfile records the following core packages used by the workflow:

- `terra` 1.8-54
- `sf` 1.0-21
- `dplyr` 1.1.4
- `ggplot2` 3.5.2
- `cowplot` 1.2.0
- `patchwork` 1.3.1
- `scales` 1.3.0
- `renv` 1.2.4

The lockfile remains the authoritative source for the complete dependency set.
