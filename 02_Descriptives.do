******** Philippines Family Income and Expenditure Survey 2012, 2015, and 2018 ********
******** ANALYSIS OF TOBACCO, ALCOHOL, AND OUT-OF-POCKET HEALTH EXPENDITURES ***
******** Code written by: Nel Jason L. Haw
******** Last updated: July 25, 2021
******** ANALYSIS FILE 1: DESCRIPTIVES

******** Change directory based on your local folder - leave blank when making public
cd "C:\Users\neljasonhaw\OneDrive\Documents\Teaching\Research\FIES 2012 to 2018\Code"


******** Setting up and saving log file
clear all
capture log close _all
log using "03_Log_Files\02 Descriptives.log", replace name(Log02_Descriptives)
set more off
version 17


******** Load data set, survey set declarations
use "01_Intermediate_Extracts\tob_alc_health_final.dta"
svyset psu [pweight = weight], strata(stratum) singleunit(centered)


*************************************************************************************
******** Descriptives table - sociodemographic characteristics by survey year
// Generate a new variable that combines poverty and survey round
gen survey_poornew = .
label variable survey_poornew "Survey & Poverty Status (new 2015 threshold)"
replace survey_poornew = 1 if survey == 1 & poor_new2015 == 1
replace survey_poornew = 2 if survey == 1 & poor_new2015 == 0
replace survey_poornew = 3 if survey == 2 & poor_new2015 == 1
replace survey_poornew = 4 if survey == 2 & poor_new2015 == 0
replace survey_poornew = 5 if survey == 3 & poor_new2015 == 1
replace survey_poornew = 6 if survey == 3 & poor_new2015 == 0
label define survey_poor 1 "2012 Poor" 2 "2012 Non-Poor" 3 "2015 Poor" ///
	 4 "2015 Non-Poor" 5 "2018 Poor" 6 "2018 Non-Poor"
label values survey_poornew survey_poor

gen survey_poorold = .
label variable survey_poorold "Survey & Poverty Status (old 2015 threshold)"
replace survey_poorold = 1 if survey == 1 & poor_old2015 == 1
replace survey_poorold = 2 if survey == 1 & poor_old2015 == 0
replace survey_poorold = 3 if survey == 2 & poor_old2015 == 1
replace survey_poorold = 4 if survey == 2 & poor_old2015 == 0
replace survey_poorold = 5 if survey == 3 & poor_old2015 == 1
replace survey_poorold = 6 if survey == 3 & poor_old2015 == 0
label values survey_poorold survey_poor

// Temporarily recode variables with zero category values - this will aid in generating the descriptive table neatly
recode urb (0 = 1 "urban") (1 = 2 "rural"), gen(urb2)
recode educ (0 = 1 "No educ/some elem") (1 = 2 "Elem grad/some HS") (2 = 3 "HS grad or higher"), gen(educ2)
recode job (0 = 1 "No job") (1 = 2 "Has job"), gen(job2)

// Copy descipriptives table for categorical variables
putdocx begin 
putdocx save "05_Manual_Results\Descriptives.docx", replace

