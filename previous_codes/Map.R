install.packages(c("cowplot", "googleway", "ggplot2", "ggrepel", 
                   "ggspatial", "libwgeom", "sf", "rnaturalearth", "rnaturalearthdata", "rgeos", "haven", "readstata13", "dplyr"))
                 
library("haven")
library("readstata13")
library("dplyr")
library("tidyr")
library("ggplot2")
theme_set(theme_bw())
library("sf")
library("rnaturalearth")
library("rnaturalearthdata")
library("rgeos")
data = read.dta13(file.choose(),nonint.factors=T)
t = read.dta13(file.choose(),nonint.factors=T)
data = merge(data, t, by = 'location_name')
data$Location = data$location_name
data$QCI = data$pca
data$iso = data$iso3_countries
data2 = filter(data, year == 2019, age_name == "Age-standardized", type %in% c("Country"))
world <- ne_countries(scale = "medium", returnclass = "sf")
world$iso = world$iso_a3
world = merge(world, data2, by = 'iso')
tiff("Figure1.tif",units = "cm",height = 13,width = 30,res = 300)
ggplot(data = world) +
  geom_sf(aes(fill = QCI)) +
  scale_fill_gradient(high = 'green',  low = 'red')
dev.off()
data3 = select(data2, Location, QCI)
