# SIECCLongWeather

`SIECCLongWeather` is the reviewer-facing R implementation of the validated SIECC Israel long-term weather analysis. It covers calendar years 1950–2025 (N=76) and December–February winters 1950/51–2024/25 (N=75). The final metrics are Copernicus/ERA5 air temperature, IMS air temperature, Copernicus/ERA5 relative humidity, UTCI, MRT, and IMS rainfall total. Official source providers are the Israel Meteorological Service and the Copernicus Climate Change Service/ECMWF.

The package reproduces the frozen national series, descriptive and inferential results, four-panel annual and DJF figures, figure CSV companions, traceability records, and Word companions. The historical production lineage was a validated R 4.4.2/Python 3.13.3 hybrid; the public reviewer interface is R-first and reproduces that validated mathematics. R 4.4.3 is a later publication/rendering compatibility lineage, not the creator of the frozen numerical authority.

## Quick demo

```r
library(SIECCLongWeather)
run_demo()
```

No credentials or downloads are needed. The demo exercises known-answer area weighting, DJF assignment, temperature anomalies, rainfall ratios, the one-time study-specific calibration, statistics, tables, figures, CSV companions, and traceability.

## Installation

```r
install.packages("SIECCLongWeather_1.0.0.tar.gz", repos = NULL, type = "source")
library(SIECCLongWeather)
```

Or from GitHub:

```r
remotes::install_github("ngngn1977-cloud/SIECCLongWeather@v1.0.0")
```

Use `renv::restore()` when reproducing the archived development environment. Production authority: R 4.4.2. Later compatibility is recorded separately.

Validated on R 4.4.2 (reference lineage) and R 4.4.3.

## Statistical reproduction

```r
x <- reproduce_statistics()
x$PUBLICATION_REPRODUCTION
```

This fast reviewer path starts from hash-verified frozen annual/DJF national series. HAC/Newey–West is primary; modified Mann–Kendall is the autocorrelation-adjusted non-parametric sensitivity. Ordinary Mann–Kendall is legacy/reference only.

## Full reproduction

```r
reproduce_all()
```

Without licensed raw inputs, this runs all reproducible publication stages from compact frozen processed inputs and reports `PUBLIC_FULL_REACQUISITION_REQUIRES_PROVIDER_ACCESS`. A standardized source bundle can be supplied for the source-to-national pathway. Rainfall method selection is closed: climatology-aided precipitation ratios, dense year-specific QC-complete IMS network, fixed grid, IDW p=2, and exactly one study-specific calibration.

## Data access

See `docs/DATA_ACCESS_IMS.md`, `docs/DATA_ACCESS_COPERNICUS.md`, and `DATA_SOURCE_AND_LICENSE_MANIFEST.csv`. Live downloads are never substituted for frozen inputs. Raw IMS station observations are not included and must be obtained from IMS under its terms. The derived national annual and December-February IMS aggregates (temperature, rainfall) are included with attribution; see `DATA_RIGHTS.md`.

### Required attribution

- Contains data derived from the Israel Meteorological Service (IMS) station observations; (c) IMS.
- Contains modified Copernicus Climate Change Service information [2026]; neither the European Commission nor ECMWF is responsible for any use of this information.

Dataset citations: Hersbach et al. (2020), ERA5 (DOI 10.24381/cds.f17050d7); Di Napoli et al. (2021), ERA5-HEAT (DOI 10.24381/cds.553b7518); Israel Meteorological Service (IMS) database, https://ims.gov.il.

## Figure output standard

Every analytical figure supplies IMAGE + DOCX + CSV. Publication figures additionally supply PDF and SVG. Multipanel DOCX files place each panel image in its own borderless table cell, with a separate panel-letter cell immediately below it.

## Validation

```r
verify_publication_inputs()
validate_against_publication()
```

Validation reports reference/reproduced values, absolute and relative differences, tolerance, and status for series, statistics, descriptives, and figure data.

Internal validation labels in the reference files (e.g. MISSION3) are historical stage names and are kept for byte-identity with the sealed reference values.

The secret, privacy and path scan reports are not stored in the repository. Regenerate them with `Rscript scripts/run_repository_scans.R`.

## External benchmark status

Temperature is concordant. RH direction is externally supported but exact national magnitude lacks a definition-matched benchmark. UTCI is concordant with caveat. No matched Israel-specific national MRT trend benchmark was found. Rainfall change/timing is concordant with caveats; absolute DJF depths differ because spatial domains and area weighting are non-equivalent.

## Known limitations

- IMS RH is not qualified: only Beer Sheva and Negba continuously cover 1950–2025, which is not nationally representative.
- IMS rainy-day count is not qualified because national/regional spatial representation failed.
- IMS daily temperature is `(TX + TN) / 2`, not a 24-hourly mean.
- The rainfall multiplier is a study-specific grid-domain calibration to 415.438229 mm, not an IMS standard or universal constant.
- Raw-provider reacquisition requires accounts, credentials, and provider authorization; live products may change.

## Citation

Use `citation("SIECCLongWeather")`.

Gabinet, N. M. (2026). *SIECCLongWeather: Reproduce the SIECC Israel Long-Term Weather Analysis* (Version 1.0.0) [Computer software]. https://github.com/ngngn1977-cloud/SIECCLongWeather (DOI to be added after the Zenodo release).

## Licence

Package code is MIT licensed (Nahum M. Gabinet). Data remain subject to their source terms; see `DATA_RIGHTS.md` and `DATA_SOURCE_AND_LICENSE_MANIFEST.csv`.

## Author

Nahum M. Gabinet (ORCID 0000-0001-5861-1507), ngabinet@campus.haifa.ac.il.
Louis and Gabi Weisfeld School of Social Work, Bar-Ilan University, Ramat Gan, Israel; School of Environmental Sciences, Faculty of Social Sciences, University of Haifa, Haifa, Israel.
