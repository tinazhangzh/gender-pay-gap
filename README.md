# Gender Wage Gap in NC Public Universities

This repo contains code for analyzing gender-based salary disparities among professors in the North Carolina public university system using causal inference methods.

## 📁 Data

- **Source**: [UNC Salary Database (2022)](https://uncdm.northcarolina.edu/salaries/index.php)
- **Sample**: 12,039 faculty across 16 universities
- **Key variables**:
  - `salary`: annual salary (log10-transformed)
  - `gender`: inferred from first names using Genderize API + manual checks
  - `title`: Assistant, Associate, or Full Professor
  - `working_years`: 2022 - initial hire year
  - `university_code`: Carnegie classification (Bachelor/Master, DRU(H), DU/VA)
  - `department_code`: 6 broad fields (STEM, Humanities, Business, etc.)
  - `log10(i10_index)`: publication metric from Google Scholar (with imputation)

> 📌 Preprocessing code in `01-cleaning/`

## ⚙️ Methods

Implemented in R:

- **Raw gap**: unadjusted average salary difference
- **Propensity Score Matching (PSM)**  
  - Logistic model with interaction terms:
    - `title × working_years`
    - `university × department × i10_index`
  - Matched linear regression on log-salary
- **Causal Forest (via `grf`)**
  - Estimate ATE and ITE
  - Subgroup analysis by working years and research productivity

> 📌 Scripts in `02-analysis/`

## ▶️ Run Example

```r
# Run OLS analysis
source("02-analysis/run_OLS.R")

# Run PSM analysis
source("02-analysis/run_psm.R")

# Run Causal Forest analysis
source("02-analysis/run_causal_forest.R")
```

## 📦 Dependencies

```r
install.packages(c(
  "tidyverse", 
  "MatchIt", 
  "grf", 
  "table1", 
  "ggplot2"
))
```
