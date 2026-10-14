test_that("Kelvin conversion is exact", expect_equal(celsius_from_kelvin(c(0,273.15,300)),c(-273.15,0,26.85),tolerance=1e-12))
