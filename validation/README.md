# Validation evidence

Two files record how the R package reproduces the validated reference outputs.
Neither is read by the package at run time.

| File | Content |
|---|---|
| `PUBLICATION_VALIDATION.csv` | Output of `validate_against_publication()`: 3,078 reference values (series, statistics, descriptives, figure data) against the values the package reproduces, with absolute and relative differences, the tolerance (1e-7) and a PASS/FAIL status. All 3,078 rows pass. |
| `FULL_R_VS_SEALED_HYBRID_PARITY.csv` | Parity of the R-first implementation against the original R/Python hybrid production run (the sealed reference values), per metric, period and result field, with the same difference and tolerance columns. |

To regenerate the first file from an installed package:

```r
library(SIECCLongWeather)
verify_publication_inputs()
validate_against_publication()
```

Detailed check, demo and fresh-run folders from development are not part of the
public release.
