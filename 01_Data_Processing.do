******** Philippines Family Income and Expenditure Survey 2012, 2015, and 2018 ********
******** Code written by: Nel Jason L. Haw
******** Last updated: August 3, 2021
******** DATA CLEANING FILE

******** Accessing the raw data
*** Public use files (PUF) of the Family Income and Expenditure Survey (FIES)
*** are merged with the subsequent quarter's Labor Force Survey (LFS) and
*** were provided using a data sharing agreement between the
*** Philippine Statistics Authority and Ateneo de Manila University
*** Export to Stata .dta using CSPro, file names are: 2012FIES, 2015FIES, 2018FIES
*** Once the PUF are available as Stata .dta files, save them in one directory (here called PUF)

******** Change directory based on your local folder - leave blank when making public
cd "C:\Users\neljasonhaw\OneDrive\Documents\Teaching\Research\FIES 2012 to 2018\Code"



******** Setting up and saving log file
clear all
capture log close _all
log using "03_Log_Files\01 Data Processing.log", replace name(Log01_DataProcessing)
set more off
version 17


*************************************************************************************
******** EXTRACT VARIABLES FROM ALL PUF *******
** Description **       ** 2012 varname **		** 2015 varname **		** 2018 varname **
** ** ID variable **	other_id 				other_id 				sequence_no
** ** svyset declaration variables **
** PSU 					psu 					rpsu 					rpsu
** pweight				rfact 					rfact 					rfact
** strata 				rstr 					rstr 					w_prov
** ** Geographic information **
** Region 				region 					w_regn 					w_regn
** Urban/Rural			urb 					urb 					urb
** Province 			estrata_01 				restrata_01 			w_prov
**						Not part of sampling 	Not part of sampling	Part of sampling
** ** Income and expenditure indicators **
** Total income 		toinc 					toinc 					toinc
** Total food exp   	t_food 					food 					food
** Total non-food exp 	t_nfood 				nfood 					nfood
** Total exp 			t_totex  				totex 					totex
** Per capita income    pcinc  					pcinc 				    pcinc	
** Natl pc inc decile 	natpc					pcinc_decile 			npcinc
** Natl inc decile 		natdc					toinc_decile 			ntoinc
** Regl pc inc decile 	regpc 					reg_pcdecile 			rpcinc
** Regl inc decile 		regdc 					*N/A*					rtoinc
** Prov pc inc decile 	*Not powered*  			*Not powered* 			ppcinc
** Prov inc decile 		*Not powered* 			*Not powered* 			ptoinc
** Total alcohol 		t_alcohol				alcohol 				alcohol
** Total tobacco 		t_tobacco 				tobacco 				tobacco
** Total health 		t_health  				health 					health
** ** Sociodemographic indicators **
** Family size 			fsize  					fsize 					fsize
** HH head sex 			sex 					rc06_sex_01 			hs001001_sex
** HH head age 			age 					rc07_age_01 			hs001002_age
** HH head marital		ms 						rc08_mstat_01			hs001003_ms
** HH head educ 		hgc 					rc09_grade01 / 			hs001004_hgc
**												rc10_cursch_01
** HH head job 			job 					rc13_work_01 /			hs001005_job
**												rc14_job_01

****** 2012 FIES
use "PUF\2012FIES.dta", clear

keep other_id w_regn urb rstr psu rfact fsize toinc t_food t_nfood t_totex ///
	pcinc natpc natdc regdc regpc ///
	t_alcohol t_tobacco t_health ///
	sex age ms hgc job ///
	estrata_01
	/// occup kb cw ///
	// hhtype members ageless5 age5_17 ///
	// employed_pay employed_prof ///
	// spouse_emp ///
	// bldg_type roof walls tenure hse_altertn ///
	// toilet electric water distance radio_qty tv_qty cd_qty ///
	// stereo_qty ref_qty wash_qty aircon_qty car_qty ///
	// landline_qty cellphone_qty pc_qty oven_qty ///
	// motor_banca_qty motorcycle_qty
