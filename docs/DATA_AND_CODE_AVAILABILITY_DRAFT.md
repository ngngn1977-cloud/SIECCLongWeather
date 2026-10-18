# Draft Data and Code Availability Statement

The R code, tests, documentation, synthetic demonstration data, and compact reference outputs are prepared for a tagged GitHub release and a fixed Zenodo software archive. The processed six-metric annual and DJF national series are included in the reviewer package. IMS-derived series are redistributed with attribution to the Israel Meteorological Service and Copernicus-derived series under the Copernicus licence (see DATA_RIGHTS.md).

Large frozen climate inputs are not included in the software archive. Copernicus ERA5 and ERA5-HEAT data should be reacquired from the Climate Data Store using the documented product/version requests and verified against retained request manifests/checksums. Raw IMS observations and raw station metadata are not redistributed; users must obtain them from IMS under its current terms. The package includes official acquisition instructions and empty credential templates.

The credential-free `run_demo()` path is fully self-contained. Exact statistical reproduction uses hash-verified compact frozen national series. Full source-to-result reproduction requires provider access and the frozen source manifest. Live source data may have changed after publication and are not the numerical authority.

Repository: https://github.com/ngngn1977-cloud/SIECCLongWeather; release tag v1.0.0; DOI inserted after the Zenodo release.
