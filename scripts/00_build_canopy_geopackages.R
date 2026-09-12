# ============================================================
# 00_build_canopy_geopackages.R
#
# Optional preparation utility.
# Consolidates P1-P5 canopy shapefiles into one GeoPackage
# per UAV flight.
#
# Expected working directory: repository root.
# Source shapefiles are not modified or deleted.
# ============================================================

rm(list = ls())
gc()

library(terra)

project_root <- normalizePath(".", winslash = "/", mustWork = TRUE)
spatial_root <- file.path(project_root, "data", "spatial")
derived_root <- file.path(project_root, "derived")

if (!dir.exists(spatial_root)) {
  stop("Directory not found: ", spatial_root,
       "\nOpen the RStudio project from the repository root.")
}
if (!dir.exists(derived_root)) dir.create(derived_root, recursive = TRUE)

flights <- data.frame(
  flight = 1:5,
  folder = sprintf("flight%02d", 1:5),
  date = c("2024-09-07","2024-09-14","2024-10-02","2024-10-09","2024-10-16"),
  file_date = c("20240907","20240914","20241002","20241009","20241016"),
  growth_stage = c("V4","R5","R6","R7","R8"),
  stringsAsFactors = FALSE
)

N_rate <- c(P1 = 0, P2 = 100, P3 = 200, P4 = 300, P5 = 400)

validation_rows <- list()
counter <- 1

for (i in seq_len(nrow(flights))) {

  flight_id <- flights$flight[i]
  flight_dir <- file.path(spatial_root, flights$folder[i])
  date_txt <- flights$date[i]
  file_date <- flights$file_date[i]
  stage <- flights$growth_stage[i]

  if (!dir.exists(flight_dir)) stop("Missing flight directory: ", flight_dir)

  cat("\n====================================================\n")
  cat("FLIGHT ", flight_id, " | ", date_txt, " | ", stage, "\n", sep = "")
  cat("====================================================\n")

  subplot_vectors <- list()
  reference_crs <- NULL

  for (p in 1:5) {

    subplot <- paste0("P", p)
    shp <- file.path(
      flight_dir,
      paste0("plantas_p", p, "_", file_date, ".shp")
    )

    if (!file.exists(shp)) stop("Missing shapefile: ", shp)

    v <- vect(shp)
    if (nrow(v) == 0) stop("Empty shapefile: ", shp)

    if (is.null(reference_crs)) {
      reference_crs <- crs(v)
    } else if (!same.crs(v, reference_crs)) {
      v <- project(v, reference_crs)
    }

    n_objects <- nrow(v)

    values(v) <- data.frame(
      flight = rep(flight_id, n_objects),
      date = rep(date_txt, n_objects),
      growth_stage = rep(stage, n_objects),
      subplot = rep(subplot, n_objects),
      N_rate_kg_ha = rep(as.numeric(N_rate[subplot]), n_objects),
      canopy_object_id = seq_len(n_objects),
      stringsAsFactors = FALSE
    )

    subplot_vectors[[subplot]] <- v
    cat(subplot, ": ", n_objects, " canopy object(s)\n", sep = "")
  }

  canopy_all <- Reduce(function(x, y) rbind(x, y), subplot_vectors)

  gpkg_file <- file.path(flight_dir, paste0("canopy_", file_date, ".gpkg"))
  if (file.exists(gpkg_file)) file.remove(gpkg_file)

  writeVector(
    canopy_all,
    gpkg_file,
    filetype = "GPKG",
    layer = "canopy",
    overwrite = TRUE
  )

  canopy_check <- vect(gpkg_file, layer = "canopy")

  if (nrow(canopy_check) != nrow(canopy_all)) {
    stop("Feature count changed after GeoPackage export.")
  }
  if (!same.crs(canopy_check, canopy_all)) {
    stop("CRS changed after GeoPackage export.")
  }

  for (subplot in names(subplot_vectors)) {

    original <- subplot_vectors[[subplot]]
    exported <- canopy_check[canopy_check$subplot == subplot, ]

    original_area <- sum(expanse(original, unit = "m"), na.rm = TRUE)
    exported_area <- sum(expanse(exported, unit = "m"), na.rm = TRUE)

    validation_rows[[counter]] <- data.frame(
      flight = flight_id,
      date = date_txt,
      growth_stage = stage,
      subplot = subplot,
      N_rate_kg_ha = as.numeric(N_rate[subplot]),
      source_polygon_count = nrow(original),
      gpkg_polygon_count = nrow(exported),
      source_area_m2 = original_area,
      gpkg_area_m2 = exported_area,
      area_difference_m2 = exported_area - original_area,
      stringsAsFactors = FALSE
    )

    counter <- counter + 1
  }

  cat("Created: ", basename(gpkg_file), "\n", sep = "")
  cat("Total polygons: ", nrow(canopy_check), "\n", sep = "")
}

validation <- do.call(rbind, validation_rows)
validation$polygon_count_ok <-
  validation$source_polygon_count == validation$gpkg_polygon_count
validation$area_ok <- abs(validation$area_difference_m2) < 1e-6

write.csv(
  validation,
  file.path(derived_root, "qa_canopy_geopackages.csv"),
  row.names = FALSE
)

cat("\n====================================================\n")
cat("GEOPACKAGE VALIDATION\n")
cat("====================================================\n\n")
print(validation, row.names = FALSE)

if (all(validation$polygon_count_ok & validation$area_ok)) {
  cat("\nRESULT: ALL GEOPACKAGES PASSED VALIDATION\n")
} else {
  cat("\nRESULT: REVIEW REQUIRED\n")
}

cat("\nSource shapefiles were not modified or deleted.\n")
