## code to prepare `stpd_df` dataset goes here

library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)


# Read --------------------------------------------------------------------


### Read Raw STPD Lookup table
stpd_df_wide_miss <- read_csv(system.file("extdata", "STPD_factor_raw_wrong.csv", package = "rslab"))


# Incorrect Data ----------------------------------------------------------


### Raw Data Probably has an incorrect data point at temp = 27
stpd_df_wide_miss %>%
  ggplot(aes(temp_c_27, baro)) +
  geom_point()

### The incorrect data is in the 40th rows of `temp_c_27`, at that point `baro` is 778 mmHg.
stpd_df_wide_miss %>%
  select(baro, temp_c_27) %>%
  slice(40)


### Thus, I will assign NA to the incorrect data
stpd_df_wide_miss$temp_c_27[40] <- NA



# Pivot -------------------------------------------------------------------

### Pivot To Long Version (good for Plotting and Modeling)
stpd_df_miss <- stpd_df_wide_miss %>%
  pivot_longer(cols = starts_with("temp_c"),
               names_to = "temp_c", names_prefix = "temp_c_",
               names_transform = list(temp_c = as.integer),
               values_to = "stpd_factor")


# Imputation --------------------------------------------------------------


### Because the relationship between `stpd_factor` as response variable,
### and `baro` and `temp_c` as predictors is linear, so I will impute the missing value using linear model.

## Fit Linear Model
stpd_lm_fit <- lm(stpd_factor ~ baro + temp_c, data = stpd_df_miss)

## Impute missing data by linear model
stpd_pred_778_27 <- predict(stpd_lm_fit,
  newdata = data.frame(baro = 778, temp_c = 27),
  interval = NULL
)


# Replace NA --------------------------------------------------------------

## Replace NA value of Long Version with Predicted STPD factor.
stpd_df <- replace_na(stpd_df_miss, list(stpd_factor = stpd_pred_778_27))

## Replace NA value of Wide Version with Predicted STPD factor.
stpd_df_wide <- replace_na(stpd_df_wide_miss,
                           list(temp_c_27 = stpd_pred_778_27))


## Make sure that we have replaced `NA` value.

sum(is.na(stpd_df$stpd_factor))

sum(is.na(stpd_df_wide$temp_c_27))


# Final Plot --------------------------------------------------------------

## 3D plot can show us that the imputed missing value blends nicely with the rest of the surface.

library(plotly)

plotly_stpd_surface <- function(add_point = TRUE,
                                baro = 778,
                                temp_c = 27
){

  stpd_mat <- stpd_df_wide %>%
    column_to_rownames("baro") %>%
    as.matrix()

  Baro <- as.numeric(rownames(stpd_mat))
  Temp <- c(1:ncol(stpd_mat) + 14)

  STPD_factor <- stpd_mat

  if (add_point) {
    stpd_pred <- predict(stpd_lm_fit,
                         newdata = data.frame(baro = baro, temp_c = temp_c),
    )
    stpd_point <- data.frame(baro = baro, temp_c = temp_c, stpd_factor = stpd_pred)
  }

  p_base <- plot_ly(z = ~STPD_factor) %>%
    add_surface(x = ~Temp, y = ~Baro)

  if (add_point){
    p_base <- p_base %>%
      add_markers(data = stpd_point, x = ~temp_c, y = ~baro, z = ~stpd_factor)
  }

  p_base %>%
    layout(
      title = "STPD correction factor as a function of temperature & barometric pressure",
      scene = list(
        xaxis = list(title = "Temperature (c)"),
        yaxis = list(title = "Barometric pressure (mmHg)"),
        zaxis = list(title = "STPD factor")
      )
    )


}

### Surface Plot with Imputed value shows as orange dot:

plotly_stpd_surface(baro = 778,
                    temp_c = 27)

