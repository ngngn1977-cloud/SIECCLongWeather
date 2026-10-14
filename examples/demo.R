library(SIECCLongWeather)
demo_result <- run_demo()
stopifnot(demo_result$DEMO_REPRODUCTION == "PASS")
