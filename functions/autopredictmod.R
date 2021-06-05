# A function to prepare graphable model-based predictions as quickly as possible.

# Verified to work with lm() and glm(), may work with other functions but no guarantees

# want: The variable that you want to allow to vary. All other variables will be held constant.
# ticks: The number of evenly-spaced x values to predict. Should be an integer.
# out="plot" returns a graph.
# out="pred" returns the predictions with x values appended at ...$x

autopredictmod <- function(model, data, want, ticks = 50, out = "plot") {
    
    # build the domain of the "want" variable
    
    wantx <- seq(
        min(eval(parse(text=want))),
        max(eval(parse(text=want))),
        length.out = ticks
        )
    
    # loop identifying covariates to be held constant
    constants <- as.character()
    for (i in 2:length(variable.names(model))) {
        if (variable.names(model)[i] != want) {
            constants <- c(constants, variable.names(model)[i])
        }
    }

    # loop converting list of constants into list of vector of arguments strings
    string <- as.character()
    for (j in 1:length(constants)) {
        avg <- paste("mean(",constants[j],", na.rm = TRUE)")
        string <- c(string, paste0(constants[j], "=", avg))
    }

    # collapse the vector
    string2 <- paste(string, collapse=",")
    
    # string command creating predicition data frame
    cmd1 <- paste(
        "with(data, data.frame(want=wantx,",
        string2,
        "))"
    )
    
    # make the prediction data frame
    newdata <- eval(parse(text=cmd1))
    names(newdata)[names(newdata)=="want"] <- eval(want)
    
    # predict
    autopreds <- predict(model, newdata, type="response", se.fit=TRUE)
    
    # define the CI for the plot
    lb <- autopreds$fit - (1.96*autopreds$se.fit)
    ub <- autopreds$fit + (1.96*autopreds$se.fit)
    
    # output
    if (out == "plot") {
        return(
            plot(wantx,autopreds$fit, type="l",xlab=want, ylab="predicted value") +
            lines(wantx,lb, lty=2) +
            lines(wantx,ub, lty=2)
        )
    }
    if (out == "preds") {
        autopreds$x <- wantx
        outdata <- data.frame(
            x = autopreds$x,
            fit = autopreds$fit,
            lb = lb,
            ub = ub
        )
        return(outdata)
    }
    else {return(print("Error: Invalid 'out' requested; specify either 'plot' or 'pred'"))}
    
}

# example generating predicted probabilities for a probit model
# data(mtcars)
# attach(mtcars)
# mod <- lm(wt ~ disp + mpg, data=mtcars)

# autopredictmod(model=mod,data=mtcars,want="disp", out="plot")

# if you want to build the plot yourself, specify "preds" output
# ap <- autopredictmod(model=mod,data=mtcars,want="disp", out="preds")
# plot(ap$x,ap$fit,type="l",xlab="disp",ylab="predicted value") +
#    lines(ap$x,ap$lb, lty=2) +
#    lines(ap$x,ap$ub, lty=2)

# same as above, but with ggplot
# library(ggplot2)
# ap <- autopredictmod(model=mod,data=mtcars,want="disp", out="preds")
# ggplot(data=ap, aes(x=x,y=fit)) + 
#    geom_line() +
#    geom_ribbon(aes(ymin=lb,ymax=ub,fill=I("gray")),alpha=.5) +
#    labs(x="disp",y="predicted values")






