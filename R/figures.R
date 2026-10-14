.siecc_figure_columns <- list(
  A = c("COPERNICUS_AIR_TEMP_C", "IMS_AIR_TEMP_C"),
  B = c("UTCI_C", "MRT_C"),
  C = "COPERNICUS_RH_PERCENT",
  D = "IMS_RAINFALL_MM"
)

.siecc_plot_panel <- function(data, period, panel, file, device = "png") {
  x <- if (period == "ANNUAL") data$YEAR else data$WINTER_START_YEAR
  cols <- .siecc_figure_columns[[panel]]
  trend_cols <- paste0(sub("_C$", "", sub("_PERCENT$", "", sub("_MM$", "", cols))), "_TREND")
  trend_cols <- list(A=c("COPERNICUS_AIR_TEMP_TREND","IMS_AIR_TEMP_TREND"), B=c("UTCI_TREND","MRT_TREND"), C="COPERNICUS_RH_TREND", D="IMS_RAINFALL_TREND")[[panel]]
  if (device == "png") grDevices::png(file, width=1500, height=800, res=180)
  else if (device == "pdf") grDevices::pdf(file, width=7.5, height=4.2, useDingbats=FALSE)
  else grDevices::svg(file, width=7.5, height=4.2)
  on.exit(grDevices::dev.off(), add=TRUE)
  y <- unlist(data[cols], use.names=FALSE); ylim <- range(c(y, unlist(data[trend_cols],use.names=FALSE)), finite=TRUE)
  pad <- diff(ylim)*.08; if (!is.finite(pad) || pad==0) pad <- 1
  graphics::plot(x, data[[cols[1]]], type="n", xlab=if(period=="ANNUAL") "Year" else "Winter start year", ylab=switch(panel,A="Air temperature (deg C)",B="Thermal index (deg C)",C="Relative humidity (%)",D="Rainfall total (mm)"), ylim=ylim+c(-pad,pad), main=switch(panel,A="Air temperature",B="UTCI and MRT",C="Copernicus relative humidity",D="IMS rainfall total"), bty="l")
  colors <- c("#1F78B4", "#E31A1C")
  for(i in seq_along(cols)) { graphics::points(x,data[[cols[i]]],pch=16,cex=.45,col=grDevices::adjustcolor(colors[i],.72)); graphics::lines(x,data[[trend_cols[i]]],lwd=2,col=colors[i]) }
  if(length(cols)>1) graphics::legend("topleft",legend=gsub("_"," ",cols),col=colors,pch=16,lty=1,bty="n",cex=.78)
  graphics::mtext(panel, side=3, adj=0, line=.35, font=2, cex=1.05)
}

.siecc_make_figure <- function(period, data, output_dir, stem) {
  dir.create(output_dir, recursive=TRUE, showWarnings=FALSE); panel_dir <- file.path(output_dir,"panels"); dir.create(panel_dir,showWarnings=FALSE)
  panels <- file.path(panel_dir,paste0(stem,"_PANEL_",LETTERS[1:4],".png"))
  for(i in 1:4) .siecc_plot_panel(data,period,LETTERS[i],panels[i],"png")
  draw_all <- function(file, device) {
    if(device=="png") grDevices::png(file,width=1800,height=1300,res=180) else if(device=="pdf") grDevices::pdf(file,width=10,height=7.2,useDingbats=FALSE) else grDevices::svg(file,width=10,height=7.2)
    old <- graphics::par(mfrow=c(2,2),mar=c(4,4.2,3,1)); on.exit({graphics::par(old); grDevices::dev.off()},add=TRUE)
    for(p in LETTERS[1:4]) { tmp<-tempfile(fileext=".png"); .siecc_plot_panel(data,period,p,tmp,"png"); img<-png::readPNG(tmp); graphics::plot.new(); graphics::rasterImage(img,0,0,1,1); unlink(tmp) }
  }
  .siecc_require("png")
  draw_all(file.path(output_dir,paste0(stem,".png")),"png"); draw_all(file.path(output_dir,paste0(stem,".pdf")),"pdf"); draw_all(file.path(output_dir,paste0(stem,".svg")),"svg")
  utils::write.csv(data,file.path(output_dir,paste0(stem,"_DATA.csv")),row.names=FALSE,na="")
  .siecc_write_figure_docx(panels,file.path(output_dir,paste0(stem,".docx")),paste(gsub("_"," ",stem),collapse=" "))
  invisible(list(panels=panels,data=data))
}
