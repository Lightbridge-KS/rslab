

# Test: Get Metabolic Rate ------------------------------------------------


test_that("test get_metabolic_rate()",{

  ## Test Value
  out <- expect_invisible(get_metabolic_rate(x = 20, y = 10,
                                             baro = 760, temp_c = 25,
                                             wt_kg = 80, ht_cm = 180))
  expect_type(out, "double")
  ## Error: Check Missing Args
  expect_error(get_metabolic_rate(x = 20, y = 10), "Must provide all of these args")

})


# Test: Get BSA -----------------------------------------------------------


test_that("test get_BSA()",{

  out <- expect_invisible(get_BSA(wt_kg = 70:72, ht_cm = 180:182))
  expect_type(out, "double")
})
