groundwater\_pollution\_dk
================
Johan Horsmans
05/06/2021

# Loading- and preprocessing data:

### Loading packages

``` r
library(pacman)
p_load(sf, raster, dplyr, tmap, ggplot2, tidyverse, lubridate, sp, gstat, ggthemes, lmtest)
```

### Loading nitrate data:

``` r
# Load the .csv-file as a dataframe and save it as "nitrate":
nitrate <- as.data.frame(read_csv("data/nitrate.csv")) 
```

``` r
# Rename columns to remove spaces and odd characters:
names(nitrate)[names(nitrate) == "Seneste"] <- "Seneste_måling" 
names(nitrate)[names(nitrate) == "Seneste mg/l"] <- "Seneste_mgl"
names(nitrate)[names(nitrate) == "Indtag topdybde"] <- "Indtag_topdybde" 
```

### Remove outliers (see written report for more info):

``` r
# Remove all nitrate-measures above 200:
nitrate <- nitrate %>%
  filter_at(vars("Seneste_mgl"), any_vars(. < 200))

# Remove all nitrate-measures below 0:
nitrate <- nitrate %>%
  filter_at(vars("Indtag_topdybde"), any_vars(. > 0))
```

### Processing the nitrate-dataframe to make it compatible with shapefile-format:

``` r
# Transform coordinate column to characters:
nitrate$WKT <- as.character(nitrate$WKT)

# Use Regex to remove non-coordinate characters:
nitrate$WKT <- gsub("POINT \\(", "", nitrate$WKT)
nitrate$WKT <- gsub(")", "", nitrate$WKT)
```

### Separate into two columns:

``` r
# Separate the longitude- and latitude coordinates into separate columns. The coordinates are separated by space (i.e. " "):
nitrate <- nitrate %>% 
  separate(col = WKT, into = c("longitude","latitude"), sep = " ") 
```

### Making it a shapefile:

``` r
nitrate <- st_as_sf(nitrate, coords = c("longitude", "latitude"))
```

### Inspecting “nitrate”:

``` r
head(nitrate)
```

    ## Simple feature collection with 6 features and 18 fields
    ## geometry type:  POINT
    ## dimension:      XY
    ## bbox:           xmin: 475687 ymin: 6095070 xmax: 707352 ymax: 6377856
    ## CRS:            NA
    ##                                                        Vis data    DGUnr.
    ## 1 http://data.geus.dk/JupiterWWW/proeve.jsp?proeveid=2008094446   5.  921
    ## 2 http://data.geus.dk/JupiterWWW/proeve.jsp?proeveid=2020051024 132. 2480
    ## 3 http://data.geus.dk/JupiterWWW/proeve.jsp?proeveid=2018025191 200. 9609
    ## 4 http://data.geus.dk/JupiterWWW/proeve.jsp?proeveid=2019018210  94. 2838
    ## 5 http://data.geus.dk/JupiterWWW/proeve.jsp?proeveid=1996010161 233.   10
    ## 6 http://data.geus.dk/JupiterWWW/proeve.jsp?proeveid=2006386596 217.  510
    ##                                                     Borerapport Indtag Analyser
    ## 1    http://data.geus.dk/JupiterWWW/borerapport.jsp?dgunr=5.921      1        1
    ## 2 http://data.geus.dk/JupiterWWW/borerapport.jsp?dgunr=132.2480     NA        1
    ## 3 http://data.geus.dk/JupiterWWW/borerapport.jsp?dgunr=200.9609      1        1
    ## 4  http://data.geus.dk/JupiterWWW/borerapport.jsp?dgunr=94.2838      1        1
    ## 5   http://data.geus.dk/JupiterWWW/borerapport.jsp?dgunr=233.10      1        1
    ## 6  http://data.geus.dk/JupiterWWW/borerapport.jsp?dgunr=217.510      1        1
    ##   Median mg/l Min. mg/l Maks. mg/l Indtag_topdybde
    ## 1           2         2          2             2.0
    ## 2           2         2          2             4.0
    ## 3           2         2          2             1.0
    ## 4           2         2          2            55.0
    ## 5           2         2          2            36.0
    ## 6           2         2          2            21.1
    ##              Topdybde forklaret Seneste_måling Seneste_mgl   objectid
    ## 1              Dybdetop anvendt     1989-06-01           2 2008094446
    ## 2 Boringdybde minus 2 m anvendt     1997-09-16           2 2020051024
    ## 3              Dybdetop anvendt     2016-10-31           2 2018025191
    ## 4              Dybdetop anvendt     2019-09-25           2 2019018210
    ## 5              Dybdetop anvendt     1995-06-12           2 1996010161
    ## 6              Dybdetop anvendt     1968-03-12           2 2006386596
    ##   symbol_ident symbol_size symbol_txt_size txt_search     rgb
    ## 1         NUM5          12               7    5.  921 0 255 0
    ## 2         NUM5          12               7  132. 2480 0 255 0
    ## 3         NUM3          12               7  200. 9609 0 255 0
    ## 4         NUM2          22              11   94. 2838 0 255 0
    ## 5         NUM5          19              10  233.   10 0 255 0
    ## 6         NUM5          16               9  217.  510 0 255 0
    ##                 geometry
    ## 1 POINT (557818 6377856)
    ## 2 POINT (508877 6148371)
    ## 3 POINT (701255 6174649)
    ## 4 POINT (475687 6208449)
    ## 5 POINT (707352 6095070)
    ## 6 POINT (690302 6134155)

