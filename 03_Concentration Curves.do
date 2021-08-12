******** Philippines Family Income and Expenditure Survey 2012, 2015, and 2018 ********
******** ANALYSIS OF TOBACCO, ALCOHOL, AND OUT-OF-POCKET HEALTH EXPENDITURES ***
******** Code written by: Nel Jason L. Haw
******** Last updated: July 25, 2021
******** ANALYSIS FILE 2: CONCENTRATION CURVES

******** Change directory based on your local folder - leave blank when making public
cd "C:\Users\neljasonhaw\OneDrive\Documents\Teaching\Research\FIES 2012 to 2018\Code"


******** Setting up and saving log file
clear all
capture log close _all
log using "03_Log_Files\03 Concentration Curves.log", replace name(Log03_ConcentrationCurve)
set more off
version 17


******** Load data set, survey set declarations
use "01_Intermediate_Extracts\tob_alc_health_final.dta"
svyset psu [pweight = weight], strata(stratum) singleunit(centered)
// Need to generate fweights since most commands here on won't accept pweights
gen fweight = int(weight * 1000000)	
label variable fweight "Frequency weight (pweight * 1,000,000)"


******** Store locals of all needed names
local shortname_inc tob alc hea inc
local longname_inc tobacco alcohol health toinc
local shortname_exp tob alc hea exp
local longname_exp tobacco alcohol health totex

local exp_name tob alc hea
local expense_name tobacco alcohol health
local title_exp_name " "Tobacco" "Alcohol" "Health OOP" "

local rank_varlist_tot toinc_2018 totex_2018
local rank_varlist_pc pcinc_2018 pcexp_2018
local rank_var_short1 inc_toinc exp_totex
local rank_var_short2 _toinc _totex
local rank_var_short3 inc_pcinc exp_pcexp
local rank_var_short4 pcinc pcexp
local title_rank_tot " "(ranked by total income)" "(ranked by total expenditure)" "
local title_rank_pc " "(ranked by per capita income)" "(ranked by per capita expenditure)" "

local surveyyear 2012 2015 2018


******** Generate the per capita expenditure variables
forvalues i = 1/4 {
	local shortname_var: word `i' of `shortname_exp'
	local longname_var: word `i' of `longname_exp'
	gen pc`shortname_var'_2018 = `longname_var'_2018 / fsize
	label var pc`shortname_var'_2018 "`longname_var'_2018 per capita"
}


*************************************************************************************
******** Concentration curves by survey year and expenditure type
// ssc install glcurve - Generalized Lorenz curves with microdata


