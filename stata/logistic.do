* Fit logistic regression model of rideshare usage
cd "/Users/matthewc/Dropbox (Personal)/asu/uber-nhts/stata/"

clear
use "/Users/matthewc/Dropbox (Personal)/asu/uber-nhts/stata/pers17.dta"

gen float vehPerHHMember = HHVEHCNT / HHSIZE
g unrelated = (HHRELATD == 2)


* I had to remove the lifecycle category as it caused really severe multicollinearity issues with income by HH size (VIFs over 22,000, I kid you not)
* I also removed bikeshare, due to insignificance and because it is only nonzero for a handful of cases.
* I tried this previously with an indicator for > 1 vehicle per driver, but it was only significant for the middle income categorie, probably because it has lower variance in the
* extreme categories (most wealthy households, for example, probably have at least one vehicle per driver). This did lead to some high VIFs, presumably because larger households have fewer
* vehicles per household member.
logit ridehailLast30Days i.hhSizeTopcode4 i.isWorker i.homeowner i.sex i.children0to12 i.children13to17 i.unrelated i.outOfTown i.dailySmartphoneUseHH i.incomeCategory#c.vehPerHHMember ///
	c.pubTransCount#i.incomeCategory c.walkCount#i.incomeCategory c.bikeCount#i.incomeCategory ///
	i.incomeCategory#c.CNTTDTR i.hhSizeTopcode4#i.incomeCategory i.race i.isHispanic i.agecat i.msaSize i.msaSize#i.density i.msaRail i.season i.geographicCell, ///
	vce(cluster HOUSEID) or
est store logit
outreg2 using "logit.tsv", stats(coef pval ci_low ci_high) label sideway replace eform alpha(0.001, 0.01, 0.05)

* TODO compute replicate weight standard errors for margins... may need to do in Python
* First do margins for all main effects

margins [pweight=WTPERFIN] if e(sample), dydx(hhSizeTopcode4 outOfTown homeowner race isHispanic agecat isWorker children0to12 children13to17 unrelated sex dailySmartphoneUseHH msaRail geographicCell season) post
outreg2 using "logit.tsv", stats(coef pval ci_low ci_high) label sideway alpha(0.001, 0.01, 0.05)

* Margins for msaSize are not estimable because there are no observations that are not in an MSA and have density > 25000.
* But density > 25000 is rare, so just exclude those places from the marginal effects, and note that in the paper
est restore logit
margins [pweight=WTPERFIN] if e(sample) & density != 7, dydx(msaSize) post
outreg2 using "logit.tsv", stats(coef pval ci_low ci_high) label sideway alpha(0.001, 0.01, 0.05)

* Income is over household size
est restore logit
margins [pweight=WTPERFIN] if e(sample), dydx(incomeCategory) over(hhSizeTopcode4) post
outreg2 using "income_hhsize.tsv", stats(coef pval ci_low ci_high) label sideway replace alpha(0.001, 0.01, 0.05)	

* Density is over MSA size
est restore logit
margins [pweight=WTPERFIN] if e(sample), dydx(density) over(msaSize) post
outreg2 using "density_msaSize.tsv", stats(coef pval ci_low ci_high) label sideway replace alpha(0.001, 0.01, 0.05)

* Others are over income
est restore logit
margins [pweight=WTPERFIN] if e(sample), dydx(pubTransCount walkCount bikeCount vehPerHHMember CNTTDTR) over(incomeCategory) post
outreg2 using "alt_hhsize.tsv", stats(coef pval ci_low ci_high) label sideway replace alpha(0.001, 0.01, 0.05)

* Head-to-head tests of coefficients
est restore logit
test 3.incomeCategory#c.vehPerHHMember = 0.incomeCategory#c.vehPerHHMember
test 3.incomeCategory#pubTransCount = 0.incomeCategory#pubTransCount
test 3.incomeCategory#bikeCount = 0.incomeCategory#bikeCount
test 3.incomeCategory#walkCount = 0.incomeCategory#walkCount
test 3.incomeCategory#CNTTDTR = 0.incomeCategory#CNTTDTR

test 1.hhSizeTopcode4#3.incomeCategory = 2.hhSizeTopcode4#3.incomeCategory 
test 1.hhSizeTopcode4#3.incomeCategory = 3.hhSizeTopcode4#3.incomeCategory 
test 1.hhSizeTopcode4#3.incomeCategory = 4.hhSizeTopcode4#3.incomeCategory

test 1.hhSizeTopcode4#2.incomeCategory = 2.hhSizeTopcode4#2.incomeCategory 
test 1.hhSizeTopcode4#2.incomeCategory = 3.hhSizeTopcode4#2.incomeCategory 
test 1.hhSizeTopcode4#2.incomeCategory = 4.hhSizeTopcode4#2.incomeCategory

test 1.hhSizeTopcode4#1.incomeCategory = 2.hhSizeTopcode4#1.incomeCategory 
test 1.hhSizeTopcode4#1.incomeCategory = 3.hhSizeTopcode4#1.incomeCategory 
test 1.hhSizeTopcode4#1.incomeCategory = 4.hhSizeTopcode4#1.incomeCategory 

* Does vehicle ownership matter as much for high income individuals
test 3.incomeCategory#c.vehPerHHMember = 2.incomeCategory#c.vehPerHHMember

regress ridehailLast30Days i.hhSizeTopcode4 i.isWorker i.homeowner i.sex i.children0to12 i.children13to17 i.unrelated i.outOfTown i.dailySmartphoneUseHH i.incomeCategory#c.vehPerHHMember ///
	c.pubTransCount#i.incomeCategory c.walkCount#i.incomeCategory c.bikeCount#i.incomeCategory ///
	i.incomeCategory#c.CNTTDTR i.hhSizeTopcode4#i.incomeCategory i.race i.isHispanic i.agecat i.msaSize i.msaSize#i.density i.msaRail i.season i.geographicCell, ///
	vce(cluster HOUSEID)
	
estat vif
