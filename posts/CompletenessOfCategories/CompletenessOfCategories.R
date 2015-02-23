
## ----rndcats-------------------------------------------------------------
    # a list of random, ordered quantiles
    froq <- function(Q){
        Len <- 0
        Rnd <- 0
        while(Rnd <= Q) {
            Rnd <- runif(1,Rnd)
            Len <- Len+1
        }
        return(Len)
    }
    
    # Simulate large number of times. Get average and upper confidence level.
    X <- replicate(1e5,froq(0.999))
    Expected <- mean(X)
    Upper <- quantile(X,0.999)


