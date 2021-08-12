******** Philippines Family Income and Expenditure Survey 2012, 2015, and 2018 ********
******** ANALYSIS OF TOBACCO, ALCOHOL, AND OUT-OF-POCKET HEALTH EXPENDITURES ***
******** Code written by: Nel Jason L. Haw
******** Last updated: August 5, 2021
******** ANALYSIS FILE 3: IMPOVERISHMENT

******** Change directory based on your local folder - leave blank when making public
cd "C:\Users\neljasonhaw\OneDrive\Documents\Teaching\Research\FIES 2012 to 2018\Code"


******** Setting up and saving log file
clear all
capture log close _all
log using "03_Log_Files\04 Impoverishment.log", replace name(Log04_Impoverishment)
set more off
version 17


******** Load data set, survey set declarations
use "01_Intermediate_Extracts\tob_alc_health_final.dta"
svyset psu [pweight = weight], strata(stratum) singleunit(centered)
// Need to generate fweights since most commands here on won't accept pweights
gen fweight = int(weight * 1000000)	
label variable fweight "Frequency weight (pweight * 1,000,000)"


*************************************************************************************
******** Calculate overall poverty incidence
// Overall
svy: tab poor_new2015 survey, obs col format(%10.3f) ci
svy: tab poor_old2015 survey, obs col format(%10.3f) ci


******** Calculate poverty incidence after accounting for expenditures
*** Generate new income variables net of expenditures
local exp_type tobacco alcohol health
local exp_title " "tobacco" "alcohol" "health OOP" "
local oldnew old new
local urbrur rur urb

forvalues h = 1/3 {
	local exp_name: word `h' of `exp_type'
	local exp_title_name: word `h' of `exp_title'
	qui gen pcinc_net_`exp_name' = pcinc - (`exp_name' / fsize)
	label variable pcinc_net_`exp_name' "Per capita income net of `exp_title_name' expenditure (Nominal)"
	forvalues i = 1/2 {
		local oldnew_name: word `i' of `oldnew'
		qui gen poor_`oldnew_name'2015_net_`exp_name' = .
		label variable poor_`oldnew_name'2015_net_`exp_name' "Poverty status net of `exp_title_name' expenditure (`oldnew_name' 2015 threshold)"
		forvalues j = 1/2 {
			local urbrur_name: word `j' of `urbrur'
			qui replace poor_`oldnew_name'2015_net_`exp_name' = 1 if urb == `j' - 1 & survey == 1 & pcinc_net_`exp_name' <= pt_`urbrur_name'_2012
			qui replace poor_`oldnew_name'2015_net_`exp_name' = 0 if urb == `j' - 1 & survey == 1 & pcinc_net_`exp_name' > pt_`urbrur_name'_2012
			qui replace poor_`oldnew_name'2015_net_`exp_name' = 1 if urb == `j' - 1 & survey == 2 & pcinc_net_`exp_name' <= pt_`urbrur_name'_2015_`oldnew_name'
			qui replace poor_`oldnew_name'2015_net_`exp_name' = 0 if urb == `j' - 1 & survey == 2 & pcinc_net_`exp_name' > pt_`urbrur_name'_2015_`oldnew_name'
			qui replace poor_`oldnew_name'2015_net_`exp_name' = 1 if urb == `j' - 1 & survey == 3 & pcinc_net_`exp_name' <= pt_`urbrur_name'_2018
			qui replace poor_`oldnew_name'2015_net_`exp_name' = 0 if urb == `j' - 1 & survey == 3 & pcinc_net_`exp_name' > pt_`urbrur_name'_2018
			label values poor_`oldnew_name'2015_net_`exp_name' noyes
		}
		// Report poverty incidence
		svy: tab poor_`oldnew_name'2015_net_`exp_name' survey, obs col format(%10.3f) ci
		// Test for differences
		qui gen pov_change_`oldnew_name'2015_`exp_name' = poor_`oldnew_name'2015_net_`exp_name' - poor_`oldnew_name'2015
		label variable pov_change_`oldnew_name'2015_`exp_name' "Became poor after `exp_title_name' expenditure (`oldnew_name' 2015 threshold)"
		label values pov_change_`oldnew_name'2015_`exp_name' noyes
		svy: tab pov_change_`oldnew_name'2015_`exp_name' survey, obs col format(%12.5f) ci		
	}
}

save "01_Intermediate_Extracts\tob_alc_health_final_net.dta", replace 
*************************************************************************************



*************************************************************************************
******** Generate new variables for Pen's parade then export data for R visualization

*** Per capita income as a multiple of poverty line
forvalues i = 1/2 {
	local oldnew_name: word `i' of `oldnew'
	qui gen poor_`oldnew_name'2015_mult = .
	label variable poor_`oldnew_name'2015_mult "Per capita income as a multiple of poverty line (`oldnew_name' 2015 threshold)"
	forvalues j = 1/2 {
		local urbrur_name: word `j' of `urbrur'
		qui replace poor_`oldnew_name'2015_mult = pcinc / pt_`urbrur_name'_2012 if urb == `j' - 1 & survey == 1
		qui replace poor_`oldnew_name'2015_mult = pcinc / pt_`urbrur_name'_2015_`oldnew_name' if urb == `j' - 1 & survey == 2
		qui replace poor_`oldnew_name'2015_mult = pcinc / pt_`urbrur_name'_2018 if urb == `j' - 1 & survey == 3
		label values poor_`oldnew_name'2015_mult noyes
	}
}

