rm(list = ls())
library(tidyverse)

#--------------------------------------------------------------------------------------
# Read all tables of interest from the working directory
#--------------------------------------------------------------------------------------
movie_summary <- read_csv("movie_summary.csv",
                          col_names = TRUE,
                          na = c("","NA","NULL"))

movie_production_companies <- read_csv("movie_production_companies.csv",
                                       col_names = TRUE,
                                       na = c("","NA","NULL"))

movie_ratings <- read_csv("movie_ratings.csv",
                          col_names = TRUE,
                          na = c("","NA","NULL"))

acting_credits <- read_csv("acting_credits.csv",
                           col_names = TRUE,
                           na = c("","NA","NULL"))

technical_credits <- read_csv("technical_credits.csv",
                              col_names = TRUE,
                              na = c("","NA","NULL"))

#--------------------------------------------------------------------------------------
# Calculate the length of movie display name
# Assumption 1: length of movie display name may be related to domestic box office
#--------------------------------------------------------------------------------------
movie_summary$name_length <- sapply(movie_summary$display_name,
                                    nchar,
                                    USE.NAMES = FALSE)

#--------------------------------------------------------------------------------------
# Assumption 2: We're only interested in those movies which have box office in America
#--------------------------------------------------------------------------------------
movie_summary1 <- filter(movie_summary,inflation_adjusted_domestic_box_office != 0)

#--------------------------------------------------------------------------------------
# Assumption 3: We're not interested in dvd or bluray spending(since the number of NAs
# in these columns occupy 70% of the total records)
#--------------------------------------------------------------------------------------
movie_summary1 <- select(movie_summary1,
                         -domestic_dvd_units,
                         -domestic_dvd_spending,
                         -domestic_bluray_units,
                         -domestic_bluray_spending)

#--------------------------------------------------------------------------------------
# Assumption 4: In acting_credits and technical_credits, we only care about top 5 biling 
# people because they are the most important actors/actress, contributors 
# in the movie or in the backend
#--------------------------------------------------------------------------------------
acting_credits <- filter(acting_credits,billing <= 5)
technical_credits <- filter(technical_credits,billing <= 5)
#--------------------------------------------------------------------------------------
# Inner join 4 tables above to movie_summary
#--------------------------------------------------------------------------------------
df1 <- inner_join(movie_summary1,movie_production_companies,
                 by = c("odid","display_name"))

df2 <- inner_join(df1,movie_ratings,
                 by = c("odid","display_name"))

df3 <- inner_join(df2,acting_credits,
                 by = c("odid","display_name"))

df4 <- inner_join(df3,technical_credits,
                 by = c("odid","display_name"))

colnames(df4)[c(24,25,28,29)] <- c("cast_billing","castperson",
                                        "technical_billing","technical_person")

write.csv(df4,file = "mainTable.csv",
          row.names = FALSE)

movie_maintable <- read.csv("mainTable.csv",
                            header = TRUE,
                            na = c("","NA","NULL"))
summary(movie_maintable)                          






























