




## ----karylprob-----------------------------------------------------------
# k-ary tree level probability functions (without error checks)
dkaryl <- function(i,L,g) (g^i * (g-1)) / (g^(L+1) -1)
pkaryl <- function(n,L,g) (g^(n+1) -1) / (g^(L+1) -1)
qkaryl <- function(q,L,g) floor((log(q*(g^(L+1)-1)+1)-log(g))/log(g))
rkaryl <- function(n,L,g) sample(0:L,n,replace=TRUE,prob=dkaryl(0:L,L,g))




