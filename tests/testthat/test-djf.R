test_that("DJF crosses calendar years", expect_equal(assign_djf(as.Date(c("2000-12-15","2001-01-15","2001-02-15")))$WINTER,rep("2000/01",3)))
