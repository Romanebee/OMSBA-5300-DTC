# Load the necessary libraries for the regression analyses
library(tidyverse)
library(rio)
library(fixest)
library(ggplot2)

# Import the data sett needed for the analyses
employment_data <- rio::import("../OMSBA 5300 Data Translation Challenge/Processed_Data/Covid19_Retail_Employment.csv")
indnames <- rio::import("../OMSBA 5300 Data Translation Challenge/indnames.csv")

# Question 1 - How has COVID affected the health of the retail industry, as measured by employment? 

# Create a filtered data frame for the retail industry
retail_data <- indnames %>%
  filter(indname == 'Retail Trade')

retail_employment <- inner_join(retail_data, employment_data, by= c("ind" = "Industry_code"))

# Convert Employment_Status to a categorical variable
retail_employment$Employment_Category <- ifelse(retail_employment$Employment_Status %in% c(10, 12), TRUE, FALSE)

summary(retail_employment$Employment_Category)
retail_employment %>%
  group_by(COVID_Indicator) %>%
  summarize(mean_employment_status = mean(Employment_Category, na.rm = TRUE))

# Create a bar plot
ggplot(retail_employment, aes(x = factor(COVID_Indicator), y = Employment_Category)) +
  geom_bar(stat = "summary", fun = "mean", fill = "skyblue", alpha = 0.7) +
  labs(x = "COVID Indicator", y = "Mean Employment Status") +
  ggtitle("Mean Employment Status by COVID Indicator") +
  theme_minimal()

m1 <- feols(Employment_Category ~ COVID_Indicator, data = retail_employment)

etable(m1)
etable(m1, vcov = 'hetero')

# Predict the probabilities for the regression
retail_employment$predicted_prob <- predict(m1, type = "response")

# Create a scatter plot with a fitted line
ggplot(retail_employment, aes(x = COVID_Indicator, y = predicted_prob)) +
  geom_point(color = "blue") +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  labs(x = "COVID Indicator", y = "Predicted Probability of Employment") +
  ggtitle("Predicted Probability of Employment vs. COVID Indicator") +
  theme_minimal()


# Question 2 - How has retail fared relative to other industries?

# Convert Employment_Status to a categorical variable
employment_data$Employment_Category <- ifelse(employment_data$Employment_Status %in% c(10, 12), TRUE, FALSE)

# Create a binary variable for the type of industry to isolate Retail
employment_data$Industry_binary <- ifelse(employment_data$Industry == "Retail Trade", 1,0)

m_did <- feols(Employment_Category ~ Industry_binary * COVID_Indicator, data = employment_data)
summary(m_did)
etable(m_did)

# Question 3 - Retail needs to worry about who has money to spend - what has changed about who is working and earning money?