### Loading land-use data:

``` r
# Loading "Markblok.shp" which contains all registered fields in Denmark:
all_fields <- st_read("data/Markblok.shp") %>% na.omit() 
```

    ## Reading layer `Markblok' from data source `/home/cds-au618771/cds-spatial/groundwater_polution_dk/data/Markblok.shp' using driver `ESRI Shapefile'
    ## replacing null geometries with empty geometries
    ## Simple feature collection with 476658 features and 6 fields (with 1 geometry empty)
    ## geometry type:  POLYGON
    ## dimension:      XY
    ## bbox:           xmin: 442061.7 ymin: 6049864 xmax: 892661.5 ymax: 6401571
    ## proj4string:    +proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs

``` r
# Convert "fields" to SpatialPolygons-object:
all_fields <- as_Spatial(all_fields$geometry)

# Load all registered ecological fields (from 2012 to 2020):
organic_fields_2012<-st_read("data/Oekologiske_arealer_2012.shp") %>% na.omit()
```

    ## Reading layer `Oekologiske_arealer_2012' from data source `/home/cds-au618771/cds-spatial/groundwater_polution_dk/data/Oekologiske_arealer_2012.shp' using driver `ESRI Shapefile'
    ## Simple feature collection with 49904 features and 5 fields
    ## geometry type:  POLYGON
    ## dimension:      XY
    ## bbox:           xmin: 445062.9 ymin: 6050575 xmax: 891630.3 ymax: 6391823
    ## proj4string:    +proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs

``` r
organic_fields_2013<-st_read("data/Oekologiske_arealer_2013.shp") %>% na.omit()
```

    ## Reading layer `Oekologiske_arealer_2013' from data source `/home/cds-au618771/cds-spatial/groundwater_polution_dk/data/Oekologiske_arealer_2013.shp' using driver `ESRI Shapefile'
    ## Simple feature collection with 49326 features and 5 fields
    ## geometry type:  POLYGON
    ## dimension:      XY
    ## bbox:           xmin: 445063.1 ymin: 6050575 xmax: 892019.1 ymax: 6391818
    ## proj4string:    +proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs

``` r
organic_fields_2014<-st_read("data/Oekologiske_arealer_2014.shp") %>% na.omit()
```

    ## Reading layer `Oekologiske_arealer_2014' from data source `/home/cds-au618771/cds-spatial/groundwater_polution_dk/data/Oekologiske_arealer_2014.shp' using driver `ESRI Shapefile'
    ## Simple feature collection with 47797 features and 5 fields
    ## geometry type:  POLYGON
    ## dimension:      XY
    ## bbox:           xmin: 445063.1 ymin: 6050576 xmax: 892019.6 ymax: 6391818
    ## proj4string:    +proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs

``` r
organic_fields_2015<-st_read("data/Oekologiske_arealer_2015.shp") %>% na.omit()
```

    ## Reading layer `Oekologiske_arealer_2015' from data source `/home/cds-au618771/cds-spatial/groundwater_polution_dk/data/Oekologiske_arealer_2015.shp' using driver `ESRI Shapefile'
    ## Simple feature collection with 48803 features and 5 fields
    ## geometry type:  POLYGON
    ## dimension:      XY
    ## bbox:           xmin: 445063.1 ymin: 6050576 xmax: 892017.4 ymax: 6391818
    ## proj4string:    +proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs

