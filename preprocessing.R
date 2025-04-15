library(utils);
library(tidyverse);
set.seed(112358);

# ensure script will execute correctly with file paths when run with source()
setwd(getSrcDirectory(function(){})[1]);

load("in/youth_data.Rdata");

# Some hardcoded transformations based on trying to maintain legitimate skip codes
transformDemographics <- function(data) {
  rdata <- data.frame(data);
  
  # change code 11 to 1 to consolidate yes answers (we'll just worry about what 
  # the answer was and also include EDUSKPCOM). Consolidate other codes to NaN
  rdata[["EDUSCHLGO"]] <- as.factor(ifelse(rdata[["EDUSCHLGO"]] %in% c(85, 94, 97, 98), NA,
                                           ifelse(rdata[["EDUSCHLGO"]] == 2, "Enrolled in School",
                                                  "Not Enrolled in School")));
  rdata <- rdata %>% mutate(EDUSCHLGO_T = EDUSCHLGO) %>% select(-EDUSCHLGO);
  
  # convert EDUSKPCOM to categorical so we can use the 99 responses
  rdata[["EDUSKPCOM"]] <- as.factor(ifelse(rdata[["EDUSKPCOM"]] == 0, "Skipped School",
                                           ifelse(rdata[["EDUSKPCOM"]] <= 30, "Did Not Skip School",
                                                  ifelse(rdata[["EDUSKPCOM"]] %in% c(94, 97, 98), NA,
                                                         "Question N/A"))));
  rdata <- rdata %>% mutate(EDUSKPCOM_T = EDUSKPCOM) %>% select(-EDUSKPCOM);
  
  # properly label blank grade answers
  rdata[["EDUSCHGRD2"]] <- as.factor(ifelse(rdata[["EDUSCHGRD2"]] %in% 1:11, rdata[["EDUSCHGRD2"]],
                                            ifelse(rdata[["EDUSCHGRD2"]] == 99, 99, NA)));
  rdata <- rdata %>% mutate(EDUSCHGRD2_T = EDUSCHGRD2) %>% select(-EDUSCHGRD2);
  
  return(rdata);
};


reconcileFreqCodes <- function(colname, colvec) {
  # Convert codes that represent no usage to 0 so they can be compared as numeric or ordinal
  yrfreq_or_agetry_names <- c("IRALCFY", "IRMJFY", "IRCIGAGE", "IRSMKLSSTRY",
                              "IRALCAGE", "IRMJAGE");
  mnthfreq_names <- c("IRCIGFM", "IRSMKLSS30N", "IRALCFM", "IRMJFM");
  ndays_6cats_names <- c("ALCYDAYS", "MRJYDAYS", "CIGMDAYS");
  ndays_5cats_names <- c("ALCMDAYS", "MRJMDAYS", "SMKLSMDAYS");
  if (colname %in% yrfreq_or_agetry_names) {
    return(ifelse((colvec == 991) | (colvec == 993), 0, colvec));
  }
  else if (colname %in% mnthfreq_names) {
    return(ifelse((colvec == 91) | (colvec == 93), 0, colvec));
  }
  else if (colname %in% ndays_5cats_names) {
    return(ifelse(colvec == 5, 0, colvec));
  }
  else if (colname %in% ndays_6cats_names) {
    return(ifelse(colvec == 6, 0, colvec));
  }
  return(colvec);
};

youth_nsduh_2023_transformed <- data.frame(df);

for (column in names(youth_nsduh_2023_transformed)) {
  youth_nsduh_2023_transformed[[column]] <- reconcileFreqCodes(column, youth_nsduh_2023_transformed[[column]]);
}

youth_nsduh_2023_transformed_old <- transformDemographics(youth_nsduh_2023_transformed);
youth_nsduh_2023_transformed <- youth_nsduh_2023_transformed_old %>% na.omit();
demographic_cols <- ifelse(demographic_cols %in% c("EDUSCHLGO", "EDUSCHGRD2", "EDUSKPCOM"),
                           paste0(demographic_cols, "_T"), demographic_cols);
