# Causal Forest model
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
