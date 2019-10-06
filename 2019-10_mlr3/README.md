# stlrug_mlr3
materials for Saint Louis R User Group 10/2/2019  presentation on mlr3 

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
