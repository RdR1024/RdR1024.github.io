










## ----distributeM---------------------------------------------------------
require("actuar", quietly=TRUE)

# distribute an amount M over n bins
# in proportion to some distribution pdist
distributeM <- function(nbins,amount=1,qmin=0.0001,qmax=0.9999,
						method="rounding",pdist=pnorm,...){
	distname <- substring(deparse(substitute(pdist)),2)
	qdistr <- get(paste('q',distname,sep=''))
	bin <- list(start=NA,end=NA,step=NA)
	bin[1:2] <- qdistr(c(qmin,qmax),...)
	bin$step <- (bin$end - bin$start) / nbins
	p <- discretize(pdist(x,...), method=method,
			from=bin$start,to=bin$end,by=bin$step)
	p <- amount * p / sum(p)
	return(p)
}




