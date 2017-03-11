# Input load. Please do not change #
`dataset` = read.csv('C:/Users/wmclellan/AppData/Local/Radio/REditorWrapper_abc97372-2209-4004-9774-268efd0c55fe/input_df_dabb8db7-9400-45a5-9ccc-d7adb87929bc.csv', check.names = FALSE, encoding = "UTF-8", blank.lines.skip = FALSE);
# Original Script. Please update your script content here and once completed copy below section back to the original editing window #

#require(astsa)
#require(forecast)
#require(corrplot)
require(ggplot2)
require(reshape2)

# inspect data
head(dataset); tail(dataset)
summary(dataset)
class(Year)


# massage data
dataset[which(is.na(dataset$LivesLost)), "LivesLost"] <- 0
dataset <- dataset[order(dataset$Year),]
cor(dataset[, 2:3])
corrplot(cor(dataset[, 2:3]), method = "circle", tl.cex = 0.6, tl.srt = 45, tl.col = "black", type = "upper", order = "hclust")
head(dataset); tail(dataset)
attach(dataset)



# 6-year moving averages
window = 6
filter = rep(1 / window, window)

s.livesLost <- na.omit(filter(x = dataset$LivesLost, filter = filter, method = "convolution", sides = 1))
s.milex <- na.omit(filter(x = dataset$milex, filter = filter, method = "convolution", sides = 1))
s.mts <- ts.intersect(s.livesLost, s.milex)
plot(s.mts, type = 'l', col = "darkblue", lwd = 3)
ts.plot(s.mts, type = 'l', col = c("darkred", "darkblue"), lwd = 6)


head(s.livesLost); tail(s.livesLost)
length(s.livesLost)
nrow(dataset)
nrow(dataset[window:nrow(dataset),])
dataset$s.livesLost[window:nrow(dataset)] <- s.livesLost

length(s.milex)
dataset$s.milex[window:nrow(dataset)] <- s.milex

dataset[which(is.na(dataset$s.livesLost)), "s.livesLost"] <- 0
dataset[which(is.na(dataset$s.milex)), "s.milex"] <- 0


head(dataset); tail(dataset)
summary(dataset)
cor(dataset[, 2:ncol(dataset)])
corrplot(cor(dataset[, 2:5]), method = "circle", tl.cex = 0.6, tl.srt = 45, tl.col = "black", type = "upper", order = "hclust")

# smoothed variables are less correlated
lm <- lm(LivesLost ~ milex, data = dataset)
summary(lm)
#plot(lm)

# leading indicators?


livesLost <- ts(LivesLost)
milex <- ts(milex)
lag1.plot(milex, 1) # from package astsa, see https://onlinecourses.science.psu.edu/stat510/node/41
acf(milex)
lag.milex <- lag(milex, -1)
arima.livesLost <- auto.arima(livesLost)
summary(arima.livesLost) # no pattern
arima.milex <- auto.arima(milex)
summary(arima.milex) # no pattern


ar1fit = lm(livesLost ~ lag.milex) #Does regression, stores results object named ar1fit
summary(ar1fit) # This lists the regression results

plot(ar1fit$fit, ar1fit$residuals) #plot of residuals versus fits
acf(ar1fit$residuals, xlim = c(1, 18)) # ACF of the residuals for lags 1 to 18


ccfvalues = ccf(livesLost, milex)
ccfvalues
lag2.plot(livesLost, milex, 12)

# conclusion
# in the leadup to WW1, military expenditures are concurrent with livesLost, not a leading indicator

ts.plot(ts.intersect(livesLost, milex))
ts.plot(ts.intersect(livesLost, milex), type = 'l', col = c("darkred", "darkblue"), lwd = 6)

# plot a multiple time series with ggplot2
# see http://stackoverflow.com/questions/13324004/plotting-multiple-time-series-in-ggplot
melt.df <- melt(dataset[,1:3], id = "Year")
head(melt.df, 10)
gg <- ggplot(melt.df, aes(x = Year, y = value, colour = variable, group = variable))
gg + geom_line()
gg <- gg + geom_line(size = 2)
gg + scale_y_log10()

