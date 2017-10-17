By: Kay Apperson, PhD

This talk is inspired by my collaborations with the healthcare and financial services industries that often require data to be synthesized to protect personally identifiable information. In addition, many data warehouse systems also maintain a non-exact copy of the production data in their staging environments.

However, to simply randomly change individual values of the data will not do because the original characteristics (statistics, relationships among variables) must be maintained. This is so that the synthesized data could be analyzed in a meaningful way that its results are as close as the results from analyzing the original data itself. 

A relatively new R package called [synthpop](https://CRAN.R-project.org/package=synthpop) is a practical way to achieve these goals. I'll show you how to use synthpop and the comparisons between the original and synthesized datasets. After this talk, I hope you might be inspired to try synthpop or any other data synthesis approaches yourself.
