# autoR
Collection of R functions to make common analysis tasks quicker. Eventually, I'll get around to packaging this. For now, it's just the functions.

## autopredictmod()
Produce predicted-value plots from an existing model.

```
autopredictmod(model, data, want, ticks=50, out="plot")
````

### Parameters

- `model` Model estimates
- `data` Data frame your estimates come from
- `want` x variable that you want to generate predictions for. All other variables are held constant at the mean.
- `ticks` Number of evenly spaced values of x to use. Should be an integer.
- `out` Specificy whether you want an automatic plot or a data frame that you can use to make a custom plot.

### Example

First, estimate a model

```
data(mtcars)
attach(mtcars)
mod <- lm(wt ~ disp + mpg, data=mtcars)
```

Option #1: Use the built-in plotter.
```
autopredictmod(model=mod,data=mtcars,want="disp", out="plot")
```
![plot output](/autopredictmod-plot.png "'plot' output")

Option #2: Get a data frame and build the plot yourself, such as with `ggplot()`
```
library(ggplot2)
ap <- autopredictmod(model=mod,data=mtcars,want="disp", out="preds")
ggplot(data=ap, aes(x=x,y=fit)) + 
    geom_line() +
    geom_ribbon(aes(ymin=lb,ymax=ub,fill=I("gray")),alpha=.5) +
    labs(x="disp",y="predicted values")
```

![preds output using ggplot](/autopredictmod-ggplot.png "'preds' output using ggplot")
