
## ----start---------------------------------------------------------------
	# seats and dishes
	nSeats <- 5			# number of seats
	nDishes <- 10		# number of dishes
	dishes <- 1:nDishes # ready dishes
	
	# start with preferred dishes in front of seats
	xdish <- 1:nSeats
	seats <- dishes[xdish]			 # give dishes to seat
	dishes[xdish] <- -dishes[xdish]  # dishes not ready anymore
	
	# who is eating?
	eating <- rep(0,nSeats)
	eatTime <- nSeats				# eating time is one cycle


## ----prefs---------------------------------------------------------------
	# dish preference matrix
	prefs <- t(matrix(1:nDishes,nrow=nDishes,ncol=nSeats))
	
	# rotate a vector of e.g. preferences
	rotvec <- function(x){ c(x[2:length(x)],x[1])}


## ----eating--------------------------------------------------------------
	# count of dishes passed for each seat
	passed <- rep(0,nSeats)		# for each seat how long have we waited?
	genpassed <- c()			# in general, how long do we wait?
	making <- rep(0,nDishes)    # which dishes are we making?
	makeTime <- nSeats			# making a dish takes one cycle
	
	
	# process one turn 
	turn <- function(){
		# at chef's seat
		if(seats[1] < 0){ # there's eaten dish
			x <- which(dishes == -seats[1])
			if(length(x)>0){ # there's a replacement ready
				seats[1] <<- -seats[1]
				dishes[x[1]] <<- -dishes[x[1]]
				making[x[1]] <<- makeTime
			} else {	# there's no replacement ready
				x <- which(dishes == seats[1])
				if(length(x)>0)	{
					if(making[x[1]] > 0) making[x[1]] <<- making[x[1]] -1
					else dishes[x[1]] <<- -dishes[x[1]]
				}
			}
		} else {	# no eaten dish, but prep replacements
			x <- which(dishes < 0)
			if(length(x)>0){	# there is a dish to prep
				if(making[x[1]] > 0) making[x[1]] <<- making[x[1]] -1
				else dishes[x[1]] <<- -dishes[x[1]]
			} else {		# no dish to prep, but replace one
				x <- prefs[1,1]
				prefs[1,] <<- rotvec(prefs[1,])
				seats[1] <<- dishes[x]
				dishes[x] <<- -dishes[x]
			}
		}
		
		# at diners' seats
		for(i in 2:nSeats){
			if(eating[i]==0){
				if(seats[i] == prefs[i,1]){	# yeah! preference is here
					seats[i] <<- -seats[i]
					prefs[i,] <<- rotvec(prefs[i,])
					genpassed <<- c(genpassed,passed[i])
					passed[i] <<- 0
					eating[i] <<- eatTime
				} else {					# pass: not preference
					passed[i] <<- passed[i] + 1
				}
			} else {	# we're eating: count it down
				eating[i] <<- eating[i] -1 
			}
		}
		
		# rotate the dishes through the seats
		seats <<- rotvec(seats)
	}


## ----hist, fig.cap="", echo=FALSE----------------------------------------
for(i in 1:1000) turn()
hist(genpassed,main="dishes passed before selection",
			   xlab="number of dishes passed before choice made",
			   ylab="count",
			   col="lightgrey"
	)
abline(v=mean(genpassed),col="red")
legend("topright",c("avg #dishes passed"),col=c("red"),lwd=1,bty="n")

