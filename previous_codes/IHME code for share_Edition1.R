
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
  main.data_long_Number=main.data_long[which(main.data_long$metric_name=="Number"),]
  
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
  
    # DALY to Incidence ------------------------------------------------------
  
  # main.data.wide_Number$DALtoINC <- main.data.wide_Number$val_DALYs/main.data.wide_Number$val_Incidence
  # main.data.wide_Number$lower_DALtoINC <- main.data.wide_Number$lower_DALYs/main.data.wide_Number$lower_Incidence
  # main.data.wide_Number$upper_DALtoINC <- main.data.wide_Number$upper_DALYs/main.data.wide_Number$upper_Incidence
  
  # Prevalence to Incidence -------------------------------------------------
  
  main.data.wide_Number$PERtoINC <- main.data.wide_Number$val_Prevalence/main.data.wide_Number$val_Incidence
  main.data.wide_Number$lower_PERtoINC <- main.data.wide_Number$lower_Prevalence/main.data.wide_Number$lower_Incidence
  main.data.wide_Number$upper_PERtoINC <- main.data.wide_Number$upper_Prevalence/main.data.wide_Number$upper_Incidence
 
  # PCA Approach 3 ----------------------------------------------------------
  output.data <- data.frame()
  
  for(s in unique(main.data.wide_Number$sex_name)){
    for(a in unique(main.data.wide_Number$age_name)){
      pca_index <- main.data.wide_Number$sex_name==s & main.data.wide_Number$age_name==a
      pca_data <- main.data.wide_Number[pca_index,]
      pca_out <- PCA(pca_data[,c("MIR", "YLLtoYLD", "PERtoINC", "DALtoPER")], graph = F )
      score0 <- pca_out$ind$coord[,1]
      score1 <- 100*(score0 - min(score0))/(max(score0) - min(score0))
      pca_score=100 - score1
      score <- as.data.frame(pca_score)
      pca_data <- bind_cols(pca_data,score)
      output.data <- bind_rows(output.data,pca_data)
      cat(paste0("loop s: ",s," and age: ", a, " is done. \n"))
    }
  }
  
  save.dta13(output.data,file=paste(getwd(),"main_data.dta",sep = "/"))
  
  output.data <- output.data[output.data$age_name %in% age.cat,]
  
  
  output.data <- output.data %>% dplyr::rename(val_DALtoINC=DALtoINC, val_PERtoINC=PERtoINC, val_pca_score=pca_score, val_DALtoPER=DALtoPER)
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



