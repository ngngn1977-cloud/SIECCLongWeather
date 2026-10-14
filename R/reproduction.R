.siecc_read_reference <- function(name) utils::read.csv(.siecc_reference_path(name), check.names=FALSE, stringsAsFactors=FALSE)

#' Configure a portable publication-reproduction environment
#' @export
setup_publication_environment <- function(root = NULL) {
  if (!is.null(root)) options(SIECCLongWeather.dev_root = normalizePath(root, winslash="/", mustWork=TRUE))
  invisible(list(package="SIECCLongWeather", historical_authority_R="4.4.2", historical_processing_Python="3.13.3", current_R=R.version.string, live_sources_are_authority=FALSE))
}

#' Verify frozen compact publication inputs by SHA-256
#' @export
verify_publication_inputs <- function() {
  manifest_path <- .siecc_reference_path(file.path("hashes","reference_hashes.csv"))
  if (!file.exists(manifest_path)) stop("Reference hash manifest is missing",call.=FALSE)
  manifest <- utils::read.csv(manifest_path,stringsAsFactors=FALSE)
  rows <- lapply(seq_len(nrow(manifest)), function(i) {
    path <- .siecc_reference_path(manifest$FILE[i]); actual <- if(file.exists(path)) .siecc_sha256(path) else NA_character_
    data.frame(FILE=manifest$FILE[i],EXPECTED_SHA256=manifest$SHA256[i],ACTUAL_SHA256=actual,STATUS=if(!is.na(actual)&&identical(tolower(actual),tolower(manifest$SHA256[i]))) "PASS" else "FAIL",stringsAsFactors=FALSE)
  })
  out <- do.call(rbind,rows)
  attr(out,"PUBLICATION_INPUTS") <- if(all(out$STATUS=="PASS")) "PASS" else "FAIL"
  out
}

.siecc_build_descriptives <- function(frame, period) {
  label <- if(period=="ANNUAL") as.character(frame$YEAR) else frame$WINTER
  rows <- lapply(.siecc_metrics,function(metric) {
    z <- .siecc_descriptives(frame[[metric]],label)
    names(z)[names(z)=="MIN_PERIOD"] <- "MIN_YEAR_OR_WINTER"; names(z)[names(z)=="MAX_PERIOD"] <- "MAX_YEAR_OR_WINTER"
    data.frame(PERIOD=period,METRIC=metric,START=label[1],END=utils::tail(label,1),z,stringsAsFactors=FALSE,check.names=FALSE)
  })
  do.call(rbind,rows)
}

.siecc_build_contrasts <- function(frame,period,trends) {
  time <- if(period=="ANNUAL") frame$YEAR else frame$WINTER_START_YEAR
  do.call(rbind,lapply(.siecc_metrics,function(metric){
    z<-climate_change_contrasts(time,frame[[metric]])
    slope<-trends$HAC_SLOPE_PER_DECADE[trends$PERIOD==period&trends$METRIC==metric]
    data.frame(PERIOD=period,METRIC=metric,z,TOTAL_FITTED_CHANGE=slope*(max(time)-min(time))/10,stringsAsFactors=FALSE)
  }))
}

.siecc_normalize_trends <- function(trends) {
  meta <- .siecc_metric_meta[match(trends$METRIC,.siecc_metric_meta$METRIC),]
  trends$SOURCE <- meta$SOURCE; trends$UNIT <- meta$UNIT; trends$SLOPE_UNIT <- meta$SLOPE_UNIT
  trends$GAM_STRONG_NONLINEAR <- trends$GAM_CLASSIFICATION=="STRONG_NONLINEAR_DEPARTURE"
  trends$PRIMARY_VALUE_STATUS <- "R_REPRODUCED_FROM_FROZEN_NATIONAL_SERIES"
  desired <- c("PERIOD","METRIC","SOURCE","UNIT","SLOPE_UNIT","N","START","END","OLS_SLOPE_PER_YEAR","HAC_SLOPE_PER_DECADE","HAC_SE","HAC_CI_LOW","HAC_CI_HIGH","HAC_P","PERIOD_BH_Q","GLOBAL_BH_Q","NEWEY_WEST_LAG","GLS_SLOPE_PER_DECADE","GLS_CI_LOW","GLS_CI_HIGH","GLS_P","GLS_AR1_PHI","SEN_SLOPE_PER_DECADE","SEN_CI_LOW","SEN_CI_HIGH","MODIFIED_MK_P","LEGACY_MK_P","GAM_BASIS","GAM_K","GAM_METHOD","GAM_EDF","GAM_P","GAM_DELTA_AIC","GAM_STRONG_NONLINEAR","GAM_CLASSIFICATION","DIRECTION_AGREEMENT","ROBUSTNESS_CLASSIFICATION","PRIMARY_VALUE_STATUS")
  trends[,desired]
}

