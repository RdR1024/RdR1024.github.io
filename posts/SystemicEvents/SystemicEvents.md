---
title: "Systemic events"
author: "Richard de Rozario"
date: 	2015-03-09
subject: operational risk, systemic events, modeling, R-code
description: One of the most significant things that the Basel II accord did for Operational Risk was to call attention to its heavy tailed nature. An organisation may have years of almost trivial losses, and then experience a loss event that is hundreds of times larger. This characteristic of rare and very large losses presents quite a challenge to quantitative models. Even fitting the data to heavy-tailed distributions doesn't usually solve the problem, and most loss-distribution based models will try to model the tail events separately.  However, there is not a lot of theory underneath the modelling that explains why the tail might be different.  A possible explanation is hinted at in casual conversation about operational losses, namely "systemic events" -- where multiple unit components (like multiple transactions, multiple customers, or multiple businesses) are affected by a single event.  In this blog post, I show with some simulations that systemic events could "hide" in the tail of ordinary loss distributions.  Most loss-distribution approaches do not try to capture the underlying mechanism that might explain why the tail is different.  However, without representing such mechanisms, such as systemic loss events, the models are risking their validity.
---



One of the most significant things that the Basel II accord did for Operational Risk was to call attention to its heavy tailed nature. An organisation may have years of almost trivial losses, and then experience a loss event that is hundreds of times larger. This characteristic of rare and very large losses presents quite a challenge to quantitative models. Even fitting the data to heavy-tailed distributions doesn't usually solve the problem, and most loss-distribution based models will try to model the tail events separately.  However, there is not a lot of theory underneath the modelling that explains why the tail might be different.

There is a lot of talk about mixture models, lack of data, correlations and so forth, but I wondered what a mechanism might be that would justify our supposition that the tail events are fundamentally different, yet intrinsically tied to the other losses. A possible explanation is hinted at in casual conversation about operational losses, namely "systemic events" -- where multiple unit components (like multiple transactions, multiple customers, or multiple businesses) are affected by a single event.

For example, imagine a payments process.  The stream of individual transactions will experience occasional losses, typically due to keying errors or similar mistakes. However, the process is also part of a network of other processes, such as customer on-boarding, setting fee and interest rates, and so forth. In hierarchical fashion, some processes can affect multiple lower level transactions.

So, what might loss distributions look like if you assume systemic effects, like a process hierarchy? 

Let's simulate an example, with some (I hope) reasonable assumptions. To start, assume a business process that is hierarchically organised, like the payments example above. Next, let's say that loss events (errors, frauds, interruptions, etc.) occur in the business operations at a rate of, say 360 per year, with a systemic event about 4 times a year. If an event occurs at a higher level process, then it affects multiple lower-level transactions -- in effect, it becomes multiple events.

