.siecc_demo_frame <- function() {
  year<-1990:2019; t<-year-1990
  data.frame(YEAR=year,
    COPERNICUS_AIR_TEMP_C=18+0.025*t+0.35*sin(t), IMS_AIR_TEMP_C=19+0.023*t+0.30*sin(t+.2),
    COPERNICUS_RH_PERCENT=64-0.035*t+0.8*cos(t/2), UTCI_C=16+0.03*t+0.4*sin(t+.5),
    MRT_C=24+0.032*t+0.5*sin(t+.8), IMS_RAIN_TOTAL_MM=420-0.6*t+35*cos(t/2.5),
    IMS_RAIN_ELIGIBLE_STATIONS=rep(3L,length(year)),check.names=FALSE)
}

.siecc_demo_figure_data <- function(frame,period="ANNUAL") {
  x<-frame$YEAR; out<-data.frame(YEAR=x,frame[.siecc_metrics[1:5]],IMS_RAINFALL_MM=frame$IMS_RAIN_TOTAL_MM,check.names=FALSE)
  mapping<-c(COPERNICUS_AIR_TEMP_C="COPERNICUS_AIR_TEMP_TREND",IMS_AIR_TEMP_C="IMS_AIR_TEMP_TREND",UTCI_C="UTCI_TREND",MRT_C="MRT_TREND",COPERNICUS_RH_PERCENT="COPERNICUS_RH_TREND",IMS_RAIN_TOTAL_MM="IMS_RAINFALL_TREND")
  for(metric in names(mapping)) out[[mapping[[metric]]]]<-stats::predict(stats::lm(frame[[metric]]~x))
  out
}

#' Run the credential-free known-answer demonstration
#' @export
run_demo <- function(output_dir=file.path(tempdir(),"SIECCLongWeather_demo")) {
  dir.create(output_dir,recursive=TRUE,showWarnings=FALSE)
  station<-utils::read.csv(.siecc_extdata_path("demo_station_observations.csv"))
  grid<-utils::read.csv(.siecc_extdata_path("demo_grid.csv"))
  known<-data.frame(CHECK=c("KELVIN_TO_CELSIUS","AREA_WEIGHTED_MEAN","IDW_EXACT_STATION","IMS_TMEAN","RAIN_CALIBRATION","DJF_ASSIGNMENT"),VALUE=c(celsius_from_kelvin(273.15),area_weighted_mean(c(10,20),c(1,3)),idw_interpolate(c(0,2),c(0,0),c(10,20),0,0),ims_tmean(25,15),unname(apply_rainfall_calibration(100)),assign_djf(as.Date("2000-12-15"))$WINTER_START_YEAR),EXPECTED=c(0,17.5,10,20,128.24239753736433,2000),stringsAsFactors=FALSE)
  known$ABS_DIFF<-abs(known$VALUE-known$EXPECTED); known$STATUS<-ifelse(known$ABS_DIFF<1e-10,"PASS","FAIL")
  frame<-.siecc_demo_frame(); trends<-.siecc_add_multiplicity_robustness(.siecc_analyse_frame(frame,"ANNUAL")); trends<-.siecc_normalize_trends(trends)
  desc<-.siecc_build_descriptives(frame,"ANNUAL"); contrasts<-.siecc_build_contrasts(frame,"ANNUAL",trends)
  fig<-.siecc_demo_figure_data(frame); .siecc_make_figure("ANNUAL",fig,output_dir,"DEMO_LONG_WEATHER_FIGURE")
  results<-merge(data.frame(PERIOD="ANNUAL",METRIC=.siecc_metrics,SOURCE=.siecc_metric_meta$SOURCE,UNIT=.siecc_metric_meta$UNIT,N=desc$N,START=desc$START,END=desc$END,MEAN=desc$MEAN,SD=desc$SD,MEDIAN=desc$MEDIAN,IQR=desc$IQR,MIN=desc$MIN,MIN_YEAR=desc$MIN_YEAR_OR_WINTER,MAX=desc$MAX,MAX_YEAR=desc$MAX_YEAR_OR_WINTER,HAC_SLOPE_PER_DECADE=trends$HAC_SLOPE_PER_DECADE,HAC_SE=trends$HAC_SE,HAC_CI_LOW=trends$HAC_CI_LOW,HAC_CI_HIGH=trends$HAC_CI_HIGH,HAC_P=trends$HAC_P,PERIOD_BH_Q=trends$PERIOD_BH_Q,GLOBAL_BH_Q=trends$GLOBAL_BH_Q,stringsAsFactors=FALSE),trends[,c("PERIOD","METRIC","GLS_SLOPE_PER_DECADE","SEN_SLOPE_PER_DECADE","MODIFIED_MK_P","LEGACY_MK_P","GAM_CLASSIFICATION","ROBUSTNESS_CLASSIFICATION")],by=c("PERIOD","METRIC"))
  .siecc_write_results_docx(results,contrasts,file.path(output_dir,"DEMO_RESULTS_TABLE.docx"),"Demo Long-Weather Descriptive and Results Table")
  utils::write.csv(frame,file.path(output_dir,"DEMO_NATIONAL_ANNUAL_SERIES.csv"),row.names=FALSE); utils::write.csv(trends,file.path(output_dir,"DEMO_STATISTICS.csv"),row.names=FALSE); utils::write.csv(known,file.path(output_dir,"DEMO_KNOWN_ANSWER_VALIDATION.csv"),row.names=FALSE)
  trace<-data.frame(FIGURE="DEMO_LONG_WEATHER_FIGURE",PANEL=rep(LETTERS[1:4],c(2,2,1,1)),CSV_COLUMN=c("COPERNICUS_AIR_TEMP_C","IMS_AIR_TEMP_C","UTCI_C","MRT_C","COPERNICUS_RH_PERCENT","IMS_RAINFALL_MM"),SOURCE_AUTHORITY="DEMO_ANALYTIC_GENERATOR",SOURCE_HASH=.siecc_sha256(file.path(output_dir,"DEMO_LONG_WEATHER_FIGURE_DATA.csv")),STATUS="PASS",stringsAsFactors=FALSE); utils::write.csv(trace,file.path(output_dir,"DEMO_FIGURE_TRACE.csv"),row.names=FALSE)
  status<-if(all(known$STATUS=="PASS")&&all(file.exists(c(file.path(output_dir,"DEMO_LONG_WEATHER_FIGURE.png"),file.path(output_dir,"DEMO_LONG_WEATHER_FIGURE.docx"),file.path(output_dir,"DEMO_LONG_WEATHER_FIGURE_DATA.csv"),file.path(output_dir,"DEMO_RESULTS_TABLE.docx"))))) "PASS" else "FAIL"
  list(DEMO_REPRODUCTION=status,output_dir=normalizePath(output_dir,winslash="/",mustWork=TRUE),known_answers=known,station_records=nrow(station),grid_cells=nrow(grid))
}
