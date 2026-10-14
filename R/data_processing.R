#' Convert Kelvin to degrees Celsius
#' @export
celsius_from_kelvin <- function(kelvin) {
  kelvin <- as.numeric(kelvin)
  if (any(kelvin < 0, na.rm = TRUE)) stop("Kelvin values cannot be negative", call. = FALSE)
  kelvin - 273.15
}

#' Derive relative humidity from air and dew-point temperatures
#' @export
relative_humidity_from_dewpoint <- function(temperature_c, dewpoint_c) {
  temperature_c <- as.numeric(temperature_c); dewpoint_c <- as.numeric(dewpoint_c)
  if (length(temperature_c) != length(dewpoint_c)) stop("Temperature vectors must have equal length", call. = FALSE)
  es <- exp((17.625 * temperature_c) / (243.04 + temperature_c))
  e <- exp((17.625 * dewpoint_c) / (243.04 + dewpoint_c))
  pmin(100, pmax(0, 100 * e / es))
}

#' Weighted mean using valid-hour counts
#' @export
valid_hour_weighted_mean <- function(values, valid_hours) {
  values <- as.numeric(values); valid_hours <- as.numeric(valid_hours)
  if (length(values) != length(valid_hours) || any(valid_hours < 0, na.rm = TRUE)) stop("Invalid valid-hour weights", call. = FALSE)
  ok <- is.finite(values) & is.finite(valid_hours) & valid_hours > 0
  if (!any(ok)) return(NA_real_)
  stats::weighted.mean(values[ok], valid_hours[ok])
}

#' Assign dates to December-February winters
#' @export
assign_djf <- function(date) {
  d <- as.Date(date); month <- as.integer(format(d, "%m")); year <- as.integer(format(d, "%Y"))
  if (any(!month %in% c(12L, 1L, 2L))) stop("assign_djf accepts December, January, or February only", call. = FALSE)
  start <- ifelse(month == 12L, year, year - 1L)
  data.frame(WINTER_START_YEAR = start, WINTER = sprintf("%d/%02d", start, (start + 1L) %% 100L), stringsAsFactors = FALSE)
}

#' Area-weighted mean over intersected cells
#' @export
area_weighted_mean <- function(values, intersection_area) {
  values <- as.numeric(values); intersection_area <- as.numeric(intersection_area)
  if (length(values) != length(intersection_area) || any(intersection_area < 0, na.rm = TRUE)) stop("Invalid area weights", call. = FALSE)
  ok <- is.finite(values) & is.finite(intersection_area) & intersection_area > 0
  if (!any(ok)) return(NA_real_)
  sum(values[ok] * intersection_area[ok]) / sum(intersection_area[ok])
}

#' Inverse-distance interpolation
#' @export
idw_interpolate <- function(station_x, station_y, station_value, target_x, target_y, p = 2) {
  station_x <- as.numeric(station_x); station_y <- as.numeric(station_y); station_value <- as.numeric(station_value)
  if (!all(length(station_x) == c(length(station_y), length(station_value)))) stop("Station vectors must be equal length", call. = FALSE)
  target_x <- as.numeric(target_x); target_y <- as.numeric(target_y)
  if (length(target_x) != length(target_y) || p <= 0) stop("Invalid IDW target or exponent", call. = FALSE)
  vapply(seq_along(target_x), function(i) {
    distance <- sqrt((station_x - target_x[i])^2 + (station_y - target_y[i])^2)
    exact <- which(distance == 0 & is.finite(station_value))
    if (length(exact)) return(mean(station_value[exact]))
    ok <- is.finite(distance) & is.finite(station_value) & distance > 0
    if (!any(ok)) return(NA_real_)
    weight <- 1 / distance[ok]^p
    sum(weight * station_value[ok]) / sum(weight)
  }, numeric(1))
}

#' IMS historical daily-mean temperature definition
#' @export
ims_tmean <- function(tx_c, tn_c) {
  (as.numeric(tx_c) + as.numeric(tn_c)) / 2
}

#' Apply the fixed study-specific rainfall domain calibration once
#' @export
apply_rainfall_calibration <- function(rainfall_mm) {
  count <- attr(rainfall_mm, "siecc_calibration_count", exact = TRUE)
  if (is.null(count)) count <- 0L
  if (count != 0L) stop("DOUBLE_CALIBRATION_FORBIDDEN", call. = FALSE)
  result <- as.numeric(rainfall_mm) * .siecc_rain_calibration_factor
  attr(result, "siecc_calibration_count") <- 1L
  result
}

