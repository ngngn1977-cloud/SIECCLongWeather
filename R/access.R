#' Prepare or perform live official-source reacquisition
#' @export
download_live_sources <- function(destination=file.path(tempdir(),"SIECCLongWeather_live"), providers=c("IMS","ERA5","ERA5_HEAT"), dry_run=TRUE) {
  warning("LIVE OFFICIAL SOURCES MAY HAVE BEEN UPDATED AFTER PUBLICATION.",call.=FALSE)
  providers<-match.arg(providers,c("IMS","ERA5","ERA5_HEAT"),several.ok=TRUE)
  records<-data.frame(provider=providers,product=c(IMS="IMS 10-/1-minute observation API",ERA5="ERA5 monthly averaged single levels",ERA5_HEAT="ERA5-HEAT UTCI/MRT v1.1")[providers],version=c(IMS="LIVE_OPERATIONAL_NOT_FROZEN",ERA5="REQUESTED_DATASET_VERSION_MUST_BE_RECORDED",ERA5_HEAT="v1.1")[providers],retrieval_timestamp=format(Sys.time(),tz="UTC",usetz=TRUE),url_identifier=c(IMS="https://ims.gov.il/en/ObservationDataAPI",ERA5="https://cds.climate.copernicus.eu/datasets/reanalysis-era5-single-levels-monthly-means",ERA5_HEAT="https://cds.climate.copernicus.eu/datasets/derived-utci-historical")[providers],file_hash=NA_character_,status="INSTRUCTIONS_ONLY",stringsAsFactors=FALSE)
  if(!dry_run) {
    if("IMS"%in%providers&&!nzchar(Sys.getenv("IMS_API_TOKEN"))) stop("IMS_API_TOKEN is required after IMS authorization and acceptance of IMS terms; it is never stored by this package.",call.=FALSE)
    dir.create(destination,recursive=TRUE,showWarnings=FALSE)
    stop("Live downloads require provider-specific request parameters. Use the documented IMS/CDS acquisition templates; frozen publication inputs are never overwritten.",call.=FALSE)
  }
  records
}
