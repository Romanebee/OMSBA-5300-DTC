# Load the necessary libraries for the regression analyses
library(tidyverse)
library(rio)
library(fixest)
library(ggplot2)

# Import the data set needed for the analyses
employment_data <- rio::import("../OMSBA 5300 Data Translation Challenge/Processed_Data/Covid19_Retail_Employment.csv")

retail_data <- indnames %>%
  filter(indname == 'Retail Trade')

retail_employment <- inner_join(retail_data, employment_data, by= c("ind" = "IND"))