**** Generate concentration curve variables
** Main analysis - use per capita income (pcinc_2018) to rank variables
// Loop glcurve command and label resulting variables
forvalues i = 1/4 {
	local shortname_var: word `i' of `shortname_inc'
	glcurve pc`shortname_var'_2018 [fw = fweight], glvar(yord_`shortname_var'_pcinc) ///
		pvar(rank_`shortname_var'_pcinc) sortvar(pcinc_2018) replace by(survey) split nograph lorenz
	label var yord_`shortname_var'_pcinc_1 "pc`shortname_var'_2018 2012 share - pcinc rank"
	label var yord_`shortname_var'_pcinc_2 "pc`shortname_var'_2018 2015 share - pcinc rank"	
	label var yord_`shortname_var'_pcinc_3 "pc`shortname_var'_2018 2018 share - pcinc rank"
	label var rank_`shortname_var'_pcinc "Rank in per capita income distribution" 
}

** Sensitivity analysis 1 - use total household income (toinc_2018) to rank variables
// Loop glcurve command and label resulting variables
forvalues i = 1/4 {
	local shortname_var: word `i' of `shortname_inc'
	local longname_var: word `i' of `longname_inc'
	glcurve `longname_var'_2018 [fw = fweight], glvar(yord_`shortname_var'_toinc) ///
		pvar(rank_`shortname_var'_toinc) sortvar(toinc_2018) replace by(survey) split nograph lorenz 
	label var yord_`shortname_var'_toinc_1 "`longname_var' 2012 share - toinc rank"
	label var yord_`shortname_var'_toinc_2 "`longname_var' 2015 share - toinc rank"
	label var yord_`shortname_var'_toinc_3 "`longname_var' 2018 share - toinc rank"
	label var rank_`shortname_var'_toinc "Rank in income distribution"
}
// All the rank_* variables are the same since they are all ranked by toinc_2018

** Sensitivity analysis 2 - use total household expenditure (totex_2018) instead to rank variables
// Loop glcurve command and label resulting variables
forvalues i = 1/4 {
	local shortname2_var: word `i' of `shortname_exp'
	local longname2_var: word `i' of `longname_exp'
	glcurve `longname2_var'_2018 [fw = fweight], glvar(yord_`shortname2_var'_totex) ///
		pvar(rank_`shortname2_var'_totex) sortvar(totex_2018) replace by(survey) split nograph lorenz 
	label var yord_`shortname2_var'_totex_1 "`longname2_var' 2012 share - totex rank"
	label var yord_`shortname2_var'_totex_2 "`longname2_var' 2015 share - totex rank"
	label var yord_`shortname2_var'_totex_3 "`longname2_var' 2018 share - totex rank"
	label var rank_`shortname2_var'_totex "Rank in expenditure distribution"
}

** Sensitivity analysis 3 - use per capital expenditure (pcexp_2018) to rank variables
// Loop glcurve command label resulting variables - per capita expenditure as rank
forvalues i = 1/4 {
	local shortname2_var: word `i' of `shortname_exp'
	glcurve pc`shortname2_var'_2018 [fw = fweight], glvar(yord_`shortname2_var'_pcexp) ///
		pvar(rank_`shortname2_var'_pcexp) sortvar(pcexp_2018) replace by(survey) split nograph lorenz
	label var yord_`shortname2_var'_pcexp_1 "pc`shortname2_var'_2018 2012 share - pcexp rank"
	label var yord_`shortname2_var'_pcexp_2 "pc`shortname2_var'_2018 2015 share - pcexp rank"	
	label var yord_`shortname2_var'_pcexp_3 "pc`shortname2_var'_2018 2018 share - pcexp rank"
	label var rank_`shortname2_var'_pcexp "Rank in per capita expenditure distribution" 
}

** Save data
save "01_Intermediate_Extracts\tob_alc_health_final_concurve.dta", replace


**** Set theme
// Use scheme cleanplots:  net install cleanplots, from("https://tdmize.github.io/data/cleanplots")
// Customize colors: ssc install palettes
// colorpalette economist: extract navy for 2012, maroon for 2015, teal for 2018
set scheme cleanplots
graph set window fontface HelveticaforSAS

// Remove gridlines - ssc install grstyle
grstyle init 
grstyle set plain, nogrid noextend


**** Curves per expenditure category - main figure in paper, customize layout per plot
// Tobacco
twoway (line rank_inc_pcinc rank_inc_pcinc, sort clpat(dash) clwidth(medthick) clcolor(gray)) ///
	   (line yord_tob_pcinc_1 rank_tob_pcinc, sort clpat(solid) clwidth(thick) clcolor(navy)) ///
	   (line yord_tob_pcinc_2 rank_tob_pcinc, sort clpat(solid) clwidth(thick) clcolor(maroon)) ///
	   (line yord_tob_pcinc_3 rank_tob_pcinc, sort clpat(solid) clwidth(thick) clcolor(teal)), ///
	   ytitle("Cumulative proportion of per capita expenditure") ///
	   xtitle("Cumulative population proportion" "(ranked ascending by per capita income)")  ///
	   legend(label(1 "Line of equality") label(2 "2012") label(3 "2015") label(4 "2018") order(2 3 4 1) position(10) ring(0)) ///
	   ylabel(0 "0%" 0.2 "20%" 0.4 "40%" 0.6 "60%" 0.8 "80%" 1.0 "100%") ///
	   xlabel(0 "0%" 0.2 "20%" 0.4 "40%" 0.6 "60%" 0.8 "80%" 1.0 "100%") ///
	   title({bf:TOBACCO}) ///
	   saving("02_Figures\fig2A", replace)

// Alcohol
twoway (line rank_inc_pcinc rank_inc_pcinc, sort clpat(dash) clwidth(medthick) clcolor(gray)) ///
	   (line yord_alc_pcinc_1 rank_alc_pcinc, sort clpat(solid) clwidth(thick) clcolor(navy)) ///
	   (line yord_alc_pcinc_2 rank_alc_pcinc, sort clpat(solid) clwidth(thick) clcolor(maroon)) ///
	   (line yord_alc_pcinc_3 rank_alc_pcinc, sort clpat(solid) clwidth(thick) clcolor(teal)), ///
	   ytitle("") ///
	   xtitle("Cumulative population proportion" "(ranked ascending by per capita income)")  ///
	   legend(off) ///
	   ylabel(0 "0%" 0.2 "20%" 0.4 "40%" 0.6 "60%" 0.8 "80%" 1.0 "100%") ///	   
	   xlabel(0 "0%" 0.2 "20%" 0.4 "40%" 0.6 "60%" 0.8 "80%" 1.0 "100%") ///
	   title({bf:ALCOHOL}) ///
	   saving("02_Figures\fig2B", replace)

// Health OOP
twoway (line rank_inc_pcinc rank_inc_pcinc, sort clpat(dash) clwidth(medthick) clcolor(gray)) ///
	   (line yord_hea_pcinc_1 rank_hea_pcinc, sort clpat(solid) clwidth(thick) clcolor(navy)) ///
	   (line yord_hea_pcinc_2 rank_hea_pcinc, sort clpat(solid) clwidth(thick) clcolor(maroon)) ///
	   (line yord_hea_pcinc_3 rank_hea_pcinc, sort clpat(solid) clwidth(thick) clcolor(teal)), ///
	   ytitle("") ///
	   xtitle("Cumulative population proportion" "(ranked ascending by per capita income)")  ///
	   legend(off) ///
	   ylabel(0 "0%" 0.2 "20%" 0.4 "40%" 0.6 "60%" 0.8 "80%" 1.0 "100%") ///
	   xlabel(0 "0%" 0.2 "20%" 0.4 "40%" 0.6 "60%" 0.8 "80%" 1.0 "100%") ///
	   title({bf:HEALTH OOP}) ///
	   saving("02_Figures\fig2C", replace)

// Combine them altogether
graph combine "02_Figures\fig2A" "02_Figures\fig2B" "02_Figures\fig2C", ///
rows(1) ycommon xcommon ysize(4.5) xsize(10) iscale(0.9) saving("02_Figures\fig2", replace)
graph export "02_Figures\fig2.tif", replace


**** Curves per expenditure category - supplementary, sensitivity analysis, no need to customize
// toinc_2018 rank
local toinc_title " "Tobacco (by total income)" "Alcohol (by total income)" "Health OOP (by total income)" "
forvalues i = 1/3 {
	local name: word `i' of `exp_name'
	local title: word `i' of `toinc_title'
	twoway (line rank_inc_toinc rank_inc_toinc, sort clpat(dash) clwidth(medthick) clcolor(gray)) ///
		   (line yord_`name'_toinc_1 rank_inc_toinc, sort clpat(solid) clwidth(thick) clcolor(navy)) ///
		   (line yord_`name'_toinc_2 rank_inc_toinc, sort clpat(solid) clwidth(thick) clcolor(maroon)) ///
		   (line yord_`name'_toinc_3 rank_inc_toinc, sort clpat(solid) clwidth(thick) clcolor(teal)), ///
		   ytitle("Cumulative proportion of expenditure") ///
		   xtitle("Cumulative population proportion" "(ranked ascending by total income)") ///
	 	   legend(label(1 "Line of equality") label(2 "2012") label(3 "2015") label(4 "2018") order(2 3 4 1) position(10) ring(0)) ///
	   	   ylabel(0 "0%" 0.2 "20%" 0.4 "40%" 0.6 "60%" 0.8 "80%" 1.0 "100%") ///
	       xlabel(0 "0%" 0.2 "20%" 0.4 "40%" 0.6 "60%" 0.8 "80%" 1.0 "100%") ///
	       title(`title') ///
	       saving("02_Figures\Supplementary_Figures\suppfig_toinc_`name'", replace)
}

// totex_2018 rank
local exp_title " "Tobacco (by total expenditure)" "Alcohol (by total expenditure)" "Health OOP (by total expenditure)" "
forvalues i = 1/3 {
	local name: word `i' of `exp_name'
	local title: word `i' of `exp_title'
	twoway (line rank_exp_totex rank_exp_totex, sort clpat(dash) clwidth(medthick) clcolor(gray)) ///
		   (line yord_`name'_totex_1 rank_exp_totex, sort clpat(solid) clwidth(thick) clcolor(navy)) ///
		   (line yord_`name'_totex_2 rank_exp_totex, sort clpat(solid) clwidth(thick) clcolor(maroon)) ///
		   (line yord_`name'_totex_3 rank_exp_totex, sort clpat(solid) clwidth(thick) clcolor(teal)), ///
		   ytitle("Cumulative proportion of expenditure") ///
		   xtitle("Cumulative population proportion" "(ranked ascending by total expenditure)") ///
	 	   legend(label(1 "Line of equality") label(2 "2012") label(3 "2015") label(4 "2018") order(2 3 4 1) position(10) ring(0)) ///
	   	   ylabel(0 "0%" 0.2 "20%" 0.4 "40%" 0.6 "60%" 0.8 "80%" 1.0 "100%") ///
	       xlabel(0 "0%" 0.2 "20%" 0.4 "40%" 0.6 "60%" 0.8 "80%" 1.0 "100%") ///
	       title(`title') ///
	       saving("02_Figures\Supplementary_Figures\suppfig_totex_`name'", replace)
}

// pcexp_2018 rank
local pcexp_title " "Tobacco (by per capita expenditure)" "Alcohol (by per capita expenditure)" "Health OOP (by per capita expenditure)" "
forvalues i = 1/3 {
	local name: word `i' of `exp_name'
	local title: word `i' of `pcexp_title'
	twoway (line rank_exp_pcexp rank_exp_pcexp, sort clpat(dash) clwidth(medthick) clcolor(gray)) ///
		   (line yord_`name'_pcexp_1 rank_exp_pcexp, sort clpat(solid) clwidth(thick) clcolor(navy)) ///
		   (line yord_`name'_pcexp_2 rank_exp_pcexp, sort clpat(solid) clwidth(thick) clcolor(maroon)) ///
		   (line yord_`name'_pcexp_3 rank_exp_pcexp, sort clpat(solid) clwidth(thick) clcolor(teal)), ///
		   ytitle("Cumulative proportion of per capita expenditure") ///
		   xtitle("Cumulative population proportion" "(ranked ascending by per capita expenditure)") ///
	 	   legend(label(1 "Line of equality") label(2 "2012") label(3 "2015") label(4 "2018") order(2 3 4 1) position(10) ring(0)) ///
	   	   ylabel(0 "0%" 0.2 "20%" 0.4 "40%" 0.6 "60%" 0.8 "80%" 1.0 "100%") ///
	       xlabel(0 "0%" 0.2 "20%" 0.4 "40%" 0.6 "60%" 0.8 "80%" 1.0 "100%") ///
	       title(`title') ///
	       saving("02_Figures\Supplementary_Figures\suppfig_pcexp_`name'", replace)
}

// Combine them altogether
graph combine "02_Figures\Supplementary_Figures\suppfig_toinc_tob" "02_Figures\Supplementary_Figures\suppfig_toinc_alc" "02_Figures\Supplementary_Figures\suppfig_toinc_hea" ///
	"02_Figures\Supplementary_Figures\suppfig_totex_tob" "02_Figures\Supplementary_Figures\suppfig_totex_alc" "02_Figures\Supplementary_Figures\suppfig_totex_hea" ///
	"02_Figures\Supplementary_Figures\suppfig_pcexp_tob" "02_Figures\Supplementary_Figures\suppfig_pcexp_alc" "02_Figures\Supplementary_Figures\suppfig_pcexp_hea", ///
rows(3) col(3) ycommon xcommon ysize(12) xsize(15.6) iscale(0.4) saving("02_Figures\Supplementary_Figures\suppfig_otherrank", replace)
graph export "02_Figures\Supplementary_Figures\suppfig_otherrank.tif", replace
*************************************************************************************




*************************************************************************************
******** Testing for dominance
// Download dominance package http://132.203.59.36/dad
// Alternatively there is a newer Lorenz package from ssc install lorenz

**** Create a program to automate the process of creating a twoway plot of
**** line of equality, Lorenz curves, and the concentration curve
capture program drop conc_curve
program define conc_curve
	syntax varlist(min = 3 max = 3), survey(integer) name(string)
	local rank: word 1 of `varlist'
	local income: word 2 of `varlist'
	local expend: word 3 of `varlist'
	local title = "`name'`survey'"
	local filename = "02_Figures/Supplementary_Figures\cc_`expend'_`rank'_`income'"
	twoway	(line `rank' `rank', sort clpat(dash) clwidth(medium) clcolor(gray)) ///
			(line `income' `rank', sort clpat(solid) clwidth(medium) clcolor(black)) ///
			(line `expend' `rank', sort clpat(solid) clwidth(medium) clcolor(maroon)), ///
			ytitle("Cumulative proportion of expenditure") ///
			xtitle("Cumulative population proportion")  ///
			legend(label(1 "Line of equality") label(2 "Lorenz curve") label(3 "`survey'") ///
				order(3 2 1) position(10) ring(0)) ///
	   	   	ylabel(0 "0%" 0.2 "20%" 0.4 "40%" 0.6 "60%" 0.8 "80%" 1.0 "100%") ///
	       	xlabel(0 "0%" 0.2 "20%" 0.4 "40%" 0.6 "60%" 0.8 "80%" 1.0 "100%") ///
			title("`name' `survey'") ///
			saving("`filename'", replace)
end


**** Dominance tests of each individual concentration curve vs Lorenz curve and line of equality
// Generate a separate linelist for each survey round since the dominance command can only handle one group at a time
// While doing this, run dominance vs. Lorenz curve of household income and line of equality
// Also show the curves using conc_curve
// aweights are allowed, just use weight as is
// Unfortunately, the results are not stored in a scalar or matrix, so copy manually from log file

// Loop command
forvalues h = 1/3 {
	preserve
	keep if survey == `h'
	local year: word `h' of `surveyyear'
	// Ranking by total household income and total household expenditure
	forvalues i = 1/2 {
		local rankvar: word `i' of `rank_varlist_tot'
		local rank_short: word `i' of `rank_var_short1'
		local title_rank_word: word `i' of `title_rank_tot'
		local shortname2: word `i' of `rank_var_short2'
		forvalues j = 1/3 {
			local longname: word `j' of `expense_name'
			local shortname: word `j' of `exp_name'
			local title_exp_name_word: word `j' of `title_exp_name'
			di "Dominance test for `longname'_2018 using rank `rankvar' for the year `year'"
			dominance `longname'_2018 [aw = weight], sortvar(`rankvar') shares(quintiles)
			conc_curve rank_`rank_short' yord_`rank_short'_`h' yord_`shortname'`shortname2'_`h', survey(`year') name("`title_exp_name_word' `title_rank_word'")
		}
	}
	// Ranking by per capita household income and household expenditure
	forvalues i = 1/2 {
		local rankvar: word `i' of `rank_varlist_pc'
		local rank_short: word `i' of `rank_var_short3'
		local shortname2: word `i' of `rank_var_short4'
		local title_rank_word: word `i' of `title_rank_pc'
		forvalues j = 1/3 {
			local shortname: word `j' of `exp_name'
			local title_exp_name_word: word `j' of `title_exp_name'
			di "Dominance test for pc`shortname'_2018 using rank `rankvar' for the year `year'"
			dominance pc`shortname'_2018 [aw = weight], sortvar(`rankvar') shares(quintiles)
			conc_curve rank_`rank_short' yord_`rank_short'_`h' yord_`shortname'_`shortname2'_`h', survey(`year') name("`title_exp_name_word' `title_rank_word'")
		}
	}
	save "01_Intermediate_Extracts\tob_alc_health_final_concurve_`year'.dta", replace
	restore
}

// Combine in one graph
local cc_rank inc_toinc exp_totex inc_pcinc exp_pcexp
local cc_rank_short _toinc _totex _pcinc _pcexp

forvalues i = 1/4 {
	local cc_rank_name: word `i' of `cc_rank'
	local cc_shortrank: word `i' of `cc_rank_short'
	graph combine "02_Figures\Supplementary_Figures\cc_yord_tob`cc_shortrank'_1_rank_`cc_rank_name'_yord_`cc_rank_name'_1.gph" ///
	"02_Figures\Supplementary_Figures\cc_yord_tob`cc_shortrank'_2_rank_`cc_rank_name'_yord_`cc_rank_name'_2.gph" ///
	"02_Figures\Supplementary_Figures\cc_yord_tob`cc_shortrank'_3_rank_`cc_rank_name'_yord_`cc_rank_name'_3.gph" ///
	"02_Figures\Supplementary_Figures\cc_yord_alc`cc_shortrank'_1_rank_`cc_rank_name'_yord_`cc_rank_name'_1.gph" ///
	"02_Figures\Supplementary_Figures\cc_yord_alc`cc_shortrank'_2_rank_`cc_rank_name'_yord_`cc_rank_name'_2.gph" ///
	"02_Figures\Supplementary_Figures\cc_yord_alc`cc_shortrank'_3_rank_`cc_rank_name'_yord_`cc_rank_name'_3.gph" ///
	"02_Figures\Supplementary_Figures\cc_yord_hea`cc_shortrank'_1_rank_`cc_rank_name'_yord_`cc_rank_name'_1.gph" ///
	"02_Figures\Supplementary_Figures\cc_yord_hea`cc_shortrank'_2_rank_`cc_rank_name'_yord_`cc_rank_name'_2.gph" ///
	"02_Figures\Supplementary_Figures\cc_yord_hea`cc_shortrank'_3_rank_`cc_rank_name'_yord_`cc_rank_name'_3.gph", ///
	rows(3) ycommon xcommon iscale(0.45) saving("02_Figures\Supplementary_Figures\cc_`cc_rank_name'.gph", replace)
graph export "02_Figures\Supplementary_Figures\cc_`cc_rank_name'.tif", replace
}


**** The next set of dominance tests compares 2012 vs 2015 and 2015 and 2018 in the same expenditure group
// The curves per expenditure category have already been made above
// We just need to run the pairwise dominance tests
// Load 2012 into memory
use "01_Intermediate_Extracts\tob_alc_health_final_concurve_2012.dta", clear
local filenames " "01_Intermediate_Extracts/tob_alc_health_final_concurve_2015.dta" "01_Intermediate_Extracts/tob_alc_health_final_concurve_2018.dta" "
local year2 2015 2018
// 2012 vs. 2015
forvalues h = 1/2 {
	local filename_using: word `h' of `filenames'
	local year: word `h' of `year2'
	// Ranking by total household income and total household expenditure
	forvalues i = 1/2 {
		local rankvar: word `i' of `rank_varlist_tot'
		forvalues j = 1/3 {
			local longname: word `j' of `expense_name'
			di "Dominance test for `longname'_2018 using rank `rankvar' for the year `year' vs 2012"
			dominance `longname'_2018 [aw = weight] using "`filename_using'", /// 
			sortvar(`rankvar') labels(2012 `year')
		}
	}
	// Ranking by per capita household income and household expenditure
	forvalues i = 1/2 {
		local rankvar: word `i' of `rank_varlist_pc'
		forvalues j = 1/3 {
			local shortname: word `j' of `exp_name'
			di "Dominance test for pc`shortname'_2018 using rank `rankvar' for the year `year' vs 2012"
			dominance pc`shortname'_2018 [aw = weight] using "`filename_using'", ///
			sortvar(`rankvar') labels(2012 `year')
		}
	}
}
// Load 2015 into memory
use "01_Intermediate_Extracts\tob_alc_health_final_concurve_2015.dta", clear
// Ranking by total household income and total household expenditure
forvalues i = 1/2 {
	local rankvar: word `i' of `rank_varlist_tot'
	forvalues j = 1/3 {
		local longname: word `j' of `expense_name'
		di "Dominance test for `longname'_2018 using rank `rankvar' for the year `year'"
		dominance `longname'_2018 [aw = weight] using "01_Intermediate_Extracts/tob_alc_health_final_concurve_2018.dta", /// 
		sortvar(`rankvar') labels(2015 `year')
	}
}
// Ranking by per capita household income and household expenditure
forvalues i = 1/2 {
	local rankvar: word `i' of `rank_varlist_pc'
	forvalues j = 1/3 {
		local shortname: word `j' of `exp_name'
		di "Dominance test for pc`shortname'_2018 using rank `rankvar' for the year 2018 vs 2015"
		dominance pc`shortname'_2018 [aw = weight] using "01_Intermediate_Extracts/tob_alc_health_final_concurve_2018.dta", ///
		sortvar(`rankvar') labels(2015 2018)
	}
}
*************************************************************************************




*************************************************************************************
******** Concentration index
// The concentration index can be estimated from the regression
// 2*sigma_rank^2 (health / mean health) = constant + concentration index * rank + error
// Retrieve the beta coefficient of rank to get the POINT estimate of the concentration index
// For standard error, we may take the standard error of the beta coefficient but does not take account
// the sampling variability of the estimate of the mean of the health variable.
// To take into account the sampling variability of the mean of the health variable, use nlcom.
// Consider also Newey-West regression to account for lag 1 autocorrelation as a function of the ranking

**** Generate a program that will calculate concentration indices
capture program drop conc_index
program define conc_index
	syntax varlist (min = 4 max = 4) [fweight] using, year(integer)
	use `using', clear
	local outcome: word 1 of `varlist'
	local rank: word 2 of `varlist'
	local psu: word 3 of `varlist'
	local prob_weight: word 4 of `varlist'
	// Calculate the mean of the outcome and store in scalar mean
	qui sum `outcome' [`weight'`exp']
	local mean = r(mean)
	// Calculate the variance of the rank and store in scalar v_rank
	qui sum `rank' [`weight'`exp']
	local v_rank = r(Var)
	// Generate left hand side of regression
	tempvar lhs 
	gen `lhs' = 2 * `v_rank' * (`outcome'/`mean')
	// Regress 
	qui svy: regr `lhs' `rank'
	// Retrieve coefficient - this is the concentration index point estimate
	local c = _b[`rank']
	local c_se = _se[`rank']
	local c_upper = _b[`rank'] + abs(invnormal(0.025))*`c_se'
	local c_lower = _b[`rank'] - abs(invnormal(0.025))*`c_se'
	local c_pval = 1 - normal(`c'/`c_se')
	// SE adjusted for variability of mean of health variable
	qui svy: regr `outcome' `rank'
	qui nlcom ((2 *`v_rank')/(_b[_cons] + 0.5* _b[`rank'])) * _b[`rank']
	local c_se_adj = sqrt(r(V)[1,1])
	local c_upper_adj = r(b)[1,1] + abs(invnormal(0.025))*`c_se_adj'
	local c_lower_adj = r(b)[1,1] - abs(invnormal(0.025))*`c_se_adj'
	local c_pval_adj = 1 - normal(r(b)[1,1]/`c_se_adj')
	// Newey-West regression to account for serial correlation
	tempvar ranki
	egen `ranki' = rank(`rank'), unique
	qui tsset `ranki'
	qui newey `outcome' `rank' [aw = `prob_weight'], lag(1)
	qui nlcom ((2 *`v_rank')/(_b[_cons] + 0.5* _b[`rank'])) * _b[`rank']
	local c_se_newey = sqrt(r(V)[1,1])
	local c_upper_newey = r(b)[1,1] + abs(invnormal(0.025))*`c_se_newey'
	local c_lower_newey = r(b)[1,1] - abs(invnormal(0.025))*`c_se_newey'
	local c_pval_newey = 1 - normal(r(b)[1,1]/`c_se_newey')
	// Display all the results
	di as text _dup(100) "="
	di "The concentration index point estimate of `outcome' in `year' is " %6.5f `c'
	di " "
	di "Method" _col(50) "SE" _col(60) 	"p-value" _col(70) "Lower 95% CI" _col(85) "Upper 95% CI"
	di as text _dup(100) "-"
	di "Unadjusted for variance of health variable" _col(50) %6.5f `c_se' _col(60) %4.3f `c_pval' _col(70) %6.5f `c_lower' _col(85) %6.5f `c_upper'
	di "Adjusted for variance of health variable" _col(50) %6.5f `c_se_adj' _col(60) %4.3f `c_pval_adj' _col(70) %6.5f `c_lower_adj' _col(85) %6.5f `c_upper_adj'
	di "Newey-West, autocorrelation lag (1)" _col(50) %6.5f `c_se_newey' _col(60) %4.3f `c_pval_newey' _col(70) %6.5f `c_lower_newey' _col(85) %6.5f `c_upper_newey'
	di as text _dup(100) "="
end
// Sample code conc_index tobacco_2018 rank_inc psu weight [fweight = fweight] using "01_Intermediate_Extracts\tob_alc_health_final_concurve_2012.dta", year(2012)


**** Run commands to generate concentration index point estimate and SE
// Ranking by total household income and total household expenditure
// Tobacco, alcohol, health expenditure
forvalues h = 1/3 {
	local year_name: word `h' of `surveyyear'
	forvalues i = 1/2 {
		local rank_name: word `i' of `rank_var_short1'
		forvalues j = 1/3 {
			local outcome_name: word `j' of `expense_name'
			di "Ranking variable: `rank_name'"
			conc_index `outcome_name'_2018 rank_`rank_name' psu weight [fweight = fweight] using "01_Intermediate_Extracts\tob_alc_health_final_concurve_`year_name'.dta", year(`year_name')
			di " "
		} 
	}
}
// Household income and expenditure
forvalues h = 1/3 {
	local year_name: word `h' of `surveyyear'
	forvalues i = 1/2 {
		local rank_name: word `i' of `rank_var_short1'
		local outcome_name: word `i' of `rank_varlist_tot'
		di "Ranking variable: `rank_name'"
		conc_index `outcome_name' rank_`rank_name' psu weight [fweight = fweight] using "01_Intermediate_Extracts\tob_alc_health_final_concurve_`year_name'.dta", year(`year_name')
		di " "
	}
}
// Ranking by per capita household income and household expenditure
// Tobacco, alcohol, health expenditure
forvalues h = 1/3 {
	local year_name: word `h' of `surveyyear'
	forvalues i = 1/2 {
		local rank_name: word `i' of `rank_var_short3'
		forvalues j = 1/3 {
			local outcome_name: word `j' of `exp_name'
			di "Ranking variable: `rank_name'"
			conc_index pc`outcome_name'_2018 rank_`rank_name' psu weight [fweight = fweight] using "01_Intermediate_Extracts\tob_alc_health_final_concurve_`year_name'.dta", year(`year_name')
			di " "
		} 
	}
}
// Household income and expenditure
forvalues h = 1/3 {
	local year_name: word `h' of `surveyyear'
	forvalues i = 1/2 {
		local rank_name: word `i' of `rank_var_short3'
		local outcome_name: word `i' of `rank_varlist_pc'
		di "Ranking variable: `rank_name'"
		conc_index `outcome_name' rank_`rank_name' psu weight [fweight = fweight] using "01_Intermediate_Extracts\tob_alc_health_final_concurve_`year_name'.dta", year(`year_name')
		di " "
	}
}


*************************************************************************************
**** Sensitivity analysis using household expenditure
// The regression is: 2*sigma_rerank^2 (health / mean health) = constant + gamma * rerank + error
// where rerank = rank_1i - rank_2i and gamma is the difference in concentration indices (CI_1 - CI_2)
// Rank 1 is income, Rank 2 is expenditure
capture program	drop conc_index_sensi
program define conc_index_sensi
	syntax varlist (min = 5 max = 5) [fweight] using/, year(integer)
	use `using', clear
	local outcome: word 1 of `varlist'
	local rank1: word 2 of `varlist'
	local rank2: word 3 of `varlist'
	local psu: word 4 of `varlist'
	local prob_weight: word 5 of `varlist'
	// Calculate the mean of the outcome and store in scalar mean
	qui sum `outcome' [`weight'`exp']
	local mean = r(mean)
	// Create a new variable rerank
	tempvar rerank
	gen `rerank' = `rank1' - `rank2'
	// Calculate the variance of the rerank and store in scalar v_rerank
	qui sum `rerank' [`weight'`exp']
	local v_rerank = r(Var)
	// Generate left hand side of regression
	tempvar lhs 
	gen `lhs' = 2 * `v_rerank' * (`outcome'/`mean')
	// Regress 
	qui svy: regr `lhs' `rerank'
	local gamma_est = _b[`rerank']
	local gamma_se = _se[`rerank']
	// There is no transformation that accounts for the variability of the health variable
	// If the p-value is too low anyway, any additional variability of the health variable will increase the p-value but not by much
	local gamma_upper = `gamma_est' + abs(invnormal(0.025))*`gamma_se'
	local gamma_lower = `gamma_est' - abs(invnormal(0.025))*`gamma_se'
	local gamma_est_p = normal(`gamma_est'/`gamma_se')
	// Generate the point estimates of the concentration indices
	forvalues i = 1/2 {
		// Calculate the variance of rank and store in scalar v_rank
		qui sum `rank`i'' [`weight'`exp']
		local v_rank`i' = r(Var)
		// Generate left hand side of regression of rank
		tempvar lhs_rank`i'
		gen `lhs_rank`i'' = 2 * `v_rank`i'' * (`outcome'/`mean')
		// Regress and retrieve concentration index of rank
		qui svy: regr `lhs_rank`i'' `rank`i''
		local c_rank`i' = _b[`rank`i'']
	}
	// Display all the results
	di as text _dup(100) "="
	di "`outcome'" " for the year " `year'
	di " "
	di "CIndex Income" _col(20) "CIndex Expenditure" _col(40) "Diff" _col(50) "SE" _col(60) "p-value" _col(70) "Lower 95% CI" _col(85) "Upper 95% CI"
	di as text _dup(100) "-"
	di %6.5f `c_rank1' _col(20) %6.5f `c_rank2' _col(40) %6.5f `gamma_est' _col(50) %6.5f `gamma_se' _col(60) %4.3f `gamma_est_p' _col(70) %6.5f `gamma_lower' _col(85) `gamma_upper'
	di as text _dup(100) "="
end
// Sample code conc_index_sensi tobacco_2018 rank_inc rank_exp psu weight [fweight = fweight] using "01_Intermediate_Extracts\tob_alc_health_final_concurve_2012.dta", year(2012)


**** Run commands to generate concentration index point estimate and SE
// Ranking by total household income and total household expenditure
forvalues h = 1/3 {
	local year_name: word `h' of `surveyyear'
	local rank_name1: word 1 of `rank_var_short1'
	local rank_name2: word 2 of `rank_var_short1'
	forvalues j = 1/3 {
		local outcome_name: word `j' of `expense_name'
		di "Ranking variables: `rank_name1' vs `rank_name2'"
		conc_index_sensi `outcome_name'_2018 rank_`rank_name1' rank_`rank_name2' psu weight [fweight = fweight] using "01_Intermediate_Extracts\tob_alc_health_final_concurve_`year_name'.dta", year(`year_name')
		di " "
	}
}
// Ranking by per capita household income and household expenditure
forvalues h = 1/3 {
	local year_name: word `h' of `surveyyear'
	local rank_name1: word 1 of `rank_var_short3'
	local rank_name2: word 2 of `rank_var_short3'
	forvalues j = 1/3 {
		local outcome_name: word `j' of `exp_name'
		di "Ranking variables: `rank_name1' vs `rank_name2'"
		conc_index_sensi pc`outcome_name'_2018 rank_`rank_name1' rank_`rank_name2' psu weight [fweight = fweight] using "01_Intermediate_Extracts\tob_alc_health_final_concurve_`year_name'.dta", year(`year_name')
		di " "
	}
}
*************************************************************************************



*************************************************************************************
******** Kakwani's progressivity index
// The concentration index can be estimated from the regression
// 2*sigma_rank^2 (health / mean health - income / mean income) = constant + Kakwani index * rank + error
// Retrieve the beta coefficient of rank to get the POINT estimate of the concentration index
// For standard error, we may take the standard error of the beta coefficient but does not take account
// the sampling variability of the estimate of the mean of the health variable.

**** Generate a program that will calculate Kakwani's progressiviy indices
capture program drop kakwani_index
program define kakwani_index
	syntax varlist (min = 5 max = 5) [fweight] using, year(integer)
	use `using', clear	
	local outcome: word 1 of `varlist'
	local living: word 2 of `varlist' 
	local rank: word 3 of `varlist'
	local psu: word 4 of `varlist'
	local prob_weight: word 5 of `varlist'
	// Calculate the mean of the outcome and store in scalar mean
	qui sum `outcome' [`weight'`exp']
	local mean_outcome = r(mean)
	// Calculate the mean of the living standards variable (income) and store in scalar mean
	qui sum `living' [`weight'`exp']
	local mean_living = r(mean)
	// Calculate the variance of the rank and store in scalar v_rank
	qui sum `rank' [`weight'`exp']
	local v_rank = r(Var)
	// Generate left hand side of regression
	tempvar lhs 
	gen `lhs' = 2 * `v_rank' * (`outcome'/`mean_outcome' - `living'/`mean_living')
	// Regress 
	qui svy: regr `lhs' `rank'
	// Retrieve coefficient - this is the Kakwani progressivity index point estimate
	local ki = _b[`rank']
	local ki_se = _se[`rank']
	local ki_upper = _b[`rank'] + abs(invnormal(0.025))*`ki_se'
	local ki_lower = _b[`rank'] - abs(invnormal(0.025))*`ki_se'
	local ki_pval = normal(`ki'/`ki_se')
	// Regress to retrieve outcome concentration index
	tempvar lhs_outcome
	gen `lhs_outcome' = 2 * `v_rank' * (`outcome'/`mean_outcome')
	qui svy: regr `lhs_outcome' `rank'
	local ci_outcome = _b[`rank']
	// Regress to retrieve living standards concentration index
	tempvar lhs_living
	gen `lhs_living' = 2 * `v_rank' * (`living'/`mean_living')
	qui svy: regr `lhs_living' `rank'
	local ci_living = _b[`rank']
	// Display all the results
	di as text _dup(110) "="
	di "Kakwani Progressivity Index for `outcome'" " for the year " `year' " using ranking variable `living'"
	di " "
	di "CIndex Outcome" _col(18) "CIndex Living" _col(35) "Kakwani Index" _col(50) "SE" _col(60) "p-value" _col(70) "Lower 95% CI" _col(85) "Upper 95% CI"
	di as text _dup(100) "-"
	di %6.5f `ci_outcome' _col(18) %6.5f `ci_living' _col(35) %6.5f `ki' _col(50) %6.5f `ki_se' _col(60) %4.3f `ki_pval' _col(70) %6.5f `ki_lower' _col(85) %6.5f `ki_upper'
	di as text _dup(100) "="
end
// Sample code kakwani_index tobacco_2018 toinc_2018 rank_inc psu weight [fweight = fweight] using "01_Intermediate_Extracts\tob_alc_health_final_concurve_2012.dta", year(2012)


**** Run commands to generate Kakwani progessivity index point estimate and SE
// Ranking by total household income and total household expenditure
forvalues h = 1/3 {
	local year_name: word `h' of `surveyyear'
	forvalues i = 1/2 {
		local rank_name: word `i' of `rank_var_short1'
		local living_name: word `i' of `rank_varlist_tot'
		forvalues j = 1/3 {
			local outcome_name: word `j' of `expense_name'
			di "Ranking variable: `rank_name'"
			kakwani_index `outcome_name'_2018 `living_name' rank_`rank_name' psu weight [fweight = fweight] using "01_Intermediate_Extracts\tob_alc_health_final_concurve_`year_name'.dta", year(`year_name')
			di " "
		} 
	}
}
// Ranking by per capita household income and household expenditure
forvalues h = 1/3 {
	local year_name: word `h' of `surveyyear'
	forvalues i = 1/2 {
		local rank_name: word `i' of `rank_var_short3'
		local living_name: word `i' of `rank_varlist_pc'
		forvalues j = 1/3 {
			local outcome_name: word `j' of `exp_name'
			di "Ranking variable: `rank_name'"
			kakwani_index pc`outcome_name'_2018 `living_name' rank_`rank_name' psu weight [fweight = fweight] using "01_Intermediate_Extracts\tob_alc_health_final_concurve_`year_name'.dta", year(`year_name')
			di " "
		} 
	}
}


log close Log03_ConcentrationCurve
