test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})


test_that("test get_STPD_factor()", {

  # Single Estimated Values
  out <- expect_invisible(get_STPD_factor(baro = 761:762, temp_c = 29:30))
  expect_type(out, "double")

  # Confidence Interval
  pred_mat <- get_STPD_factor(baro = 761:762, temp_c = 29:30, interval = "c")
  expect_identical(class(pred_mat), c("matrix","array"))

})