We can model the systemic hierarchy using the [k-ary level probabilities](http://richardderozario.org/posts/karyl/karyl.html) that I wrote about in an earlier post.  Essentially, the k-ary hierarchy acts as an upper limit for the more random hierarchy that might exist in reality.  The closest k-ary tree for our assumptions will have a group size of 100 and a maximum level of 3. 

Experience shows that the impacts of operational losses are typically heavy-tailed (even without systemic events).  I'll chose the common lognormal distribution with a meanlog of 7 (about $1000) and standard deviation (log) of 2.  For the purposes of analysis, the parameter choices don't matter, except in relation to the systemic effects (more on that later). 

For simplicity, we'll keep the annual rate of events a constant, although for realistic models that would also be a random variable -- typically Poisson or Negative Binomially distributed.  Keeping the rate of events constant allows us to focus on the impact.  With the systemic modification, the impact formulation can be summarised as:

$$
Impact = \sum^K_i X
$$
where $K$ is a random variable following the k-rary level distribution and $X$ is a random variable following the log-normal distribution. 

We'll generate the results in a table, so that we can distinguish the systemic from single events.


```r
	source("../karyl/karyl.R")  # use k-ary tree probability
	set.seed(123)	# make this single simulation reproducible
	
	gsize <- 100	# group size
	Lmax <- 3		# max level
	nSim = 30*12	# one year of events
    Err <- data.frame(Impact=gsize^(Lmax-rkaryl(nSim,Lmax,gsize)), Systemic=FALSE)
	Err$Systemic[Err$Impact>1] <- TRUE
	Err$Impact <- sapply(Err$Impact,function(i){sum(rlnorm(i,meanlog=7,sdlog=2))})
```

The distribution of the impact of the errors is easiest to see on a log-scale. In addition to the histogram, I'll draw some red vertical lines so that we can see where the systemic losses are.


```r
    # distribution of loss event impact
	source("../loglabels/loglabels.R")
    br<-hist(log(Err$Impact,10),axes=F,
		main="systemic loss effect", xlab="log of impact")$breaks
	axis(1,at=br,labels=loglabels(br))
	axis(2)
	abline(v=log(Err$Impact[Err$Systemic==TRUE],10),col="red")
```

![](figure/hist-1.png) 

As the histogram shows, the systemic events are in the tail.  You'd expect that, because impact of a systemic event is a multiple of the impact of single events. However, if the single events have a heavily skewed distribution, such as a log-normal, the expected loss of an individual transaction is usually a lot lower than the larger losses.  This means that the systemic event can be expected to be a multiplication of small(er) losses, which probably means that the size of the systemic events overlaps with the tail of the individual events.

Now, with relatively few systemic events that affect many (but not usually close to all) transactions, would we detect them by just looking at the historical impact data?  To get a better sense of this, let's simulate many years of just single loss events, as well as years of combined single and systemic events.

<figure>

```r
	# qqplot of single and combined single & systemic losses
	x <- replicate(10000, sum(rlnorm(nSim, meanlog=7, sdlog=2 )))
	
	y <- replicate(10000, sum(rlnorm(
		gsize^(Lmax-rkaryl(nSim,Lmax,gsize)),
		meanlog=7, sdlog=2)))
		
	qqplot(x,y,
		main="single vs. systemic & single losses",
		xlab="single losses", 
		ylab="single & systemic losses")
		
	abline(0,1)
```

![](figure/comparison-1.png) 
<figcaption>
*Figure 1. distribution comparison: qqplot of single vs. systemic & single losses*
</figcaption>
</figure>

With a straight comparison of many years single vs. combined systemic and single loss events, we should be able to detect the difference. As *Figure 1* shows, the distributions look the same for lower value losses, but the combined distribution has more higher value losses.

However, in practice there are far fewer years to compare and the annual rate of losses varies.  Below is the comparison again, but now taking into account those more realistic aspects.

<figure>

```r
	# qqplot of single and combined single and systemic losses
	x <- replicate(500, sum(rlnorm(rpois(1,nSim), meanlog=7, sdlog=2 )))
	
	y <- replicate(500, sum(rlnorm(
		gsize^(Lmax-rkaryl(rpois(1,nSim),Lmax,gsize)),
		meanlog=7, sdlog=2)))
		
	qqplot(x,y,
		main="single vs. systemic & single losses",
		xlab="single losses", 
		ylab="single & systemic losses")
		
	abline(0,1)
```

![](figure/comparison2-1.png) 
<figcaption>
*Figure 2. qqplot of single vs. systemic & single losses: less data and random rate*
</figcaption>
</figure>

In the case illustrated in *Figure 2*, the differences in the tail are less clear.  We could well decide that the tail differences are just outliers and that the data fits a lognormal distribution of single events.

The problem of sparsity of tail events (by definition) is well known and most loss-distribution models in practice try to model the tail separately.  However,  most loss-distribution approaches do not, as far as I know, try to capture the underlying mechanism, such as systemic loss events, that might explain why the tail is different.  Without representing such mechanisms, the models are risking their validity.