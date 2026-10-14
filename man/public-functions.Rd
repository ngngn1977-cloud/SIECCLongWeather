\name{public-functions}
\alias{area_weighted_mean}
\alias{apply_rainfall_calibration}
\alias{assign_djf}
\alias{bh_adjust}
\alias{celsius_from_kelvin}
\alias{climate_change_contrasts}
\alias{download_live_sources}
\alias{idw_interpolate}
\alias{ims_tmean}
\alias{modified_mk_fit}
\alias{ols_fit}
\alias{rainfall_ratio_interpolate}
\alias{relative_humidity_from_dewpoint}
\alias{reproduce_all}
\alias{reproduce_all_publication}
\alias{reproduce_statistics}
\alias{run_demo}
\alias{setup_publication_environment}
\alias{validate_against_publication}
\alias{verify_publication_inputs}
\alias{valid_hour_weighted_mean}
\title{Public Reproduction, Processing, and Statistical Functions}
\description{Functions supporting the credential-free demonstration, frozen publication reproduction, live-source acquisition instructions, validated processing mathematics, and publication validation.}
\usage{
celsius_from_kelvin(kelvin)
relative_humidity_from_dewpoint(temperature_c, dewpoint_c)
valid_hour_weighted_mean(values, valid_hours)
assign_djf(date)
area_weighted_mean(values, intersection_area)
idw_interpolate(station_x, station_y, station_value, target_x, target_y, p = 2)
ims_tmean(tx_c, tn_c)
apply_rainfall_calibration(rainfall_mm)
rainfall_ratio_interpolate(station_x, station_y, station_rain_mm,
  station_climatology_mm, grid_x, grid_y, grid_climatology_mm,
  calibrate = TRUE)
ols_fit(time, value)
modified_mk_fit(value)
bh_adjust(p)
climate_change_contrasts(time, value)
setup_publication_environment(root = NULL)
verify_publication_inputs()
run_demo(output_dir = file.path(tempdir(), "SIECCLongWeather_demo"))
reproduce_statistics(output_dir = file.path(tempdir(),
  "SIECCLongWeather_statistics"), validate = TRUE, write_outputs = TRUE)
reproduce_all(source_bundle = NULL, output_dir = file.path(tempdir(),
  "SIECCLongWeather_full"))
reproduce_all_publication(...)
validate_against_publication(reproduction = NULL, tolerance = 1e-7)
download_live_sources(destination = file.path(tempdir(),
  "SIECCLongWeather_live"), providers = c("IMS", "ERA5", "ERA5_HEAT"),
  dry_run = TRUE)
}
\arguments{
\item{kelvin, temperature_c, dewpoint_c, values, valid_hours, intersection_area, tx_c, tn_c, rainfall_mm, value}{Numeric inputs.}
\item{date}{Date-like DJF inputs.}
\item{station_x, station_y, station_value, target_x, target_y, grid_x, grid_y}{Coordinates and interpolation values.}
\item{p}{Positive IDW exponent.}
\item{station_rain_mm, station_climatology_mm, grid_climatology_mm}{Rainfall reconstruction inputs.}
\item{calibrate}{Apply the fixed study-specific calibration once.}
\item{time}{Integer or numeric time coordinate.}
\item{root}{Optional development package root.}
\item{output_dir, destination}{Portable output directory.}
\item{validate, write_outputs, dry_run}{Logical controls.}
\item{source_bundle}{Optional standardized frozen source bundle.}
\item{reproduction}{Optional prior reproduction object.}
\item{tolerance}{Absolute numerical validation tolerance.}
\item{providers}{Official providers to prepare for reacquisition.}
\item{...}{Arguments passed to \code{reproduce_all}.}
}
\value{A numeric result, data frame, or structured reproduction result, depending on the function.}
\examples{
celsius_from_kelvin(273.15)
area_weighted_mean(c(10, 20), c(1, 3))
assign_djf(as.Date("2000-12-15"))
}
