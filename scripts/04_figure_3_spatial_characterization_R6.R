# ============================================================
# 04_figure_3_spatial_characterization_R6.R
#
# Manuscript Figure 3 — Spatial characterization at R6
#
# Purpose
# -------
# Generates the publication-ready four-panel spatial figure for the
# R6 acquisition, integrating segmented canopy geometry and the three
# UAV-derived spectral indices.
#
# Panels
# ------
#   (a) Canopy segmentation at R6
#   (b) NDVI at R6 with zoom windows
#   (c) MSAVI at R6
#   (d) WDRVI at R6
#
# Main inputs
# -----------
#   data/spatial/flight03/canopy_20241002.gpkg
#   data/spatial/flight03/ndvi_20241002.tif
#   data/spatial/flight03/msavi_20241002.tif
#   data/spatial/flight03/wdrvi_20241002.tif
#
# Notes
# -----
# Cartographic and spectral settings in the executable code are kept
# unchanged. Historical internal output filenames are retained to avoid
# altering functional code; this script corresponds to manuscript Figure 3.
# ============================================================

rm(list = ls())
gc()

# ------------------------------------------------------------
# 1. PACKAGES
# ------------------------------------------------------------

needed <- c(
  "sf",
  "terra",
  "dplyr",
  "ggplot2",
  "cowplot",
  "grid",
  "scales"
)

missing <- needed[
  !vapply(
    needed,
    requireNamespace,
    FUN.VALUE = logical(1),
    quietly = TRUE
  )
]

if (length(missing) > 0) {
  stop(
    "Missing package(s): ",
    paste(missing, collapse = ", "),
    "\nInstall once with:\ninstall.packages(c(",
    paste(paste0('"', missing, '"'), collapse = ", "),
    "))"
  )
}

library(sf)
library(terra)
library(dplyr)
library(ggplot2)
library(cowplot)
library(grid)
library(scales)

# ------------------------------------------------------------
# 2. PATHS
# ------------------------------------------------------------

project_root <- "C:/common-bean-uav-nitrogen-gradient"

flight_dir <- file.path(
  project_root,
  "data",
  "spatial",
  "flight03"
)

canopy_file <- file.path(
  flight_dir,
  "canopy_20241002.gpkg"
)

ndvi_file <- file.path(
  flight_dir,
  "ndvi_20241002.tif"
)

fig_dir <- file.path(
  project_root,
  "figures"
)

dir.create(
  fig_dir,
  recursive = TRUE,
  showWarnings = FALSE
)

out_png <- file.path(
  fig_dir,
  "Figure1_AB_R6_v26_PANEL_A_FINE_TUNING.png"
)

if (!file.exists(canopy_file)) {
  stop("Missing file: ", canopy_file)
}

if (!file.exists(ndvi_file)) {
  stop("Missing file: ", ndvi_file)
}

# ------------------------------------------------------------
# 3. READ DATA
# ------------------------------------------------------------

canopy_sf <- st_read(
  canopy_file,
  layer = "canopy",
  quiet = TRUE
)

if (is.na(st_crs(canopy_sf))) {
  stop("The canopy layer has no CRS.")
}

canopy_sf <- st_make_valid(
  canopy_sf
)

canopy_sf <- st_transform(
  canopy_sf,
  32618
)

ndvi_r <- rast(
  ndvi_file
)

if (!same.crs(ndvi_r, "EPSG:32618")) {
  ndvi_r <- project(
    ndvi_r,
    "EPSG:32618",
    method = "bilinear"
  )
}

# ------------------------------------------------------------
# 4. BASIC CLEANING
# ------------------------------------------------------------

canopy_sf$subplot <- factor(
  canopy_sf$subplot,
  levels = c("P1", "P2", "P3", "P4", "P5")
)

subplot_cols <- c(
  "P1" = "#2C91D1",
  "P2" = "#E69F00",
  "P3" = "#00A087",
  "P4" = "#CC79A7",
  "P5" = "#D55E00"
)

