# ============================================================
# 03_descriptive_analysis.R
#
# Descriptive and exploratory analysis for the common-bean UAV
# nitrogen-gradient study.
#
# DESIGN CONSTRAINTS
# ------------------
# - Five fixed field subplots were observed repeatedly across five UAV flights.
# - Each nitrogen rate is represented by one subplot only.
# - Nitrogen rates are therefore NOT independently replicated treatments.
# - Grain yield was measured once per subplot at final harvest.
# - The 25 longitudinal rows must NOT be treated as 25 independent
#   yield observations.
#
# This manuscript-aligned script intentionally avoids ANOVA, treatment-level
# hypothesis tests, inferential p-values, pooled n=25 yield regressions,
# dose-response modelling, and N-rate optimization.
#
# Input:
#   data/common_bean_uav_master_dataset.csv
#
# Outputs:
#   derived/descriptive_summary_by_flight.csv
#   derived/exploratory_yield_associations_by_flight.csv
#   derived/final_harvest_by_subplot.csv
#   derived/descriptive_analysis_notes.txt
#
# Expected working directory: repository root.
# ============================================================

rm(list = ls())
gc()

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

derived_root <- file.path(
  project_root,
  "derived"
)

if (!file.exists(master_file)) {
  stop(
    "Missing master dataset:\n",
    master_file
  )
}

if (!dir.exists(derived_root)) {
  dir.create(
    derived_root,
    recursive = TRUE
  )
}

# ------------------------------------------------------------
# 2. READ DATA
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
  "canopy_polygon_count",
  "NDVI_mean",
  "MSAVI_mean",
  "WDRVI_mean",
  "harvest_area_m2",
  "harvested_grain_kg",
  "grain_yield_t_ha"
)

missing_columns <- setdiff(
  required_columns,
  names(d)
)

if (length(missing_columns) > 0) {
  stop(
    "Missing required column(s): ",
    paste(missing_columns, collapse = ", ")
  )
}

# ------------------------------------------------------------
# 3. STRUCTURAL QA
# ------------------------------------------------------------

if (nrow(d) != 25) {
  stop("Expected 25 rows; found ", nrow(d))
}

if (length(unique(d$flight)) != 5) {
  stop("Expected 5 UAV flights.")
}

if (length(unique(d$subplot)) != 5) {
  stop("Expected 5 subplots.")
}

if (any(table(d$flight) != 5)) {
  stop("Each flight must contain exactly 5 subplot records.")
}

if (any(table(d$subplot) != 5)) {
  stop("Each subplot must contain exactly 5 repeated UAV observations.")
}

for (s in unique(d$subplot)) {
  z <- d[d$subplot == s, ]

  if (length(unique(z$N_rate_kg_ha)) != 1) {
    stop("Nitrogen rate is not constant for subplot ", s)
  }

  for (v in c("harvest_area_m2", "harvested_grain_kg", "grain_yield_t_ha")) {
    if (length(unique(z[[v]])) != 1) {
      stop(
        "Harvest variable ", v,
        " is not constant across flights for subplot ", s
      )
    }
  }
}

# ------------------------------------------------------------
# 4. ORDER DATA
# ------------------------------------------------------------

d <- d[
  order(
    d$flight,
    d$N_rate_kg_ha
  ),
]

# ------------------------------------------------------------
# 5. DESCRIPTIVE SUMMARY BY FLIGHT
# ------------------------------------------------------------

uav_variables <- c(
  "canopy_area_m2",
  "NDVI_mean",
  "MSAVI_mean",
  "WDRVI_mean"
)

summary_rows <- list()
k <- 1

for (f in sort(unique(d$flight))) {
  z <- d[d$flight == f, ]

  for (v in uav_variables) {
    x <- z[[v]]

    summary_rows[[k]] <- data.frame(
      flight = f,
      date = z$date[1],
      growth_stage = z$growth_stage[1],
      variable = v,
      n_subplots = sum(is.finite(x)),
      mean = mean(x, na.rm = TRUE),
      sd = sd(x, na.rm = TRUE),
      median = median(x, na.rm = TRUE),
      min = min(x, na.rm = TRUE),
      max = max(x, na.rm = TRUE),
      range = diff(range(x, na.rm = TRUE)),
      stringsAsFactors = FALSE
    )

    k <- k + 1
  }
}

