# ============================================================
# 04_yield_association_figure.R
#
# Generates the manuscript heatmap of stage-specific exploratory
# Pearson correlations between UAV-derived metrics and final grain yield.
#
# Input:
#   derived/exploratory_yield_associations_by_flight.csv
#
# Outputs:
#   figures/Figure_5_yield_association_heatmap.png
#   figures/Figure_5_yield_association_heatmap.pdf
#
# Interpretation constraint:
#   Each coefficient uses n = 5 subplots and is descriptive/exploratory.
#   The figure does not establish statistical superiority of any stage
#   or UAV metric.
#
# Expected working directory: repository root.
# ============================================================

rm(list = ls())
gc()

if (!requireNamespace("ggplot2", quietly = TRUE)) {
  stop(
    "Package 'ggplot2' is required.\n",
    "Install it once with: install.packages('ggplot2')"
  )
}

library(ggplot2)

# ------------------------------------------------------------
# 1. PROJECT PATHS
# ------------------------------------------------------------

project_root <- normalizePath(
  ".",
  winslash = "/",
  mustWork = TRUE
)

yield_assoc_file <- file.path(
  project_root,
  "derived",
  "exploratory_yield_associations_by_flight.csv"
)

figure_root <- file.path(
  project_root,
  "figures"
)

if (!file.exists(yield_assoc_file)) {
  stop(
    "Missing yield-association table:\n",
    yield_assoc_file,
    "\nRun scripts/03_descriptive_analysis.R first."
  )
}

if (!dir.exists(figure_root)) {
  dir.create(
    figure_root,
    recursive = TRUE
  )
}

# ------------------------------------------------------------
# 2. READ AND CHECK DATA
# ------------------------------------------------------------

yield_assoc <- read.csv(
  yield_assoc_file,
  stringsAsFactors = FALSE,
  check.names = FALSE
)

required_columns <- c(
  "flight",
  "date",
  "growth_stage",
  "UAV_variable",
  "n",
  "pearson_r"
)

missing_columns <- setdiff(
  required_columns,
  names(yield_assoc)
)

if (length(missing_columns) > 0) {
  stop(
    "Missing required column(s): ",
    paste(missing_columns, collapse = ", ")
  )
}

if (nrow(yield_assoc) != 20) {
  stop(
    "Expected 20 stage-by-metric correlations; found ",
    nrow(yield_assoc)
  )
}

if (any(yield_assoc$n != 5)) {
  stop("Each stage-specific correlation must use n = 5 subplots.")
}

# ------------------------------------------------------------
# 3. ORDERING AND LABELS
# ------------------------------------------------------------

stage_levels <- c(
  "V4",
  "R5",
  "R6",
  "R7",
  "R8"
)

yield_assoc$growth_stage <- factor(
  yield_assoc$growth_stage,
  levels = stage_levels
)

variable_labels <- c(
  canopy_area_m2 = "Projected canopy area",
  NDVI_mean = "NDVI",
  MSAVI_mean = "MSAVI",
  WDRVI_mean = "WDRVI"
)

yield_assoc$variable_label <- unname(
  variable_labels[
    yield_assoc$UAV_variable
  ]
)

if (any(is.na(yield_assoc$variable_label))) {
  stop("Unexpected UAV_variable value found in association table.")
}

yield_assoc$variable_label <- factor(
  yield_assoc$variable_label,
  levels = c(
    "Projected canopy area",
    "NDVI",
    "MSAVI",
    "WDRVI"
  )
)

yield_assoc$r_label <- sprintf(
  "%.2f",
  yield_assoc$pearson_r
)

# ------------------------------------------------------------
# 4. FIGURE
# ------------------------------------------------------------

fig <- ggplot(
  yield_assoc,
  aes(
    x = growth_stage,
    y = variable_label,
    fill = pearson_r
  )
) +
  geom_tile(
    color = "white",
    linewidth = 0.7
  ) +
  geom_text(
    aes(label = r_label),
    size = 3.8,
    color = "black",
    fontface = "bold"
  ) +
  scale_fill_gradient2(
    low = "#3B4CC0",
    mid = "white",
    high = "#B40426",
    midpoint = 0,
    limits = c(-1, 1),
    breaks = c(-1, -0.5, 0, 0.5, 1),
    name = "Pearson r"
  ) +
  labs(
    x = "Growth stage",
    y = NULL
  ) +
  theme_classic(
    base_size = 11
  ) +
  theme(
    plot.background = element_rect(
      fill = "white",
      color = NA
    ),
    panel.background = element_rect(
      fill = "white",
      color = NA
    ),
    axis.line = element_blank(),
    axis.ticks = element_blank(),
    axis.text.y = element_text(
      face = "bold",
      color = "black"
    ),
    axis.text.x = element_text(
      color = "black"
    ),
    legend.position = "right",
    legend.background = element_rect(
      fill = "white",
      color = NA
    ),
    legend.key = element_rect(
      fill = "white",
      color = NA
    )
  )

png_file <- file.path(
  figure_root,
  "Figure_5_yield_association_heatmap.png"
)

pdf_file <- file.path(
  figure_root,
  "Figure_5_yield_association_heatmap.pdf"
)

ggsave(
  filename = png_file,
  plot = fig,
  width = 7.6,
  height = 4.3,
  units = "in",
  dpi = 600,
  bg = "white"
)

ggsave(
  filename = pdf_file,
  plot = fig,
  width = 7.6,
  height = 4.3,
  units = "in",
  bg = "white"
)

cat("\nYield-association figure completed.\n")
cat("PNG: ", png_file, "\n", sep = "")
cat("PDF: ", pdf_file, "\n", sep = "")

# ============================================================
# END
# ============================================================
