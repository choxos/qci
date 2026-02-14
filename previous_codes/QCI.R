
library(clipr)
library(tidyr)
library(dplyr)
library(readstata13)
library(data.table)
library(FactoMineR)
library(foreign)
library(RColorBrewer)
library(rgdal)
library(ggplot2)
library(readxl)
library(randomcoloR)
library(viridis)
library(ineq)
library(sp)
library(LSD)
library(reshape)
library(ff)
library(ffbase)
#library(missMDA)
# library(ggthemes)


# read and manage data ----------------------------------------------------
create_data <- function(){
  path <- readline("Please paste \"main\" data file directory path here:")
  main.data <- read.csv(gsub('"', "", gsub("\\\\", "/", path)))
  path2 <- readline("Please paste \"location_type.dta\" data file directory path here:")
  iso3 <- read.dta13(gsub('"', "", gsub("\\\\", "/", path2)))
  path3 <- readline("where do you want to save your Datasets?")
  setwd(gsub('"', "", gsub("\\\\", "/", path3))) 
  
  main.data <- main.data[which(main.data$location_id != 533),]
  main.data[which(main.data$measure_name=="DALYs (Disability-Adjusted Life Years)"),"measure_name"]="DALYs"
  main.data[which(main.data$measure_name=="YLDs (Years Lived with Disability)"),"measure_name"]="YLDs"
  main.data[which(main.data$measure_name=="YLLs (Years of Life Lost)"),"measure_name"]="YLLs"
  
  main.data_long <- main.data[ main.data$location_name %in% iso3$location_name,]
  
  
  # Determine age categories below ------------------------------------------
  
  age.cat <- c("Age-standardized")
  
  ########All age categories########### 
  # c("Under 5"    ,      "Early Neonatal"  , "Late Neonatal"  ,  "Post Neonatal"  ,  "1 to 4"   ,       
  #  "5 to 9"      ,     "10 to 14"    ,     "15 to 19"    ,     "20 to 24"   ,      "25 to 29"   ,     
  #  "30 to 34"    ,     "35 to 39"     ,    "40 to 44"     ,    "45 to 49"  ,       "50 to 54"   ,     
  #  "55 to 59"     ,    "60 to 64"     ,    "65 to 69"   ,      "70 to 74"    ,     "75 to 79"    ,    
  #  "80 plus"      ,    "All Ages"     ,    "5-14 years"   ,    "15-49 years"  ,    "50-69 years"   ,  
  #  "70+ years"   ,     "Age-standardized" ,"<1 year"       ,   "80 to 84"    ,     "85 to 89"     ,   
  #  "90 to 94"    ,     "<20 years"     ,   "10 to 24"   ,      "10 to 54"    ,     "95 plus"   ,  "Birth" )    
  
  
  
  
  main.data_long <- main.data_long[main.data_long$age_name %in% age.cat,]
  main.data_long_Rate=main.data_long[which(main.data_long$metric_name=="Rate"),]
  main.data_long_Number=main.data_long[which(main.data_long$metric_name=="Rate"),]
  
  main.data.wide_Rate <- data.table::dcast(setDT(main.data_long_Rate), location_id+location_name+year+sex_name+age_name ~ measure_name, value.var = c("val", "upper", "lower") )
  main.data.wide_Number <- data.table::dcast(setDT(main.data_long_Number), location_id+location_name+year+sex_name+age_name ~ measure_name, value.var = c("val", "upper", "lower") )
  ##
  ################## calculate by number data ################
  
  # MIR ---------------------------------------------------------------------
  
  main.data.wide_Number$MIR <- main.data.wide_Number$val_Deaths/main.data.wide_Number$val_Incidence
  main.data.wide_Number$lower_MIR <- main.data.wide_Number$lower_Deaths/main.data.wide_Number$lower_Incidence
  main.data.wide_Number$upper_MIR <- main.data.wide_Number$upper_Deaths/main.data.wide_Number$upper_Incidence
  
  # YLLs to YLDs ------------------------------------------------------------
  
  main.data.wide_Number$YLLtoYLD <- main.data.wide_Number$val_YLLs/main.data.wide_Number$val_YLDs
  main.data.wide_Number$lower_YLLtoYLD <- main.data.wide_Number$lower_YLLs/main.data.wide_Number$lower_YLDs
  main.data.wide_Number$upper_YLLtoYLD <- main.data.wide_Number$upper_YLLs/main.data.wide_Number$upper_YLDs
  
  # DALY to Prevalence ------------------------------------------------------
  
  main.data.wide_Number$DALtoPER <- main.data.wide_Number$val_DALYs/main.data.wide_Number$val_Prevalence
  main.data.wide_Number$lower_DALtoPER <- main.data.wide_Number$lower_DALYs/main.data.wide_Number$lower_Prevalence
  main.data.wide_Number$upper_DALtoPER <- main.data.wide_Number$upper_DALYs/main.data.wide_Number$upper_Prevalence
  
  # Prevalence to Incidence -------------------------------------------------
  
  main.data.wide_Number$PERtoINC <- main.data.wide_Number$val_Prevalence/main.data.wide_Number$val_Incidence
  main.data.wide_Number$lower_PERtoINC <- main.data.wide_Number$lower_Prevalence/main.data.wide_Number$lower_Incidence
  main.data.wide_Number$upper_PERtoINC <- main.data.wide_Number$upper_Prevalence/main.data.wide_Number$upper_Incidence
  
  # PCA Approach 3 ----------------------------------------------------------
  output.data <- data.frame()
  var_comp1 <- numeric(0)
  for(s in unique(main.data.wide_Number$sex_name)){
    for(a in unique(main.data.wide_Number$age_name)){
      pca_index <- main.data.wide_Number$sex_name==s & main.data.wide_Number$age_name==a
      pca_data <- main.data.wide_Number[pca_index,]
      pca_out <- PCA(pca_data[,c("MIR", "YLLtoYLD", "DALtoPER", "PERtoINC")], graph = F )
      score0 <- pca_out$ind$coord[,1]
      score1 <- 100*(score0 - min(score0))/(max(score0) - min(score0))
      pca_score=100 - score1
      score <- as.data.frame(pca_score)
      pca_data <- bind_cols(pca_data,score)
      output.data <- bind_rows(output.data,pca_data)
      var_comp1 <- c(var_comp1, pca_out$eig[1,2])
      cat(paste0("loop s: ",s," and age: ", a, " is done. \n"))
    }
  }
  
  var_comp1 <- as.data.frame(var_comp1)
  
  save.dta13(output.data,file=paste(getwd(),"main_data.dta",sep = "/"))
  save.dta13(var_comp1,file=paste(getwd(),"variance_component_1.dta",sep = "/"))
  output.data <- output.data[output.data$age_name %in% age.cat,]
  
  
  output.data <- output.data %>% dplyr::rename( val_MIR=MIR, val_YLLtoYLD=YLLtoYLD, val_DALtoPER=DALtoPER, val_PERtoINC=PERtoINC, val_pca_score=pca_score)
  main.data.wide_Rate <- base::merge(main.data.wide_Rate,output.data,by=c("location_name","year","sex_name","age_name"),suffixes=c("","_Number"))
  save.dta13(main.data.wide_Rate,file=paste(getwd(),"main_data_six_sigma.dta",sep = "/"))
  
  
  output.data_long1 <- data.table::melt(setDT(main.data.wide_Rate), id.vars=c("location_id","location_name","year","sex_name","age_name"), measure.vars=patterns("^val"),
                                        variable.name="measure", value.name="value")
  output.data_long1 <- output.data_long1[-grep("Number",output.data_long1$measure),]
  output.data_long1$measure <- gsub("val_","",output.data_long1$measure)
  
  output.data_long2 <- data.table::melt(setDT(main.data.wide_Rate), id.vars=c("location_id","location_name","year","sex_name","age_name"), measure.vars=patterns("^upper"),
                                        variable.name="measure", value.name="upper")
  output.data_long2 <- output.data_long2[-grep("Number",output.data_long2$measure),]
  output.data_long2$measure <- gsub("upper_","",output.data_long2$measure)
  
  output.data_long3 <- data.table::melt(setDT(main.data.wide_Rate), id.vars=c("location_id","location_name","year","sex_name","age_name"), measure.vars=patterns("^lower"),
                                        variable.name="measure", value.name="lower")
  output.data_long3 <- output.data_long3[-grep("Number",output.data_long3$measure),]
  output.data_long3$measure <- gsub("lower_","",output.data_long3$measure)
  
  output.data_long <- base::merge(base::merge(output.data_long1,output.data_long2,by=c("location_id","location_name","year","sex_name","age_name","measure"),all.x=T),output.data_long3,by=c("location_name","year","sex_name","age_name","measure"),all.x=T) 
  save.dta13(output.data_long,file=paste(getwd(),"main_data_distribution_scatter.dta",sep = "/"))
  
}