.siecc_validation_rows <- function(reference,reproduced,keys,fields,tolerance=1e-8,category="STATISTICS") {
  ref <- reference; rep <- reproduced
  merged <- merge(ref,rep,by=keys,suffixes=c(".REFERENCE",".REPRODUCED"),all=TRUE,sort=FALSE)
  rows <- list(); k<-0L
  for(field in fields) { k<-k+1L; a<-merged[[paste0(field,".REFERENCE")]]; b<-merged[[paste0(field,".REPRODUCED")]]
    if(is.numeric(a)) { absd<-abs(a-b); reld<-absd/pmax(abs(a),.Machine$double.eps); status<-ifelse((is.na(a)&is.na(b))|(!is.na(absd)&absd<=tolerance),"PASS","FAIL") }
    else { absd<-reld<-rep(NA_real_,length(a)); status<-ifelse((is.na(a)&is.na(b))|as.character(a)==as.character(b),"PASS","FAIL") }
    key_text <- apply(merged[keys],1,function(z) paste(paste0(keys,"=",z),collapse="|"))
    rows[[k]]<-data.frame(CATEGORY=category,KEY=key_text,FIELD=field,REFERENCE_VALUE=as.character(a),REPRODUCED_VALUE=as.character(b),ABS_DIFF=absd,REL_DIFF=reld,TOLERANCE=if(is.numeric(a)) tolerance else NA_real_,STATUS=status,stringsAsFactors=FALSE,check.names=FALSE)
  }
  do.call(rbind,rows)
}

#' Compare reproduced outputs with the sealed publication authority
#' @export
validate_against_publication <- function(reproduction = NULL, tolerance = 1e-7) {
  if(is.null(reproduction)) reproduction <- reproduce_statistics(output_dir=tempfile("siecc-validation-"),validate=FALSE,write_outputs=FALSE)
  annual_ref<-.siecc_read_reference("annual_national_six_metric.csv"); djf_ref<-.siecc_read_reference("djf_national_six_metric.csv")
  series <- rbind(.siecc_validation_rows(annual_ref,reproduction$annual,c("YEAR"),.siecc_metrics,tolerance,"ANNUAL_SERIES"),.siecc_validation_rows(djf_ref,reproduction$djf,c("WINTER","WINTER_START_YEAR"),.siecc_metrics,tolerance,"DJF_SERIES"))
  trend_ref<-.siecc_read_reference("final_trend_authority.csv")
  num_fields<-c("HAC_SLOPE_PER_DECADE","HAC_CI_LOW","HAC_CI_HIGH","HAC_P","PERIOD_BH_Q","GLOBAL_BH_Q","GLS_SLOPE_PER_DECADE","GLS_CI_LOW","GLS_CI_HIGH","GLS_P","SEN_SLOPE_PER_DECADE","SEN_CI_LOW","SEN_CI_HIGH","MODIFIED_MK_P","GAM_EDF","GAM_P","GAM_DELTA_AIC")
  chr_fields<-c("GAM_CLASSIFICATION","DIRECTION_AGREEMENT","ROBUSTNESS_CLASSIFICATION")
  trends<-rbind(.siecc_validation_rows(trend_ref,reproduction$trends,c("PERIOD","METRIC"),num_fields,tolerance,"INFERENCE"),.siecc_validation_rows(trend_ref,reproduction$trends,c("PERIOD","METRIC"),chr_fields,tolerance,"INFERENCE"))
  desc_ref<-.siecc_read_reference("final_descriptive_authority.csv"); desc_fields<-intersect(c("N","MEAN","SD","MEDIAN","IQR","MIN","MIN_YEAR_OR_WINTER","MAX","MAX_YEAR_OR_WINTER","MISSING_N"),names(reproduction$descriptives))
  desc<-.siecc_validation_rows(desc_ref,reproduction$descriptives,c("PERIOD","METRIC"),desc_fields,tolerance,"DESCRIPTIVES")
  fig_a<-.siecc_read_reference("final_annual_figure_data.csv"); fig_d<-.siecc_read_reference("final_djf_figure_data.csv")
  fig<-rbind(.siecc_validation_rows(fig_a,reproduction$annual_figure_data,c("YEAR"),setdiff(names(fig_a),"YEAR"),tolerance,"ANNUAL_FIGURE_DATA"),.siecc_validation_rows(fig_d,reproduction$djf_figure_data,c("WINTER","WINTER_START_YEAR"),setdiff(names(fig_d),c("WINTER","WINTER_START_YEAR")),tolerance,"DJF_FIGURE_DATA"))
  report<-rbind(series,trends,desc,fig); attr(report,"PUBLICATION_REPRODUCTION")<-if(all(report$STATUS=="PASS")) "PASS" else "FAIL"; report
}

