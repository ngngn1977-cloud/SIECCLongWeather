test_that("RH known answers and bounds hold", {expect_equal(relative_humidity_from_dewpoint(20,20),100); expect_true(relative_humidity_from_dewpoint(20,10)<100)})
