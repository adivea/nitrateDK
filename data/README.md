# Retrieving the data
The spatial analysis requires some data layers, which exceeds the maximum filesize on GitHub. To download the data, we have created a script ```data_download.rmd``` which automatically will run through [a folder on Google Drive](https://drive.google.com/drive/folders/1ZbnRr2CnVcMm0M2-v3AN7aOMlW5HMXfT?usp=sharing) with the required layers and download each file individually into this data folder. 

To retrieve the data for the analysis run the following from a unix-based bash:

```bash
cd groundwater_pollution_dk/data
bash data_download.sh
```