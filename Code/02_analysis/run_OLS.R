# Baseline Model (OLS)

baseline_model <- lm(
  log10_Salary ~ Gender + Titles + University_Code + Department_Code +
    Working_Years + log10_i10index,
  data = data
)
summary(baseline_model)
