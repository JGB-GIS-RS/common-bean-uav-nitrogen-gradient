# Common Bean UAV Nitrogen Gradient

This repository contains the analysis-ready dataset and R scripts associated with a multitemporal UAV study of common bean (*Phaseolus vulgaris* L.) grown under a nitrogen fertilization gradient.

It provides a transparent workflow linking final spatial products, canopy statistics, field harvest data, the canonical analysis dataset, descriptive statistics, stage-specific UAV–yield associations, and manuscript figures.

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

Nitrogen was applied on **30 August 2024**. All UAV acquisitions therefore occurred after fertilization.

| Flight | Date | Growth stage | Days after N application |
|---|---|---|---:|
| 1 | 2024-09-07 | V4 | 8 |
| 2 | 2024-09-14 | R5 | 15 |
| 3 | 2024-10-02 | R6 | 33 |
| 4 | 2024-10-09 | R7 | 40 |
| 5 | 2024-10-16 | R8 | 47 |

The UAV platform was a DJI Phantom 3 Professional equipped with a MAPIR Survey2 Red/NIR camera. Final analysis variables include projected canopy area and mean canopy values of NDVI, MSAVI, and WDRVI.

## Repository structure

```text
common-bean-uav-nitrogen-gradient/
│
├── README.md
├── data/
│   ├── common_bean_uav_master_dataset.csv
│   ├── field/
│   │   └── harvest_data.csv
│   └── spatial/
│       ├── flight01/
│       ├── flight02/
│       ├── flight03/
│       ├── flight04/
│       └── flight05/
│
├── derived/
│   ├── canopy_statistics_by_subplot_index.csv
│   ├── canopy_summary_by_subplot.csv
│   ├── descriptive_analysis_notes.txt
│   ├── descriptive_summary_by_flight.csv
│   ├── exploratory_N_associations_by_flight.csv
│   ├── exploratory_N_yield_association.csv
│   ├── exploratory_yield_associations_by_flight.csv
│   ├── final_harvest_by_subplot.csv
│   ├── qa_canopy_geopackages.csv
│   └── qa_spatial_extraction.csv
│
├── scripts/
│   ├── 00_build_canopy_geopackages.R
│   ├── 01_extract_canopy_statistics.R
│   ├── 02_build_master_dataset.R
│   ├── 03_descriptive_analysis.R
│   ├── 04_figure_3_spatial_characterization_R6.R
│   ├── 05_figure_4_multitemporal_uav_metrics.R
│   ├── 06_figure_5_uav_yield_correlations.R
│   └── 07_figure_6_final_grain_yield.R
│
├── figures/
│   └── [generated locally; not currently tracked]
│
└── docs/
    └── data_dictionary.md
```

The `data/spatial/` directories describe the expected local project structure. The large spatial files are not currently tracked in GitHub; see **Spatial inputs** below.

## Data access

- [Analysis-ready master dataset](data/common_bean_uav_master_dataset.csv)
- [Final harvest data](data/field/harvest_data.csv)
- [Validated canopy summary](derived/canopy_summary_by_subplot.csv)
- [Spatial extraction QA](derived/qa_spatial_extraction.csv)
- [GeoPackage QA](derived/qa_canopy_geopackages.csv)
- [Descriptive summaries by flight](derived/descriptive_summary_by_flight.csv)
- [Stage-specific UAV–yield associations](derived/exploratory_yield_associations_by_flight.csv)
- [Final harvest by subplot](derived/final_harvest_by_subplot.csv)
- [Descriptive-analysis notes](derived/descriptive_analysis_notes.txt)
- [Data dictionary](docs/data_dictionary.md)

## Spatial inputs

The spatial-processing scripts expect the final products under `data/spatial/flight01` through `flight05`.

For each flight, the workflow uses:

- canopy polygons, either as the original subplot shapefiles or as the consolidated canopy GeoPackage;
- NDVI GeoTIFF;
- MSAVI GeoTIFF;
- WDRVI GeoTIFF.

Because these spatial files are substantially larger than the tabular data and code, they are not currently tracked in this GitHub repository. A permanent external archive link can be added before final publication if the spatial products are deposited separately.

## Reproducible workflow

The scripts are numbered according to the recommended execution order.

```text
Original canopy shapefiles by subplot
                ↓
00_build_canopy_geopackages.R
                ↓
Consolidated canopy GeoPackage for each flight
                +
Final NDVI / MSAVI / WDRVI rasters
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
                ↓
03_descriptive_analysis.R
                ↓
Descriptive summaries + stage-specific exploratory associations
                ↓
        ┌──────────────────────┬──────────────────────┬──────────────────────┬──────────────────────┐
        ↓                      ↓                      ↓                      ↓
04_figure_3_             05_figure_4_            06_figure_5_            07_figure_6_
spatial_                  multitemporal_           uav_yield_              final_grain_
characterization_R6.R     uav_metrics.R            correlations.R           yield.R
        ↓                      ↓                      ↓                      ↓
Manuscript Figure 3      Manuscript Figure 4      Manuscript Figure 5      Manuscript Figure 6
```

### Script descriptions