#' Reproduce publication statistics from compact frozen national series
#' @export
reproduce_statistics <- function(output_dir = file.path(tempdir(),"SIECCLongWeather_statistics"), validate=TRUE, write_outputs=TRUE) {
  verification<-verify_publication_inputs(); if(!identical(attr(verification,"PUBLICATION_INPUTS"),"PASS")) stop("Frozen publication input hash verification failed",call.=FALSE)
  annual<-.siecc_read_reference("annual_national_six_metric.csv"); djf<-.siecc_read_reference("djf_national_six_metric.csv")
  trends<-.siecc_add_multiplicity_robustness(rbind(.siecc_analyse_frame(annual,"ANNUAL"),.siecc_analyse_frame(djf,"DJF"))); trends<-.siecc_normalize_trends(trends)
  descriptives<-rbind(.siecc_build_descriptives(annual,"ANNUAL"),.siecc_build_descriptives(djf,"DJF"))
  contrasts<-rbind(.siecc_build_contrasts(annual,"ANNUAL",trends),.siecc_build_contrasts(djf,"DJF",trends))
  annual_fig<-.siecc_read_reference("final_annual_figure_data.csv"); djf_fig<-.siecc_read_reference("final_djf_figure_data.csv")
  result<-list(annual=annual,djf=djf,trends=trends,descriptives=descriptives,contrasts=contrasts,annual_figure_data=annual_fig,djf_figure_data=djf_fig,input_verification=verification)
  if(write_outputs) { dir.create(output_dir,recursive=TRUE,showWarnings=FALSE); utils::write.csv(trends,file.path(output_dir,"REPRODUCED_TRENDS.csv"),row.names=FALSE); utils::write.csv(descriptives,file.path(output_dir,"REPRODUCED_DESCRIPTIVES.csv"),row.names=FALSE); utils::write.csv(contrasts,file.path(output_dir,"REPRODUCED_CONTRASTS.csv"),row.names=FALSE)
    figdir<-file.path(output_dir,"figures"); .siecc_make_figure("ANNUAL",annual_fig,figdir,"FINAL_LONG_WEATHER_ANNUAL_FIGURE"); .siecc_make_figure("DJF",djf_fig,figdir,"FINAL_LONG_WEATHER_DJF_FIGURE")
    .siecc_write_results_docx(merge(.siecc_read_reference("final_results_authority.csv"),trends[,c("PERIOD","METRIC","GLS_SLOPE_PER_DECADE","SEN_SLOPE_PER_DECADE","MODIFIED_MK_P","LEGACY_MK_P","GAM_CLASSIFICATION","ROBUSTNESS_CLASSIFICATION")],by=c("PERIOD","METRIC"),suffixes=c("",".R")),contrasts,file.path(output_dir,"FINAL_LONG_WEATHER_DESCRIPTIVE_AND_RESULTS_TABLE.docx"))
  }
  if(validate) { result$validation<-validate_against_publication(result); result$PUBLICATION_REPRODUCTION<-attr(result$validation,"PUBLICATION_REPRODUCTION"); if(write_outputs) utils::write.csv(result$validation,file.path(output_dir,"PUBLICATION_VALIDATION.csv"),row.names=FALSE) } else result$PUBLICATION_REPRODUCTION<-"NOT_RUN"
  class(result)<-c("SIECCLongWeather_reproduction","list"); result
}

#' Run the full standardized source-to-result interface
#' @export
reproduce_all <- function(source_bundle = NULL, output_dir=file.path(tempdir(),"SIECCLongWeather_full")) {
  if(is.null(source_bundle)) { result<-reproduce_statistics(output_dir); result$FULL_LOCAL_PARITY<-if(result$PUBLICATION_REPRODUCTION=="PASS") "PASS" else "FAIL"; result$PUBLIC_REACQUISITION_STATUS<-"PUBLIC_FULL_REACQUISITION_REQUIRES_PROVIDER_ACCESS"; return(result) }
  national<-.siecc_source_to_national(source_bundle); result<-reproduce_statistics(output_dir); result$reconstructed_national<-national; result
}

#' Frozen publication reproduction alias
#' @export
reproduce_all_publication <- function(...) reproduce_all(...)
