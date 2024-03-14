# Load the necessary libraries for the data cleaning process

library(tidyverse)
library(ipumsr)
library(dplyr)
library(rio)
library(vtable)

# Read the IPUMS data 

if (!require("ipumsr")) stop("Reading IPUMS data into R requires the ipumsr package. It can be installed using the following command: install.packages('ipumsr')")

ddi <- read_ipums_ddi("cps_00002.xml")
data <- read_ipums_micro(ddi)

# Join industry names data to obtain "Retail Trade" category

indnames <- rio::import("../OMSBA 5300 Data Translation Challenge/indnames.csv")

indnames_filtered <- indnames %>%
  filter(indname == 'Retail Trade')

merged_data <- inner_join(indnames_filtered, data, by= c("ind" = "IND"))

# Drop unnecessary variables
final_data <- merged_data %>%
  select(-ASECFLAG, -HWTFINL, -CPSIDV, -CPSIDP, -WTFINL, -SERIAL, -CPSIDV)

# Rename the columns to human readable names

final_data <- final_data %>%
  rename("Industry" = indname,
         "Industry_code" = ind,
         "Year" = YEAR,
         "Month" = MONTH,
         "Household_Record" = CPSID,
         "State" = "STATECENSUS",
         "Person_Number" = PERNUM,
         "Age" = AGE,
         "Employment_Status" = EMPSTAT,
         "Occupation" = OCC,
         "Worker_Class" = CLASSWKR,
         "Work_Unable_COVID-19" = COVIDUNAW,
         "Received_Pay_COVID-19" = COVIDPAID)

# Filter out the years we don't need
final_data$Year_month <- paste0(final_data$Year, "-", final_data$Month)
final_data <- final_data %>% filter(Year >= 2019 & Year <= 2021)

# Group by and summarize summary_data <- final_data %>%
summary_data <- final_data %>%
  group_by(Year, Month, Year_month) %>%
  summarize(RetailEmployment = sum(Industry == 'Retail Trade'))

# Setting up the dates before and after Covid (March is not considered Covid based on employment)

final_data$COVID_Indicator <- ifelse(final_data$Year_month >= "2020-04" & final_data$Year_month <= "2021-06", 1, 0)

# Look at a summary of the data
head(summary_data)

# Export the clean data for analysis into a csv file
rio::export(final_data, "Covid19_Retail_Employment.csv")
