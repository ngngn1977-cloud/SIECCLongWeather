.siecc_metrics <- c(
  "COPERNICUS_AIR_TEMP_C", "IMS_AIR_TEMP_C", "COPERNICUS_RH_PERCENT",
  "UTCI_C", "MRT_C", "IMS_RAIN_TOTAL_MM"
)

.siecc_rain_calibration_factor <- 1.2824239753736433
.siecc_rain_calibration_target_mm <- 415.438229

.siecc_metric_meta <- data.frame(
  METRIC = .siecc_metrics,
  SOURCE = c("COPERNICUS_ERA5", "IMS_18_CHAIN", "COPERNICUS_ERA5",
             "ERA5_HEAT_V1_1", "ERA5_HEAT_V1_1", "IMS_RATIO_RECONSTRUCTION"),
  UNIT = c("degC", "degC", "percent", "degC", "degC", "mm"),
  SLOPE_UNIT = c("degC/decade", "degC/decade", "percentage_points/decade",
                 "degC/decade", "degC/decade", "mm/decade"),
  stringsAsFactors = FALSE
)

.siecc_reference_path <- function(name) {
  root <- getOption("SIECCLongWeather.dev_root", Sys.getenv("SIECCLONGWEATHER_ROOT", ""))
  if (nzchar(root)) return(file.path(root, "inst", "reference", name))
  system.file("reference", name, package = "SIECCLongWeather", mustWork = TRUE)
}

.siecc_extdata_path <- function(name) {
  root <- getOption("SIECCLongWeather.dev_root", Sys.getenv("SIECCLONGWEATHER_ROOT", ""))
  if (nzchar(root)) return(file.path(root, "inst", "extdata", name))
  system.file("extdata", name, package = "SIECCLongWeather", mustWork = TRUE)
}

.siecc_require <- function(package) {
  if (!requireNamespace(package, quietly = TRUE)) {
    stop("Required reproducibility dependency is unavailable: ", package, call. = FALSE)
  }
  invisible(TRUE)
}

.siecc_sha256 <- function(path) {
  .siecc_require("digest")
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}