# ------------------------------------------------------------
# 5. EXTRACT MEAN NDVI BY SEGMENTED CANOPY OBJECT
# ------------------------------------------------------------

canopy_vect <- vect(
  canopy_sf
)

ext_df <- terra::extract(
  ndvi_r,
  canopy_vect,
  fun = mean,
  na.rm = TRUE
)

if (ncol(ext_df) < 2) {
  stop("Mean NDVI extraction failed.")
}

canopy_sf$ndvi_mean <- ext_df[[2]]

if (all(is.na(canopy_sf$ndvi_mean))) {
  stop("Mean NDVI extraction failed: all extracted values are NA.")
}

# ------------------------------------------------------------
# 6. COMMON TYPOGRAPHY
# ------------------------------------------------------------

TXT_PANEL_TAG     <- 17.5
TXT_AXIS_TITLE    <- 13.5
TXT_AXIS_TICK     <- 11.5
TXT_LEGEND_TITLE  <- 11.5
TXT_LEGEND_VALUE  <- 10.0

# annotate("text") sizes are not pt, so use proportional increase
TXT_SCALE <- 4.0
TXT_NORTH <- 4.8

# ------------------------------------------------------------
# 7. HELPER FUNCTIONS
# ------------------------------------------------------------

theme_map_pub <- function() {

  theme_minimal(
    base_size = 13.5
  ) +

    theme(
      panel.grid.major = element_line(
        color = "grey82",
        linewidth = 0.35
      ),

      panel.grid.minor = element_blank(),

      axis.title = element_text(
        size = TXT_AXIS_TITLE,
        color = "black"
      ),

      axis.text = element_text(
        size = TXT_AXIS_TICK,
        color = "black"
      ),

      axis.ticks = element_line(
        color = "black",
        linewidth = 0.35
      ),

      axis.line = element_line(
        color = "black",
        linewidth = 0.35
      ),

      legend.title = element_text(
        size = TXT_LEGEND_TITLE,
        face = "bold"
      ),

      legend.text = element_text(
        size = TXT_LEGEND_VALUE
      ),

      panel.background = element_rect(
        fill = "white",
        color = NA
      ),

      plot.background = element_rect(
        fill = "white",
        color = NA
      ),

      plot.margin = margin(
        6,
        6,
        6,
        6
      )
    )
}

north_arrow_layers <- function(
  x,
  y,
  size = 1.0
) {

  list(

    annotate(
      "segment",
      x = x,
      xend = x,
      y = y - 1.15 * size,
      yend = y + 0.10 * size,
      linewidth = 0.60,
      color = "black"
    ),

    annotate(
      "polygon",
      x = c(
        x,
        x - 0.22 * size,
        x,
        x + 0.22 * size
      ),
      y = c(
        y + 0.55 * size,
        y + 0.05 * size,
        y + 0.20 * size,
        y + 0.05 * size
      ),
      fill = "black",
      color = "black",
      linewidth = 0.35
    ),

    annotate(
      "text",
      x = x,
      y = y + 1.05 * size,
      label = "N",
      size = TXT_NORTH,
      fontface = "bold"
    )
  )
}

line_scalebar_layers <- function(
  x_left,
  y,
  length_m = 6,
  text = "6 m"
) {

  list(

    annotate(
      "segment",
      x = x_left,
      xend = x_left + length_m,
      y = y,
      yend = y,
      linewidth = 0.55,
      color = "black"
    ),

    annotate(
      "segment",
      x = x_left,
      xend = x_left,
      y = y - 0.18,
      yend = y + 0.18,
      linewidth = 0.55,
      color = "black"
    ),

    annotate(
      "segment",
      x = x_left + length_m,
      xend = x_left + length_m,
      y = y - 0.18,
      yend = y + 0.18,
      linewidth = 0.55,
      color = "black"
    ),

    annotate(
      "text",
      x = x_left + length_m / 2,
      y = y + 0.48,
      label = text,
      size = TXT_SCALE
    )
  )
}

# ------------------------------------------------------------
# FIXED FUNCTION
# ------------------------------------------------------------
# Robust to any sf geometry-column name.
# It does not call sub$geometry.
# ------------------------------------------------------------