** Coding manual:
* For svyset declaration: psu = psu, pweight = rfact, strata = rstr
* w_regn: region
* urb: urban/rural
* toinc: total income
* t_food: total food expenditure (home + outside, does not include alcohol and tobacco)
* 		sum of t_bread + t_meat + t_fish + t_milk + t_oil + t_fruit + t_veg + t_sugar +
*		t_food_nec + t_coffee + t_mineral + t_other_veg + t_food_outside
* t_nfood: total non-food expenditure
* t_totex: total expenditure (food + non-food)
* pcinc: Per capita income
* natpc: National per capita income decile
* natdc: National income decile
* regdc: Regional income decile
* regpc: Regional per capita income decile
* t_alcohol: total alcohol expenditure
* t_tobacco: total tobacco expenditure
* t_health: total health expenditure
* estrata_01: Province recode

save "01_Intermediate_Extracts\2012FIESextract.dta", replace


****** 2015 FIES
use "PUF\2015FIES.dta", clear
keep w_regn other_id urb rstr rpsu rfact fsize toinc food nfood totex ///
	pcinc pcinc_decile toinc_decile reg_pcdecile ///
	alcohol tobacco health ///
	rc06_sex_01 rc07_age_01 rc08_mstat_01 rc09_grade_01 rc10_cursch_01 rc13_work_01 rc14_job_01 ///
	restrata_01
** Coding manual changes from 2012
* psu is now rpsu
* t_food is now food
* t_nfood is now nfood
* t_totex is now totex
* natpc is now pcinc_decile
* natdc is now toinc_decile
* regdc is not available
* regpc is now reg_pcdecile
* t_alcohol is now alcohol
* t_tobacco is now tobacco
* t_health is now health
* All the household head data is suffixed _01
* sex is now rc06_sex_01
* age is now rc07_age_01
* ms is now rc08_mstat_01
* hgc is now rc09_grade_01, keep rc10_cursch_01 as well for further recoding
* job is now a combination of rc13_work_01 rc14_job_01
* estrata_01 is now restrata_01

save "01_Intermediate_Extracts\2015FIESextract.dta", replace


****** 2018 FIES
use "PUF\2018FIES.dta", clear
keep w_regn sequence_no w_prov urb rpsu rfact fsize toinc food nfood totex ///
	pcinc ntoinc rtoinc ptoinc npcinc rpcinc ppcinc ///
	alcohol tobacco health ///
	hs001001_sex hs001002_age hs001003_ms hs001004_hgc hs001005_job
** Coding manual changes from 2015
* There is a new w_prov variable since survey is powered at the province/HUC/ICC level
* Stratum variable: w_prov
* pcinc_decile is now npcinc
* toinc_decile is now ntoinc
* reg_pcdecile is now rpcinc
* Regional household decile is back as rtoinc
* New provincial/HUC/ICC deciles ptoinc ppcinc
* rc06_sex_01 is now hs001001_sex
* rc07_age_01 is now hs001002_age
* rc08_mstat_01 is now hs001003_ms
* rc09_grade_01/rc10_cursch01 is now hs001004_hgc
* rc13_work_01/rc14_job_01 is now hs001005_job

save "01_Intermediate_Extracts\2018FIESextract.dta", replace
*************************************************************************************




*************************************************************************************
******* PREARING VARIABLES FOR MERGING *******
*** Rename variables for consistency - use 2018 names
*** Handle missing values not coded as .
*** Drop all non-responses
*** Remap values of region of 2012/2015 to 2018
*** Make primary sampling units (PSUs) and strata unique across survey rounds
// Generate a survey round with the year as string
// Treat each PSU and strata separately
// Read https://userforum.dhsprogram.com/index.php?t=msg&goto=2225&S=Google for more info
// Essentially, each psu & strata across survey years must STAND ALONE, thus unique values must be assigned
// Generate a new variable that just appends a prefix of the survey year to make them unique
*** Adjust all costs for inflation - based on Consumer Price Index (CPI)
// Check: https://psa.gov.ph/price-indices/annual-cpi
// 2012 CPI = 100, 2015 CPI = 106.5, 2018 CPI = 115.4
// Formula for adjustment to 2018 prices: 2012: x115.4/100.0; 2015: x115.4/106.5
*** Denormalizing survey weights to pool sample
// Visit https://userforum.dhsprogram.com/index.php?t=msg&goto=82 for more info
// Also visit https://userforum.dhsprogram.com/index.php?t=msg&goto=2225&S=Google
// Refer to full technical report of the FIES for the values of the sampled households
// Refer to the 2003 Master Sample for total households in 2012 and 2015, 2013 Master Sample for 2018
// For 2012, sampled households = 40,171; sampling frame = 15,312,414
// For 2015, sampled households = 41,544; sampling frame = 15,312,414
// For 2018, sampled households = 147,717; sampling frame = 22,984,971
// Formula for denormalization = orig wgt * (# households in country / # households in sample)


