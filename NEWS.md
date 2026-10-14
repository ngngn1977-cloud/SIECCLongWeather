# SIECCLongWeather 1.0.0

- First public release. Metadata and packaging changed only; no estimator, rule,
  tolerance or reference value changed.
- Numerical outputs are identical to 0.1.0 (3,078/3,078 reference values
  reproduced).
- Author, maintainer, licence-holder, citation and repository metadata completed.
- IMS-derived national annual and December-February series are shipped with
  attribution to the Israel Meteorological Service (see DATA_RIGHTS.md).
- Internal development records were removed from the public tree.

# SIECCLongWeather 0.1.0

- Initial reviewer and archival release package.
- Preserves six qualified annual and DJF metrics and the 6/6/12 BH families.
- Implements HAC/Newey-West primary inference, AR(1) GLS, Theil-Sen,
  autocorrelation-adjusted modified Mann-Kendall, legacy ordinary
  Mann-Kendall, GAM assessment, descriptives, contrasts, figures, Word
  companions, CSV companions, and traceability.
- Carries the external-validation review items without altering the validated
  reference outputs.

