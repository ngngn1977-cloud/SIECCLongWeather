.siecc_source_to_national <- function(bundle) {
  required<-c("ims_temperature","ims_rainfall","station_climatology","grid","copernicus")
  missing<-setdiff(required,names(bundle)); if(length(missing)) stop("Source bundle missing: ",paste(missing,collapse=", "),call.=FALSE)
  grid<-bundle$grid; .siecc_check_schema(grid,c("GRID_ID","X","Y","INTERSECTION_AREA")); .siecc_qc_numeric(grid$INTERSECTION_AREA,0,Inf,"intersection area")
  temp<-bundle$ims_temperature; .siecc_check_schema(temp,c("DATE","STATION_ID","X","Y","TX_C","TN_C","CLIMATOLOGY_C","QC_FLAG")); temp$TMEAN_C<-ims_tmean(temp$TX_C,temp$TN_C)
  rain<-bundle$ims_rainfall; .siecc_check_schema(rain,c("DATE","STATION_ID","X","Y","RAIN_MM","CLIMATOLOGY_MM","QC_FLAG")); .siecc_qc_numeric(rain$RAIN_MM,0,Inf,"rainfall")
  dates<-sort(unique(as.Date(temp$DATE))); mapped_temp<-lapply(dates,function(d){z<-temp[as.Date(temp$DATE)==d&temp$QC_FLAG%in%c("","OK"),]; g<-.siecc_temperature_anomaly_map(z$X,z$Y,z$TMEAN_C,z$CLIMATOLOGY_C,grid$X,grid$Y,grid$TEMP_CLIMATOLOGY_C); data.frame(DATE=d,IMS_AIR_TEMP_C=area_weighted_mean(g,grid$INTERSECTION_AREA))})
  rain_dates<-sort(unique(as.Date(rain$DATE))); mapped_rain<-lapply(rain_dates,function(d){z<-rain[as.Date(rain$DATE)==d&rain$QC_FLAG%in%c("","OK"),]; g<-rainfall_ratio_interpolate(z$X,z$Y,z$RAIN_MM,z$CLIMATOLOGY_MM,grid$X,grid$Y,grid$RAIN_CLIMATOLOGY_MM,TRUE); data.frame(DATE=d,IMS_RAIN_TOTAL_MM=area_weighted_mean(g,grid$INTERSECTION_AREA))})
  list(ims_temperature_daily=do.call(rbind,mapped_temp),ims_rainfall_daily=do.call(rbind,mapped_rain),copernicus=bundle$copernicus,processing=list(idw_p=2,rainfall_method="CLIMATOLOGY_AIDED_PRECIPITATION_RATIO",temperature_definition="(TX+TN)/2",rainfall_calibration_target_mm=.siecc_rain_calibration_target_mm))
}