****** 2012 FIES
use "01_Intermediate_Extracts\2012FIESextract.dta", clear

*** Drop observations with blank PSUs to get final sample size
drop if psu == ""
count
di "There are " `r(N)' " observations in this dataset"

*** Recode region (map to 2018 values)
recode w_regn (1=1) (2=2) (3=3) (41=4) (5=5) (6=6) (7=7) (8=8) (9=9) (10=10) (11=11) (12=12) ///
	(13=13) (14=14) (15=15) (16=16) (42=17), generate(region)
drop w_regn

*** Generate survey round variable
gen survey = "2012"

*** Rename PSU
rename psu rpsu

*** Generate unique survey ID, PSU, and stratum
egen id = concat(survey other_id), punct(_)
egen psu = concat(survey rpsu), punct(_)
egen stratum = concat(survey rstr), punct(_)

*** Denormalize survey weights
gen weight = rfact * (15312414/40171)

*** Rename income and expenditure variables
rename t_alcohol alcohol
rename t_tobacco tobacco
rename t_food food
rename t_health health
rename t_nfood nfood
rename t_totex totex

*** Apply 2018 prices to income and expenditure variables
foreach var of varlist toinc alcohol tobacco food health nfood totex pcinc {
    gen `var'_2018 = `var' * 115.4/100
}

*** Rename decile variables
rename natpc npcinc
rename natdc ntoinc
rename regpc rpcinc
rename regdc rtoinc

*** Clean sociodemographic variables
replace ms = . if ms == 5  // Replace unknown values in marital status to missing
replace ms = 4 if ms == 6  // Merge annulled to divorced/separated
gen educ = .			   // Generate education variable
replace educ = 0 if hgc >= 0 & hgc <= 260		// No education / Some elem
replace educ = 1 if hgc >= 280 & hgc <= 330		// Elem grad / Some high school
replace educ = 2 if hgc >= 350 & hgc <= 900		// High school grad or higher
drop hgc

*** Extract province/HUC/ICC code
gen rprov_s = substr(estrata_01, 1, 4)
destring rprov_s, generate(w_prov)
replace w_prov = round(w_prov/100)
drop estrata_01 rprov_s

save "01_Intermediate_Extracts\2012FIESextract_cleaned.dta", replace


****** 2015 FIES
use "01_Intermediate_Extracts\2015FIESextract.dta", clear
*** Drop observations with blank PSUs to get final sample size
drop if rpsu == ""
count
di "There are " `r(N)' " observations in this dataset"

*** Recode region (map to 2018 values)
recode w_regn (1=1) (2=2) (3=3) (41=4) (5=5) (6=6) (7=7) (8=8) (9=9) (10=10) (11=11) (12=12) ///
	(13=13) (14=14) (15=15) (16=16) (42=17), generate(region)
drop w_regn

*** Generate survey round variable
gen survey = "2015"

*** Generate unique survey ID, PSU, and stratum
egen id = concat(survey other_id), punct(_)
egen psu = concat(survey rpsu), punct(_)
egen stratum = concat(survey rstr), punct(_)

*** Denormalize survey weights
gen weight = rfact * (15312414/41544)

*** Apply 2018 prices to income and expenditure variables
foreach var of varlist toinc alcohol tobacco food health nfood totex pcinc {
    gen `var'_2018 = `var' * 115.4/106.5
}

*** Rename decile variables
rename toinc_decile ntoinc
rename pcinc_decile npcinc
rename reg_pcdecile rpcinc

