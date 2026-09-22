# Reproducible R Environment

This project uses R. The analytical workflow is designed to be reproducible
from the repository root.

## Environment capture

The exact R environment should be captured from the local machine on which the
current manuscript workflow runs successfully. Do not generate the lockfile on
a different machine merely to populate the repository.

From the repository root in RStudio, run:

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

The resulting `sessionInfo.txt` should be committed together with
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