create_map <- function(){
  
  path <- readline("Please paste \"main\" data file directory path here:")
  main.data <- read.dta13(gsub('"', "", gsub("\\\\", "/", path)))
  path2 <- readline("Please paste \"iso3.dta\" data file directory path here:")
  iso3 <- read.dta13(gsub('"', "", gsub("\\\\", "/", path2)))
  path3 <- readline("where do you want to save your Maps?")
  setwd(gsub('"', "", gsub("\\\\", "/", path3))) 
  
  data.map <- merge(main.data,iso3,by="location_name", all=T)
  data.map <- data.map[!is.na(data.map$year),]
  
  path4 <- readline("Please paste Map folder directory path here:")
  
  ogrListLayers(paste(gsub('"', "", gsub("\\\\", "/", path4)),"World_map.shp",sep="/"))
  map1 <- readOGR(paste(gsub('"', "", gsub("\\\\", "/", path4)),"World_map.shp",sep="/"), layer="World_map")
  

  res=c("pca_score")
  
  m=length(unique(data.map$year))*length(unique(res))*length(unique(data.map$sex_name))*length(unique(data.map$age_name))
  cat("Plotting ... \n")
  pbar <- txtProgressBar(min = 0, max = m, style = 3)
  seq=1
  for(y in unique(data.map$year)){
    for (r in unique(res)) {
      for (s in unique(data.map$sex_name)){
        for(a in unique(data.map$age_name)){
          
          if(r=="pca_score") r1="Quality of Care Index (%)"
          else if(r=="PERtoINC") r1="Prevalence to Incidence"
          else if(r=="DALtoPER") r1="DALY to Prevalence"
          else if(r=="YLLtoYLD") r1="YLL to YLD"
          else if(r=="MIR") r1="Mortality to Incidence"
          else r1=r

          index.map= data.map$year==y & data.map$sex_name==s & data.map$age_name==a
          subset.map=data.map[index.map,]
          subset.map.new=data.map[data.map$year==2017 & data.map$sex_name==s & data.map$age_name==a,]
          
          subset.map$col <- "gray"
          #head(subset.map)  
          n=5
          d=1/n
          depend=subset.map[,paste0(r)]
          depend.new=subset.map.new[,paste0(r)]
          
          #sub$cat = findInterval(mean_effcover,  quantile(mean_effcover, seq(0,1,by=1/n)[-c(1,(n+1))]    ) )
          cutter=quantile(subset.map[,paste0(r)],probs = seq(0,1,d),na.rm = T)
          cutter.new=quantile(subset.map.new[,paste0(r)],probs = seq(0,1,d),na.rm = T)
          
          subset.map$cat = findInterval(subset.map[,paste0(r)],   cutter.new,all.inside = T )   
          table(subset.map$cat)
          subset.map[subset.map$cat==(n+1) & !is.na(subset.map$cat) ,"cat"]=5
          if(r=="pca_score") col=(brewer.pal(n,"RdYlGn"))
          else col=rev(brewer.pal(n,"RdYlGn"))
          subset.map$col = col[subset.map$cat]  
          table(subset.map$col)
          
          #pdf(paste0("D:\\Erfan Ghasemi\\IHME Paper\\map\\CVD\\Map_",r,"_",y,"_",s,"_",".pdf")  ,width=7 , height=6)
          jpeg(paste(getwd(),paste0("Map_",r,"_",y,"_",s,"_",a,".jpeg"),sep = "/")  , width=6.5, height=3, units="in", res=600)
          
          par(mar=c(0, 0, 0, 0))
          
          plot(map1,col=subset.map$col[match(map1$ISO3,subset.map$iso3)],lwd=0.3)   
          
          #plot(map2 , add=T , col="#AADAFF")
          
          # title(main="Average Anuual Percent Change in Age-Standardized Incidence Rate In Both Sexes for All Cancers From 1990 th 2016" , cex.main=0.7, font=1)
          leg=rep(NA,5) 
          leg[1] = paste0(0," to ",round(cutter.new[2],2))
          for (k in 2:(n)) leg[k] = paste0(round(cutter.new[k],2)," to ",round(cutter.new[k+1],2))
          legend("bottomleft",inset=c(0.08,0.05),cex=0.5,pt.cex=0.9 ,legend=leg, col=col , title=paste0(r1) ,pch=15 , bty="n",text.font=1, ncol=1)
          dev.off()
          flush.console()
          Sys.sleep(0.02)
          setTxtProgressBar(pbar, seq)
          on.exit(close(pbar))
          seq=seq+1
          #cat(paste0("loop year: ",y," and responce: ", r," and sex: ", s, " and age: ", a," is done. \n"))
          
        }
      }
    }
  }
  
}


# Male to Female QI -------------------------------------------------------


