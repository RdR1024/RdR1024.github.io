---
title:	The Annual March
author:	Richard de Rozario
date:	2014-06-21
subject: Melbourne, Neumayer, analytics, Bessel
description: Happy birthday to Melbourne's first quant, Georg von Neumayer
---

The next time you want to catch your breath from a busy morning of statistical modelling, head to [Flagstaff Gardens](https://www.flickr.com/search/?q=flagstaff%20gardens). You can buy a nice roll from Vic Markets and enjoy the fresh air and leafy surrounds.  Go ahead, munch your lunch, look up at the fresh sky… and enjoy the hallowed grounds of Melbourne’s first analytics colleague, [Georg von Neumayer](http://en.wikipedia.org/wiki/Georg_von_Neumayer).

We may call our work “predictive analytics” now, but that’s just the latest spin. Trying to predict things with calculations based on careful data gathering goes back a long way.  The forecasting of weather events qualifies as one of the ancient roots of our industry. Stemming from these roots is Georg’s work in establishing Melbourne’s first meteorological observatory at Flagstaff Gardens in 1858.

I came across Georg when I started wondering who the first quant was in Melbourne. But then I got curious about his work, because he predates the foundation of modern timeseries analysis by Yule in the late 1800s[^1]. It turns out that Georg used Bessel functions, which in his day would have been as innovative as random trees are to us. Here is a small section of his work[^2]:

<pre><code>
    If S signifies any of the meteorological elements, 
	n the number of the month commencing with the 1st of January, 
	the annual march is expressed by the following formula of Bessel:

    S(n) = s* + u' sin{(n+1/2) 30° + v' - 15°} + u'' sin{(n+1/2) 60° + 
	v-30°} + u''' sin{(n+1/2) 90° + v''' - 45°} + ...

    By the aid of this formula, the monthly mean values for each 
	element are computed and compared with the actual mean values 
	observed, thereby affording a means for testing the reliability 
	of the formula.
</code>
</pre>
	
Aside from the particular approach, the predictive work sounds very familiar. Georg also faced other familiar challenges. He had to get foreign investment to fund his work and people questioned whether his work had any practical use, and whether it was even valid[^3]. Georg would be right at home in the analytics community of today’s Melbourne.  
 
Happy Birthday, Georg.

[^1]: Terence Mills (2011) *[Foundations of Modern Time Series Analysis](http://www.amazon.com/Foundations-Analysis-Palgrave-Advanced-Econometrics/dp/0230290183)*,Ch.2
[^2]: G. Neumayer (1860) [Results of the magnetical, nautical and meteorological observations made and collected at the Flagstaff Observatory, Melbourne, and at various stations in the Colony of Victoria, March, 1858 to February, 1859](http://search.slv.vic.gov.au/primo_library/libweb/action/dlDisplay.do?vid=MAIN&reset_config=true&docId=SLV_VOYAGER1211729)
[^3]: M.L.A. (1858, Aug 11) "[Professor Neumayer’s observations](http://trove.nla.gov.au/ndp/del/article/7299088?searchTerm=neumayer&searchLimits=exactPhrase|||anyWords|||notWords|||requestHandler|||dateFrom=1858-08-11|||dateTo=1858-08-11|||l-advtitle=13|||l-advcategory=Article|||sortby).", [The Argus](http://en.wikipedia.org/wiki/The_Argus_%28Melbourne%29), Melbourne