*** Tobacco, alcohol, and health OOP expenditure as multiple of poverty line
forvalues h = 1/3 {
	local exp_name: word `h' of `exp_type'
	local exp_title_name: word `h' of `exp_title'
	forvalues i = 1/2 {
		local oldnew_name: word `i' of `oldnew'
		qui gen poor_`oldnew_name'2015_mult_net_`exp_name' = .
		label variable poor_`oldnew_name'2015_mult_net_`exp_name' "Per capita `exp_title_name' expenditure as a multiple of poverty line (`oldnew_name' 2015 threshold)"
		forvalues j = 1/2 {
			local urbrur_name: word `j' of `urbrur'
			qui replace poor_`oldnew_name'2015_mult_net_`exp_name' = (`exp_name' / fsize) / pt_`urbrur_name'_2012 if urb == `j' - 1 & survey == 1
			qui replace poor_`oldnew_name'2015_mult_net_`exp_name' = (`exp_name' / fsize) / pt_`urbrur_name'_2015_`oldnew_name' if urb == `j' - 1 & survey == 2
			qui replace poor_`oldnew_name'2015_mult_net_`exp_name' = (`exp_name' / fsize) / pt_`urbrur_name'_2018 if urb == `j' - 1 & survey == 3
		}
	}
}

*** Extract relevant variables
// Four variables are needed:
// (1) Per capita income as a multiple of poverty line
// (2) Fractional rank variable by per capita income as a multiple of poverty line
// (3) Per capita expenditure as a multiple of poverty line
// (4) Per capita income - per capita expenditure as a multiple of poverty line
// Variations:
// Old vs new 2015 poverty threshold - at the moment wide
// Expenditure types: tobacco, alcohol, health OOP - at the moment wide
// Year: 2012, 2015, 2018 - at the moment, tall

// keep id survey fweight poor_old2015_mult poor_new2015_mult ///
// 	poor_old2015_mult_net_tobacco poor_new2015_mult_net_tobacco ///
// 	poor_old2015_mult_net_alcohol poor_new2015_mult_net_alcohol ///
// 	poor_old2015_mult_net_health poor_new2015_mult_net_health