*** Replenish regional rtoinc variable
// Download and install egenmore package: ssc install egenmore
// For some reason, there is some level of misclassification of decile using Stata command (as seen in 2012 and 2018 data), but there is no other method more accurate to regenerate regional household deciles
egen rtoinc = xtile(toinc), n(10) by(region)

*** Clean sociodemographic variables
rename rc06_sex_01 sex
rename rc07_age_01 age
rename rc08_mstat_01 ms
replace ms = . if ms == 5  // Replace unknown values in marital status to missing
replace ms = 4 if ms == 6  // Merge annulled to divorced/separated
gen educ = .			   // Generate education variable
replace educ = 0 if rc09_grade_01 >= 0 & rc09_grade_01 <= 260		// No education / Some elem
replace educ = 1 if rc09_grade_01 >= 280 & rc09_grade_01 <= 330		// Elem grad / Some high school
replace educ = 2 if rc09_grade_01 >= 350 & rc09_grade_01 <= 900		// High school grad or higher
replace educ = 2 if educ == . & rc10_cursch_01 == 1	
		// Classify all household heads currently in school as having at least high school education
drop rc09_grade_01 rc10_cursch_01
gen job = .				   // Generate job indicator
replace job = 1 if rc13_work_01 == 1			// Yes
replace job = 1 if job == . & rc14_job_01 == 1	// Yes
replace job = 2 if job == . & rc14_job_01 == 2  // No
drop rc13_work_01 rc14_job_01

*** Extract province/HUC/ICC code
gen rprov_s = substr(restrata_01, 1, 4)
destring rprov_s, generate(w_prov)
replace w_prov = round(w_prov/100)
drop restrata_01 rprov_s

save "01_Intermediate_Extracts\2015FIESextract_cleaned.dta", replace


****** 2018 FIES
use "01_Intermediate_Extracts\2018FIESextract.dta", clear

*** Drop observations with blank PSUs to get final sample size
drop if rpsu == .
count
di "There are " `r(N)' " observations in this dataset"

*** Rename region variable
rename w_regn region

*** Generate survey round variable
gen survey = "2018"

*** Generate unique survey ID, PSU, and stratum
rename sequence_no other_id
tostring other_id, replace
egen id = concat(survey other_id), punct(_)
gen rstr = w_prov		// Remember this is also the province/HUC/ICC level estimate
tostring(rstr), replace
tostring(rpsu), replace
egen psu = concat(survey rpsu), punct(_)
egen stratum = concat(survey rstr), punct(_)

*** Denormalize survey weights
gen weight = rfact * (22984971/147717)

*** Rename income and expenditure categories
foreach var of varlist toinc alcohol tobacco food health nfood totex pcinc {
    gen `var'_2018 = `var'
}

*** Clean sociodemographic variables
rename hs001001_sex sex
rename hs001002_age age
rename hs001003_ms ms
replace ms = . if ms == 5  // Replace unknown values in marital status to missing
replace ms = 4 if ms == 6  // Merge annulled to divorced/separated
gen educ = .			   // Generate education variable
replace educ = 0 if hs001004_hgc >= 0 & hs001004_hgc <= 10010				// No education / Some elem
replace educ = 1 if hs001004_hgc >= 10020 & hs001004_hgc <= 24010		// Elem grad / Some high school
replace educ = 2 if hs001004_hgc >= 24020 & hs001004_hgc <= 81041		// High school grad or higher
drop hs001004_hgc
rename hs001005_job job

save "01_Intermediate_Extracts\2018FIESextract_cleaned.dta", replace
*************************************************************************************




*************************************************************************************
******* MERGE DATASET, FINALIZE VARIABLE AND LABEL NAMES *******
****** Merge dataset
append using "01_Intermediate_Extracts\2015FIESextract_cleaned.dta"
append using "01_Intermediate_Extracts\2012FIESextract_cleaned.dta"


****** Cleaning data labels (use codebook command to check value labels)
// Survey round
encode survey, generate(round) label(survey)
drop survey
rename round survey

// Urban/rural
recode urb (1=1) (2=0)
label define urb 0 "Rural" 1 "Urban"
label values urb urb

