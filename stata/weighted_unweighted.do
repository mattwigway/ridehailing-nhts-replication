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
	i.incomeCategory#c.CNTTDTR i.hhSizeTopcode4#i.incomeCategory i.race i.isHispanic i.agecat b1.msaSize i.msaSize#i.density i.msaRail i.season i.geographicCell, ///
	vce(cluster HOUSEID) or
* Three outreg2 commands so sideways table is labeled correctly
outreg2 using "wtunwt.tsv", stats(coef) ctitle(unweighted) noaster eform replace
outreg2 using "wtunwt.tsv", stats(ci_low) ctitle(unweighted_low) noaster eform
outreg2 using "wtunwt.tsv", stats(ci_high) ctitle(unweighted_high) noaster eform

logit ridehailLast30Days i.hhSizeTopcode4 i.isWorker i.homeowner i.sex i.children0to12 i.children13to17 i.unrelated i.outOfTown i.dailySmartphoneUseHH i.incomeCategory#c.vehPerHHMember ///
	c.pubTransCount#i.incomeCategory c.walkCount#i.incomeCategory c.bikeCount#i.incomeCategory ///
	i.incomeCategory#c.CNTTDTR i.hhSizeTopcode4#i.incomeCategory i.race i.isHispanic i.agecat b1.msaSize i.msaSize#i.density i.msaRail i.season i.geographicCell [pw=WTPERFIN], ///
	vce(cluster HOUSEID) or
outreg2 using "wtunwt.tsv", stats(coef) ctitle(weighted) noaster eform
outreg2 using "wtunwt.tsv", stats(ci_low) ctitle(weighted_low) noaster eform
outreg2 using "wtunwt.tsv", stats(ci_high) ctitle(weighted_high) noaster eform