male_to_female_map <- function(){
  
  path <- readline("Please paste \"main\" data file directory path here:")
  mtof <- read.dta13(gsub('"', "", gsub("\\\\", "/", path)))
  path2 <- readline("Please paste \"iso3.dta\" data file directory path here:")
  iso3 <- read.dta13(gsub('"', "", gsub("\\\\", "/", path2)))
  path3 <- readline("where do you want to save your Maps?")
  setwd(gsub('"', "", gsub("\\\\", "/", path3))) 
  
  path4 <- readline("Please paste Map folder directory path here:")
  
  ogrListLayers(paste(gsub('"', "", gsub("\\\\", "/", path4)),"World_map.shp",sep="/"))
  map1 <- readOGR(paste(gsub('"', "", gsub("\\\\", "/", path4)),"World_map.shp",sep="/"), layer="World_map")
  
  mtof <- merge(mtof,iso3,by="location_name", all=T)
  mtof <- mtof[!is.na(mtof$year),]
  mtof <- dcast(setDT(mtof), location_name+ iso3 + year+age_name  ~ sex_name, value.var = c("pca_score") )
  
  mtof$QI_Male_to_Female <- mtof$Male/mtof$Female
  
  
  ##### map
  data.map <- mtof
  
  m=length(unique(data.map$year))*length(unique(data.map$age_name))
  cat("Plotting ... \n")
  pbar <- txtProgressBar(min = 0, max = m, style = 3)
  seq=1
  for(a in unique(data.map$age_name)){
    for(y in unique(data.map$year)){
      index.map= data.map$year==y  & data.map$age_name==a
      subset.map=data.map[index.map,]
      subset.map.new=data.map[data.map$year==2017  & data.map$age_name==a,]
      
      subset.map$col <- "gray"
      #head(subset.map)  
      n=5
      d=1/n
      depend=subset.map[,"QI_Male_to_Female"]
      depend.new=subset.map.new[,"QI_Male_to_Female"]
      
      #sub$cat = findInterval(mean_effcover,  quantile(mean_effcover, seq(0,1,by=1/n)[-c(1,(n+1))]    ) )
      cutter=quantile(depend,probs = seq(0,1,d),na.rm = T)
      cutter.new=quantile(depend.new,probs = seq(0,1,d),na.rm = T)
      
      subset.map$cat = findInterval(depend$QI_Male_to_Female,   cutter )   
      table(subset.map$cat)
      subset.map[subset.map$cat==(n+1) & !is.na(subset.map$cat) ,"cat"]=5
      
      #col=(brewer.pal(n,"RdYlGn"))
      col=c("hotpink4","hotpink2","lightgreen","coral","coral3")
      subset.map$col = col[subset.map$cat]  
      table(subset.map$col)
      
      #pdf(paste0("D:\\Erfan Ghasemi\\IHME Paper\\map\\CVD\\Map_",r,"_",y,"_",s,"_",".pdf")  ,width=7 , height=6)
      jpeg(paste(getwd(),paste0("Map_QI_male to female_", y,"_",a,".jpeg"),sep="/")  , width=6.5, height=3, units="in", res=600)
      
      par(mar=c(0, 0, 0, 0))
      
      plot(map1,col=subset.map$col[match(map1$ISO3,subset.map$iso3)],lwd=0.3)   
      
      #plot(map2 , add=T , col="#AADAFF")
      
      # title(main="Average Anuual Percent Change in Age-Standardized Incidence Rate In Both Sexes for All Cancers From 1990 th 2016" , cex.main=0.7, font=1)
      leg=rep(NA,5) 
      leg[1] = paste0(0," to ",round(cutter.new[2],2))
      for (k in 2:(n)) leg[k] = paste0(round(cutter.new[k],2)," to ",round(cutter.new[k+1],2))
      legend("bottomleft",inset=c(0.08,0.05),cex=0.5,pt.cex=0.9 ,legend=leg, col=col , title="Male to Female Quality Index" ,pch=15 , bty="n",text.font=1, ncol=1)
      dev.off()
      flush.console()
      Sys.sleep(0.02)
      setTxtProgressBar(pbar, seq)
      on.exit(close(pbar))
      seq=seq+1
  }
  
  
}
}




# Age pattern -------------------------------------------------------------

