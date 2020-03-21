
# Plots and tables

# first, unzip results file
unzip(file.path(outputFolder, "diagnosticsExport", paste0("Results_", databaseId, ".zip")),
      exdir=file.path(outputFolder, "diagnosticsExport", paste0("Results_", databaseId)))

# folder for these tables and plots

if (file.exists(file.path(outputFolder, "diagnosticsExport", paste0("Results_", databaseId),
                          "plots_tables"))==FALSE){
  dir.create(file.path(outputFolder, "diagnosticsExport", paste0("Results_", databaseId),
                       "plots_tables"))
} 




# table 1 settings -----
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
                       output="list")

table.1 <- data.frame(
names=c(
  # age
  "Age (median [IQR])",
  # gender 
  "Sex (%)",
  # charlson
  "Charlson score (median [IQR])",
  # hopital fraility
  "Hospital Frailty Risk Score (median [IQR])",
  # rest
  table.1$part1[2,1],
  paste0(table.1$part1[3:17,1], " (%)"  ),
  table.1$part1[18,1],
  paste0(table.1$part1[19:25,1], " (%)"  ),
  table.1$part1[26,1],
  paste0(table.1$part1[27:29,1], " (%)"  ),
  table.1$part1[30,1],
  paste0(table.1$part1[31:48,1], " (%)"  )),
values=c(
# age
paste0(table.1$part2[14,2], " [", table.1$part2[13,2], " to ",  table.1$part2[15,2], "]"),
# gender 
table.1$part1[1,2],
# charlson
paste0(table.1$part2[6,2], " [", table.1$part2[5,2], " to ",  table.1$part2[7,2], "]"),
# hopital fraility
paste0(table.1$part2[22,2], " [", table.1$part2[21,2], " to ",  table.1$part2[23,2], "]"),
# rest
table.1$part1[-1,2])) 

table.1<-rbind(
  data.frame(names="n", 
             values=covariateData$metaData$populationSize),
table.1)

write.csv2(table.1, file.path(outputFolder, "diagnosticsExport", paste0("Results_", databaseId),
                                                    "plots_tables", "table.1.csv"),
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

write.csv2(table.1.pneumonia_comparison, file.path(outputFolder, "diagnosticsExport", paste0("Results_", databaseId),
                              "plots_tables", "table.1.pneumonia_comparison.csv"),
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

write.csv2(table.1.age_30.day_comparison, file.path(outputFolder, "diagnosticsExport", paste0("Results_", databaseId),
                                                   "plots_tables", "table.1.age_30.day_comparison.csv"),
           row.names = FALSE)


### -------------
# flow chart






attrition.plot<-grViz("digraph flowchart {

      # node definitions with substituted label text
      node [fontname = Helvetica, shape = rectangle]
      tab1 [label = '@@1']
      tab2 [label = '@@2']
      tab3 [label = '@@3']
      tab4 [label = '@@4']
      tab5 [label = '@@5']

      # edge definitions with the node IDs
      tab1 -> tab2 -> tab3 -> tab4 -> tab5;
      }

      [1]: 'Individuals in registry (n: 1,443)'
      [2]: 'With an observable index procedure (n: 1,441)'
      [3]: 'Index procedure was LRTI or simple trapeziectomy (n: 1382)'
      [4]: 'With full baseline data (n: 1023)'
      [5]: 'With at least one post-op PEM and EQ5D recorded (n: 746)'
      ")

attrition.plot %>% html_print(viewer=NULL) %>% 
  webshot("results/plots/attrition.png")
# zip -----

files <- list.files(file.path(outputFolder, "diagnosticsExport", paste0("Results_", databaseId)), 
      pattern = ".*\\.csv$")

list.files(file.path(outputFolder, "diagnosticsExport", paste0("Results_", databaseId),
           "plots_tables"))



zip(zipfile, files, flags = "-r9X", extras = "",
    zip = Sys.getenv("R_ZIPCMD", "zip"))

zip(zipfile=file.path(outputFolder, "diagnosticsExport", paste0("Results_", databaseId, ".zip")),
      files=file.path(outputFolder, "diagnosticsExport", paste0("Results1_", databaseId)))