// Education
label define educ 0 "No educ/some elem" 1 "Elem grad/some HS" 2 "HS grad or higher"
label values educ educ

// Marital Status
label define ms 1 "Single" 2 "Married" 3 "Widowed" 4 "Divorced/Separated/Unknown"
label values ms ms

// Job
recode job (1=1) (2=0)
label define job 0 "No job" 1 "Has job"
label values job job

// Age: 95 onwards will be maxed out at 95
replace age = 95 if age > 95 & age <= 99

// Rename province
rename w_prov province

******* The following code is deprecated - the province codes are now clean for 2018, will remain blank for 2012 and 2015 since survey was not powered for these provinces
*** Clean province categories - deprecated code
// Follow categorization of PSA for generation of province-level poverty thresholds
// ssc install elabel
// label define rprov_2 1724 "Naga City" 3135 "City of Santiago" 3617 "Marawi?" 3738 "Ormoc City" 7606 "Unknown NCR District City"
// labvalcombine RPROV rprov_2, lblname(newprov)
// label values rprov newprov
// 3617 under Lanao del Sur (likely Marawi), 7606 likely a 4th district NCR city (point estimate correct but CV cannot be recreated exactly)
// Code for investigating - compare to officially reported estimates
// gen poor = . // or replace poor = . if doing after the first time
// replace poor = 1 if rprov & survey & pcinc = 1 & urb (do similar for urb = 0 and repeat steps for poor = 0)
// svy: mean poor

*** Generate PSA province variable - deprecated code
// gen province = floor(rprov/100)*100 if rprov < 9804
// replace province = 9804 if rprov == 9804
// Relabel province names		- run label list newprov to check names
// label define rprov_3 200 "Agusan del Norte" 300 "Agusan del Sur" 1100 "Benguet" ///
//	1600 "Camarines Norte" 1700 "Camarines Sur" 2200 "Cebu" 2300 "Davao del Norte" ///
//	2400 "Davao del Sur" 2600 "Eastern Samar" 3000 "Iloilo" 3100 "Isabela" ///
//	3500 "Lanao del Norte" 3600 "Lanao del Sur" 3700 "Leyte" ///
//	3900 "NCR District 1" 4200 "Misamis Occidental" 4300 "Misamis Oriental" ///
//	4500 "Negros Occidental" 4700 "North Cotabato" ///
//	4800 "Northern Samar" 5100 "Occidental Mindoro" 5200 "Oriental Mindoro" ///
//	5300 "Palawan" 5400 "Pampanga" 5600 "Quezon" 6000 "Western Samar" 6300 "South Cotabato" ///
//	6400 "Southern Leyte" 6700 "Surigao del Norte" 6800 "Surigao del Sur" ///
//	7100 "Zambales" 7200 "Zamboanga del Norte" 7300 "Zamboanga del Sur" ///
//	7400 "NCR District 2" 7500 "NCR District 3" 7600 "NCR District 4" ///
//	8200 "Compostela Valley" 8300 "Zamboanga Sibugay"
// Note that both Dinagat Islands became a province in 2006, Davao Occidental in 2013, so neither were included in the 2003 Master Sample that constituted the 2012 and 2015 FIES. They are only available in the 2018 FIES.
// Dinagat Island poverty incidence was calculated for 2015 in the 2018 update but the PSUs cannot be identified from Surigao del Norte, therefore retain poverty comparison to poverty line of Surigao del Norte
// labvalcombine newprov rprov_3, lblname(province)
// label values province province


****** Order variables
order id other_id survey region province psu rpsu stratum rstr weight rfact ///
	toinc pcinc ntoinc rtoinc ptoinc npcinc rpcinc ppcinc ///
	totex food nfood alcohol tobacco health ///
	toinc_2018 pcinc_2018 totex_2018 food_2018 nfood_2018 alcohol_2018 tobacco_2018 health_2018 ///
	urb fsize sex age ms educ job


