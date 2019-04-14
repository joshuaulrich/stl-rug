By: John Snyder

Bayesian Additive Regression Trees, or BART, is a highly flexible machine learning approach which is gaining popularity in recent years. In additional to being high performing, it has numerous advantages as a result of being a fully developed Bayesian technique such as obtaining credible intervals along with estimates, performing model free variable selection, and others. The bartMachine R package is a relatively recent(2016) implementation which adds many computational and practical quality of life improvements over the BART author's release.

This month, I will first provide a brief and high level overview of the BART structure and how the model is fit. I will then thoroughly discuss and demonstrate the practical usage of the package applied to publicly available datasets. Finally, I will demonstrate and show the results of a simulation demonstrating BART's consistently superior predictive performance over many popular machine learning techniques such as random forests and gradient boosting.

- Data_Demo.R contains the code for the example walked through in the slides.

- The Simulation folder contains code which test BART under simulation.  The main file is Simulation.R
