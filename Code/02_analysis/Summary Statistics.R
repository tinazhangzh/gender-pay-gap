if (!require("pacman")) install.packages("pacman")
pacman::p_load(janitor, broom, tidyverse, haven, corrplot, RColorBrewer,
               survival, ggsurvfit, survey, gtsummary, labelled, glmnet,
               forcats, fastDummies, stargazer, readstata13, table1, readr, 
               dplyr, knitr, kableExtra, ggplot2, moments, hms, stringr, dplyr)


data <- read.csv("whole_data.csv")

ggplot(data, aes(x = Salary)) +
  geom_density(fill = "skyblue", alpha = 0.5, size = 1) +
  scale_x_continuous(labels = dollar_format()) +
  labs(
    title = "Salary Distribution Density",
    x = "Annual Salary",
    y = "Density"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 11),
    legend.position = "bottom"
  )


ggplot(data, aes(x = log10_Salary)) +
  geom_density(fill = "skyblue", alpha = 0.5, size = 1) +
  labs(
    title = "Log10(Salary) Distribution Density",
    x = "Log Transformation Annual Salary",
    y = "Density"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 11),
    legend.position = "bottom"
  )


# Salary
table1(~ Salary + log10_Salary, data = data)

# Gender
cleaning_data1 <- read.csv("cleaning_data1.csv")
filtered_data1 <- cleaning_data1 %>% filter(EMPLOYEE.ANNUAL.BASE.SALARY >= 27000)
table1(~ ga_gender, data = filtered_data1)


ggplot(data, aes(x = i10index)) +
  geom_density(fill = "skyblue", alpha = 0.5, size = 1) +
  labs(
    title = "i10index Distribution Density",
    x = "i10index",
    y = "Density"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 11),
    legend.position = "bottom"
  )

ggplot(data, aes(x = log10_i10index)) +
  geom_density(fill = "skyblue", alpha = 0.5, size = 1) +
  labs(
    title = "log10(i10index) Distribution Density",
    x = "log10(i10index)",
    y = "Density"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 11),
    legend.position = "bottom"
  )


# Boxplot with jittered points
plot1 <- ggplot(data, aes(x = factor(Gender, labels = c("Male", "Female")), 
                          y = Salary, 
                          fill = factor(Gender, labels = c("Male", "Female")))) +
  geom_boxplot(alpha = 0.7, outlier.shape = NA) +
  geom_jitter(alpha = 0.1, width = 0.2, color = "darkgrey") +
  scale_y_continuous(labels = dollar_format(), 
                     limits = c(min(data$Salary), max(data$Salary))) +
  scale_fill_manual(values = c("#4477AA", "#EE6677")) +
  labs(title = "Distribution of Academic Salaries by Gender",
       x = "Gender",
       y = "Annual Salary",
       caption = sprintf("Gender Pay Gap: %.1f%%", gender_pay_gap)) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 11),
    legend.position = "none",
    plot.caption = element_text(hjust = 1, size = 10)
  )

# Density plot
plot2 <- ggplot(data, aes(x = Salary, 
                          fill = factor(Gender, labels = c("Male", "Female")))) +
  geom_density(alpha = 0.5) +
  scale_x_continuous(labels = dollar_format()) +
  scale_fill_manual(values = c("#4477AA", "#EE6677")) +
  labs(title = "Salary Distribution Density by Gender",
       x = "Annual Salary",
       y = "Density",
       fill = "Gender") +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 11),
    legend.position = "bottom"
  )

# Combine plots
combined_plots <- grid.arrange(plot1, plot2, ncol = 2)


# Create violin plot alternative
violin_plot <- ggplot(data, aes(x = factor(Gender, labels = c("Male", "Female")), 
                                y = Salary, 
                                fill = factor(Gender, labels = c("Male", "Female")))) +
  geom_violin(alpha = 0.7) +
  geom_boxplot(width = 0.2, alpha = 0.7, outlier.shape = NA) +
  scale_y_continuous(labels = dollar_format()) +
  scale_fill_manual(values = c("#4477AA", "#EE6677")) +
  labs(title = "Salary Distribution by Gender",
       subtitle = sprintf("Gender Pay Gap: %.1f%%", gender_pay_gap),
       x = "Gender",
       y = "Annual Salary") +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
    plot.subtitle = element_text(hjust = 0.5, size = 12),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 11),
    legend.position = "none"
  )

violin_plot
