# ==============================================================
#  SIMULATED DATASET: Air Quality and Lung Health Study
#  1200 adults, 15 variables, 4 city zones. Base R only.
#  Output: data/lung_health_study.csv   (fixed seed = reproducible)
#  Run from the repository root:  Rscript scripts/simulate_lung_data.R
# ==============================================================

# ---- 1. SETTINGS (edit these) ---------------------------------
out_dir  <- "data"
my_seed  <- 2026                          # change it to get a different dataset

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)


# ---- 2. FUNCTION THAT BUILDS THE DATASET ------------
make_lung_data <- function(seed) {

  set.seed(seed)
  n <- 1200                                              # number of participants

  # --- identifiers and dates ---
  Participant_ID <- 5000 + 1:n
  Survey_Date    <- as.Date("2026-01-05") + sample(0:89, n, replace = TRUE)

  # --- where the person lives (4 zones of the city) ---
  Zone <- sample(c("Industrial", "Traffic_Hub", "Residential", "Park"), n, replace = TRUE,
                 prob = c(0.20, 0.30, 0.30, 0.20))

  # --- the person ---
  Age <- round(pmin(pmax(rnorm(n, mean = 36, sd = 11), 18), 65))          # whole years
  Sex <- sample(c("Female", "Male"), n, replace = TRUE)
  Smoker <- ifelse(runif(n) < ifelse(Sex == "Male", 0.30, 0.06), "Yes", "No")
  Exercise_Level <- sample(c("Low", "Moderate", "High"), n, replace = TRUE,
                           prob = c(0.35, 0.40, 0.25))
  BMI <- round(pmin(pmax(rnorm(n, 24.5, 4), 15), 42), 1)
  Sleep_Hours <- round(pmin(pmax(rnorm(n, 6.9, 1.1), 3), 10), 1)          # same for men and women
  Sleep_Hours[sample(n, sample(20:60, 1))] <- NA                           # some left it blank

  # --- air: fine-dust exposure (PM2.5), right-skewed, highest in industrial areas ---
  pm_mean <- c(Industrial = 140, Traffic_Hub = 110, Residential = 70, Park = 40)
  PM25 <- round(rgamma(n, shape = 4, scale = pm_mean[Zone] / 4), 1)       # ug per cubic metre
  PM25 <- as.numeric(PM25)

  # --- mask use (ordered category) ---
  Mask_Use <- character(n)
  for (i in 1:n) {
    p <- if (PM25[i] > 100) c(0.25, 0.40, 0.35) else c(0.55, 0.30, 0.15)
    Mask_Use[i] <- sample(c("Never", "Sometimes", "Always"), 1, prob = p)
  }

  # --- body measurements and health outcomes ---
  Resting_HR <- round(78 - ifelse(Exercise_Level == "Moderate", 5, 0) -
                      ifelse(Exercise_Level == "High", 9, 0) +
                      0.3 * (BMI - 24.5) + rnorm(n, 0, 7))                # beats per minute

  Lung_Capacity_L <- round(3.3 + 0.7 * (Sex == "Male") - 0.02 * (Age - 36) -
                           0.35 * (Smoker == "Yes") - 0.004 * PM25 +
                           rnorm(n, 0, 0.35), 2)                          # litres

  Cough_Days <- rpois(n, lambda = 0.5 + 0.03 * PM25 + 3 * (Smoker == "Yes"))   # days per month
  Cough_Days <- pmin(Cough_Days, 30)

  logit <- -2.6 + 1.1 * (Smoker == "Yes") + 0.010 * PM25
  Respiratory_Illness <- ifelse(runif(n) < 1 / (1 + exp(-logit)), "Yes", "No")

  data.frame(Participant_ID, Survey_Date = format(Survey_Date), Zone, Age, Sex, Smoker,
             Exercise_Level, BMI, Sleep_Hours, Mask_Use, PM25, Cough_Days, Resting_HR,
             Lung_Capacity_L, Respiratory_Illness, stringsAsFactors = FALSE)
}


# ---- 3. CHECK THAT THE PLANTED EFFECTS ARE PRESENT ------------
#  If a random draw hides them, the script tries the next seed.
story_is_clear <- function(d) {
  p_sleep  <- t.test(Sleep_Hours ~ Sex, data = d)$p.value
  p_zone   <- summary(aov(Lung_Capacity_L ~ Zone, data = d))[[1]][["Pr(>F)"]][1]
  zmeans   <- tapply(d$Lung_Capacity_L, d$Zone, mean)
  p_smoke  <- chisq.test(table(d$Smoker, d$Respiratory_Illness))$p.value
  ct       <- cor.test(d$PM25, d$Lung_Capacity_L)
  skew     <- mean((d$PM25 - mean(d$PM25))^3) / sd(d$PM25)^3

  p_sleep > 0.20 &&                                          # sleep: no sex difference
    p_zone < 0.001 && names(which.min(zmeans)) == "Industrial" &&   # industrial = worst lungs
    p_smoke < 0.01 &&                                        # smoking linked to illness
    unname(ct$estimate) < -0.30 && ct$p.value < 0.001 &&     # more dust, smaller lungs
    skew > 0.8                                               # dust levels are right-skewed
}


# ---- 4. BUILD THE DATASET ------------------
attempt <- 0
repeat {
  d <- make_lung_data(seed = my_seed * 1000 + attempt)
  if (story_is_clear(d)) break
  attempt <- attempt + 1
}

write.csv(d, file.path(out_dir, "lung_health_study.csv"), row.names = FALSE)

cat("Done. Wrote", file.path(out_dir, "lung_health_study.csv"), "\n")
str(d)
