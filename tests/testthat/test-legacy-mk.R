test_that("ordinary MK is legacy only", {r<-SIECCLongWeather:::.siecc_legacy_mk_fit(1:20); expect_identical(r$role,"LEGACY_REFERENCE_ONLY")})