get_subplot_center <- function(
  x_sf,
  subplot_name
) {

  if (!("subplot" %in% names(x_sf))) {
    stop("The canopy layer does not contain the field 'subplot'.")
  }

  sub <- x_sf[
    as.character(x_sf$subplot) == subplot_name,
  ]

  if (nrow(sub) == 0) {
    stop(
      "Subplot not found: ",
      subplot_name
    )
  }

  bb_sub <- st_bbox(
    sub
  )

  center_x <- (
    as.numeric(bb_sub["xmin"]) +
      as.numeric(bb_sub["xmax"])
  ) / 2

  center_y <- (
    as.numeric(bb_sub["ymin"]) +
      as.numeric(bb_sub["ymax"])
  ) / 2

  c(
    x = center_x,
    y = center_y
  )
}

make_square_bbox <- function(
  center_x,
  center_y,
  size,
  crs_obj
) {

  center_x <- as.numeric(center_x)
  center_y <- as.numeric(center_y)
  size <- as.numeric(size)

  half <- size / 2

  poly <- st_polygon(
    list(
      matrix(
        c(
          center_x - half, center_y - half,
          center_x + half, center_y - half,
          center_x + half, center_y + half,
          center_x - half, center_y + half,
          center_x - half, center_y - half
        ),
        ncol = 2,
        byrow = TRUE
      )
    )
  )

  st_sfc(
    poly,
    crs = crs_obj
  )
}


# ------------------------------------------------------------
# DOTTED CONNECTOR HELPERS
# ------------------------------------------------------------
# These functions only define the geometry of the visual guide lines.
# They do not modify zoom windows, source boxes, map extent, CRS,
# legends, palettes, or any underlying spectral values.

bbox_center_xy <- function(bb) {
  c(
    x = (as.numeric(bb["xmin"]) + as.numeric(bb["xmax"])) / 2,
    y = (as.numeric(bb["ymin"]) + as.numeric(bb["ymax"])) / 2
  )
}

# Find the point where the line from the rectangle center toward a target
# reaches the rectangle boundary. This makes the connector start/end on
# the border rather than through the middle of either box.
rect_boundary_toward <- function(bb, target_xy) {

  cx <- (as.numeric(bb["xmin"]) + as.numeric(bb["xmax"])) / 2
  cy <- (as.numeric(bb["ymin"]) + as.numeric(bb["ymax"])) / 2

  dx <- as.numeric(target_xy["x"]) - cx
  dy <- as.numeric(target_xy["y"]) - cy

  if (abs(dx) < .Machine$double.eps && abs(dy) < .Machine$double.eps) {
    return(c(x = cx, y = cy))
  }

  tx <- Inf
  ty <- Inf

  if (abs(dx) >= .Machine$double.eps) {
    xedge <- if (dx > 0) as.numeric(bb["xmax"]) else as.numeric(bb["xmin"])
    tx <- (xedge - cx) / dx
  }

  if (abs(dy) >= .Machine$double.eps) {
    yedge <- if (dy > 0) as.numeric(bb["ymax"]) else as.numeric(bb["ymin"])
    ty <- (yedge - cy) / dy
  }

  candidates <- c(tx, ty)
  candidates <- candidates[is.finite(candidates) & candidates > 0]

  if (length(candidates) == 0) {
    return(c(x = cx, y = cy))
  }

  t <- min(candidates)

  c(
    x = cx + t * dx,
    y = cy + t * dy
  )
}

make_zoom_connector <- function(display_box, source_box_sfc, connector_id) {

  # display_box is a named numeric vector: xmin/xmax/ymin/ymax
  display_bb <- c(
    xmin = as.numeric(display_box["xmin"]),
    xmax = as.numeric(display_box["xmax"]),
    ymin = as.numeric(display_box["ymin"]),
    ymax = as.numeric(display_box["ymax"])
  )

  source_bb <- st_bbox(source_box_sfc)

  display_center <- bbox_center_xy(display_bb)
  source_center  <- bbox_center_xy(source_bb)

  p_display <- rect_boundary_toward(
    display_bb,
    source_center
  )

  p_source <- rect_boundary_toward(
    source_bb,
    display_center
  )

  data.frame(
    id = connector_id,
    x = as.numeric(p_display["x"]),
    y = as.numeric(p_display["y"]),
    xend = as.numeric(p_source["x"]),
    yend = as.numeric(p_source["y"])
  )
}