*** Generate per capita income fractional rank
forvalues i = 1/2 {
	local oldnew_name: word `i' of `oldnew'
	bysort survey: egen rank_poor_`oldnew_name'2015_mult = rank(poor_`oldnew_name'2015_mult), track
	egen maxrank_`oldnew_name' = max(rank_poor_`oldnew_name'2015_mult), by(survey)
	gen fracrank_poor_`oldnew_name'2015_mult = rank_poor_`oldnew_name'2015_mult / maxrank_`oldnew_name'
	label variable fracrank_poor_`oldnew_name'2015_mult "Fractional rank of per capita income (`oldnewname' 2015 threshold)"
	drop maxrank_`oldnew_name'
}

*** Generate the difference between per capita income and per capita expenditure
forvalues h = 1/3 {
	local exp_name: word `h' of `exp_type'
	local exp_title_name: word `h' of `exp_title'
	forvalues i = 1/2 {
		local oldnew_name: word `i' of `oldnew'
		gen diff_poor_`oldnew_name'2015_mult_`exp_name' = poor_`oldnew_name'2015_mult - poor_`oldnew_name'2015_mult_net_`exp_name'
		label variable diff_poor_`oldnew_name'2015_mult_`exp_name' "Difference of per capita income and expenditure of `exp_title_name' (`oldnew_name' 2015 threshold)"
	}
}

*** Quality control check - compare the poverty threshold using a different formula
// forvalues h = 1/3 {
// 	local exp_name: word `h' of `exp_type'
// 	local exp_title_name: word `h' of `exp_title'
// 	forvalues i = 1/2 {
// 		local oldnew_name: word `i' of `oldnew'
// 		gen new_poor_`oldnew_name'2015_net_`exp_name' = diff_poor_`oldnew_name'2015_mult_`exp_name' < 1
// 		assert new_poor_`oldnew_name'2015_net_`exp_name' == poor_`oldnew_name'2015_net_`exp_name'
// 	}
// }
*************************************************************************************



*************************************************************************************
******** Normalized poverty gap
// Poverty gap is calculated as the difference between the poverty line and per capita income among those who are poor
// Normalizing it means dividing it by the poverty line
// Measures depth of poverty

*** Generate the normalized poverty gap of per capita income
forvalues i = 1/2 {
	local oldnew_name: word `i' of `oldnew'
	qui gen pov_gap_`oldnew_name'2015 = poor_`oldnew_name'2015 * (1 - poor_`oldnew_name'2015_mult)
	label variable pov_gap_`oldnew_name'2015 "Normalized poverty gap of pcinc (`oldnew_name' 2015 threshold)"
}

*** Generate the normalized poverty gap variable net of health expenditures
forvalues h = 1/3 {
	local exp_name: word `h' of `exp_type'
	local exp_title_name: word `h' of `exp_title'
	forvalues i = 1/2 {
		local oldnew_name: word `i' of `oldnew'
		qui gen pov_gap_`oldnew_name'2015_`exp_name' = poor_`oldnew_name'2015_net_`exp_name' * (1 - diff_poor_`oldnew_name'2015_mult_`exp_name')
		label variable pov_gap_`oldnew_name'2015_`exp_name' "Norm pov gap of pcinc net of `exp_title_name' (`oldnew_name' 2015)"
	}
}

*** Generate the difference in poverty gaps and report differences
forvalues h = 1/3 {
	local exp_name: word `h' of `exp_type'
	local exp_title_name: word `h' of `exp_title'
	forvalues i = 1/2 {
		local oldnew_name: word `i' of `oldnew'
		qui gen absdiff_pov_gap_`oldnew_name'2015_`exp_name' = pov_gap_`oldnew_name'2015_`exp_name' - pov_gap_`oldnew_name'2015
		label variable absdiff_pov_gap_`oldnew_name'2015_`exp_name' "Abs diff of norm pov gap of pcinc net of `exp_title_name' (`oldnew_name' 2015)"
		svy: mean absdiff_pov_gap_`oldnew_name'2015_`exp_name', over(survey)
		qui gen reldiff_pov_gap_`oldnew_name'2015_`exp_name' = absdiff_pov_gap_`oldnew_name'2015_`exp_name' / pov_gap_`oldnew_name'2015
		label variable reldiff_pov_gap_`oldnew_name'2015_`exp_name' "Rel diff of norm pov gap of pcinc net of `exp_title_name' (`oldnew_name' 2015)"
		svy: mean reldiff_pov_gap_`oldnew_name'2015_`exp_name', over(survey)
	}
}

***

save "01_Intermediate_Extracts\tob_alc_health_final_net_pens.dta", replace

log close Log04_Impoverishment 
