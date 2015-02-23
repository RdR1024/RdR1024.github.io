
## ----lubr----------------------------------------------------------------
	# Melbourne public holidays
	require(lubridate, quietly=TRUE)


## ----easter--------------------------------------------------------------
	# Easter calculation
	Easter <- function(year=1971){
		d <- ((year %% 19) * 18.37 -6) %% 29
		s <- as.numeric(as.Date(paste(year,3,d,sep="-"))) + 5
		s <- (s %/% 7 * 7 + 24)
		return(format(as.Date(s,origin="1970-01-01"),"%d-%m-%Y"))
	}


## ----nthday--------------------------------------------------------------
	# calculate date of nth weekday in a month
	# example: 2nd Monday in the month
	# daynum is Sun=1, Mon=2, Tue=3,...
	nthday <- function(daynum, n, month, year){
		Monthstart <- dmy(paste(1,month,year,sep="-"))
		firstday <- wday(Monthstart)
		delta <- (daynum + 7 - firstday) %% 7 + (n-1)*7
		return(Monthstart + days(delta))
	}


## ----holidays------------------------------------------------------------
# get list of holidays for given year
    melbhols <- function(year=1971){
        hols <- dmy(paste( 1,1, year, sep="-"))
    	hols <- c(hols, dmy(paste( 26,1, year, sep="-")))
    	hols <- c(hols, nthday(2,2,3,year))
	
    	EasterSunday <- dmy(Easter(year))
    	hols <- c(hols, EasterSunday + ddays(-2))
    	hols <- c(hols, EasterSunday + ddays(1))
	
    	hols <- c(hols, dmy(paste(25,4,year,sep="-")))
    	hols <- c(hols, nthday(2,2,6,year))
    	hols <- c(hols, nthday(3,1,11,year))
    	hols <- c(hols, dmy(paste(25,12,year,sep="-")))
    	hols <- c(hols, dmy(paste(26,12,year,sep="-")))
	
    	names(hols) <- c("NewYears","AusDay","LabourDay","GoodFriday",
					 "EasterMonday","Anzac","QueensBD","CupDay",
					 "Xmas","BoxingDay")
	
    	# adjust for holidays on weekends
    	nh <- length(hols)
    	for(h in 1:nh){
			if(h != 6){  # days in lieu, except for ANZAC
				wd <- wday(hols[h])
				if(wd==7) hols[h] <- hols[h] + ddays(2)
				if(wd==1) hols[h] <- hols[h] + ddays(1)
			}
    	}
    	if(hols[nh]==hols[nh-1]) hols[nh] <- hols[nh] + ddays(1)
        
        return(format(as.Date(hols),"%d-%m-%Y"))
    }


## ----melbhols------------------------------------------------------------
    melbhols(2015)


