# GitHub and Zenodo Release Guide

Do not publish until the final licence and authorship review is complete.

1. Create the GitHub repository (https://github.com/ngngn1977-cloud/SIECCLongWeather) and push the reviewed package without credentials, raw restricted IMS data, participant data, or personal paths.
2. Confirm CI, `R CMD check`, tests, demo, frozen statistical reproduction, validation, traceability, privacy, secret, and path scans.
3. Confirm the metadata is final, then create a signed/tagged version release matching `DESCRIPTION`.
4. Connect the GitHub repository to Zenodo and archive that tagged release.
5. Obtain the Zenodo DOI; do not invent it. Update `CITATION.cff`, `.zenodo.json`, README, and manuscript availability statement in a new reviewed commit/release.
6. Retain GitHub as the development interface and cite the Zenodo DOI as the fixed scholarly software archive.
7. Store large frozen raw inputs in a separate archive only where licensing permits. Otherwise publish acquisition instructions, request manifests, versions, and checksums.

Recommended split: GitHub contains code, docs, tests, compact processed/reference data, and synthetic demo data. Zenodo contains the tagged release and publication archive. Restricted/large source data remain provider-controlled or in a separate permitted archive.
