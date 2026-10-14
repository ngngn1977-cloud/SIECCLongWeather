test_that("normal-period contrast is computed from named periods", {z<-climate_change_contrasts(1950:2025,1950:2025); expect_equal(z$NORMAL_DIFFERENCE,30)})
