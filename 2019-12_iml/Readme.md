Visualizing Variable Effects in Black Box Models

By: John Snyder

Interpreting the effects of individual variables from flexible machine learning models such as random forests or neural networks can be a difficult task. Typically, the flexibility of these methods tends to obfuscate these effects in favor of superior predictive performance. This tradeoff can often leave the data scientist wondering how their inputs are working for them to achieve their predictive accuracy.

Visualization techniques such as Partial Dependence(PD), Individual Conditional Expectation(ICE) and Accumulated Local Effect(ALE) plots exist to recover some of the global interpretability we would get with a parametric model such as regression. These techniques frequently shed valuable insights into how the features relate to the target variable and make explaining results much easier.

This month, I will first provide a brief background on why these types of procedures are valuable additions to a data scientist's analytical toolkit. Then, I will discuss the practical usage of the Interpretable Machine Learning(iml) R package, which provides a suite of functionality for analyzing any black box machine learning model. Specifically, we will discuss how to create and interpret PD, ICE, and ALE plots.

