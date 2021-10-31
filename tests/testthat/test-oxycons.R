test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})



test_that("Test get_oxycons()",{

  ## Check Numeric Output
  ### Simple
  out1 <- expect_invisible(get_oxycons(100, 50))
  expect_type(out1, "double")
  ### Complex
  out2 <- expect_invisible(
    get_oxycons(100:101, 50:51, condition = "STPD", baro = 760:761, temp_c = 23:24)
  )
  expect_type(out2, "double")

  ## Error Msg
  expect_error(get_oxycons(100, 50, condition = "STPD"),
               "please provide values for `baro` and `temp_c`.")

})