``` r
organic_fields_2016<-st_read("data/Oekologiske_arealer_2016.shp") %>% na.omit()
```

    ## Reading layer `Oekologiske_arealer_2016' from data source `/home/cds-au618771/cds-spatial/groundwater_polution_dk/data/Oekologiske_arealer_2016.shp' using driver `ESRI Shapefile'
    ## Simple feature collection with 59376 features and 5 fields
    ## geometry type:  POLYGON
    ## dimension:      XY
    ## bbox:           xmin: 444745.7 ymin: 6050576 xmax: 892017.4 ymax: 6392806
    ## proj4string:    +proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs

``` r
organic_fields_2017<-st_read("data/Oekologiske_arealer_2017.shp") %>% na.omit()
```

    ## Reading layer `Oekologiske_arealer_2017' from data source `/home/cds-au618771/cds-spatial/groundwater_polution_dk/data/Oekologiske_arealer_2017.shp' using driver `ESRI Shapefile'
    ## Simple feature collection with 66344 features and 5 fields
    ## geometry type:  POLYGON
    ## dimension:      XY
    ## bbox:           xmin: 442061.7 ymin: 6050576 xmax: 892017.4 ymax: 6398325
    ## proj4string:    +proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs

``` r
organic_fields_2018<-st_read("data/Oekologiske_arealer_2018.shp") %>% na.omit()
```

    ## Reading layer `Oekologiske_arealer_2018' from data source `/home/cds-au618771/cds-spatial/groundwater_polution_dk/data/Oekologiske_arealer_2018.shp' using driver `ESRI Shapefile'
    ## Simple feature collection with 74446 features and 6 fields
    ## geometry type:  POLYGON
    ## dimension:      XY
    ## bbox:           xmin: 442061.7 ymin: 6050576 xmax: 891630.3 ymax: 6398325
    ## proj4string:    +proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs

``` r
organic_fields_2019<-st_read("data/Oekologiske_arealer_2019.shp") %>% na.omit()
```

    ## Reading layer `Oekologiske_arealer_2019' from data source `/home/cds-au618771/cds-spatial/groundwater_polution_dk/data/Oekologiske_arealer_2019.shp' using driver `ESRI Shapefile'
    ## Simple feature collection with 80218 features and 6 fields
    ## geometry type:  POLYGON
    ## dimension:      XY
    ## bbox:           xmin: 442061.7 ymin: 6050576 xmax: 891705.8 ymax: 6398325
    ## proj4string:    +proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs

``` r
organic_fields_2020<-st_read("data/Oekologiske_arealer_2020.shp") %>% na.omit()
```

    ## Reading layer `Oekologiske_arealer_2020' from data source `/home/cds-au618771/cds-spatial/groundwater_polution_dk/data/Oekologiske_arealer_2020.shp' using driver `ESRI Shapefile'
    ## Simple feature collection with 80916 features and 6 fields
    ## geometry type:  POLYGON
    ## dimension:      XY
    ## bbox:           xmin: 442061.7 ymin: 6050576 xmax: 892069.6 ymax: 6401475
    ## proj4string:    +proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs

``` r
# Merge ecological field-geometries as "organic_fields":
organic_fields <- c(organic_fields_2012$geometry, organic_fields_2013$geometry, organic_fields_2014$geometry, organic_fields_2015$geometry, organic_fields_2016$geometry, organic_fields_2017$geometry, organic_fields_2018$geometry, organic_fields_2019$geometry, organic_fields_2020$geometry)

# Convert "organic_fields" to SpatialPolygons-object:
organic_fields <- as_Spatial(organic_fields)

# Make a new variable called "conventional_fields", where all polygons in "all_fields" that overlap with the polygons in "organic_fields" are removed:
conventional_fields <- all_fields[lengths(st_intersects(st_as_sf(all_fields),st_as_sf(organic_fields)))==0,]

# Assess how many organic fields have been filtered out:
length(all_fields) - length(conventional_fields)
```

    ## [1] 9756

9756 organic fields have been filtered out.

### Inspecting “conventional\_fields” and “organic\_fields”:

``` r
# Inspect "conventional_fields" and "organic_fields":
print("conventional fields:")
```

    ## [1] "conventional fields:"

``` r
head(conventional_fields)
```

    ## class       : SpatialPolygons 
    ## features    : 1 
    ## extent      : 480012.5, 480504.3, 6177890, 6178556  (xmin, xmax, ymin, ymax)
    ## crs         : +proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs

``` r
print("organic fields:")
```

    ## [1] "organic fields:"

