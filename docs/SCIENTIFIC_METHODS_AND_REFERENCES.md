# Scientific Methods and References

## Scope and provenance

Final inference covers six metrics only: ERA5 air temperature, IMS air temperature, ERA5-derived RH, UTCI, MRT, and IMS rainfall total. Annual 1950–2025 has N=76; DJF 1950/51–2024/25 has N=75. IMS RH and rainy-day count remain unqualified. Historical production was a validated R 4.4.2/Python 3.13.3 hybrid. This public R interface reproduces the frozen mathematics; R 4.4.3 is later rendering compatibility.

## Source processing and QC

Each source record is bound to provider, product, version, retrieval timestamp, URL identifier, and SHA-256. Schema, units, finite ranges, missingness, IMS flags, station eligibility, temporal completeness, and provenance are checked before aggregation. Live provider data never replace frozen publication inputs.

Kelvin conversion is `T_C = T_K - 273.15`. Relative humidity from air/dew-point Celsius temperatures uses the Magnus form `RH = 100 exp(17.625 Td/(243.04+Td) - 17.625 T/(243.04+T))`, bounded to [0,100]. Hourly summaries weight valid subperiod values by valid-hour counts.

## Time

Daily/monthly values aggregate to calendar years. DJF labels December by its calendar year and January–February by the preceding year, so December 1950–February 1951 is 1950/51. Completeness rules are applied before averaging.

## Space

National values are intersection-area means: `sum(value_i area_i) / sum(area_i)`. Copernicus uses a fixed national grid/polygon support. IMS uses a fixed 5-km grid. IDW uses `w_i=d_i^-2`, with an exact-location rule.

IMS temperature is `(TX+TN)/2`. Eighteen reconciled chains, Beer Sheva excluded, are mapped as anomalies from 1991–2020 station-month climatology: interpolate `T_station - climatology_station` with IDW p=2, add grid climatology, then area-average. This definition is not a true mean of 24 hourly observations.

Rainfall method selection is closed. For the dense year-specific QC-complete IMS network, compute station ratios `P_period/P_climatology`, interpolate ratios by IDW p=2, multiply by grid climatology, apply the study-specific grid-domain calibration exactly once, then area-average. The target is 415.438229 mm. The coefficient is not an IMS standard, universal coefficient, or meteorological constant. Regression guards fail for omission or double application.

## Inference

For `y_t = beta0 + beta1 t + error_t`, the primary slope and 95% interval use OLS coefficients with Newey–West HAC covariance (`prewhite=FALSE`, finite-sample adjustment, lag `max(1,floor(4(N/100)^(2/9)))`, t critical value with N−2 df). Slopes are reported per decade.

Sensitivities are ML GLS with AR(1) correlation, Theil–Sen slope/interval, and Hamed–Rao autocorrelation-adjusted modified Mann–Kendall. Ordinary Mann–Kendall assumes serial independence and is retained only as legacy/reference evidence, never principal non-parametric evidence.

Nonlinearity uses `mgcv::gam(y ~ s(time, bs="cr", k=6), method="ML")`. Strong departure requires EDF≥2, smooth p<0.05, and GAM-minus-linear AIC≤−10. Benjamini–Hochberg correction uses primary HAC p-values only in annual (6), DJF (6), and global (12) families. Robustness combines adjusted HAC, direction agreement, GLS, Theil–Sen, and modified MK.

Descriptives include N, mean, SD, median, IQR, extrema and periods, and missingness. Supporting contrasts compare 1961–1990 with 1991–2020, first with recent decade, and total fitted change. Celsius changes are not percentages; RH absolute change is percentage points; rainfall can additionally use relative percent.

## Three validation layers

Method support is the scientific literature and official provider documentation. Implementation validation is known-answer/unit/regression testing of formulas and failure modes. External benchmark validation compares definitions and independent Israeli/regional evidence where available; non-equivalent comparators are reported as caveats rather than exact confirmation.

Key software/method references include Newey and West (1987), Hamed and Rao (1998), Sen (1968), Theil (1950), Benjamini and Hochberg (1995), Wood (2017, GAMs), Pinheiro and Bates (mixed-effects/GLS), and official IMS/Copernicus documentation. ERA5-HEAT DOI: 10.24381/cds.553b7518.