| Script | Purpose | Main input(s) | Main output(s) |
|---|---|---|---|
| `00_build_canopy_geopackages.R` | Optional preparation step that consolidates P1–P5 canopy shapefiles into one GeoPackage per UAV flight and validates feature counts and area preservation. | Subplot canopy shapefiles | `canopy_YYYYMMDD.gpkg`; `derived/qa_canopy_geopackages.csv` |
| `01_extract_canopy_statistics.R` | Extracts subplot-level projected canopy area and spectral-index statistics from final NDVI, MSAVI and WDRVI rasters within the segmented canopy. | Canopy GeoPackages; NDVI/MSAVI/WDRVI rasters | `derived/canopy_statistics_by_subplot_index.csv`; `derived/canopy_summary_by_subplot.csv`; `derived/qa_spatial_extraction.csv` |
| `02_build_master_dataset.R` | Joins canopy summaries with harvest data and constructs the canonical 25-row longitudinal dataset. | Canopy summary; harvest data | `data/common_bean_uav_master_dataset.csv` |
| `03_descriptive_analysis.R` | Produces descriptive summaries, exploratory associations with N rate, stage-specific UAV–yield correlations, and the final harvest table. | Canonical master dataset | Analytical tables and notes in `derived/` |
| `04_figure_3_spatial_characterization_R6.R` | Reproduces manuscript Figure 3: R6 canopy segmentation and spatial NDVI, MSAVI and WDRVI characterization. | R6 canopy GeoPackage and spectral rasters | Manuscript Figure 3 |
| `05_figure_4_multitemporal_uav_metrics.R` | Reproduces manuscript Figure 4: multitemporal projected canopy area and mean NDVI, MSAVI and WDRVI trajectories from V4 to R8. | Canonical master dataset | `figures/Figure_4_multitemporal_UAV_response.png` |
| `06_figure_5_uav_yield_correlations.R` | Reproduces manuscript Figure 5: heatmap of stage-specific exploratory Pearson correlations between UAV-derived metrics and final grain yield. | `derived/exploratory_yield_associations_by_flight.csv` | `figures/Figure_5_UAV_yield_associations.png` |
| `07_figure_6_final_grain_yield.R` | Reproduces manuscript Figure 6: observed final grain yield for the five subplot/N-rate combinations. | Canonical master dataset | `figures/Figure_6_final_grain_yield.png` |

`00_build_canopy_geopackages.R` is optional when the consolidated GeoPackages are already available. Scripts `01`–`03` form the principal data-to-analysis chain. Scripts `04`–`07` reproduce manuscript Figures 3–6. The analytical and quality-assurance outputs generated by scripts `00`–`03` are tracked in `derived/`, including the stage-specific UAV–yield association table used by Figure 5.

## Software requirements

The workflow is implemented in R. Depending on the script, the following packages are required:

- `terra`
- `ggplot2`
- `patchwork`
- `sf`
- `dplyr`
- `cowplot`
- `scales`

Base R is used for tabular data handling and the stage-specific descriptive/correlation calculations where possible. Each script checks or loads the packages needed for its own task.

## Statistical structure

Each row of the master dataset represents one **subplot × UAV flight** observation.

The dataset contains 5 subplots, 5 UAV flights, and 25 subplot × flight records. Spectral and canopy variables are repeated measurements through time.

Grain yield was measured once at final harvest for each subplot. The same final-harvest value is repeated across the five UAV-flight rows belonging to that subplot only to maintain a rectangular longitudinal dataset.

Consequently:

- there are **25 spectral/structural observations**;
- there are only **5 independent final-harvest observations**;
- repeated yield values must **not** be treated as 25 independent yield measurements;
- nitrogen rates must **not** be treated as independently replicated treatments.

For this reason, `03_descriptive_analysis.R` intentionally emphasizes descriptive summaries and stage-specific exploratory associations. It does not use the 25 repeated rows as independent yield observations and is not intended to estimate a causal fertilizer dose–response relationship or an optimal N rate.

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

Mean NDVI, MSAVI and WDRVI values are calculated from valid raster pixels located within the segmented canopy regions for each subplot and acquisition date.

## Variables

The canonical dataset contains:

`flight`, `date`, `growth_stage`, `subplot`, `N_rate_kg_ha`, `canopy_area_m2`, `canopy_polygon_count`, `NDVI_mean`, `MSAVI_mean`, `WDRVI_mean`, `harvest_area_m2`, `harvested_grain_kg`, and `grain_yield_t_ha`.

A complete description is provided in the [data dictionary](docs/data_dictionary.md).

## Recommended use

The dataset and scripts are appropriate for:

- descriptive multitemporal analysis of canopy development;
- visualization of structural and spectral trajectories from V4 to R8;
- within-date descriptive comparison across the field nitrogen gradient;
- exploratory stage-specific associations between UAV-derived variables and final grain yield;
- reproduction of the manuscript's analytical figures.

Because the nitrogen rates were not independently replicated, treatment-response relationships should not be interpreted as confirmatory causal effects, statistically validated fertilizer optima, or generalized fertilizer recommendations.

## Reproducible R environment

The computational environment was captured with `renv` from the local R
installation used for the manuscript workflow (R 4.4.1 on Windows 11). The repository includes
instructions in [docs/reproducibility.md](docs/reproducibility.md).

The repository includes `renv.lock` and `sessionInfo.txt`, captured from
the local R environment used for the manuscript workflow. A third party can
restore the recorded package versions with:

```r
install.packages("renv")
renv::restore()
```

## License

R source code in `scripts/` is licensed under the MIT License; see
[LICENSE](LICENSE).

Data tables, derived analytical outputs, and documentation are licensed under
the Creative Commons Attribution 4.0 International License (CC BY 4.0), unless
otherwise stated; see [LICENSE-DATA.md](LICENSE-DATA.md).

## Citation

If you use these data or scripts, please cite the associated manuscript when available.

Repository citation details will be updated after publication or DOI registration.
