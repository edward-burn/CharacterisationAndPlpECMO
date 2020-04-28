# install.packages("Rcpp")
# 
# devtools::install_github("OHDSI/DatabaseConnector")
# 
# devtools::install_github("OHDSI/CohortDiagnostics")

library(readr)
library(CohortDiagnostics)
library(dplyr)
library(stringr)

results.folder<-"C:/Users/eburn/Documents/ECMO_prediction/output/cohort diagnostics"
#results.folder<-"C:/Users/Ed/Dropbox/OHDSI/covid/ECMO/output/cohort diagnostics"

#CohortDiagnostics::launchDiagnosticsExplorer(results.folder)


# build table 1

working_cohort_id<-"171"
  
# CCAE
name<-"CCAE-1"

cohort_count<- read_csv(paste0(results.folder, "/Results_",name,"/cohort_count.csv"))
cohort<- read_csv(paste0(results.folder, "/Results_",name,"/cohort.csv"))
covariate <-  read_csv(paste0(results.folder, "/Results_",name,"/covariate.csv"))
covariate_value <-  read_csv(paste0(results.folder, "/Results_",name,"/covariate_value.csv"))


# chars_of_interest<-c("age group: 15-19", 
#                      "age group: 60-64", "age group: 65-69")

chars_of_interest<-data.frame(covariate %>%  filter(str_detect(covariate_name,
                                    'age group: |gender = MALE' ) ))

chars_of_interest<-chars_of_interest$covariate_name

characteristics<-covariate %>% 
  left_join(covariate_value,
            by="covariate_id")
characteristics<-characteristics %>% 
  left_join(cohort,
            by="cohort_id")
# keep only those of interest
characteristics<-characteristics %>% 
  filter(covariate_name %in% chars_of_interest)
#only cohort of interet
characteristics<-characteristics %>% 
  filter(cohort_id=={{working_cohort_id}})

characteristics %>% 
  mutate(value=paste0(mean, " (", sd, ")")) %>% 
  select(covariate_name, value)



rm(covariate,covariate_value,cohort)






a<-data.frame(ccae_characteristics) %>% 
  filter(str_detect(covariate_name, ' age'))
