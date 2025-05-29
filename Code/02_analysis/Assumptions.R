# 1. Unconfoundedness
# SMD (test whether < 0.1 after matching)
bal.tab(matchit_obj, un = TRUE)
# visualization
love_plot <- love.plot(matchit_obj)
matched_data <- match.data(matchit_obj)
plot(love_plot)  

# 2. Positivity
# Overlap checking
ggplot(matched_data, aes(x = propensity_score)) +
  geom_histogram(data = subset(data, Gender == 0), aes(y = after_stat(count)), 
                 binwidth = 0.02, color = "black", fill = "#619CFF", alpha = 0.6) +
  geom_histogram(data = subset(data, Gender == 1), aes(y = -after_stat(count)), 
                 binwidth = 0.02, color = "black", fill = "#F8766D", alpha = 0.6) +
  labs(title = "Propensity Score Overlap by Gender",
       x = "Propensity Score (PS)",
       y = "Frequency") +
  scale_y_continuous(labels = abs) + 
  annotate("text", x = 0.1, y = max(table(cut(data$propensity_score, breaks = seq(0, 1, by = 0.02)))), 
           label = "Male") +
  annotate("text", x = 0.1, y = -max(table(cut(data$propensity_score, breaks = seq(0, 1, by = 0.02)))), 
           label = "Female") + 
  theme_minimal(base_size = 14)

# 3. Consistency
# Control institution-Level variables (University and Department) --> see whether gender is significant influential factor
lm_fe <- lm(log10_Salary ~ Gender + factor(University_Code) + factor(Department_Code) + log10_i10index + Titles + Working_Years, 
            data = data)
summary(lm_fe)
