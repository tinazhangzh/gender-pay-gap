library(tidyverse)
library(MatchIt)
library(cobalt)
library(sensitivity)
library(car)
library(grf)
library(dplyr)


data <- read.csv("whole_data.csv")

# 1. Raw Model
# Wage Difference in Percetage 
average_salary_by_gender <- data %>%
  group_by(Gender) %>%
  summarise(mean_salary = mean(Salary, na.rm = TRUE))
male_salary <- average_salary_by_gender$mean_salary[average_salary_by_gender$Gender == 0]
female_salary <- average_salary_by_gender$mean_salary[average_salary_by_gender$Gender == 1]
gender_pay_gap <- (male_salary - female_salary) / male_salary * 100


# 2. OLS
baseline_model <- lm(
  log10_Salary ~ Gender + Google.Scholar.ID + Titles + University_Code + Department_Code + Working_Years + log10_i10index,
  data = data
)
summary(baseline_model)


# 3. PSM model
# 1) Propensity Scores
# Propensity score model
new_propensity_model <- glm(Gender ~ University_Code : Department_Code : log10_i10index + Google.Scholar.ID + Titles : Working_Years, 
                            family = binomial(link = "logit"), data = data, na.action = na.exclude)
# Predict propensity scores
new_predicted_scores <- predict(new_propensity_model, type = "response", na.action = na.pass)
# Assign propensity scores to the dataset
data$propensity_score <- ifelse(is.na(new_predicted_scores), NA, new_predicted_scores)

# 2) Matching
matchit_obj <- matchit(Gender ~ University_Code : Department_Code : log10_i10index + Google.Scholar.ID + Titles : Working_Years, 
                       method = "nearest", replace = TRUE, data = data, caliper = 0.2) 
bal.tab(matchit_obj, un = TRUE)
love.plot(matchit_obj)
matched_data <- match.data(matchit_obj)

# 3) Analysis
lm_model <- lm(log10_Salary ~ Gender + University_Code : Department_Code : log10_i10index + Google.Scholar.ID + Titles : Working_Years, data = data)
summary(lm_model)


# 4. Causal Forest model
Y <- data$log10_Salary      # Outcome variable            
W <- data$Gender        # Binary treatment indicator           
X <- data[, c("Working_Years", "log10_i10index", "Department_Code", "University_Code", "Titles", "Google.Scholar.ID")]      # A set of covariates 
# Convert categorical variables to one-hot encoded dummies using model.matrix()
X <- model.matrix(~ University_Code : Department_Code : log10_i10index + Google.Scholar.ID + Titles : Working_Years, data = data)
# Fit a causal forest
causal_forest_model <- causal_forest(X, Y, W)

# Estimate the average treatment effect (ATE)
# The ATE measures the expected difference in populations between a treatment group and a control group with similar features.
ate_estimate <- average_treatment_effect(causal_forest_model, target.sample = "overlap")
print(ate_estimate)
 
# individual effects
individual_effects <- predict(causal_forest_model)$predictions
summary(individual_effects)

# Distributions of Individual Treatment Effects (ITEs)
hist(individual_effects, 
     main = "Distribution of Estimated Individual Treatment Effects",
     xlab = "Estimated Treatment Effect (Gender on Salary)",
     col = "lightblue", 
     border = "white",
     xlim = c(-0.2, 0.1))

lines(density(individual_effects), col = "darkblue", lwd = 2)

individual_effects <- individual_effects 
ggplot(data.frame(ITE = individual_effects), aes(x = ITE)) +
  geom_density(fill = "lightblue", alpha = 0.6) +
  geom_vline(xintercept = mean(individual_effects), color = "darkblue", linetype = "dashed") +
  annotate("text", x = mean(individual_effects), y = 5, label = "Mean ITE", hjust = -0.1, color = "darkblue") +
  labs(
    title = "Distribution of Estimated Individual Treatment Effects",
    x = "Individual Treatment Effect (Gender on Salary)",
    y = "Density"
  ) +
  theme_minimal()

# Plot treatment effects by i10index
ggplot(data, aes(x = log10_i10index, y = individual_effects)) +
  geom_point(aes(color = Gender), alpha = 0.7) +
  geom_smooth(method = "loess", se = TRUE) +
  labs(title = "Heterogeneous Treatment Effects by log10(i10-Index)",
       x = "log10(i10-Index)", y = "Estimated Treatment Effect (Gender on Salary)") +
  theme_minimal()
