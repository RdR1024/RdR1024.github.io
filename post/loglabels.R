	# log-10 scale labels with order of
	# magnitude grouping letters up to Quadrillions
	loglabels <- function(X, logscale=T, prec=0){
		if(max(X) >= 1e18) r <- X
		else{
			r <- c()
			Gchar <- c("","K","M","B","T","Q")
			if(!logscale) X <- log(X,10)
			for(x in X){
				z <- x
				if( abs(z-trunc(z)) == 0) z <- as.integer(z)
				sx <- z %/% 3
				r <- c(r,paste(round(10^(x-sx*3),prec),Gchar[sx+1],sep=""))
			}
		}
		return(r)
	}