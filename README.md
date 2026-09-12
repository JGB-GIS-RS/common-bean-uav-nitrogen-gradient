# Common Bean UAV Nitrogen Gradient

This repository contains the analysis-ready dataset associated with a multitemporal UAV study of common bean (*Phaseolus vulgaris* L.) grown under a nitrogen fertilization gradient.

It provides a transparent and compact description of the final dataset used for statistical analysis and figure generation.

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

## Data access

- [Download the analysis-ready master dataset](data/common_bean_uav_master_dataset.csv)
- [View the data dictionary](docs/data_dictionary.md)

Each row of the master dataset represents one **subplot × UAV flight** observation.

The dataset therefore contains:

- 5 subplots;
- 5 UAV flights;
- 25 subplot × flight records.

The spectral and canopy variables are repeated measurements through time.

## Statistical structure

Grain yield was measured once at final harvest for each subplot. The same final-harvest value is repeated across the five UAV-flight rows belonging to that subplot only to maintain a rectangular longitudinal dataset.

Consequently:

- there are **25 spectral/structural observations**;
- there are only **5 independent final-harvest observations**;
- repeated yield values must **not** be treated as 25 independent yield measurements.

This distinction should be preserved in any statistical analysis using the dataset.

## Grain-yield calculation

Grain yield is expressed relative to the harvested ground area:

`Y = (M_g / A_h) × 10`

where:

- `Y` = grain yield (t ha⁻¹);
- `M_g` = harvested grain mass (kg);
- `A_h` = harvested ground area (m²).

The harvested ground area was **40 m² for each subplot**.

Projected canopy area (`canopy_area_m2`) is a UAV-derived structural variable and is **not** used as the denominator for agronomic grain-yield calculation.

## Canopy-area and canopy-object variables

`canopy_area_m2` represents the total projected canopy area segmented within each subplot at each UAV acquisition date.

`canopy_polygon_count` represents the number of segmented canopy objects within the subplot. It should **not** be interpreted as plant count, because neighboring plant canopies progressively merged into larger connected objects during crop development.

## Variables

The master dataset contains the following fields:

`flight`, `date`, `growth_stage`, `subplot`, `N_rate_kg_ha`, `canopy_area_m2`, `canopy_polygon_count`, `NDVI_mean`, `MSAVI_mean`, `WDRVI_mean`, `harvest_area_m2`, `harvested_grain_kg`, and `grain_yield_t_ha`.

A complete description of the variables, units, and interpretation is provided in the [data dictionary](docs/data_dictionary.md).

## Recommended use

The dataset is appropriate for:

- descriptive multitemporal analysis;
- visualization of canopy development;
- within-date comparison across the nitrogen gradient;
- exploratory associations between UAV-derived variables and final grain yield.

Because the nitrogen rates were not independently replicated, treatment-response relationships should not be interpreted as confirmatory causal effects or generalized fertilizer recommendations.

## Citation

If you use these data, please cite the associated manuscript when available.

Repository citation details will be updated after publication or DOI registration.