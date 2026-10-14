test_that("BH family adjustment is exact", expect_equal(bh_adjust(c(.01,.02,.2)),stats::p.adjust(c(.01,.02,.2),"BH")))
