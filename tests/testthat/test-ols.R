test_that("OLS slope known answer holds", expect_equal(ols_fit(1:10,3+2*(1:10))$slope_decade,20,tolerance=1e-12))
