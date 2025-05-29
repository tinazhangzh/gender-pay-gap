library(tidyverse)
library(MatchIt)
library(cobalt)
library(sensitivity)
library(car)


# Data Cleaning
# 1) Deal with N/A in `Gender` manually
# List all data with N/A in `Gender`
genderize_data <- whole_data%>%filter(whole_data$ga_gender != "female" & whole_data$ga_gender != "male")
write.csv(genderize_data, "genderize_data.csv", row.names = FALSE)
# Deal with this dataset manually
update_genderize_data <- read.csv("update_genderize_data.csv")
# Put Back
cleaning_data1 <- read.csv("cleaning_data1.csv")
cleaning_data1

# 2) Sort Useful Columns & Rename Columns
# Calculate `Working Years`
cleaning_data2 <- cleaning_data1 %>%
  mutate(INITIAL.HIRE.DATE = dmy(INITIAL.HIRE.DATE)) %>%  
  mutate(Working_Years = 2024 - year(INITIAL.HIRE.DATE))
# Rename
cleaning_data2 <- cleaning_data2 %>%
  rename(Institution = INSTITUTION.NAME, Last_Name = LAST.NAME, First_Name = FIRST.NAME, Age = AGE, Titles = JOB.CATEGORY, Salary = EMPLOYEE.ANNUAL.BASE.SALARY, Department = EMPLOYEE.HOME.DEPARTMENT, Gender = ga_gender, Initial_Hire_Date = INITIAL.HIRE.DATE)
# Select Columns
cleaning_data2 <- cleaning_data2 %>% select(Institution, Last_Name, First_Name, Name, Age, Titles, Salary, Department, Gender, i10index, hindex, citedby, i10index5y, hindex5y, citedby5y, Error, Working_Years, Initial_Hire_Date)

# 3) Carnegie Classification for `University_Code`
cleaning_data3 <- cleaning_data2 %>%
  mutate(University_Code = case_when(
    Institution %in% c('ECSU', 'FSU', 'NCCU', 'WCU', 'UNCP') ~ 'master',
    Institution %in% c('UNCA', 'UNCSA', 'WSSU') ~ 'bachelor',
    Institution %in% c('NCSU', 'UNC-CH') ~ 'DU/VA',
    Institution %in% c('ASU', 'ECU', 'UNCC', 'UNCG', 'NCA&T', 'UNCW') ~ 'DRU(H)'
  ))
cleaning_data3 <- cleaning_data3 %>%
  mutate(University_Code = ifelse(University_Code %in% c("bachelor", "master"), 
                                  "bachelor/master", University_Code))

# 4) log transformation
cleaning_data3$log10_Salary <- log10(cleaning_data3$Salary)
cleaning_data3$log10_citedby <- log10(cleaning_data3$citedby + 1)
cleaning_data3$log10_hindex <- log10(cleaning_data3$hindex + 1)
cleaning_data3$log10_i10index <- log10(cleaning_data3$i10index + 1)
cleaning_data4 <- cleaning_data3

# 5) NLP Model to assign "department code"
# Department Code Definitions: 
# 1. Business
# 2. Technology and Engineering 
# 3. Arts and Humanities 
# 4. Medical and Health Sciences	
# 5. Natural Sciences 
# 6. Social Sciences 

# 6) Deparment Code Rename
cleaning_data5$Department_Code <- 
  dplyr::recode(cleaning_data5$Department_Code, 
                `1` = "B",
                `2` = "TE", 
                `3` = "AH", 
                `4` = "MHS",
                `5` = "NS",
                `6` = "SS"
  )
cleaning_data6 <- cleaning_data5

# 7) Gender to a binary variable 
# 1: female
# 0: male
cleaning_data6$Gender <- ifelse(cleaning_data6$Gender == "female", 1, 0)
cleaning_data7 <- cleaning_data6

# 8) Column `Google Scholar ID`
cleaning_data8 <- cleaning_data7 %>%
  mutate(`Google Scholar ID` = ifelse(Error == "No results", "No", "Yes"))

# 9) Others
cleaning_data8$Working_Years <- ifelse(cleaning_data8$Working_Years < 0, cleaning_data8$Working_Years + 100, cleaning_data8$Working_Years)
cleaning_data9 <- cleaning_data8

# 10) Convert N/A to mean value (based on `department_code`, `university_code`, `Titles`, and `Gender`) in log10_i10index
data <- cleaning_data9 %>%
  group_by(Department_Code, University_Code, Titles, Gender) %>%
  mutate(log10_i10index = ifelse(is.na(log10_i10index), 
                                 mean(log10_i10index, na.rm = TRUE), 
                                 log10_i10index)) %>%
  ungroup()
data <- data %>% drop_na(log10_i10index)
