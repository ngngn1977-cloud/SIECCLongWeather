# IMS Data Access

The Israel Meteorological Service (IMS) is the official provider for station observations, station metadata, and climatological records used by the historical analysis.

Official entry points:

- IMS Meteorological Database/site: https://ims.gov.il/en
- 10-/1-minute observation API: https://ims.gov.il/en/ObservationDataAPI
- API explanation: https://ims.gov.il/sites/default/files/2023-01/API_Explanation_en.pdf
- Terms: https://ims.gov.il/sites/default/files/inline-files/termsofuse_en.pdf

QC-controlled historical databases include hourly, daily, daily-rain, monthly-rain, and seasonal/annual-rain products. The 10-/1-minute API serves operational high-frequency observations; it must not automatically replace the validated historical QC products.

The current API requires `APIToken` authentication, acceptance of IMS terms, and contact with IMS to obtain authorization/token. Supply a token only through `IMS_API_TOKEN` or an ignored local configuration. Never commit it. `.env.example` contains a blank variable solely as a template.

For publication reacquisition, record provider, product/database, station identifiers, query period, product version or retrieval state, UTC retrieval timestamp, URL identifier, and SHA-256 for every downloaded file. `download_live_sources()` warns that live sources may have changed and never overwrites frozen inputs. Raw data redistribution is not assumed; see `DATA_RIGHTS.md`.

IMS temperature uses 18 reconciled station chains, excludes Beer Sheva, continues homogeneous TX/TN observations with official post-2017 data, and defines daily mean as `(TX + TN) / 2`. This is consistent historically but differs from a 24-hourly mean. Rainfall uses the dense year-specific QC-complete network and the closed climatology-ratio method; rainy-day count and IMS RH are not qualified national long-term metrics.
