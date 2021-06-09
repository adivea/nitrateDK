Groundwater Pollution DK Metadata
================
Emil Trenckner Jessen & Johan Kresten Horsmans
10/06/2021

The following markdown contains metadata descriptions of the data used
for the `groundwater_pollution_dk.Rmd`-script (i.e. our Spatial
Analytics Exam 2021). For a detailed guide on how to download the data,
please see the repository
[README](https://github.com/emiltj/groundwater_pollution_dk/blob/master/README.md#prerequisites)

**Spatial Polygon Data**

  - `denmark_administrative_outline_boundary` A shapefile containing a
    polygon in the shape of Denmark, courtesy of the software company
    IGIS MAP.

  - `Markblok` A shapefile containing polygons of all current
    agricultural fields in Denmark as of April 2021. This dataset is
    provided by the Ministry of Food, Agriculture and Fisheries of
    Denmark (Danish Agricultural Agency)

  - `Oekologiske_arealer_{2012 - 2020}` Shapefiles containing polygons
    of all organic agricultural fields in Denmark, registered each year
    between the period of 2012 to 2020. This dataset is provided by the
    Danish Agricultural Agency.

**Agricultural Measurement Data**

  - `nitrate.csv` A csv-file containing point data with samples of
    nitrate levels in Denmark. This dataset contains 14,350 measurements
    of nitrate concentrations at different geographic locations in
    Denmark from 1900 to March 2021. The dataset was provided by
    courtesy of De Nationale Geologiske Undersøgelser for Danmark og
    Grønland (GEUS). The included variables used in our analysis are:
    * __‘WKT’__ (coordinates)*, *__‘Seneste’__ (measurement date)*, *__‘Seneste
    mg/l’__ (nitrate concentration (milligram/liter))* and *__‘Indtag
    topdybde’__ (measurement depth (metres))*.