****** Final variable labels
label variable id "ID by survey round"
label variable other_id "Original ID"
label variable survey "Survey round"
label variable province "Province/HUC/ICC"
label variable psu "PSU by survey round"
label variable rpsu "Original PSU"
label variable stratum "Stratum by survey round"
label variable rstr "Original stratum"
label variable weight "Weight (Denormalized by survey round)"
label variable rfact "Original weight"
label variable toinc "Total income (Nominal)"
label variable pcinc "Per capita income (Nominal)"
label variable ntoinc "National total income decile"
label variable rtoinc "Regional total income decile"
label variable ptoinc "Province/HUC/ICC total income decile (2018 only)"
label variable npcinc "National per capita income decile"
label variable rpcinc "Regional per capita income decile"
label variable ppcinc "Province/HUC/ICC per capita income decile (2018 only)"
label variable totex "Total expenditure (Nominal)"
label variable food "Total food expenditure (Nominal)"
label variable nfood "Total non-food expenditure (Nominal)"
label variable alcohol "Total alcohol expenditure (Nominal)"
label variable tobacco "Total tobacco expenditure (Nominal)"
label variable health "Total health expenditure (Nominal)"
label variable toinc_2018 "Total income (2018 prices)"
label variable pcinc_2018 "Per capita income (2018 prices)"
label variable totex_2018 "Total expenditure (2018 prices)"
label variable food_2018 "Total food expenditure (2018 prices)"
label variable nfood_2018 "Total non-food expenditure (2018 prices)"
label variable alcohol_2018 "Total alcohol expenditure (2018 prices)"
label variable tobacco_2018 "Total tobacco expenditure (2018 prices)"
label variable health_2018 "Total health expenditure (2018 prices)"
label variable sex "Sex of household head"
label variable age "Age of household head"
label variable ms "Marital status of household head"
label variable educ "Highest educational attainment of household head"
label variable job "Job status of household head"

save "01_Intermediate_Extracts\fies2012to2018.dta", replace
*************************************************************************************




*************************************************************************************
******* SVYSET DECLARATIONS **********
** Estimation methods validated by checking the mean, standard error, and 95% CI of technical report prior to merging
svyset psu [pweight = weight], strata(stratum) singleunit(centered)
svy: mean toinc, over(survey)
svy: mean totex, over(survey)
*************************************************************************************



*************************************************************************************
******* GENERATE VARIABLES FOR ANALYSIS **********
label define noyes 0 No 1 Yes


****** Tobacco, Alcohol, Health OOP
local expense_type tobacco alcohol health
local expense_title " "Tobacco" "Alcohol" "Health OOP" "

forvalues i = 1/3 {
	local expense_type_name: word `i' of `expense_type'
	local expense_title_name: word `i' of `expense_title'
	// Household-level prevalence of expenditure
	gen prev_`expense_type_name' = `expense_type_name' > 0
	label variable prev_`expense_type_name' "`expense_title_name' in household"
	label values prev_`expense_type_name' noyes
	// Share of consumption
	gen share_`expense_type_name'_totex = `expense_type_name' / totex
	label variable share_`expense_type_name'_totex "`expense_title_name' - expenditure share"
	gen share_`expense_type_name'_toinc = `expense_type_name' / toinc
	label variable share_`expense_type_name'_toinc "`expense_title_name' - income share"
	gen share_`expense_type_name'_nfood = `expense_type_name' / nfood
	label variable share_`expense_type_name'_nfood "`expense_title_name' - nonfood share"
	// Absolute consumption already available
	// Data quality checks
	svy: mean prev_`expense_type_name', over(survey)
	// graph box share_`expense_type_name'_totex [pweight = weight], over(survey)
}


*** Data quality check: Make sure sum of tobacco, alcohol, and health share do not exceed 100%, investigate if needed
gen temp_share = share_tobacco_totex + share_alcohol_totex + share_health_totex
// graph box temp_share [pweight = weight], over(survey)
drop temp_share
gen temp_share = share_tobacco_nfood + share_alcohol_nfood + share_health_nfood
// graph box temp_share [pweight = weight], over(survey)
drop temp_share
// graph matrix share_tobacco_totex share_alcohol_totex share_health_totex [pweight = weight], by(survey) msize(vtiny)
// No anomalies detected
// Optional graph command
// graph bar (mean) prev_tobacco, over(survey) by(region)