age_pattern <- function(){
  path <- readline("Please paste \"main\" data file directory path here:")
  age.pat.data <- read.dta13(gsub('"', "", gsub("\\\\", "/", path)))
  path3 <- readline("where do you want to save your Plots?")
  setwd(gsub('"', "", gsub("\\\\", "/", path3))) 
  
  age.cat.pat=c(	"20 to 24",	"25 to 29",	"30 to 34",	"35 to 39",
                 "40 to 44",	"45 to 49",	"50 to 54",	"55 to 59",	"60 to 64",	"65 to 69",	
                 "70 to 74",	"75 to 79",	"80 to 84",	"85 to 89",	"90 to 94",	"95 plus")
  
  age.pat.data <- age.pat.data[age.pat.data$age_name %in% age.cat.pat & age.pat.data$sex_name!="Both",]
  age.pat.data <- age.pat.data[order(age.pat.data$age_name,age.pat.data$sex_name),]
  
  m=length(unique(age.pat.data$location_name))*length(unique(age.pat.data$year))
  cat("Plotting ... \n")
  pbar <- txtProgressBar(min = 0, max = m, style = 3)
  seq=1
  for (l in unique(age.pat.data$location_name)) {
    for(y in unique(age.pat.data$year)){
      index.age.pat=age.pat.data$location_name==l & age.pat.data$year==y
      age.data.subset=age.pat.data[index.age.pat,]
      ggplot(age.data.subset ) +
        geom_line(aes(x=factor(age_name), y=pca_score,color=sex_name,group=sex_name, linetype=sex_name),size=1)+
        scale_color_manual(breaks=c("Female", "Male"), values=c("firebrick","skyblue4"),label=c("Female", "Male"),name="Sex")+
        scale_linetype_manual(breaks=c("Female", "Male"), values=c(1,4,2),label=c("Female", "Male"),name="Sex") +
        #scale_x_continuous(breaks = seq(1990,2017,3))+
        theme_bw()+
        xlab("Age Group")+ylab("Quality and early detection index")+
        ggtitle(paste0(l)) +
        theme(
          axis.text.x  = element_text(angle=45, vjust=0.5, size=8.5),
          axis.text.y  = element_text(angle=90, hjust=0.5, size=8.5),
          panel.grid.minor = element_blank(),
          panel.grid.major = element_blank()
        )
      ggsave(paste(getwd(),paste0("Age Pattern_",l,"_",y,".jpeg"), sep="/"),width = 10, height = 6,dpi = 300)
      flush.console()
      Sys.sleep(0.02)
      setTxtProgressBar(pbar, seq)
      on.exit(close(pbar))
      seq=seq+1
    }
  }
  
}





distribution_plot <- function(){
  
  path <- readline("Please paste \"main_data_distribution_scatter.dta\" data file directory path here:")
  main.data <- read.dta13(gsub('"', "", gsub("\\\\", "/", path)))
  path2 <- readline("Please paste \"iso3.dta\" data file directory path here:")
  m <- read.dta13(gsub('"', "", gsub("\\\\", "/", path2)))
  path3 <- readline("where do you want to save your plots?")
  setwd(gsub('"', "", gsub("\\\\", "/", path3))) 
  
  year1 <- as.numeric(readline("Please enter first year:"))
  year2 <- as.numeric(readline("Please enter last year:"))
  
  # min_lim <- as.numeric(readline("Please enter lower limit of x axis plot:"))
  # max_lim <- as.numeric(readline("Please enter upper limit of x axis plot:"))

  

  ############################ sex plot sex dist 2017_1990###########################
  measure = c("DALYs", "Deaths", "Incidence", "Prevalence", "YLDs", "YLLs")
  
  d2017=main.data[main.data$year==year2,]
  d1990=main.data[main.data$year==year1,]
  
  M = measure[2]
  for( M in unique(d2017$measure)){
    
    f1990_m=d1990[d1990$measure==M & d1990$sex_name=="Male" & d1990$age_name=="All Ages" , ]
    f1990_f=d1990[d1990$measure==M & d1990$sex_name=="Female" & d1990$age_name=="All Ages" , ]
    f2017_m=d2017[d2017$measure==M & d2017$sex_name=="Male" & d2017$age_name=="All Ages" , ]
    f2017_f=d2017[d2017$measure==M & d2017$sex_name=="Female" & d2017$age_name=="All Ages" , ]
  
    f1990_m = f1990_m[f1990_m$location_name%in%m$location,]
 
    f1990_f = f1990_f[f1990_f$location_name%in%m$location,]
    f2017_m = f2017_m[f2017_m$location_name%in%m$location,]
    f2017_f = f2017_f[f2017_f$location_name%in%m$location,]
    
    
    den_1990_f =  density(f1990_f$value)
    den_1990_m =  density(f1990_m$value)
    den_2017_f =  density(f2017_f$value)
    den_2017_m =  density(f2017_m$value)
    
    den_1990_f_x = den_1990_f$x
    den_1990_f_y = den_1990_f$y
    den_1990_m_x = den_1990_m$x
    den_1990_m_y = den_1990_m$y
    
    den_2017_f_x = den_2017_f$x
    den_2017_f_y = den_2017_f$y
    den_2017_m_x = den_2017_m$x
    den_2017_m_y = den_2017_m$y
    
    x=c(den_1990_f_x,den_1990_m_x,
        den_2017_f_x,den_2017_m_x)
    y=c(den_1990_f_y,den_1990_m_y,
        den_2017_f_y,den_2017_m_y)
    
    range  = (max(y)-min(y))
    pdf(paste0("plot sex dist 2017_1990_",M,".pdf"),height = 6,width = 8)
    plot(-1,-1,xlim=c(min(x),max(x)),
         ylim=c(min(y),  max(y) + max(y)*2.5  ),yaxt="n",ylab="",xlab=paste0(M),main = "Countries Density plot")
    polygon(den_1990_f_x,den_1990_f_y,col=rgb(1,0,0,.5),border = F)
    polygon(den_1990_m_x,den_1990_m_y,col=rgb(0,0,1,.5),border = F)
    
    polygon(den_2017_f_x,den_2017_f_y+1.5*range,col=rgb(1,0,0,.5),border = F)
    polygon(den_2017_m_x,den_2017_m_y+1.5*range,col=rgb(0,0,1,.5),border = F)
    
    text(max(x),max(y)/2,"1990",cex=1.2,col="gray20")
    text(max(x),max(y)*2,"2017",cex=1.2,col="gray20")
    
    legend("topright",legend = c("Female","Male"),pch=19,pt.cex=2,col=c("red","blue"))
    
    dev.off()
  }
}
  ########################## sex scater plot region ######################
  # m = read.dta13("worldshapefile/iso3.dta",convert.factors=T)