foreach var of varlist survey_poornew survey_poorold {  
    foreach ind of varlist region urb2 sex ms educ2 job2 {
        preserve
        // Prepare tempfile stats with tempname memhold
        tempname memhold
        tempfile stats
        postfile `memhold' str60 (Category Poor2012 NonPoor2012 Poor2015 NonPoor2015 Poor2018 NonPoor2018) using "`stats'"

        // Quietly run svy: tab command
        qui svy: tab `ind' `var', missing
        // Relevant scalars:
        // Number of rows: e(r) - number of rows
        // Number of columns: e(c) - number of columns
        // Relevant matrices:
        // e(Obs) - number of observations
        // e(Prop) - proportions of each cell across entire table
        // e(Row) - list of categories (but as 1 x n matrix)

        // Store column totals of proportion in a new matrix called coltotal
        mata : st_matrix("coltot", colsum(st_matrix("e(Prop)")))
        matrix coltotal = J(1, rowsof(e(Prop)), 1) * e(Prop)

        // Store locals for loop
        local colnames poor2012 nonpoor2012 poor2015 nonpoor2015 poor2018 nonpoor2018
        local lab : value label `ind'

        // Post file
        forvalues i = 1/`e(r)' {
            forvalues j = 1/`e(c)' {
                local colname_`j': word `j' of `colnames'
                local `colname_`j'': di %6.0fc e(Obs)[`i',`j'] " (" %3.1f e(Prop)[`i',`j']*100/coltotal[1,`j'] "%)"
            }
            local catname_`i' `: label `lab' `i''
            post `memhold' ("`catname_`i''") ("`poor2012'") ("`nonpoor2012'") ("`poor2015'") ("`nonpoor2015'") ("`poor2018'") ("`nonpoor2018'")
        }
        postclose `memhold'

        // Open file
        use "`stats'", clear

        // Post file on Word document of descriptives
        putdocx begin
        putdocx table table_`ind'_`var' = data(Category Poor2012 NonPoor2012 Poor2015 NonPoor2015 Poor2018 NonPoor2018), ///
            title("Descriptive table of `ind' by `var'")
        putdocx table table_`ind'_`var'(1,.), addrows(1, before)
        local colheaders " "Category" "Poor 2012" "Non-poor 2012" "Poor 2015" "Non-poor 2015" "Poor2018" "Non-poor 2018" "
        forvalues k = 1/7 {
            local colhead: word `k' of `colheaders'
            putdocx table table_`ind'_`var'(1,`k') = ("`colhead'")
        }
        putdocx save "05_Manual_Results\Descriptives.docx", append

        restore
    }
}

// Copy the results of the means and SD manually because SD is not stored in ereturn list
foreach var of varlist survey_poornew survey_poorold {
	foreach ind of varlist fsize age {
		svy: mean `ind', over(`var')
		estat sd
	}
}
*************************************************************************************





*************************************************************************************
******** Store summary data in a new Stata .dta file and this will be fed into the R code to generate the dumbbell plot
postfile dumbbell str20 (outcome poverty) int survey float (nonpoor poor N) ///
	using "02_Figures\dumbbell.dta", replace
// Run summary statistics commands for prevalence
foreach var of varlist prev_tobacco prev_alcohol prev_health {
	foreach poor of varlist poor_new2015 poor_old2015 {
		svy: mean `var', over(survey `poor')
		post dumbbell ("`var'") ("`poor'") (2012) (e(b)[1,1]) (e(b)[1,2]) (e(_N)[1,1] + e(_N)[1,2])
		post dumbbell ("`var'") ("`poor'") (2015) (e(b)[1,3]) (e(b)[1,4]) (e(_N)[1,3] + e(_N)[1,4])
		post dumbbell ("`var'") ("`poor'") (2018) (e(b)[1,5]) (e(b)[1,6]) (e(_N)[1,5] + e(_N)[1,6])
	}
}
// Run summary statistics commands for share and absolute value, subsetting on prevalence
local outcomes_group "share_tobacco_totex share_alcohol_totex share_health_totex tobacco_2018 alcohol_2018 health_2018"
local subsets_group "prev_tobacco prev_alcohol prev_health prev_alcohol prev_alcohol prev_health"
local n: word count `outcomes_group'
forvalues i = 1/`n' {
	local outcomes: word `i' of `outcomes_group'
	local subsets: word `i' of `subsets_group'
	foreach poor of varlist poor_new2015 poor_old2015 {
		svy, subpop(`subsets'): mean `outcomes', over(survey `poor')
		post dumbbell ("`outcomes'") ("`poor'") (2012) (e(b)[1,1]) (e(b)[1,2]) (e(_N)[1,1] + e(_N)[1,2])
		post dumbbell ("`outcomes'") ("`poor'") (2015) (e(b)[1,3]) (e(b)[1,4]) (e(_N)[1,3] + e(_N)[1,4])
		post dumbbell ("`outcomes'") ("`poor'") (2018) (e(b)[1,5]) (e(b)[1,6]) (e(_N)[1,5] + e(_N)[1,6])
	}
}
postclose dumbbell

