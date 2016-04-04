######################################## GEO Data Choropleth MAP #########################################################
install.packages("readxl")
library(readxl)

install.packages("rgeos")
library(rgeos)

install.packages("maptools")
library(maptools)

devtools::install_github("hadley/ggplot2")
install.packages("ggplot2")
library(ggplot2)   # devtools::install_github("hadley/ggplot2") only if you want subtitles/captions

install.packages("ggalt")
library(ggalt)

install.packages("ggthemes")
library(ggthemes)

devtools::install_github("hrbrmstr/albersusa")
library(albersusa) # devtools::install_github("hrbrmstr/albersusa")

install.packages("viridis")
library(viridis)

install.packages("scales")
library(scales)

# get the data and be nice to the server and keep a copy of the data for offline use

URL <- "http://www.cdc.gov/diabetes/atlas/countydata/OBPREV/OB_PREV_ALL_STATES.xlsx"
fil <- basename(URL)
if (!file.exists(fil)) download.file(URL, fil)

# it's not a horrible Excel file, but we do need to hunt for the data
# and clean it up a bit. we just need FIPS & 2012 percent info

wrkbk <- read_excel(fil)
obesity_2012 <- setNames(wrkbk[-1, c(2, 61)], c("fips", "pct"))
obesity_2012$pct <- as.numeric(obesity_2012$pct) / 100

# I may make a version of this that returns a fortified data.frame but
# for now, we just need to read the built-in saved shapefile and turn it
# into something ggplot2 can handle

cmap <- fortify(counties_composite(), region="fips")


gg <- ggplot()
gg <- gg + geom_map(data=cmap, map=cmap,
                    aes(x=long, y=lat, map_id=id),
                    color="#2b2b2b", size=0.05, fill=NA)
gg <- gg + geom_map(data=obesity_2012, map=cmap,
                    aes(fill=pct, map_id=fips),
                    color="#2b2b2b", size=0.05)
gg <- gg + scale_fill_viridis(name="Obesity", labels=percent)
gg <- gg + coord_proj(us_laea_proj)
gg <- gg + labs(title="U.S. Obesity Rate by County (2012)",
                subtitle="Content source: Centers for Disease Control and Prevention",
                caption="Data from http://www.cdc.gov/diabetes/atlas/countydata/County_ListofIndicators.html")
gg <- gg + theme_map(base_family="Arial Narrow")
gg <- gg + theme(legend.position=c(0.8, 0.25))
gg <- gg + theme(plot.title=element_text(face="bold", size=14, margin=margin(b=6)))
gg <- gg + theme(plot.subtitle=element_text(size=10, margin=margin(b=-14)))

##https://rud.is/b/2016/03/29/easier-composite-u-s-choropleths-with-albersusa/
