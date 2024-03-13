# Loading libraries

library(tidyverse)
library(fixest)
library(rio)
library(ipumsr)
library(dplyr)

# Adding Data 

if (!require("ipumsr")) stop("Reading IPUMS data into R requires the ipumsr package. It can be installed using the following command: install.packages('ipumsr')")

ddi <- read_ipums_ddi("cps_00002.xml")
data <- read_ipums_micro(ddi)

# Adding industry names

indnames <- read_csv("/Users/danielaina/Desktop/OMSBA R/OMSBA 5300 DTC Final/indnames.csv")

indnames_filtered <- indnames %>%
  filter(indname == 'Retail Trade')

merged_data <- inner_join(indnames_filtered, data, by= c("ind" = "IND"))

# Dropping variables

final_data <- merged_data %>%
  select(-ASECFLAG, -STATECENSUS, -HWTFINL, -CPSIDV, -CPSIDP, -WTFINL, -SERIAL, -CPSIDV)


