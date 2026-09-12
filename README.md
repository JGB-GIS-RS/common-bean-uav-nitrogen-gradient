# Common Bean UAV Nitrogen Gradient

This repository contains the analysis-ready dataset associated with a multitemporal UAV study of common bean (*Phaseolus vulgaris* L.) grown under a nitrogen fertilization gradient.

The repository is intended to provide reviewers and readers with a clear, compact, and reproducible description of the final dataset used for statistical analysis and figure generation.

## Study overview

Five nitrogen rates were evaluated in adjacent field subplots:

| Subplot | N rate (kg N ha⁻¹) |
|---|---:|
| P1 | 0 |
| P2 | 100 |
| P3 | 200 |
| P4 | 300 |
| P5 | 400 |

UAV observations were acquired at five crop growth stages:

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
│   └── common_bean_uav_master_dataset.csv
└── docs/
    └── data_dictionary.md
```

## Main dataset

The analysis-ready dataset is available at:

`data/common_bean_uav_master_dataset.csv`

Each row represents one **subplot × UAV flight** observation.

The dataset therefore contains:

- 5 subplots
- 5 UAV flights
- 25 subplot × flight records

The spectral and canopy variables are repeated measurements through time.

### Important statistical note

The experiment contains one subplot for each nitrogen rate. Therefore, nitrogen treatments are **not independently replicated**.

The dataset should be interpreted as an **exploratory field nitrogen gradient**, rather than as a replicated fertilizer trial suitable for conventional treatment-level causal inference.

Similarly, grain yield was measured once at final harvest for each subplot. The same final harvest value is repeated across the five UAV-flight rows belonging to that subplot only to maintain a rectangular longitudinal dataset.

Consequently:

- there are 25 spectral/structural observations;
- there are only 5 independent final-harvest observations;
- repeated yield values must not be treated as 25 independent yield measurements.

## Grain yield calculation

Grain yield is expressed relative to the harvested ground area:

`Y = (M_g / A_h) × 10`

where:

- `Y` = grain yield (t ha⁻¹),
- `M_g` = harvested grain mass (kg),
- `A_h` = harvested ground area (m²).

The harvested area was 40 m² for each subplot.

Projected canopy area (`canopy_area_m2`) is a UAV-derived structural variable and is **not** used as the denominator for agronomic grain-yield calculation.

## Canopy objects

`canopy_polygon_count` represents the number of segmented canopy objects in each subplot at each acquisition date.

It should **not** be interpreted as plant count. As the crop developed, neighboring plant canopies progressively merged into larger connected canopy objects.

## Variables

The master dataset contains the following fields:

`flight`, `date`, `growth_stage`, `subplot`, `N_rate_kg_ha`, `canopy_area_m2`, `canopy_polygon_count`, `NDVI_mean`, `MSAVI_mean`, `WDRVI_mean`, `harvest_area_m2`, `harvested_grain_kg`, and `grain_yield_t_ha`.

A complete description is provided in:

`docs/data_dictionary.md`

## Data-use guidance

The dataset is suitable for:

- descriptive multitemporal analysis;
- visualization of canopy development;
- within-date comparison across the nitrogen gradient;
- exploratory associations between UAV-derived variables and final grain yield.

Because nitrogen rates were not replicated, treatment-response relationships should not be interpreted as confirmatory causal effects or generalized fertilizer recommendations.

## Citation

If you use these data, please cite the associated manuscript when available.

Repository citation details can be updated after publication or DOI registration.