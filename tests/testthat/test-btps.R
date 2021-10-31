test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})


# Test lung_vol_atps_btps() -----------------------------------------------


test_that("Test lung_vol_atps_btps()",{

  expect_s3_class(lung_vol_atps_btps(FEV1 = 5,
                                     FVC = 10,
                                     PEF = 4,
                                     TV = 9,
                                     IC = 10,
                                     EC = 12,
                                     VC = 10),
                  "data.frame")

  ## Check Invalid Lung Volume
  expect_error(lung_vol_atps_btps(EC = 5, TV = 10), "Not a valid lung volumn.")
  expect_error(lung_vol_atps_btps(VC = 5, IC = 10), "Not a valid lung volumn.")
  expect_error(lung_vol_atps_btps(TV = 15, IC = 10), "Not a valid lung volumn.")

})

# Test btps_factor() --------------------------------------------------------


test_that("test get_btps_factor()",{

  # Check from Randomly generated numbers
  expect_type(purrr::map_dbl(runif(100, 0, 50), get_btps_factor), "double")
  # Check Value from Lookup
  expect_identical(purrr::map_dbl(20:37, get_btps_factor), btps_df$Factor_37)
  # Check Error Msg
  expect_error(get_btps_factor(1:20), "`temp` must be a numeric vector of length 1.")
  expect_error(get_btps_factor("hello"), "`temp` must be a numeric vector of length 1.")

})