``` r
head(organic_fields)
```

    ## class       : SpatialPolygons 
    ## features    : 1 
    ## extent      : 530727.8, 530839.2, 6288276, 6288385  (xmin, xmax, ymin, ymax)
    ## crs         : +proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs

### Plotting fields:

``` r
# Plot organic fields:
plot(organic_fields, main = "Organic fields:")
```

![](groundwater_pollution_dk_files/figure-gfm/unnamed-chunk-10-1.png)<!-- -->

``` r
# Plot conventional fields:
plot(conventional_fields, main = "Conventional fields:")
```

![](groundwater_pollution_dk_files/figure-gfm/unnamed-chunk-11-1.png)<!-- -->

### Taking subset of conventional fields to reduce computational load (see written report for more info):

``` r
# Subsetting "conventional_fields" to make it contain as many polygons as "organic_fields":
conventional_fields <- sample(conventional_fields, length(organic_fields))
```

### Setting CRS (for more info, see written report):

``` r
# Set the projection of the nitrate data as EPSG 25832:
nitrate <- st_set_crs(nitrate, value = 25832)

# Set the projection of the organic fields as EPSG 25832:
proj4string(organic_fields) <- CRS("+init=epsg:25832")
```

    ## Warning in `proj4string<-`(`*tmp*`, value = new("CRS", projargs = "+init=epsg:25832 +proj=utm +zone=32 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs")): A new CRS was assigned to an object with an existing CRS:
    ## +proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs
    ## without reprojecting.
    ## For reprojection, use function spTransform

``` r
# Set the projection of the conventional fields as EPSG 25832:
proj4string(conventional_fields) <- CRS("+init=epsg:25832")
```

    ## Warning in `proj4string<-`(`*tmp*`, value = new("CRS", projargs = "+init=epsg:25832 +proj=utm +zone=32 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs")): A new CRS was assigned to an object with an existing CRS:
    ## +proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs
    ## without reprojecting.
    ## For reprojection, use function spTransform

``` r
# Transform the geometry of the data to the assigned CRS:
organic_fields <- spTransform(organic_fields, CRS("+init=epsg:25832"))
conventional_fields <- spTransform(conventional_fields, CRS("+init=epsg:25832"))
nitrate <- st_transform(nitrate, crs=25832)

# Verify the data has been assigned new CRS:
head(nitrate)
```

    ## Simple feature collection with 6 features and 18 fields
    ## geometry type:  POINT
    ## dimension:      XY
    ## bbox:           xmin: 475687 ymin: 6095070 xmax: 707352 ymax: 6377856
    ## CRS:            EPSG:25832
    ##                                                        Vis data    DGUnr.
    ## 1 http://data.geus.dk/JupiterWWW/proeve.jsp?proeveid=2008094446   5.  921
    ## 2 http://data.geus.dk/JupiterWWW/proeve.jsp?proeveid=2020051024 132. 2480
    ## 3 http://data.geus.dk/JupiterWWW/proeve.jsp?proeveid=2018025191 200. 9609
    ## 4 http://data.geus.dk/JupiterWWW/proeve.jsp?proeveid=2019018210  94. 2838
    ## 5 http://data.geus.dk/JupiterWWW/proeve.jsp?proeveid=1996010161 233.   10
    ## 6 http://data.geus.dk/JupiterWWW/proeve.jsp?proeveid=2006386596 217.  510
    ##                                                     Borerapport Indtag Analyser
    ## 1    http://data.geus.dk/JupiterWWW/borerapport.jsp?dgunr=5.921      1        1
    ## 2 http://data.geus.dk/JupiterWWW/borerapport.jsp?dgunr=132.2480     NA        1
    ## 3 http://data.geus.dk/JupiterWWW/borerapport.jsp?dgunr=200.9609      1        1
    ## 4  http://data.geus.dk/JupiterWWW/borerapport.jsp?dgunr=94.2838      1        1
    ## 5   http://data.geus.dk/JupiterWWW/borerapport.jsp?dgunr=233.10      1        1
    ## 6  http://data.geus.dk/JupiterWWW/borerapport.jsp?dgunr=217.510      1        1
    ##   Median mg/l Min. mg/l Maks. mg/l Indtag_topdybde
    ## 1           2         2          2             2.0
    ## 2           2         2          2             4.0
    ## 3           2         2          2             1.0
    ## 4           2         2          2            55.0
    ## 5           2         2          2            36.0
    ## 6           2         2          2            21.1
    ##              Topdybde forklaret Seneste_måling Seneste_mgl   objectid
    ## 1              Dybdetop anvendt     1989-06-01           2 2008094446
    ## 2 Boringdybde minus 2 m anvendt     1997-09-16           2 2020051024
    ## 3              Dybdetop anvendt     2016-10-31           2 2018025191
    ## 4              Dybdetop anvendt     2019-09-25           2 2019018210
    ## 5              Dybdetop anvendt     1995-06-12           2 1996010161
    ## 6              Dybdetop anvendt     1968-03-12           2 2006386596
    ##   symbol_ident symbol_size symbol_txt_size txt_search     rgb
    ## 1         NUM5          12               7    5.  921 0 255 0
    ## 2         NUM5          12               7  132. 2480 0 255 0
    ## 3         NUM3          12               7  200. 9609 0 255 0
    ## 4         NUM2          22              11   94. 2838 0 255 0
    ## 5         NUM5          19              10  233.   10 0 255 0
    ## 6         NUM5          16               9  217.  510 0 255 0
    ##                 geometry
    ## 1 POINT (557818 6377856)
    ## 2 POINT (508877 6148371)
    ## 3 POINT (701255 6174649)
    ## 4 POINT (475687 6208449)
    ## 5 POINT (707352 6095070)
    ## 6 POINT (690302 6134155)