#' Interpolate station rainfall ratios and reconstruct calibrated grid rainfall
#' @export
rainfall_ratio_interpolate <- function(station_x, station_y, station_rain_mm,
                                       station_climatology_mm, grid_x, grid_y,
                                       grid_climatology_mm, calibrate = TRUE) {
  ratio <- as.numeric(station_rain_mm) / as.numeric(station_climatology_mm)
  if (any(!is.finite(ratio) | ratio < 0)) stop("Invalid rainfall climatology ratio", call. = FALSE)
  mapped <- idw_interpolate(station_x, station_y, ratio, grid_x, grid_y, p = 2) * as.numeric(grid_climatology_mm)
  if (isTRUE(calibrate)) apply_rainfall_calibration(mapped) else mapped
}

.siecc_check_schema <- function(data, required) {
  missing <- setdiff(required, names(data))
  if (length(missing)) stop("Missing required field(s): ", paste(missing, collapse = ", "), call. = FALSE)
  invisible(TRUE)
}

.siecc_qc_numeric <- function(x, lower = -Inf, upper = Inf, name = deparse(substitute(x))) {
  x <- as.numeric(x)
  if (any(!is.finite(x))) stop(name, " contains missing/nonfinite values", call. = FALSE)
  if (any(x < lower | x > upper)) stop(name, " violates unit/range check", call. = FALSE)
  invisible(TRUE)
}

.siecc_station_eligible <- function(data, value_col, period_col, min_completeness = 0.8, allowed_flags = c("", "OK", NA)) {
  .siecc_check_schema(data, c("STATION_ID", period_col, value_col, "QC_FLAG"))
  keep_flag <- data$QC_FLAG %in% allowed_flags | is.na(data$QC_FLAG)
  candidate <- data[keep_flag, , drop = FALSE]
  complete <- stats::aggregate(is.finite(candidate[[value_col]]), list(STATION_ID = candidate$STATION_ID), mean)
  eligible <- complete$STATION_ID[complete$x >= min_completeness]
  candidate[candidate$STATION_ID %in% eligible & is.finite(candidate[[value_col]]), , drop = FALSE]
}

.siecc_aggregate_calendar <- function(data, date_col, value_col, weight_col = NULL) {
  d <- as.Date(data[[date_col]]); year <- as.integer(format(d, "%Y"))
  split_index <- split(seq_len(nrow(data)), year)
  values <- vapply(split_index, function(i) {
    if (is.null(weight_col)) mean(data[[value_col]][i], na.rm = TRUE)
    else valid_hour_weighted_mean(data[[value_col]][i], data[[weight_col]][i])
  }, numeric(1))
  data.frame(YEAR = as.integer(names(values)), VALUE = as.numeric(values))
}

.siecc_aggregate_djf <- function(data, date_col, value_col, weight_col = NULL) {
  assignment <- assign_djf(data[[date_col]])
  split_index <- split(seq_len(nrow(data)), assignment$WINTER)
  values <- vapply(split_index, function(i) {
    if (is.null(weight_col)) mean(data[[value_col]][i], na.rm = TRUE)
    else valid_hour_weighted_mean(data[[value_col]][i], data[[weight_col]][i])
  }, numeric(1))
  starts <- vapply(names(values), function(x) as.integer(substr(x, 1, 4)), integer(1))
  data.frame(WINTER = names(values), WINTER_START_YEAR = starts, VALUE = as.numeric(values), row.names = NULL)
}

.siecc_temperature_anomaly_map <- function(station_x, station_y, station_value,
                                           station_climatology, grid_x, grid_y,
                                           grid_climatology) {
  anomaly <- station_value - station_climatology
  grid_climatology + idw_interpolate(station_x, station_y, anomaly, grid_x, grid_y, p = 2)
}

.siecc_validate_provenance <- function(record) {
  required <- c("provider", "product", "version", "retrieval_timestamp", "url_identifier", "file_hash")
  .siecc_check_schema(as.data.frame(record, stringsAsFactors = FALSE), required)
  invisible(TRUE)
}

