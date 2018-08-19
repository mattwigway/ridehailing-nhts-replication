* Fit logistic regression model of rideshare usage
* Obviously change this to the path to where the file is saved.
cd "/Users/matthewc/Dropbox (Personal)/asu/uber-nhts/Replication Package/stata/"

clear
use "pers17.dta"

gen float vehPerHHMember = HHVEHCNT / HHSIZE
g unrelated = (HHRELATD == 2)
replace pubTransCount = 30 if pubTransCount > 30 & pubTransCount != .

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

* Use a standard OLS estimation to compute VIFs. This is purely a Stata syntax/mechanics workaround. VIFs are defined as 1 / 1 - R2(Xj|Xnj), where
* R2(Xj|Xnj) is the R-squared of a (linear) regression of Xj onto all other X variables (James et al 2013, 102) and thus does not depend on the dependent
* variable or model form of the model being evaluated for multicollinearity. This makes sense, correlation between the independent and dependent is not
* a concern (and in fact is desirable). Stata won't let us use estat vif after a logit model, so we run an OLS model and then run estat vif.
regress ridehailLast30Days i.hhSizeTopcode4 i.isWorker i.homeowner i.sex i.children0to12 i.children13to17 i.unrelated i.outOfTown i.dailySmartphoneUseHH i.incomeCategory#c.vehPerHHMember ///
	c.pubTransCount#i.incomeCategory c.walkCount#i.incomeCategory c.bikeCount#i.incomeCategory ///
	i.incomeCategory#c.CNTTDTR i.hhSizeTopcode4#i.incomeCategory i.race i.isHispanic i.agecat i.msaSize i.msaSize#i.density i.msaRail i.season i.geographicCell, ///
	vce(cluster HOUSEID)
	
estat vif
