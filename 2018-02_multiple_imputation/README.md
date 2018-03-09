By: Travis Loux

Missing data is a common problem in many types of data analyses. Most statistical software, including R, defaults to case deletion, or removing any cases with missing values for the relevant variables. This potentially incurs substantial loss of information and bias in the results. One option for working with missing data is multiple imputation.

In this talk, we will see a brief overview of what multiple imputation is and how to implement it in R using the [mice package](https://cran.r-project.org/package=mice). We will discuss when and why to impute data, how to impute data using mice, and how to use mice to analyze multiple imputed data sets and combine the results. Other packages for multiple imputation in R will also be given.