****** Generate poverty thresholds (https://psa.gov.ph/poverty-press-releases/data)
// The Philippine Statistics Authority (PSA) has published comparable nominal estimates of 2012 and 2015, and 2015 and 2018, but not across all three years. 
// This means that the values of 2015 differ between 2012 and 2015, and 2015 and 2018, but not by much.
// To check for potential misclassification, generate both thresholds for 2015 and conduct sensitivity analysis later on to check for any discrepancies in the results
// 2012 vs 2015: https://psa.gov.ph/content/poverty-incidence-among-filipinos-registered-216-2015-psa, download Table 16
// 2015 vs 2018: https://psa.gov.ph/content/updated-2015-and-2018-full-year-official-poverty-statistics, download Table 10
// Generate an export of variable names and labels using putexcel command as workaround
// putexcel set "04_Poverty_Thresholds\names", replace
// svy: tab province, stubw(50)
// matrix prov = e(Row)'
// putexcel A1 = matrix(prov), rownames
// putexcel save
// Manually copy the thresholds and save in a csv file, make sure psgc is saved as string to retain leading zero
// import delimited "province_povthresholds.csv", stringcols(3) 
// save "province_povthresholds.dta", replace


*** Merge poverty thresholds
merge m:1 province using "04_Poverty_Thresholds\province_povthresholds.dta",
drop prov_name _merge
// Label newly imported variables
label variable psgc "PSGC code (6 digits)"
label variable pt_urb_2012 "Urban Poverty Threshold 2012"
label variable pt_urb_2015_old "Urban Poverty Threshold 2015 (Old)"
label variable pt_rur_2012 "Rural Poverty Threshold 2012"
label variable pt_rur_2015_old "Rural Poverty Threshold 2015 (Old)"
label variable pt_urb_2015_new "Urban Poverty Threshold 2015 (New)"
label variable pt_urb_2018 "Urban Poverty Threshold 2018"
label variable pt_rur_2015_new "Rural Poverty Threshold 2015 (New)"
label variable pt_rur_2018 "Rural Poverty Threshold 2018"

*** Generate poverty status
// Using old 2015 threshold
gen poor_old2015 = .
label variable poor_old2015 "Poverty status (old 2015 threshold)"
// Using new 2015 threshold
gen poor_new2015 = .
label variable poor_new2015 "Poverty status (new 2015 threshold)"
// Replace values - store locals then nested and parallel loops
local oldnew old new
local povvars poor_old2015 poor_new2015
local urbrur rur urb
forvalues i = 1/2 {
	local oldnew_name: word `i' of `oldnew'
	local povvars_name: word `i' of `povvars'
	forvalues j = 1/2 {
		local urbrur_name: word `j' of `urbrur'
		replace `povvars_name' = 1 if urb == `j' - 1 & survey == 1 & pcinc <= pt_`urbrur_name'_2012
		replace `povvars_name' = 0 if urb == `j' - 1 & survey == 1 & pcinc > pt_`urbrur_name'_2012
		replace `povvars_name' = 1 if urb == `j' - 1 & survey == 2 & pcinc <= pt_`urbrur_name'_2015_`oldnew_name'
		replace `povvars_name' = 0 if urb == `j' - 1 & survey == 2 & pcinc > pt_`urbrur_name'_2015_`oldnew_name'
		replace `povvars_name' = 1 if urb == `j' - 1 & survey == 3 & pcinc <= pt_`urbrur_name'_2018
		replace `povvars_name' = 0 if urb == `j' - 1 & survey == 3 & pcinc > pt_`urbrur_name'_2018
		label values `povvars_name' noyes
	}
}


*** Check proportions of per capita poverty at the province level vs official report
// Some minor discrepancies in a few provinces, but overall the matching of PSU to province held pretty well
svy, subpop(if survey == 1): mean poor_old2015, over(province) level(90)
svy, subpop(if survey == 2): mean poor_old2015, over(province) level(90)
svy, subpop(if survey == 2): mean poor_new2015, over(province) level(90)
svy, subpop(if survey == 3): mean poor_new2015, over(province) level(90)


save "01_Intermediate_Extracts\tob_alc_health_final.dta", replace
*************************************************************************************

log close Log01_DataProcessing
