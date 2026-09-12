# Common Bean UAV Nitrogen Gradient

This repository contains the analysis-ready dataset and R scripts associated with a multitemporal UAV study of common bean (*Phaseolus vulgaris* L.) grown under a nitrogen fertilization gradient.

It provides a transparent workflow linking final spatial products, canopy statistics, field harvest data, and the canonical dataset used for statistical analysis and figure generation.

## Associated manuscript

**Provisional title:**  
*Multitemporal UAV Monitoring of Common Bean under a Nitrogen Fertilization Gradient: Implications for Sustainable Nutrient Management*

Bibliographic details and DOI will be added after publication.

## Study design

The field study was conducted with the common-bean cultivar **Calima**, sown on **21 August 2024**.

The experimental area comprised five adjacent field subplots of **40 m² each**, with one nitrogen rate assigned to each subplot:

| Subplot | N rate (kg N ha⁻¹) |
|---|---:|
| P1 | 0 |
| P2 | 100 |
| P3 | 200 |
| P4 | 300 |
| P5 | 400 |

Because each nitrogen rate was represented by a single subplot, the nitrogen treatments were **not independently replicated**. The study should therefore be interpreted as an **exploratory field nitrogen gradient**, rather than as a replicated fertilizer experiment for confirmatory treatment-level inference.

## UAV acquisitions

| Flight | Date | Growth stage |
|---|---|---|
| 1 | 2024-09-07 | V4 |
| 2 | 2024-09-14 | R5 |
| 3 | 2024-10-02 | R6 |
| 4 | 2024-10-09 | R7 |
| 5 | 2024-10-16 | R8 |

The UAV platform was a DJI Phantom 3 Professional equipped with a MAPIR Survey2 Red/NIR camera. Final analysis variables include projected canopy area and mean canopy values of NDVI, MSAVI, and WDRVI.

## Repository structure

```text
common-bean-uav-nitrogen-gradient/
│
├── README.md
├── data/
│   ├── common_bean_uav_master_dataset.csv
│   └── field/
│       └── harvest_data.csv
├── derived/
│   ├── canopy_summary_by_subplot.csv
│   ├── qa_canopy_geopackages.csv
│   └── qa_spatial_extraction.csv
├── scripts/
│   ├── 00_build_canopy_geopackages.R
│   ├── 01_extract_canopy_statistics.R
│   └── 02_build_master_dataset.R
└── docs/
    └── data_dictionary.md
```

## Data access

- [Analysis-ready master dataset](data/common_bean_uav_master_dataset.csv)
- [Final harvest data](data/field/harvest_data.csv)
- [Validated canopy summary](derived/canopy_summary_by_subplot.csv)
- [Spatial extraction QA](derived/qa_spatial_extraction.csv)
- [GeoPackage QA](derived/qa_canopy_geopackages.csv)
- [Data dictionary](docs/data_dictionary.md)

## Spatial inputs

The extraction script expects the final spatial products under `data/spatial/flight01` through `flight05`, with three GeoTIFF index rasters and one canopy GeoPackage per flight.

Because these spatial files are substantially larger than the tabular data and code, they are not currently tracked in this GitHub repository. A permanent external archive link will be added before manuscript submission.

## Reproducible workflow

```text
Final NDVI / MSAVI / WDRVI rasters
                +
        Canopy GeoPackages
                ↓
01_extract_canopy_statistics.R
                ↓
derived/canopy_summary_by_subplot.csv
                +
     data/field/harvest_data.csv
                ↓
02_build_master_dataset.R
                ↓
data/common_bean_uav_master_dataset.csv
```

`00_build_canopy_geopackages.R` is an optional preparation utility used to consolidate the five subplot canopy shapefiles for each flight into a single GeoPackage.

The spatial workflow was validated by checking feature counts, canopy-area preservation, raster coverage, and numerical agreement between the regenerated canopy summary and the canonical master dataset.

## Statistical structure

Each row of the master dataset represents one **subplot × UAV flight** observation.

The dataset contains 5 subplots, 5 UAV flights, and 25 subplot × flight records. Spectral and canopy variables are repeated measurements through time.

Grain yield was measured once at final harvest for each subplot. The same final-harvest value is repeated across the five UAV-flight rows belonging to that subplot only to maintain a rectangular longitudinal dataset.

Consequently:

- there are **25 spectral/structural observations**;
- there are only **5 independent final-harvest observations**;
- repeated yield values must **not** be treated as 25 independent yield measurements.

## Grain-yield calculation

Grain yield is expressed relative to harvested ground area:

`Y = (M_g / A_h) × 10`

where:

- `Y` = grain yield (t ha⁻¹);
- `M_g` = harvested grain mass (kg);
- `A_h` = harvested ground area (m²).

The harvested ground area was **40 m² for each subplot**.

Projected canopy area (`canopy_area_m2`) is a UAV-derived structural variable and is **not** used as the denominator for agronomic grain-yield calculation.

## Canopy variables

`canopy_area_m2` is the total projected canopy area segmented within each subplot at each UAV acquisition date.

`canopy_polygon_count` is the number of segmented canopy objects within the subplot. It should **not** be interpreted as plant count because neighboring plant canopies progressively merged during crop development.

## Variables

The canonical dataset contains:

`flight`, `date`, `growth_stage`, `subplot`, `N_rate_kg_ha`, `canopy_area_m2`, `canopy_polygon_count`, `NDVI_mean`, `MSAVI_mean`, `WDRVI_mean`, `harvest_area_m2`, `harvested_grain_kg`, and `grain_yield_t_ha`.

A complete description is provided in the [data dictionary](docs/data_dictionary.md).

## Recommended use

The dataset is appropriate for descriptive multitemporal analysis, visualization of canopy development, within-date comparison across the nitrogen gradient, and exploratory associations between UAV-derived variables and final grain yield.

Because the nitrogen rates were not independently replicated, treatment-response relationships should not be interpreted as confirmatory causal effects or generalized fertilizer recommendations.

## Citation

If you use these data, please cite the associated manuscript when available.

Repository citation details will be updated after publication or DOI registration.
