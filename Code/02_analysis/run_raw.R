# Raw Model
# Wage Difference in Percetage 
average_salary_by_gender <- data %>%
  group_by(Gender) %>%
  summarise(mean_salary = mean(Salary, na.rm = TRUE))
male_salary <- average_salary_by_gender$mean_salary[average_salary_by_gender$Gender == 0]
female_salary <- average_salary_by_gender$mean_salary[average_salary_by_gender$Gender == 1]
gender_pay_gap <- (male_salary - female_salary) / male_salary * 100