save(youth_nsduh_2023_transformed, demographic_cols, youth_experience_cols,
     substance_cols, file="out/preprocessing/data/youth_nsduh_2023_transformed.Rdata");


# check sameness of distributions of features

# chi-squared tests for factors and ordered factors (and discrete numeric)
chisq.results <- list();
for (column in names(youth_nsduh_2023_transformed)) {
  if (!(is.factor(youth_nsduh_2023_transformed[[column]]) | is.ordered(youth_nsduh_2023_transformed[[column]]))) next;
  x <- as.factor(youth_nsduh_2023_transformed[[column]]);
  y <- as.factor(youth_nsduh_2023_transformed_old[[column]]);
  both_levels <- union(levels(x), levels(y));
  x <- factor(x, levels = both_levels);
  y <- factor(y, levels = both_levels);
  test.result <- chisq.test(table(x), table(y));
  chisq.results[[column]] <- c(test.result$p.value);
} 
chisq.results <- data.frame(chisq.results) %>%
  pivot_longer(cols=everything(), names_to="variable",
               values_to="p_value") %>%
  mutate(test_type = "chi_squared");


# kolmogorov-smirnov for discrete numeric
kolsmir.results <- list();
for (column in names(youth_nsduh_2023_transformed)) {
  if (!is.numeric(youth_nsduh_2023_transformed[[column]])) next;
  test.result <- ks.test(youth_nsduh_2023_transformed[[column]],
                         youth_nsduh_2023_transformed_old[[column]]);
  kolsmir.results[[column]] <- c(test.result$p.value);
}
kolsmir.results <- data.frame(kolsmir.results) %>%
  pivot_longer(cols=everything(), names_to="variable",
               values_to="p_value") %>%
  mutate(test_type = "kolmogorov_smirnov");

csv_path <- "out/preprocessing/data/goodness_of_fit_full_vs_clean.csv";
full_test.results <- rbind(chisq.results, kolsmir.results);
write.csv(full_test.results, csv_path, row.names=FALSE);


for (column in names(youth_nsduh_2023_transformed)) {
  if (!is.factor(youth_nsduh_2023_transformed[[column]]) & !is.ordered(youth_nsduh_2023_transformed[[column]])) next;
  bar_data <- data.frame(
    class = c(names(table(youth_nsduh_2023_transformed_old[[column]])),
              names(table(youth_nsduh_2023_transformed[[column]]))),
    freq = c(as.numeric(table(youth_nsduh_2023_transformed_old[[column]])),
             as.numeric(table(youth_nsduh_2023_transformed[[column]]))),
    dataset = c(rep("Original", length(table(youth_nsduh_2023_transformed_old[[column]]))),
                rep("NA Removed", length(table(youth_nsduh_2023_transformed[[column]]))))
  );
  png(paste0("out/preprocessing/plots/", column, "_freq_full_vs_clean.png"));
  ggplot(data=bar_data, mapping=aes(x=class, y=freq, fill = dataset)) +
    geom_bar(stat="identity", position="dodge") +
    ggtitle(paste0("Comparison of ", column, " distribution after removing NA values")) +
    scale_fill_manual(values=c("skyblue", "coral"));
  dev.off();
}

for (column in names(youth_nsduh_2023_transformed)) {
  if (!is.numeric(youth_nsduh_2023_transformed[[column]])) next;
  dens_data <- data.frame(
    value = c(youth_nsduh_2023_transformed_old[[column]],
              youth_nsduh_2023_transformed[[column]]),
    dataset = c(rep("Original", length(youth_nsduh_2023_transformed_old[[column]])),
                rep("NA Removed", length(youth_nsduh_2023_transformed[[column]])))
  );
  png(paste0("out/preprocessing/plots/", column, "_dens_full_vs_clean.png"));
  ggplot(data = dens_data) +
    geom_histogram(position="dodge", bins=30, mapping=aes(x=value, fill=dataset)) +
    ggtitle(paste0("Density of ", column, ": full vs cleaned dataset")) +
    scale_fill_manual(values=c("skyblue", "coral"));
  dev.off();
}