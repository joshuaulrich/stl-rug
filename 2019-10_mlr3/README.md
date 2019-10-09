By: Matt Dube

mlr3 (https://mlr3.mlr-org.com/) is the next generation of the mlr R package. It provides a generic, object-oriented, and extensible framework for classification, regression, survival analysis, and other machine learning tasks for the R language.

This discussion will take a brief look at the past and present of machine learning in R, and then take a detailed look at how mlr3 attempts to refine and improve the current processes and tools. This will include a sample project code walkthrough, and references for further study.

## Presentation is in this order:

### mlr3_slides.Rmd --> requires 'xaringan' package to knit
  - intro, mlr3 overview
  - html output is included if you don't want to knit yourself
  - the `00_Extras` folder contains `mlr3.css` - put this file in:
    - `R Library Path` `/xaringan/rmarkdown/templates/xaringan/resources`

## Demo / Walkthroughs
### 01_basics.Rmd
  - intro to basic tasks, learners
  
### 02_Resampling.Rmd
  - adding in cross-validation, holdout, etc.
  
### 03_Tuning.Rmd
  - tuning hyperparameters manually and with AutoTune
  
### 04_Pipelines.Rmd
  - putting it all together for a complete workflow
  
### 05_Extras.Rmd
  - small example using MaridaDB (MySQL) as a data backend.