**** Additional modifications to the dumbbell.dta file
use "02_Figures\dumbbell.dta", clear
// Expenditure type
gen exp_type = ""
replace exp_type = "tobacco" if ustrregexm(outcome, "tobacco")
replace exp_type = "alcohol" if ustrregexm(outcome, "alcohol")
replace exp_type = "OOP health expenditure" if ustrregexm(outcome, "health")
// Outcome type
gen outcome_type = ""
replace outcome_type = "Prevalence" if ustrregexm(outcome, "prev")
replace outcome_type = "Share of household expenditures" if ustrregexm(outcome, "share")
replace outcome_type = "Absolute value in 2018 PHP" if ustrregexm(outcome, "2018")
// Difference
gen diff = poor - nonpoor
// Sort
sort outcome_type exp_type survey poverty
// Check 2015 values between the old and new poverty threshold
// Very little difference, retain new poverty threshold for final analysis
list
preserve
drop if poverty == "poor_old2015"
save "02_Figures\dumbbell.dta", replace
restore

preserve
keep if survey == 2015
gen pov_thres = ""
replace pov_thres = "Original" if poverty == "poor_old2015"
replace pov_thres = "Revised" if poverty == "poor_new2015" 
save "02_Figures\dumbbell_sensi.dta", replace
restore
*************************************************************************************

log close Log02_Descriptives



// *************************************************************************************
// Deprecated code of bar graphs - originally this was supposed to be Figure 1
// ******** Load data set again, survey set declarations
// use "01_Intermediate_Extracts\tob_alc_health_final.dta"
// svyset psu [pweight = weight], strata(stratum) singleunit(centered)

// ******** Bar graphs of descriptives
// // Use scheme cleanplots:  net install cleanplots, from("https://tdmize.github.io/data/cleanplots")
// // Customize colors: ssc install palettes
// // colorpalette economist: extract navy for 2012, maroon for 2015, teal for 2018
// set scheme cleanplots

// // Figure 1A. Proportion of households reporting expenditure
// graph bar (mean) prev_tobacco prev_alcohol prev_health [pw = weight], ///
// over(survey, lab(nolab)) over(poor_new2015, lab(nolab)) ///
// legend(off) ///
// fysize(85) ///
// bar(1, color(navy)) bar(2, color(maroon)) bar(3, color(teal)) ///
// ytitle("Proportion of households" "reporting expenditure") ///
// ylabel(0 "  0%" 0.25 "  25%" 0.50 "  50%" 0.75 "  75%" 1 "  100%") ///
// title({bf:A}, position(10) ring(1) size(*1.25)) ///
// saving(fig1A, replace)

// // Figure 1B. Share of total household expenditure
// graph bar (mean) share_tobacco_totex share_alcohol_totex share_health_totex [pw = weight], ///
// over(survey, lab(nolab)) over(poor_new2015, lab(nolab)) ///
// bar(1, color(navy)) bar(2, color(maroon)) bar(3, color(teal)) ///
// legend(off) ///
// fysize(85) ///
// ytitle("Mean share of total" "household expenditure") ///
// ylabel(0 "      0%" 0.01 "      1%" 0.02 "      2%" 0.03 "      3%") ///
// title({bf:B}, position(10) ring(1) size(*1.25)) ///
// saving(fig1B, replace)

// // Figure 1C. Absolute value of household expenditure
// graph bar (mean) tobacco_2018 alcohol_2018 health_2018 [pw = weight], ///
// over(survey, label(labsize(*1.25))) over(poor_new2015, relabel(1 "Non-poor households" 2 "Poor households")) ///
// bar(1, color(navy)) bar(2, color(maroon)) bar(3, color(teal)) ///
// legend(label(1 "Tobacco") label(2 "Alcohol") label(3 "Health out-of-pocket (OOP)") position(1) ring(0)) ///
// fysize(100) ///
// ytitle("Mean monthly household" "expenditure (2018 PHP)") ///
// title({bf:C}, position(10) ring(1) size(*1.25)) ///
// saving(fig1C, replace)

// // Combining them together
// // The spaces in the y-axis labels above are workarounds to align the y-axis across the graphs
// graph combine fig1A.gph fig1B.gph fig1C.gph, col(1) ///
// title("Tobacco, alcohol, and health out-of-pocket (OOP)" "expenditures of Filipino households, 2012-2018") ///
// note("Note: PHP = Philippine pesos", size(*.75)) ///
// xsize(61.78) ysize(100) imargin(2 2 0) ///
// saving(fig1, replace)

// graph export fig1.png, replace

