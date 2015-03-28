---
title:	Distribute an amount over bins in proportion to an arbitrary probability distribution
author:	Richard de Rozario
date:	2015-03-14
subject:	discretization, bins, arbitrary distribution, R-code
description:	A basic method to distribute some total amount over a fixed number of bins or slots, in proportion to a probability distribution.  For example, assume that you have the total assets for a number of companies, but not the individual assets.  However, let's say that you can also assume that the assets are lognormally distributed among the companies.  The simple discretisation approach shown in this article will distribute the total assets across the companies in proportion to a lognormal probability distribution.
---

Here's a little task that I encounter repeatedly in practice:  distribute a total amount among a number of components in proportion to some probability distribution.  There is a simple technique for this, based on *discretization* of a probability distribution.  In this article, I'll show some basic R methods to generalise a function like `discretize` to apply to an arbitrary probability distribution that we can select with a parameter.

As an example of the task, imagine that you have the total assets of a number of businesses, but not the individual assets.  However, with some reasonable, albeit simplifying, assumptions[^1] you can also surmise that the total assets are distributed lognormally among the businesses.  So, you'll want to take the total amount of assets and allocate it to the businesses so that if you were to plot the assets of each business the graph would look like a lognormal probability curve.

To explain "discretization", I'll first implement an example manually. Let's arbitrarily say we have $500M in assets, to be distributed among 50 businesses.


```r
# arbitrary example
Amount <- 500
N <- 51  # one extra for outer bin
```

The implementation steps are relatively simple.  First, get the "end points" of a standard lognormal curve. For distributions with infinite support, that means the quantiles that are as low (and high) as suits our purposes.  For simplicity, I'll use the first and 99^th^ percentile respectively.


```r
# quantiles representing end points of the distribution
bin <- list(start=NA,end=NA,step=NA)
bin[1:2] <- qlnorm(c(0.01,0.99))
```

Next, we'll create an evenly spaced sequence between the two endpoints.


```r
# calculate the bin size for N bins
bin$step <- (bin$end - bin$start) / N

# create all x between the end points
x <- seq(bin$start,bin$end,by=bin$step)
```

Lastly, we want to calculate the probabilities for each `x`. We'll use the cumulative probability distribution for that. Each `x` will have a cumulative probability, so to get the point probability, just subtract the cumulative probability of the preceding `x`.


```r
y <- plnorm(x)
px <- y[2:N]-y[1:(N-1)]
```

Given that the endpoints aren't the true ends of the distribution, we have to make an adjustment to ensure that calculated probabilities sum up to `100%`.  Then just multiply the total amount by the vector of probabilities to get the distribution.


```r
px <- px / sum(px)  # ensure total prob=100%
plot(x[2:N],px*Amount,main="Example allocation",axes=FALSE,
	 xlab="bins",ylab="Amount")
axis(2)
axis(1,at=x[2:N],labels=1:(N-1))
```

![](figure/AllocateExample-1.png) 

The example illustrates the how to do the calculation, but it would be useful to create a function that does this.  However, in the function we would like the option to choose the distribution. That is, we might want to distribute according to a `lognormal`, a `normal`, a `exponential`, etc.  -- we just want to specify the distribution of choice as a parameter, along with any distribution specific parameters.

Also, the discretisation technique is available more generally from the `actuar` library, so we may as well use that.  I'll show the function first and describe some particulars below.


```r
require("actuar", quietly=TRUE)

# distribute an amount M over n bins
# in proportion to some distribution pdist
distributeM <- function(nbins,amount=1,qmin=0.01,qmax=0.99,
						method="rounding",pdist=pnorm,...){
	distname <- substring(deparse(substitute(pdist)),2)
	qdistr <- get(paste('q',distname,sep=''))
	bin <- qdistr(c(qmin,qmax),...)
	bin[3] <- (bin[2]-bin[1]) / nbins
	p <- discretize(pdist(x,...), method=method,
			from=bin[1],to=bin[2],by=bin[3])
	p <- amount * p / sum(p)
	return(p)
}
```

Distribution functions such as `pnorm` have *names* in R. You assign such names to parameters, just like any other value. You can get the character string of those names with a function called `deparse`. However, if the name is stored in a parameter, you have to let `deparse` know that, by using the function `substitute` -- meaning "don't deparse the parameter name, but instead deparse the parameter value". Also, the `get` is almost the opposite of `deparse` -- given a name string, it retrieves a function (or object) name.  Lastly, the *elipses* in a function represent the unknown remaining parameters that a user might provide when calling the function. Put together these functions enable us to implement a function that applies to an arbitrarily chosen distribution.

Now an example using the `distributeM()` function. We'll select `plnorm` as the desired distribution, and the method `upper` to keep the results comparable with the manual example.

```r
# example plot using distributeM function
plot(distributeM(nbins=N,amount=Amount,method="upper",pdist=plnorm),
	main="Example allocation using discretise", 
	xlab="bins",ylab="Amount")
```

![](figure/examples-1.png) 


[^1]: For simplicity, assume that the businesses start from the same initial investment (i.e. asset size) and grow with the same, but random compounded rate. After a suitably long duration, the asset sizes of the businesses will be lognormally distributed, due to the Central Limit Theorem.