descriptive_summary <- do.call(
  rbind,
  summary_rows
)

# ------------------------------------------------------------
# 6. FINAL HARVEST TABLE
# ------------------------------------------------------------

harvest_table <- unique(
  d[
    ,
    c(
      "subplot",
      "N_rate_kg_ha",
      "harvest_area_m2",
      "harvested_grain_kg",
      "grain_yield_t_ha"
    )
  ]
)

harvest_table <- harvest_table[
  order(harvest_table$N_rate_kg_ha),
]

if (nrow(harvest_table) != 5) {
  stop("Expected exactly 5 final-harvest records.")
}

# ------------------------------------------------------------
# 7. UAV METRIC / FINAL YIELD ASSOCIATIONS BY FLIGHT
# ------------------------------------------------------------
#
# Each Pearson correlation is calculated separately by growth stage
# using the five subplot-level yield observations (n = 5).
# Coefficients are descriptive/exploratory; no p-values or confidence
# intervals are calculated.
# ------------------------------------------------------------

yield_assoc_rows <- list()
k <- 1

for (f in sort(unique(d$flight))) {
  z <- d[d$flight == f, ]
  y <- z$grain_yield_t_ha

  for (v in uav_variables) {
    x <- z[[v]]

    yield_assoc_rows[[k]] <- data.frame(
      flight = f,
      date = z$date[1],
      growth_stage = z$growth_stage[1],
      UAV_variable = v,
      n = sum(complete.cases(x, y)),
      pearson_r = cor(
        x,
        y,
        method = "pearson",
        use = "complete.obs"
      ),
      stringsAsFactors = FALSE
    )

    k <- k + 1
  }
}

yield_associations <- do.call(
  rbind,
  yield_assoc_rows
)

# ------------------------------------------------------------
# 8. WRITE OUTPUTS
# ------------------------------------------------------------

write.csv(
  descriptive_summary,
  file.path(
    derived_root,
    "descriptive_summary_by_flight.csv"
  ),
  row.names = FALSE
)

write.csv(
  yield_associations,
  file.path(
    derived_root,
    "exploratory_yield_associations_by_flight.csv"
  ),
  row.names = FALSE
)

write.csv(
  harvest_table,
  file.path(
    derived_root,
    "final_harvest_by_subplot.csv"
  ),
  row.names = FALSE
)

# ------------------------------------------------------------
# 9. ANALYSIS NOTES
# ------------------------------------------------------------

notes <- c(
  "DESCRIPTIVE ANALYSIS NOTES",
  "==========================",
  "",
  "Experimental structure:",
  "- 5 fixed field subplots observed repeatedly across 5 UAV flights.",
  "- One nitrogen rate per subplot; nitrogen treatments are not independently replicated.",
  "- 25 spectral/structural records, but only 5 final-harvest observations.",
  "",
  "Analytical rules used in 03_descriptive_analysis.R:",
  "- No ANOVA or replicated-treatment hypothesis testing.",
  "- No inferential p-values or confidence intervals for stage-specific correlations.",
  "- No pooled n=25 regression against final grain yield.",
  "- UAV/yield Pearson correlations are calculated separately by stage (n=5).",
  "",
  "Interpretation:",
  "- Results describe temporal patterns and stage-specific exploratory associations.",
  "- Results do not establish causal fertilizer effects, diagnostic thresholds, or an optimum N rate."
)

writeLines(
  notes,
  file.path(
    derived_root,
    "descriptive_analysis_notes.txt"
  )
)

# ------------------------------------------------------------
# 10. CONSOLE REPORT
# ------------------------------------------------------------

cat("\n")
cat("====================================================\n")
cat("DESCRIPTIVE ANALYSIS COMPLETED\n")
cat("====================================================\n\n")

cat("Rows in master dataset: ", nrow(d), "\n", sep = "")
cat("Flights: ", length(unique(d$flight)), "\n", sep = "")
cat("Subplots: ", length(unique(d$subplot)), "\n", sep = "")
cat("Final harvest records: ", nrow(harvest_table), "\n", sep = "")

cat("\nExploratory UAV / final-yield Pearson correlations by flight:\n")
print(
  yield_associations,
  row.names = FALSE
)

cat("\nOutputs written to:\n")
cat(derived_root, "\n")

# ============================================================
# END
# ============================================================
