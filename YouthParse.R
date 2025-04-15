
# Load libraries ----------------------------------------------------------
library(tidyverse)

# Load data ---------------------------------------------------------------
load('NSDUH_2023.Rdata')
NSDUH_2023 = puf2023_102124

# Select only variables of interest -------------------------------------------

# select those that answered the youth experiences questions
dfo <- NSDUH_2023[!is.na(NSDUH_2023$SCHFELT),] 

# make a vector of substance use column names
substance_cols <- c(   # quantitative values for frequency of use
                       'iralcfy', # alcohol frequency past year (1-365)
                       'irmjfy', # marijuana frequency past year (1-365)
                       'ircigfm', #cigarette frequency past month (1-30)
                       'IRSMKLSS30N', # smokeless tobacco frequency past month (1-30)
                       'iralcfm', # alcohol frequency past month (1-30)
                       'irmjfm', # marijuana frequency past month (1-30)
                       
                       # quantitative values for age of first use
                       'ircigage', # cigarette age of first use (1-55), 991=never used
                       'irsmklsstry', # smokeless tobacco age of first use (1-70), 991=never used
                       'iralcage', # alcohol age of first use (1-66), 991=never used
                       'irmjage', # marijuana age of first use (1-83), 991=never used
                       
                       # binary categories for use at all
                       'mrjflag', # marijuana ever used (0=never, 1=ever)
                       'alcflag', # alcohol ever used (0=never, 1=ever)
                       'tobflag', # any tobacco ever used (0=never, 1=ever)
                       
                       # multiclass categories for frequency of use 
                       'alcydays', # number of days of alcohol in past year (1-5 categories, 6=none)
                       'mrjydays', # number of days of marijuana in past year (1-5 categories, 6=none)
                       'alcmdays', # number of days of alcohol in past month (1-4 categories, 5=none)
                       'mrjmdays', # number of days of marijuana in past month (1-4 categories, 5=none)
                       'cigmdays', # number of days of cigarettes in past month (1-5 categories, 6=none)
                       'smklsmdays' # number of days of smokeless tobacco in past month (1-4 categories, 5=none)
                      ) %>% toupper()

# make a vector of demographic column names ------------------------
demographic_cols <- c(
                  'irsex', # binary sex (1=male, 2=female)
                  'NEWRACE2', # race (7 categories)
                  'HEALTH2', # overall health (4 categories)
                  'eduschlgo', # now going to school (1=yes, 2=no)
                  'EDUSCHGRD2', # what grade in now/will be in (11 categories, 98,99= blank/skip)
                  'eduskpcom', #how many days skipped school in past month (1-30, 94/97/98/99=blank/skip)
                  'imother', # for youth, mother in household (1=yes, 2=no, 3=don't know, 4=over 18)
                  'ifather', # for youth, father in household (1=yes, 2=no, 3=don't know, 4=over 18)
                  'income', # total family income (4 categories)
                  'govtprog', # got gov assistance (1=yes, 2=no)
                  'POVERTY3', # poverty level (4 categories)
                  'PDEN10', # population density (1= >1M people, 2=<1M people, 3=can't be determined)
                  'COUTYP4' # metro size status (1=large metro, 2=small metro, 3=nonmetro)
                  ) %>% toupper()

# select columns of interest
df_youth <- dfo %>% select(SCHFELT:RLGFRND) # use all youth questions, start with schfelt and go through rlgfrnd
df_substance <- dfo %>% select(substance_cols) # select specific substance columns of interest
df_demog <- dfo %>% select(demographic_cols)  # select specific demographic columns of interest

# combine into one data frame
df = cbind(df_substance, df_youth, df_demog) #combine into one data frame

# Fix metadata ------------------------------------------------------------

# make vector of columns from the data that should be converted to factors, unordered and ordered
unordered_factor_cols <- c(names(df_youth), # all columns from youth
                           'mrjflag','alcflag','tobflag', # binary flag columns from substance
                           'irsex','NEWRACE2','eduschlgo','imother','ifather','govtprog','PDEN10','COUTYP4' # unordered categories for demographics
                           ) %>% toupper()
ordered_factor_cols <- c('EDUSCHGRD2','HEALTH2','POVERTY3','income') %>% toupper()

# convert to factors
df[unordered_factor_cols] <- lapply(df[unordered_factor_cols], factor) # correct columns to unordered factors (e.g. yes, no)
df[ordered_factor_cols] <- lapply(df[ordered_factor_cols], factor, ordered=TRUE) # correct columns to ordered factors (e.g. small, medium, large)

# fix variable label metadata to only include the selected columns
new_labels <- attr(dfo,'var.labels')[match(names(df), attr(dfo,'names'))]
attr(df,'var.labels') <- new_labels

# note: use attr(df,'var.labels') to see the labeled data

youth_experience_cols = names(df_youth)

# Save cleaned data ------------------------
save(df, youth_experience_cols, substance_cols, demographic_cols, file = 'youth_data.Rdata')

# for use in Python
write_csv(df, file = 'youth_data.csv')
write_csv(NSDUH_2023, file = 'NSDUH_2023.csv')
