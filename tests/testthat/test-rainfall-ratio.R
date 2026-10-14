test_that("rainfall ratio reconstruction is physical", {z<-rainfall_ratio_interpolate(c(0,2),c(0,0),c(100,200),c(100,100),1,0,100,calibrate=FALSE); expect_equal(z,150)})