# Right connector fixed as a fully horizontal dotted guide.
# It starts at the LEFT edge of the displayed right inset and ends
# at the RIGHT edge of the source box in the crop. The y-position is
# taken from the vertical middle of the displayed inset, but clipped so
# that it always intersects the source box.
make_horizontal_right_connector <- function(display_box, source_box_sfc, connector_id) {

  display_bb <- c(
    xmin = as.numeric(display_box["xmin"]),
    xmax = as.numeric(display_box["xmax"]),
    ymin = as.numeric(display_box["ymin"]),
    ymax = as.numeric(display_box["ymax"])
  )

  source_bb <- st_bbox(source_box_sfc)

  y_display_mid <- (display_bb["ymin"] + display_bb["ymax"]) / 2

  y_line <- max(
    min(y_display_mid, as.numeric(source_bb["ymax"])),
    as.numeric(source_bb["ymin"])
  )

  data.frame(
    id   = connector_id,
    x    = as.numeric(display_bb["xmin"]),
    y    = as.numeric(y_line),
    xend = as.numeric(source_bb["xmax"]) - 2.32,
    yend = as.numeric(y_line)
  )
}

build_zoom_plot <- function(
  box_sfc,
  canopy_sf,
  raster_obj,
  pixel_limits,
  pixel_palette
) {

  box_sf <- st_as_sf(
    box_sfc
  )

  canopy_box <- suppressWarnings(
    st_intersection(
      canopy_sf,
      box_sf
    )
  )

  if (nrow(canopy_box) == 0) {
    stop("Zoom window does not intersect canopy polygons.")
  }

  bb_box <- st_bbox(
    box_sfc
  )

  r_crop <- crop(
    raster_obj,
    ext(
      as.numeric(bb_box["xmin"]),
      as.numeric(bb_box["xmax"]),
      as.numeric(bb_box["ymin"]),
      as.numeric(bb_box["ymax"])
    )
  )

  # soil excluded: mask only with canopy objects
  r_mask <- mask(
    r_crop,
    vect(canopy_box)
  )

  pix_df <- as.data.frame(
    r_mask,
    xy = TRUE,
    na.rm = TRUE
  )

  if (ncol(pix_df) < 3) {
    stop("Could not create pixel data for zoom.")
  }

  names(pix_df)[3] <- "ndvi"

  ggplot() +

    geom_raster(
      data = pix_df,
      aes(
        x = x,
        y = y,
        fill = ndvi
      )
    ) +

    geom_sf(
      data = canopy_box,
      fill = NA,
      color = "grey10",
      linewidth = 0.22,
      inherit.aes = FALSE
    ) +

    scale_fill_gradientn(
      colours = pixel_palette,
      limits = pixel_limits,
      oob = squish,
      guide = "none"
    ) +

    coord_sf(
      crs = st_crs(32618),
      default_crs = st_crs(32618),
      datum = st_crs(32618),
      xlim = c(
        as.numeric(bb_box["xmin"]),
        as.numeric(bb_box["xmax"])
      ),
      ylim = c(
        as.numeric(bb_box["ymin"]),
        as.numeric(bb_box["ymax"])
      ),
      expand = FALSE
    ) +

    theme_void() +

    theme(
      panel.border = element_rect(
        color = "#17365D",
        fill = NA,
        linewidth = 0.85
      ),

      panel.background = element_rect(
        fill = "white",
        color = NA
      ),

      plot.background = element_rect(
        fill = "white",
        color = NA
      ),

      plot.margin = margin(
        0,
        0,
        0,
        0
      )
    )
}

