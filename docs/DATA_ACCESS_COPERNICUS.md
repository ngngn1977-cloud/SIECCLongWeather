# Copernicus / ECMWF Data Access

## ERA5 single levels

Official product: https://cds.climate.copernicus.eu/datasets/reanalysis-era5-single-levels-monthly-means

Use a Copernicus Climate Data Store account and its current API client/configuration. Record requested variables, units, temporal aggregation, grid/domain, retrieval timestamp, product/version metadata, request JSON, and SHA-256. For this analysis, ERA5 supplies air temperature and inputs needed for Copernicus relative humidity. Large raw fields are not bundled.

## ERA5-HEAT

Official product: https://cds.climate.copernicus.eu/datasets/derived-utci-historical

The fixed requested product is ERA5-HEAT **v1.1**, DOI `10.24381/cds.553b7518`. It provides UTCI and MRT from 1940 to near real time, based on ERA5, at 0.25-degree spatial resolution with hourly and aggregated products. UTCI and MRT are supplied in kelvin and converted to Celsius by subtracting 273.15. Version v1.0 is deprecated; no future version may silently replace v1.1 in publication reproduction.

Access requires CDS registration and configured credentials. Follow the current dataset request template and Licence to use Copernicus Products. Preserve the exact API request, provider/product/version, UTC retrieval timestamp, URL identifier, returned metadata, and SHA-256. Review provider known-issues documentation before a new live run. Live reacquisition is not the frozen publication authority.
