Working with thick data in R

By: Alexander Mueller

There is a lot of conversation out there about "big" data and rarely is it mentioned just how it is big. There are at least two ways: your data might be "long" by having many rows, and / or it might be "thick" by having many columns. This presentation will focus on modeling challenges presented by thick data.

We will start by discussing some example thick datasets and examine the problems they create for standard modeling techniques like linear regression. I will spend a little bit of time giving some heuristic arguments covering the mathematical reasons why thick datasets can produce bad behavior and then transition into some discussion of which algorithms can be expected to behave well and why. Random forest algorithms and regularized linear regression algorithms like LASSO will be discussed in particular.

We will then use R to apply these more robust algorithms to our original thick dataset, examine and compare results, and use this information to fuel some general conversation about how to approach thick datasets in general.
