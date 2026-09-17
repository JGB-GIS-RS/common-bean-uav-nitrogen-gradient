# ============================================================
# 05_multitemporal_uav_figure.R
#
# Publication-ready four-panel figure showing multitemporal UAV
# structural and spectral responses across common-bean growth stages.
#
# Panels:
#   A. Projected canopy area
#   B. NDVI
#   C. MSAVI
#   D. WDRVI
#
# Each trajectory represents one field subplot associated with a
# single nitrogen rate. The figure is descriptive and does not imply
# replicated treatment-level inference.
#
# Expected working directory: repository root.
#
# Input:
#   data/common_bean_uav_master_dataset.csv
#
# Outputs:
#   figures/Figure_4_multitemporal_UAV_response.png
#   figures/Figure_4_multitemporal_UAV_response.pdf
# ============================================================

rm(list = ls())
gc()

if (!requireNamespace("ggplot2", quietly = TRUE)) {
  stop(
    "Package 'ggplot2' is required.\n",
    "Install it once with:\n",
    "install.packages('ggplot2')"
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

master_file <- file.path(
  project_root,
  "data",
  "common_bean_uav_master_dataset.csv"
)

figure_root <- file.path(
  project_root,
  "figures"
)

if (!file.exists(master_file)) {
  stop(
    "Missing master dataset:\n",
    master_file
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

d <- read.csv(
  master_file,
  stringsAsFactors = FALSE,
  check.names = FALSE
)

required_columns <- c(
  "flight",
  "date",
  "growth_stage",
  "subplot",
  "N_rate_kg_ha",
  "canopy_area_m2",
  "NDVI_mean",
  "MSAVI_mean",
  "WDRVI_mean"
)

missing_columns <- setdiff(
  required_columns,
  names(d)
)

if (length(missing_columns) > 0) {
  stop(
    "Missing required column(s): ",
    paste(
      missing_columns,
      collapse = ", "
    )
  )
}

if (nrow(d) != 25) {
  stop(
    "Expected 25 rows; found ",
    nrow(d)
  )
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

stage_date_labels <- c(
  V4 = "V4\nSep 07",
  R5 = "R5\nSep 14",
  R6 = "R6\nOct 02",
  R7 = "R7\nOct 09",
  R8 = "R8\nOct 16"
)

d$growth_stage <- factor(
  d$growth_stage,
  levels = stage_levels
)

d$subplot_N <- factor(
  paste0(
    d$subplot,
    " / ",
    d$N_rate_kg_ha
  ),
  levels = c(
    "P1 / 0",
    "P2 / 100",
    "P3 / 200",
    "P4 / 300",
    "P5 / 400"
  )
)

# ------------------------------------------------------------
# 4. BUILD LONG TABLE
# ------------------------------------------------------------

long_data <- rbind(
  data.frame(
    growth_stage = d$growth_stage,
    subplot = d$subplot,
    subplot_N = d$subplot_N,
    metric = "A. Projected canopy area (m²)",
    value = d$canopy_area_m2,
    stringsAsFactors = FALSE
  ),
  data.frame(
    growth_stage = d$growth_stage,
    subplot = d$subplot,
    subplot_N = d$subplot_N,
    metric = "B. NDVI",
    value = d$NDVI_mean,
    stringsAsFactors = FALSE
  ),
  data.frame(
    growth_stage = d$growth_stage,
    subplot = d$subplot,
    subplot_N = d$subplot_N,
    metric = "C. MSAVI",
    value = d$MSAVI_mean,
    stringsAsFactors = FALSE
  ),
  data.frame(
    growth_stage = d$growth_stage,
    subplot = d$subplot,
    subplot_N = d$subplot_N,
    metric = "D. WDRVI",
    value = d$WDRVI_mean,
    stringsAsFactors = FALSE
  )
)

long_data$growth_stage <- factor(
  long_data$growth_stage,
  levels = stage_levels
)

long_data$metric <- factor(
  long_data$metric,
  levels = c(
    "A. Projected canopy area (m²)",
    "B. NDVI",
    "C. MSAVI",
    "D. WDRVI"
  )
)

# ------------------------------------------------------------
# 5. JOURNAL THEME
# ------------------------------------------------------------

theme_journal <- theme_classic(
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
    legend.background = element_rect(
      fill = "white",
      color = NA
    ),
    legend.key = element_rect(
      fill = "white",
      color = NA
    ),
    axis.text = element_text(
      color = "black",
      size = 9.5
    ),
    axis.title = element_text(
      color = "black",
      size = 10.5
    ),
    axis.line = element_line(
      color = "black",
      linewidth = 0.45
    ),
    axis.ticks = element_line(
      color = "black",
      linewidth = 0.35
    ),
    strip.text = element_text(
      face = "bold",
      color = "black",
      size = 10.5,
      hjust = 0
    ),
    strip.background = element_rect(
      fill = "grey95",
      color = "grey70",
      linewidth = 0.4
    ),
    legend.title = element_text(
      face = "bold",
      color = "black",
      size = 10
    ),
    legend.text = element_text(
      color = "black",
      size = 9.3
    ),
    panel.spacing.x = unit(
      1.0,
      "lines"
    ),
    panel.spacing.y = unit(
      1.0,
      "lines"
    ),
    plot.margin = margin(
      8,
      10,
      8,
      8
    )
  )

# ------------------------------------------------------------
# 6. FIGURE
# ------------------------------------------------------------

fig_multitemporal <- ggplot(
  long_data,
  aes(
    x = growth_stage,
    y = value,
    group = subplot,
    color = subplot_N
  )
) +
  geom_line(
    linewidth = 0.75,
    alpha = 0.90
  ) +
  geom_point(
    size = 2.45
  ) +
  facet_wrap(
    ~ metric,
    scales = "free_y",
    ncol = 2
  ) +
  scale_color_viridis_d(
    option = "D",
    end = 0.90
  ) +
  scale_x_discrete(
    labels = stage_date_labels
  ) +
  scale_y_continuous(
    expand = expansion(
      mult = c(
        0.05,
        0.08
      )
    )
  ) +
  labs(
    x = "Growth stage / UAV acquisition date",
    y = NULL,
    color = expression(
      "Subplot / N rate (kg N " * ha^-1 * ")"
    )
  ) +
  theme_journal +
  theme(
    legend.position = "bottom",
    legend.direction = "horizontal"
  ) +
  guides(
    color = guide_legend(
      title.position = "top",
      title.hjust = 0.5,
      nrow = 1,
      byrow = TRUE
    )
  )

# ------------------------------------------------------------
# 7. EXPORT
# ------------------------------------------------------------

png_file <- file.path(
  figure_root,
  "Figure_4_multitemporal_UAV_response.png"
)

pdf_file <- file.path(
  figure_root,
  "Figure_4_multitemporal_UAV_response.pdf"
)

ggsave(
  filename = png_file,
  plot = fig_multitemporal,
  width = 8.8,
  height = 7.0,
  units = "in",
  dpi = 600,
  bg = "white"
)

ggsave(
  filename = pdf_file,
  plot = fig_multitemporal,
  width = 8.8,
  height = 7.0,
  units = "in",
  bg = "white"
)

# ------------------------------------------------------------
# 8. CONSOLE REPORT
# ------------------------------------------------------------

cat("\n")
cat("====================================================\n")
cat("MULTITEMPORAL UAV FIGURE COMPLETED\n")
cat("====================================================\n\n")

cat(
  "PNG: ",
  png_file,
  "\n",
  sep = ""
)

cat(
  "PDF: ",
  pdf_file,
  "\n",
  sep = ""
)

cat(
  "\nEach line represents one subplot / N-rate combination.\n"
)

cat(
  "No treatment-level inference is implied by the figure.\n"
)

# ============================================================
# END
# ============================================================
