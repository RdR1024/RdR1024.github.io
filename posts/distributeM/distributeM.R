










## ----distributeM---------------------------------------------------------
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




