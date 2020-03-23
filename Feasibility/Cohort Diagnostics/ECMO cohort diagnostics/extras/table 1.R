# Table 1s
# create folder for tables and plots ----
if (file.exists(file.path(outputFolder, "diagnosticsExport", paste0("Results_", databaseId,
                                                                    "_plots_tables")))==FALSE){
  dir.create(file.path(outputFolder, "diagnosticsExport", paste0("Results_", databaseId,
                                                                 "_plots_tables")))
} 
# table settings -----
table1_specs<-getDefaultTable1Specifications()
table1_specs<-table1_specs %>% 
  filter(label!="CHADS2Vasc") %>% 
  filter(label!="Race") %>% 
  filter(label!="Ethnicity")  %>% 
  filter(label!="DCSI") 
table1_specs<-rbind(table1_specs,
                    data.frame(label="Age",
                               analysisId=2,
                               covariateIds=1002))
table1_specs<-rbind(table1_specs,
                    data.frame(label="Hospital Frailty Risk Score",
                               analysisId=926,
                               covariateIds=1926))

cov_settings<-createDefaultCovariateSettings()
cov_settings$DemographicsAge <- TRUE
cov_settings$DemographicsAgeGroup <- FALSE
cov_settings$Hfrs<-TRUE

covariateSettings <-createTable1CovariateSettings(specifications = table1_specs,
                                                  covariateSettings = cov_settings)

# get table 1 for main ECMO cohort -----
covariateData <- getDbCovariateData(connectionDetails = connectionDetails,
                                    cdmDatabaseSchema = cdmDatabaseSchema,
                                    cohortDatabaseSchema = cohortDatabaseSchema,
                                    cohortTable = cohortTable,
                                    cohortId = 3,   # ECMO cohort
                                    covariateSettings = covariateSettings,
                                    aggregated = TRUE)

table.1 <- createTable1(covariateData,
                        specifications=table1_specs,
                        output="one column")

#save
write.csv2(table.1, file.path(outputFolder, "diagnosticsExport", paste0("Results_", databaseId,
                                                                        "_plots_tables"), "table.1.csv"),
           row.names = FALSE)



# compare main ECMO cohort and sensitivity cohort with pneumonia -----
covariateData.pneumonia <- getDbCovariateData(connectionDetails = connectionDetails,
                                              cdmDatabaseSchema = cdmDatabaseSchema,
                                              cohortDatabaseSchema = cohortDatabaseSchema,
                                              cohortTable = cohortTable,
                                              cohortId = 4,   
                                              covariateSettings = covariateSettings,
                                              aggregated = TRUE)

table.1.pneumonia_comparison <- createTable1(covariateData, covariateData.pneumonia,
                                             specifications=table1_specs,
                                             output="one column")


#save
write.csv2(table.1.pneumonia_comparison, file.path(outputFolder, "diagnosticsExport", paste0("Results_", databaseId,
                                                                                             "_plots_tables"),
                                                   "table.1.pneumonia_comparison.csv"),
           row.names = FALSE)





# compare main ECMO cohort and ECMO age and 30 day only cohort -----
covariateData.age_30.day <- getDbCovariateData(connectionDetails = connectionDetails,
                                               cdmDatabaseSchema = cdmDatabaseSchema,
                                               cohortDatabaseSchema = cohortDatabaseSchema,
                                               cohortTable = cohortTable,
                                               cohortId = 2,   
                                               covariateSettings = covariateSettings,
                                               aggregated = TRUE)
table.1.age_30.day_comparison <- createTable1(covariateData, covariateData.age_30.day,
                                              specifications=table1_specs,
                                              output="one column")

#save
write.csv2(table.1.age_30.day_comparison, file.path(outputFolder, "diagnosticsExport", paste0("Results_", databaseId,
                                                                                              "_plots_tables"),
                                                    "table.1.age_30.day_comparison.csv"),
           row.names = FALSE)





# zip file with tables ----
wd<-getwd()
setwd(file.path(outputFolder, "diagnosticsExport"))

zip::zipr(zipfile=file.path(outputFolder, "diagnosticsExport", 
                            paste0("Results_", databaseId, "_plots_tables.zip")),
          paste0(paste0("Results_", databaseId,
                        "_plots_tables/"),
                 list.files(file.path(outputFolder, "diagnosticsExport", 
                                      paste0("Results_", databaseId, "_plots_tables")))))


setwd(wd)
unlink(file.path(outputFolder, "diagnosticsExport", 
                 paste0("Results_", databaseId, "_plots_tables")),
       recursive = T)

