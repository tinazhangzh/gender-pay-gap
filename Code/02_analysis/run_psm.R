# PSM model
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
