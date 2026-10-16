# Air Quality and Lung Health: An End-to-End Statistical Analysis in R

A reproducible R Markdown workflow that takes a raw epidemiological-style survey from messy import to publication-style inference: data typing and quality control, hypothesis testing with effect sizes, confounding, and multivariable regression (linear, logistic, Poisson).

**[View the rendered report](docs/lung_health_analysis.html)** (download the HTML and open it in a browser)

> **Data note.** The dataset is **simulated** (`scripts/simulate_lung_data.R`, fixed seed) so the true relationships are known and the workflow can be shared openly without patient data. The methods transfer directly to real cohort or biomonitoring data.

---

## Research question

Does exposure to fine particulate matter (PM2.5) relate to lung function and respiratory illness, after accounting for age, sex, smoking and body mass?

## Data

1,200 adults from four city zones (Park, Residential, Traffic Hub, Industrial), 15 variables:

| Type | Variables |
|---|---|
| Identifier / date | Participant_ID, Survey_Date |
| Categorical | Zone, Sex, Smoker, Respiratory_Illness |
| Ordinal | Exercise_Level (Low < Moderate < High), Mask_Use (Never < Sometimes < Always) |
| Continuous | Age, BMI, Sleep_Hours, PM25, Resting_HR, Lung_Capacity_L |
| Count | Cough_Days |

The data deliberately includes realistic problems: missing values (Sleep_Hours), a right-skewed exposure (PM2.5), and confounding between sex and smoking.

## What the analysis covers

1. **Data typing and wrangling** – IDs to character, dates to `Date`, nominal and ordered factors, integer counts; derived variables (age group, BMI category, PM2.5 band, survey month).
2. **Data quality** – missing-value audit (including whether missingness is related to the outcome), duplicates, range checks, IQR outliers.
3. **Descriptive statistics** – mean/SD/median/IQR/skewness tables, histograms, category frequencies.
4. **Distribution checks** – Shapiro-Wilk, QQ plots, log transformation of PM2.5.
5. **Group comparisons** – Welch t-test and Wilcoxon (Cohen's d), one-way ANOVA with Tukey post-hoc (eta-squared), Kruskal-Wallis with Holm-adjusted pairwise tests.
6. **Categorical association** – chi-square and Fisher tests, odds ratios, Cramér's V, standardised residuals.
7. **Correlation** – Pearson and Spearman, correlation heatmap, within-zone checks.
8. **Two-way ANOVA** – interaction effects (sex × smoking, zone × sex).
9. **Multivariable models** – linear regression with diagnostics, logistic regression with odds ratios, ROC AUC and predicted-probability curves, Poisson regression for counts with a dispersion check.

Every interpretation sentence in the report is generated from the computed results (inline R), so the text always matches the numbers.

## Key findings (seed 2026)

- **Dust and lung function:** PM2.5 correlates negatively with lung capacity (r = -0.41, p < 0.001); the link persists after adjustment (about -0.04 L per +10 µg/m³) and appears inside every zone.
- **Geography:** the Industrial zone has the lowest mean lung capacity (3.06 L) and the Park zone the highest (3.43 L); zone explains about 5% of the variance (ANOVA, p < 0.001).
- **Respiratory illness:** each +10 µg/m³ PM2.5 raises the odds by about 12% (OR 1.12); smokers have 2.9 times the odds (OR 2.87), adjusted for age, sex and PM2.5. Model discrimination is moderate (AUC 0.71).
- **Confounding:** smokers show almost no crude lung-capacity deficit (p = 0.20) because most smokers are men, who have larger lungs. Adjusting for sex in regression reveals the smoking effect.
- **Null result reported honestly:** sleep does not differ by sex (p = 0.37).

## Limitations

Simulated, cross-sectional data cannot support causal claims; with real data, unmeasured confounders (income, occupation, indoor air) would need consideration. Many tests are run for demonstration, and no formal multiple-testing correction is applied across the whole report.

## Repository structure

```
.
├── README.md
├── lung_health_analysis.Rmd        # the full analysis (knit this)
├── scripts/
│   └── simulate_lung_data.R        # generates the dataset (seeded)
├── data/
│   └── lung_health_study.csv
└── docs/
    └── lung_health_analysis.html   # rendered report
```

## How to reproduce

```r
install.packages(c("ggplot2", "rmarkdown", "knitr"))   # gridExtra is optional
# from the repository root:
source("scripts/simulate_lung_data.R")                 # optional: data/ already included
rmarkdown::render("lung_health_analysis.Rmd")
```

Tested with R 4.x. The core analysis uses base R (`stats`) plus `ggplot2` for figures.

## Skills demonstrated

Reproducible reporting (R Markdown), exploratory data analysis, statistical test selection and assumption checking, effect sizes, confounding and adjustment, generalised linear models (logistic, Poisson), model evaluation (ROC/AUC, dispersion), and clear scientific communication.

## Author

**Muhammad Imran Afzal** – MS Biotechnology, University of the Punjab, Lahore. Biostatistics and bioinformatics.

## License

MIT (code); data are synthetic and free to use.