scatter_plot <- function(){
  path <- readline("Please paste \"main_data_distribution_scatter.dta\" data file directory path here:")
  main.data <- read.dta13(gsub('"', "", gsub("\\\\", "/", path)))
  path2 <- readline("Please paste \"iso3_region.dta\" data file directory path here:")
  reg <- read.dta13(gsub('"', "", gsub("\\\\", "/", path2)))
  path3 <- readline("where do you want to save your plots?")
  setwd(gsub('"', "", gsub("\\\\", "/", path3))) 
  
  
  # measure = c("DALYs", "Deaths", "Incidence", "Prevalence", "YLDs", "YLLs")
  year1 <- readline("Please enter year:")
  d=main.data[main.data$year==year1,]

  col  = distinctcolors(22)
  # plot(1:22,col=col,pch=19,cex=2)
  col=col[1:21]
  for( M in unique(d$measure)){
    f1=d[d$measure==M & d$sex_name=="Male" & d$age_name=="All Ages" , ]
    f2=d[d$measure==M & d$sex_name=="Female" & d$age_name=="All Ages", ]
    t = merge(f1,f2[,c("location_name","value")], suffixes = c(".1",".2") , by="location_name" , all=T  )
    # t=t[t$location_id!=533,]
    head(reg)
    t = merge(reg,t,by.x="location",by.y="location_name",all.x=T)
    t$region_id  = as.numeric( as.factor(t$region) )
    table(t$region,t$region_id)
    length(unique(t$region))
    t$col = col[t$region_id]
    
    pdf(paste0("plot sex scatter regions",M,".pdf"),height = 8,width = 10)
    plot(t$value.1,t$value.2,xlab="Male",ylab="Female",col=t$col,pch=20,cex=.9, 
         main = paste0(M," (Rate)\n","Countries scatter plot") )
    abline(0,1,col="gray50",lty=2)
    legend("topleft",legend = rownames(table(t$region,t$region_id)) , col = col,ncol=4,pch=19,pt.cex = 1.7 ,cex=.7 )
    dev.off()
  }
  
}



