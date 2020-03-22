# Plots and tables

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



#export
write.csv2(table.1, file.path(outputFolder,  "table.1.csv"),
           row.names = FALSE)
zip::zipr_append(file.path(outputFolder, "diagnosticsExport", paste0("Results_", databaseId, ".zip")),
                 file.path(outputFolder,  "table.1.csv"))
unlink(file.path(outputFolder,  "table.1.csv"))



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

#export
write.csv2(table.1.pneumonia_comparison, file.path(outputFolder,  "table.1.pneumonia_comparison.csv"),
           row.names = FALSE)
zip::zipr_append(file.path(outputFolder, "diagnosticsExport", paste0("Results_", databaseId, ".zip")),
                 file.path(outputFolder,  "table.1.pneumonia_comparison.csv"))
unlink(file.path(outputFolder,  "table.1.pneumonia_comparison.csv"))




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

#export
write.csv2(table.1.age_30.day_comparison, file.path(outputFolder,  "table.1.age_30.day_comparison.csv"),
           row.names = FALSE)
zip::zipr_append(file.path(outputFolder, "diagnosticsExport", paste0("Results_", databaseId, ".zip")),
                 file.path(outputFolder,  "table.1.age_30.day_comparison.csv"))
unlink(file.path(outputFolder,  "table.1.age_30.day_comparison.csv"))

### -------------
# flow chart
library(DiagrammeR)
library(htmltools)
library(webshot)
webshot::install_phantomjs()


# get count without 30 day restriction (but with age as adult)
start.n<-as.numeric(getDbCovariateData(connectionDetails = connectionDetails,
                   cdmDatabaseSchema = cdmDatabaseSchema,
                   cohortDatabaseSchema = cohortDatabaseSchema,
                   cohortTable = cohortTable,
                   cohortId = 1,   
                   covariateSettings = createCovariateSettings(useDemographicsGender = TRUE),
                   aggregated = TRUE)$metaData$populationSize)
n.with.30.days<-covariateData



# inclusion stats
inclusion<-read.csv(unz(file.path(outputFolder, "diagnosticsExport", 
                       paste0("Results_", databaseId, ".zip")),
             "inclusion_rule_stats.csv")) 
inclusion<-inclusion %>% 
  filter(cohort_id==4) %>% 
  select("rule_name", "remain_subjects")
inclusion$remain_subjects<- ifelse(
  inclusion$remain_subjects== "-5",
  paste0("\u2264", "5"),
  as.character(inclusion$remain_subjects))
  


flowchart<-"digraph flowchart {

# node definitions with substituted label text
node [fontname = Helvetica, shape = rectangle]
tab1 [label = 'ECMO, age 18 or older  (n: n.ecmo)']
tab2 [label = 'With 30 days of prior history (n: n.prior)']
tab3 [label = 'ARDS (n: n.ARDS)']
tab4 [label = 'No transplant (n: n.trans)']
tab5 [label = 'No lung disease (n: n.lung)']
tab6 [label = 'No chest trauma (n: n.chest)']
tab7 [label = 'No pneumonectomy (n: n.pneum)']
tab8 [label = 'No pulmonary embolism (n: n.pe)']
tab9 [label = 'No cardiac procedure (n: n.card)']
tab10 [label = 'Pneumonia (n: n.pneu)'] 

# edge definitions with the node IDs
tab1 -> tab2 -> tab3 -> tab4 -> tab5-> tab6 -> tab7 -> tab8-> tab9 -> tab10;
}
"
flowchart<-gsub("n.ecmo", start.n , flowchart)
flowchart<-gsub("n.prior", inclusion$remain_subjects[1] , flowchart)
flowchart<-gsub("n.ARDS", inclusion$remain_subjects[2] , flowchart)
flowchart<-gsub("n.trans", inclusion$remain_subjects[4] , flowchart)
flowchart<-gsub("n.lung", inclusion$remain_subjects[5] , flowchart)
flowchart<-gsub("n.chest", inclusion$remain_subjects[6] , flowchart)
flowchart<-gsub("n.pneum", inclusion$remain_subjects[8] , flowchart)
flowchart<-gsub("n.pe", inclusion$remain_subjects[9] , flowchart)
flowchart<-gsub("n.card", inclusion$remain_subjects[10] , flowchart)
flowchart<-gsub("n.pneu", inclusion$remain_subjects[11] , flowchart)

grViz(flowchart) %>% html_print(viewer=NULL) %>% 
   webshot(file.path(outputFolder,  "inlusion.png"))