# ------------------------------------------------------------
# 8. COMMON EXTENT + UTM BREAKS
# ------------------------------------------------------------

bb <- st_bbox(
  canopy_sf
)

xmin <- as.numeric(bb["xmin"])
xmax <- as.numeric(bb["xmax"])
ymin <- as.numeric(bb["ymin"])
ymax <- as.numeric(bb["ymax"])

dx <- xmax - xmin
dy <- ymax - ymin

xlim_common <- c(
  xmin - 0.055 * dx,
  xmax + 0.040 * dx
)

ylim_common <- c(
  ymin - 0.165 * dy,
  ymax + 0.075 * dy
)

x_breaks <- seq(
  floor(xlim_common[1] / 10) * 10,
  ceiling(xlim_common[2] / 10) * 10,
  by = 10
)

x_breaks <- x_breaks[
  x_breaks >= xlim_common[1] &
    x_breaks <= xlim_common[2]
]

y_breaks <- seq(
  floor(ylim_common[1] / 5) * 5,
  ceiling(ylim_common[2] / 5) * 5,
  by = 5
)

y_breaks <- y_breaks[
  y_breaks >= ylim_common[1] &
    y_breaks <= ylim_common[2]
]

utm_labels <- label_number(
  accuracy = 1,
  big.mark = ",",
  decimal.mark = "."
)

# ------------------------------------------------------------
# 9. COMMON NORTH + SCALE POSITIONS
# ------------------------------------------------------------

north_x <- xlim_common[1] + 0.045 * diff(xlim_common)
north_y <- ylim_common[2] - 0.095 * diff(ylim_common)

scale_x <- xmin + 0.20
scale_y <- ymin - 0.105 * dy

# ------------------------------------------------------------
# 10. PANEL (a)
# ------------------------------------------------------------
# Updated only to fine-tune subplot callouts and N-treatment labels.
# All cartographic settings (extent, CRS, north arrow, scale, colours)
# remain unchanged.

pa_box_df <- data.frame(
  subplot = factor(c("P1", "P2", "P3", "P4", "P5"),
                   levels = levels(canopy_sf$subplot)),
  x = c(412763.05, 412766.15, 412759.45, 412753.55, 412743.55),
  y = c(501787.10, 501778.72, 501775.55, 501772.62, 501778.88),
  label = c("P1", "P2", "P3", "P4", "P5")
)

pa_treatment_df <- data.frame(
  x = c(412763.05, 412766.15, 412759.45, 412753.55, 412743.55),
  y = c(501785.90, 501777.18, 501774.02, 501771.05, 501777.22),
  label = c(
    "0~kg~N~ha^{-1}",
    "100~kg~N~ha^{-1}",
    "200~kg~N~ha^{-1}",
    "300~kg~N~ha^{-1}",
    "400~kg~N~ha^{-1}"
  )
)

pa_leader_df <- data.frame(
  x = c(
    412764.35,
    412764.05, 412764.05,
    412757.25, 412757.25,
    412751.45, 412751.45,
    412741.35, 412741.35
  ),
  y = c(
    501786.95,
    501778.72, 501778.72,
    501775.68, 501775.68,
    501772.76, 501772.76,
    501778.88, 501778.88
  ),
  xend = c(
    412766.42,
    412766.00, 412762.25,
    412758.95, 412755.72,
    412753.05, 412749.82,
    412742.95, 412741.05
  ),
  yend = c(
    501784.72,
    501778.72, 501780.42,
    501775.68, 501778.10,
    501772.76, 501775.42,
    501778.88, 501773.38
  )
)

PA_BOX_TEXT_SIZE <- 4.9
PA_TREAT_TEXT_SIZE <- 3.4
PA_BOX_LABEL_PADDING <- unit(0.28, "lines")
PA_TREAT_LABEL_PADDING <- unit(0.10, "lines")
PA_BOX_LABEL_R <- unit(0.24, "lines")
PA_TREAT_LABEL_R <- unit(0.05, "lines")
PA_LEADER_LWD <- 0.42

