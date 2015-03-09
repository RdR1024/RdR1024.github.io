
## ----setup, echo=FALSE, purl=TRUE----------------------------------------
#require(gamlss.rt, quietly=TRUE)
opts_chunk$set(comment="",highlight=TRUE,echo=TRUE)


## ----sim-----------------------------------------------------------------
	source("../karyl/karyl.R")  # use k-ary tree probability
	set.seed(123)	# make this single simulation reproducible
	
	gsize <- 100	# group size
	Lmax <- 3		# max level
	nSim = 30*12	# one year of events
    Err <- data.frame(Impact=gsize^(Lmax-rkaryl(nSim,Lmax,gsize)), Systemic=FALSE)
	Err$Systemic[Err$Impact>1] <- TRUE
	Err$Impact <- sapply(Err$Impact,function(i){sum(rlnorm(i,meanlog=7,sdlog=2))})


## ----hist, fig.cap=""----------------------------------------------------
    # distribution of loss event impact
	source("../loglabels/loglabels.R")
    br<-hist(log(Err$Impact,10),axes=F,
		main="systemic loss effect", xlab="log of impact")$breaks
	axis(1,at=br,labels=loglabels(br))
	axis(2)
	abline(v=log(Err$Impact[Err$Systemic==TRUE],10),col="red")


## ----comparison, fig.cap=""----------------------------------------------
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


## ----comparison2, fig.cap=""---------------------------------------------
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


