# Gender Wage Gap in the University of North Carolina System

This repo contains code for analyzing gender-based salary disparities among tenure-track faculties in the University of North Carolina System using both descriptive regression and causal inference methods. 

[![arXiv](https://img.shields.io/badge/arXiv-2505.24078-b31b1b.svg)](https://arxiv.org/abs/2505.24078)

## 📁 Data

- **Source**: [UNC Salary Database (2022)](https://uncdm.northcarolina.edu/salaries/index.php)
- **Sample**: 12,039 faculty across 16 universities
- **Key variables**:
  - `salary`: annual salary (log10-transformed)
  - `gender`: inferred from first names using Genderize API + manual checks
  - `title`: Assistant, Associate, or Full Professor
  - `working_years`: 2022 - initial hire year
  - `university_code`: Carnegie classification (Bachelor/Master, DRU(H), DU/VA)
  - `department_code`: 6 broad fields (Arts and Humanities, Business, Medicine and Health Science, etc.)
  - `log10(i10_index)`: academic productivity metric from Google Scholar (with imputation)

> 📌 Preprocessing code in `01-cleaning/`


## 🧐 Assumptions Check

To ensure validity of causal estimates, we examine the following three key assumptions:

- **Unconfoundedness (No Unmeasured Confounding)**
  - Assumes that all covariates affecting both gender (as exposure) and salary (as outcome) are observed and included in the model
  - We incorporate rich covariate information: academic title, working years, department, institution, and academic productivity (i10-index)
  - Propensity Score Matching (PSM) is applied and covariate balance between male and female faculty before and after matching is examined to approximate this assumption
    
- **Positivity (Overlap)**
  - Requires that each faculty member has a positive probability of being either male or female given their covariates
  - Checked via distribution of estimated propensity scores: confirmed that common support exists across groups
  - Extreme propensity scores are trimmed to improve match quality

- **Consistency and SUTVA**
  - Assumes that one individual’s salary is not affected by another’s gender (no interference) and that gender is consistently defined
  - Plausible in this institutional context, where salaries are assigned individually and gender classification is binary and consistent across records

These checks support the identification strategy used in our PSM and Causal Forest estimations.


## ⚙️ Methods

Implemented in R:

- **Raw Gap**
  - Unadjusted average salary difference between male and female faculty
  - Provides a baseline, descriptive comparison
- **Ordinary Least Squares (OLS)**
  - Linear regression with key covariates (e.g., title, experience, institution, department, research productivity)
  - Provides a conditional estimate of the gender gap
  - Used as a baseline for comparison with causal estimates  
- **Propensity Score Matching (PSM)**  
  - Logistic model with interaction terms:
    - `title × working_years`
    - `university × department × i10_index`
  - Matched linear regression on log-salary
- **Causal Forest (via `grf`)**
  - Estimate ATE and ITE
  - Subgroup analysis by working years and research productivity

> 📌 R Scripts for both Assumptions Check and Methods are in `02-analysis/`


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