pA <- ggplot() +

  geom_sf(
    data = canopy_sf,
    aes(fill = subplot),
    color = NA,
    linewidth = 0
  ) +

  scale_fill_manual(
    values = subplot_cols,
    guide = "none"
  ) +

  geom_segment(
    data = pa_leader_df,
    aes(x = x, y = y, xend = xend, yend = yend),
    inherit.aes = FALSE,
    linewidth = PA_LEADER_LWD,
    colour = "black",
    lineend = "round"
  ) +

  # Coloured border for each P1-P5 label box.
  # A second black text layer is drawn on top so the text itself
  # remains black while the border preserves the subplot colour.
  geom_label(
    data = pa_box_df,
    aes(x = x, y = y, label = label, colour = subplot),
    inherit.aes = FALSE,
    fill = "grey97",
    size = PA_BOX_TEXT_SIZE,
    fontface = "bold",
    label.size = 0.42,
    label.padding = PA_BOX_LABEL_PADDING,
    label.r = PA_BOX_LABEL_R,
    show.legend = FALSE
  ) +

  geom_text(
    data = pa_box_df,
    aes(x = x, y = y, label = label),
    inherit.aes = FALSE,
    colour = "black",
    size = PA_BOX_TEXT_SIZE,
    fontface = "bold",
    show.legend = FALSE
  ) +

  geom_label(
    data = pa_treatment_df,
    aes(x = x, y = y, label = label),
    inherit.aes = FALSE,
    parse = TRUE,
    fill = "white",
    colour = "black",
    size = PA_TREAT_TEXT_SIZE,
    fontface = "plain",
    label.size = 0,
    label.padding = PA_TREAT_LABEL_PADDING,
    label.r = PA_TREAT_LABEL_R,
    show.legend = FALSE
  ) +

  scale_colour_manual(
    values = subplot_cols,
    guide = "none"
  ) +

  north_arrow_layers(
    x = north_x,
    y = north_y,
    size = 1.0
  ) +

  line_scalebar_layers(
    x_left = scale_x,
    y = scale_y,
    length_m = 6,
    text = "6 m"
  ) +

  coord_sf(
    crs = st_crs(32618),
    default_crs = st_crs(32618),
    datum = st_crs(32618),
    xlim = xlim_common,
    ylim = ylim_common,
    expand = FALSE,
    clip = "on"
  ) +

  scale_x_continuous(
    breaks = x_breaks,
    labels = utm_labels
  ) +

  scale_y_continuous(
    breaks = y_breaks,
    labels = utm_labels
  ) +

  labs(
    x = "Easting (m)",
    y = "Northing (m)"
  ) +

  theme_map_pub()

# ------------------------------------------------------------
# 11. PANEL (b): MEAN NDVI + PIXEL ZOOMS
# ------------------------------------------------------------

# Common spectral palette for NDVI, MSAVI and WDRVI.
# Same direction for all indices: relatively low = blue,
# relatively high = red. Saturation is intentionally moderated
# so small within-index differences are not visually overstated.
ndvi_palette <- c(
  "#355C9A",
  "#6F8FB8",
  "#8FB8CA",
  "#B9D9D2",
  "#DDE8C4",
  "#F5E6A1",
  "#F6C777",
  "#F6B35F",
  "#E98A4A",
  "#D95D45",
  "#B83A3A"
)

# robust mean-object display range
mean_limits <- as.numeric(
  quantile(
    canopy_sf$ndvi_mean,
    probs = c(0.05, 0.95),
    na.rm = TRUE
  )
)

if (!all(is.finite(mean_limits)) || diff(mean_limits) <= 0) {
  mean_limits <- range(
    canopy_sf$ndvi_mean,
    na.rm = TRUE
  )
}

# Uniform legend structure:
# mean-object scales always use 5 equally spaced ticks.
mean_breaks <- seq(
  mean_limits[1],
  mean_limits[2],
  length.out = 5
)

# zoom centers — corrected function used here
center_p4 <- get_subplot_center(
  canopy_sf,
  "P4"
)

center_p1 <- get_subplot_center(
  canopy_sf,