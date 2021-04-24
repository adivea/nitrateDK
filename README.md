# Spatial Analytics exam project - Spring 2021

This repository contains the exam project on the relationship between groundwater polution and farms in Denmark

## Running the scripts

For running the scripts we recommend doing the following from your terminal both as a setup as well as doing the analysis of the data.

1. Clone the repo
```bash
git clone https://github.com/emiltj/spatial_exam.git
```
2. Download layers to layer folder
[Organic areas 2012-2020](https://filkassen.statens-it.dk/userportal/#/shared/public/1LYhhae2IbnGtiGO/%C3%98kologiske%20arealer)
[Wetland areas with nitrate problems 2021](https://filkassen.statens-it.dk/userportal/#/shared/public/3oUctK2FHIbMhRy_/Miniv%C3%A5domr%C3%A5dekort%202021)
[Wetland areas with nitrate problems 2020](https://filkassen.statens-it.dk/userportal/#/shared/public/ovpGodH6RpCw-kaq/Miniv%C3%A5domr%C3%A5der%202020)

3. Unzip organic layers
```bash
unzip spatial_exam/layers/Økologiske arealer.zip
```

4. Run the ```spatial_analysis.rmd```

5. ???

6. Profit


## Repo structure and files

This repository has the following directory structure:

| Column | Description|
|--------|:-----------|
```spatial_analysis.rmd```| Contains script used for the spatial analysis
```layers/``` | Folder which contains the different data layers used for the extraction
```README.md``` | This very readme with instructions
```LICENSE``` | [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0) which specifies the permitted usage of the repository

## Contact

Feel free to write the authors, Emil Jessen or Johan Horsmans for any questions regarding the scripts.
You may do so on Slack ([Emil](https://app.slack.com/client/T01908QBS9X/D01A1LFRDE0), [Johan](google.dk))
