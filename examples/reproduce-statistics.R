library(SIECCLongWeather)
result <- reproduce_statistics(write_outputs = FALSE)
stopifnot(result$PUBLICATION_REPRODUCTION == "PASS")