``` r
crs(organic_fields)
```

    ## CRS arguments:
    ##  +init=epsg:25832 +proj=utm +zone=32 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0
    ## +units=m +no_defs

``` r
crs(conventional_fields)
```

    ## CRS arguments:
    ##  +init=epsg:25832 +proj=utm +zone=32 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0
    ## +units=m +no_defs

### Filtering dates between 2012 and 2021:

``` r
nitrate <- nitrate %>%
 select(Seneste_måling, Seneste_mgl, geometry, Indtag_topdybde) %>%
 filter(Seneste_måling >= as.Date("2012-01-01") & Seneste_måling <= as.Date("2021-03-10"))
```

### Remove duplicate entries:

``` r
nitrate<-nitrate[!duplicated(nitrate$geometry), ]
```

### Plotting the nitrate-data:

``` r
plot(st_geometry(nitrate), pch = 16, cex = 0.4, main = "Nitrate measurements:")
```

![](groundwater_pollution_dk_files/figure-gfm/unnamed-chunk-16-1.png)<!-- -->

### Plotting nitrate measurement-points on top of organic fields (to assess CRS allignment):

``` r
plot(st_geometry(nitrate), pch = 16, cex = 0.4, col = "red", main = "Nitrate measurements (red) and organic fields (black):")
plot(organic_fields, add = TRUE)
```

![](groundwater_pollution_dk_files/figure-gfm/unnamed-chunk-17-1.png)<!-- -->

### Plotting points on top of all conventional fields (to assess CRS allignment):

``` r
plot(st_geometry(nitrate), pch = 16, cex = 0.4, col = "red", main = "Nitrate measurements (red) and conventional fields (black):")
plot(conventional_fields, add = TRUE)
```

![](groundwater_pollution_dk_files/figure-gfm/unnamed-chunk-18-1.png)<!-- -->

### Plotting points with nitrate per. mg/l metric:

``` r
ggplot(nitrate, aes(colour = Seneste_mgl)) +
  geom_sf() + coord_sf(datum = st_crs(25832)) + theme_solarized() + labs(title = "Nitrate measurements:", color = "Nitrate (mg/L)") + scale_colour_gradientn(colors = c("darkgreen", "yellow", "red")) + xlab("Metres") + ylab("Metres")
```

![](groundwater_pollution_dk_files/figure-gfm/unnamed-chunk-19-1.png)<!-- -->

# Exploratory statistics:

## The following sections is designed to create a plot with depth distributions for nitrate measurements carried out on conventional- and organic fields, respectively (see written report for more info).

### Creating a variable with convenional polygons in list-format:

``` r
conventional_polygon_list <- lapply(conventional_fields@polygons, function(x) SpatialPolygons(list(x)))
```

### Creating separate columns for nitrate X- and Y coordinates:

``` r
nitrate$X <- st_coordinates(nitrate)[,1]
nitrate$Y <- st_coordinates(nitrate)[,2]
```

### Finding nitrate measurements that fall within “conventional\_fields” polygons:

``` r
# Defining empty matrix for appending point-coordinates:
point <- matrix(ncol = 2)

# Create matrix with X- and Y coordinates for all nitrate measurements:
for (i in c(1:length(nitrate$geometry))){ # For the number of elements in in nitrate$geometry...
  p <- matrix(c(nitrate$X[i], nitrate$Y[i]), ncol = 2, byrow = TRUE) # ... iterate through X- and Y
  point <- rbind(p, point) # ... Append coordinates to "point"-matrix
}

# Remove NA in point matrix (generated when initializing the matrix):
point <- point %>% na.omit()

# Convert the point-matrix to "SpatialPoints"-object:
points <- SpatialPoints(point)

# Create variable called "conventional_overlap" with a function that goes through all points and polygons in the "conventional_polygon_list". If a point falls within a polygon it returns "1", if not it returns "NA":
conventional_overlap<-lapply(conventional_polygon_list, function(x) over(points, x))

# Create function that converts the "conventional_overlap"-variable to a regular list, rather than a nested list (for indexing purposes):
list_transform = function(x, sep = ".") {
    names(x) = paste0(seq_along(x))
    while(any(sapply(x, class) == "list")) {
        ind = sapply(x, class) == "list"
        temp = unlist(x[ind], recursive = FALSE)
        names(temp) = paste0(rep(names(x)[ind], lengths(x[ind])),
                             sep,
                             sequence(lengths(x[ind])))
        x = c(x[!ind], temp)
    }
    return(x)
}

# Apply the defined function to the "conventional_overlap"-variable:
conventional_overlap = list_transform(conventional_overlap)

# Create a variable "called "indexes", containing all nitrate-measurement-points falling within the conventional-field polygons. Note: the format is: "polygon:point":
indexes<-names(which(unlist(conventional_overlap) == 1))

# Print indexes:
indexes
```

    ##  [1] "206.2248"   "440.1567"   "2349.2883"  "4016.398"   "4016.456"  
    ##  [6] "5346.601"   "5346.886"   "5668.3343"  "6395.3320"  "7148.390"  
    ## [11] "8396.2598"  "8396.2966"  "8525.2217"  "9713.3058"  "9875.221"  
    ## [16] "10818.722"  "10818.2925" "10818.3364" "12348.2675" "12348.3404"

``` r
# Remove the "polygon"-index (i.e. the index before the ".")
indexes <- gsub("^[^.]+.", "", indexes)

# Transform to numeric variable:
indexes<-as.numeric(indexes)

# Create a new column called "land_type" and fill it with "Out of bounds":
nitrate$land_type <- "Out of bounds"

# Change the value for "land_type" to "conventional" for all the nitrate measurements overlapping with conventional field polygons:
for (i in indexes) {
  nitrate$land_type[i] <- "conventional"
}
```

### Finding nitrate measurements that fall within “organic\_fields” polygons:

``` r
organic_polygon_list <- lapply(organic_fields@polygons, function(x) SpatialPolygons(list(x)))
```

``` r
# Create variable called "organic_overlap" with a function that goes through all points and polygons in the "organic_polygon_list". If a point falls within a polygon it returns "1", if not it returns "NA":
organic_overlap<-lapply(organic_polygon_list, function(x) over(points, x))

# Apply the defined function to the "organic_overlap"-variable:
organic_overlap = list_transform(organic_overlap)

# Create a variable "called "indexes", containing all nitrate-measurement-points falling within the organic-field polygons. Note: the format is: "polygon:point":
indexes<-names(which(unlist(organic_overlap) == 1))

# Print indexes:
indexes
```

    ##  [1] "1335.1432"  "1402.2281"  "1402.3062"  "2468.210"   "4996.541"  
    ##  [6] "5458.462"   "5458.2328"  "5512.2536"  "5562.3128"  "7676.1111" 
    ## [11] "7888.1198"  "8099.3347"  "11732.979"  "12085.3375" "12156.352"

``` r
# Remove the "polygon"-index (i.e. the index before the ".")
indexes <- gsub("^[^.]+.", "", indexes)

# Transform to numeric variable:
indexes<-as.numeric(indexes)

# Change the value for "land_type" to "organic" for all the nitrate measurements overlapping with organic field polygons:
for (i in indexes) {
  nitrate$land_type[i] <- "organic"
}
```

### Plotting:

``` r
ggplot() +
  geom_density(nitrate, mapping = aes(Indtag_topdybde, colour = land_type)) + theme_solarized() + scale_colour_solarized() + labs(title = "Depth density plot:", color = "Nitrate (mg/L)") + xlab("Measurement depth") + ylab("Density")
```

![](groundwater_pollution_dk_files/figure-gfm/unnamed-chunk-25-1.png)<!-- -->

# Kriging:

### Make variogram by fitting X- and Y coordinates to nitrate mg/L:

``` r
vgm <- variogram(nitrate$Seneste_mgl ~ X + Y, nitrate)
plot(vgm)
```

<img src="groundwater_pollution_dk_files/figure-gfm/unnamed-chunk-26-1.png" width="65%" style="float:right; padding:10px" />

As seen on the plot to the right, it appears that it is quite hard to
find clear spatial correlations in the data. Nonetheless, it appears
that measurements within 55000 meters of each other are more correlated
than those further away. As such, we argue that this model can be used
for kriging, since it only needs to interpolate data that is close to
“real” data" (see written report for more info).

### Fit a model to the variogram:

``` r
# Use the above variogram to eyeball model parameters:
nugget <- 550 # Initial value.
psill <- 70 # Sealing - nugget.
range <- 55000 # Point where spatial correlation stops. 

# Fit the variogram to data:
v_model <- fit.variogram(
  vgm, 
  model = vgm(
    model = "Ste",
    nugget = nugget,
    psill = psill,
    range = range,
    kappa = 0.5
  )
)

# Show the fitted variogram on top of the binned variogram (ADELA TEXT)
plot(vgm, model = v_model)
```

![](groundwater_pollution_dk_files/figure-gfm/unnamed-chunk-27-1.png)<!-- -->

### Create kriging grid

``` r
# Find the dimensions of the nitrate data:
st_bbox(nitrate)
```

    ##    xmin    ymin    xmax    ymax 
    ##  449314 6064038  885215 6400597

``` r
# Using the st_bbox output, manually design a grid slightly larger than the bounding box (for prettier plots). Specify that the kriging resolution should be 2000 meter pr. estimate:
grid <- GridTopology(c(430734,6040448), c(2000, 2000), c(236, 190))

# Make the grid a GridTopology-object with the same CRS as the nitrate data:
gridpoints <- SpatialPoints(grid, proj4string = CRS(projection("+init=epsg:25832 +proj=utm +zone=32 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m
+no_defs")))

# Convert gridpoint to SpatialPixels:
spgrid <- SpatialPixels(gridpoints)

# Define coordinate names to be X and Y:
coordnames(spgrid) <- c("X", "Y")

# Plot the grid:
plot(spgrid)
```

![](groundwater_pollution_dk_files/figure-gfm/unnamed-chunk-28-1.png)<!-- -->

### Use fitted variogram model to interpolate new data to the grid defined above

``` r
# Force the nitrate CRS to be consistent with spgrid (otherwise error messages ensue):
nitrate_sp <- as(nitrate, "Spatial")
crs(nitrate_sp) <- crs(spgrid)

# Do kriging interpolations over the grid
nitrate_grid <- krige(Seneste_mgl ~ X + Y, nitrate_sp, newdata = spgrid, model = v_model)
```

    ## [using universal kriging]

``` r
# Plot the nitrate measurements on top of the kriged "nitrate_grid":

# Plotting raster:
tm_shape(nitrate_grid[1])  +
  tm_raster(title = "Nitrate mg/l", 
            style = "cont",
            palette = "-RdYlGn") +
  tm_credits(text = "Johan Horsmans & Emil Jessen") +
  tm_layout(main.title = "Nitrate pollution map") +
  
# Nitrate overlayed on raster:
tm_shape(nitrate_grid[1])  +
  tm_raster(title = "Nitrate mg/l", 
            style = "cont",
            palette = "-RdYlGn") +
tm_shape(nitrate) +
  tm_dots()
```

![](groundwater_pollution_dk_files/figure-gfm/unnamed-chunk-29-1.png)<!-- -->

### Load DK map

``` r
DK <- st_read("data/denmark_administrative_outline_boundary.shp")
```

    ## Reading layer `denmark_administrative_outline_boundary' from data source `/home/cds-au618771/cds-spatial/groundwater_polution_dk/data/denmark_administrative_outline_boundary.shp' using driver `ESRI Shapefile'
    ## Simple feature collection with 1 feature and 18 fields
    ## geometry type:  MULTIPOLYGON
    ## dimension:      XY
    ## bbox:           xmin: 8.074458 ymin: 54.55906 xmax: 15.19738 ymax: 57.75233
    ## CRS:            4326

### Inspect CRS

``` r
head(DK)
```

    ## Simple feature collection with 1 feature and 18 fields
    ## geometry type:  MULTIPOLYGON
    ## dimension:      XY
    ## bbox:           xmin: 8.074458 ymin: 54.55906 xmax: 15.19738 ymax: 57.75233
    ## CRS:            4326
    ##   gid    id country    name  enname locname            offname       boundary
    ## 1   1 50046     DNK Denmark Denmark Danmark Kongeriget Danmark administrative
    ##   adminlevel wikidata  wikimedia           timestamp note    path   rpath
    ## 1          2      Q35 da:Danmark 2020-01-02 22:59:02 <NA> 0,50046 50046,0
    ##   iso3166_2  tid territory_                       geometry
    ## 1      <NA> <NA>       <NA> MULTIPOLYGON (((11.90384 54...

We see that the map has the wrong CRS (i.e. 4326).

### Set correct CRS:

``` r
# Set the projection of the DK-map as EPSG 25832:
DK <- st_set_crs(DK, value = 4326)

# Transform the geometry of the map to the assigned CRS:
DK <- st_transform(DK, crs=25832)
```

### Inspect CRS:

``` r
head(DK)
```

    ## Simple feature collection with 1 feature and 18 fields
    ## geometry type:  MULTIPOLYGON
    ## dimension:      XY
    ## bbox:           xmin: 441626.5 ymin: 6049783 xmax: 893019.9 ymax: 6402282
    ## CRS:            EPSG:25832
    ##   gid    id country    name  enname locname            offname       boundary
    ## 1   1 50046     DNK Denmark Denmark Danmark Kongeriget Danmark administrative
    ##   adminlevel wikidata  wikimedia           timestamp note    path   rpath
    ## 1          2      Q35 da:Danmark 2020-01-02 22:59:02 <NA> 0,50046 50046,0
    ##   iso3166_2  tid territory_                       geometry
    ## 1      <NA> <NA>       <NA> MULTIPOLYGON (((687732.7 60...

### Crop raster to fit DK map (i.e. remove excess interpolations):

``` r
nitrate_raster <- raster(nitrate_grid)

nitrate_grid_cropped <- crop(nitrate_raster, extent(DK))
nitrate_grid_cropped <- raster::mask(nitrate_raster, DK)
```

### Make plot of interpolated data with DK map and nitrate measurements on top:

``` r
# Plotting raster:
tm_shape(nitrate_grid_cropped)  +
  tm_raster(title = "Nitrate mg/l", 
            style = "cont",
            palette = "-RdYlGn") +
  tm_credits(text = "Johan Horsmans & Emil Jessen") +
  tm_layout(main.title = "Nitrate pollution map",
            legend.position = c("right","top"),
            legend.bg.color = "white", legend.bg.alpha = .2, 
            legend.frame = "gray50",
            bg.color = "lightblue") +
  
# Points overlayed on raster:
tm_shape(nitrate) +
  tm_dots() +
  
# Adding DK-map:
tm_shape(DK) + 
  tm_polygons(alpha = 0.3)
```

![](groundwater_pollution_dk_files/figure-gfm/unnamed-chunk-35-1.png)<!-- -->

# Statistical modeling:

### Extracting all kriged nitrate-values falling within organic fields:

``` r
# Extract kriged nitrate data (r) that fall "within organic_fields":
organic_extraction <- suppressWarnings(raster::extract(x=nitrate_raster, y=organic_fields, fun=mean, df=TRUE, na.rm=TRUE))

# Add column land_type and specify that it should be "organic":
organic_extraction$land_type <- "organic"
```

### Extracting all kriged nitrate-values falling within conventional fields:

``` r
# Extract kriged nitrate data (r) that fall "within conventional_fields":
conventional_extraction <- suppressWarnings(raster::extract(x=nitrate_raster, y=conventional_fields, fun=mean, df=TRUE, na.rm=TRUE))

# Add column land_type and specify that it should be "conventional":
conventional_extraction$land_type<-"conventional"
```

### Merge the extraced data:

``` r
# Merge the extracted data as "merged":
merged <- rbind(organic_extraction, conventional_extraction)
```

Fit linear regression model with nitrate concentration predicted by land
type:

``` r
# Fit linear regression model with nitrate concentration (var1.pred) ~ land_type:
lm_model <- lm(var1.pred ~ land_type, data = merged)

# Perform coefficient t-test:
coeftest(lm_model, type = "HC1")
```

    ## 
    ## t test of coefficients:
    ## 
    ##                   Estimate Std. Error t value  Pr(>|t|)    
    ## (Intercept)      23.354430   0.058021 402.516 < 2.2e-16 ***
    ## land_typeorganic  1.154227   0.082054  14.067 < 2.2e-16 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

For interpretation of output, see written report.
