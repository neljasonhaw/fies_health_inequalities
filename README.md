# FIES Philippines 2012-2018, Health Inequalities Analysis
Stata and R codes for the paper, "Inequalities and impacts on poverty incidence of tobacco, alcohol, and health out-of-pocket expenditures in the Philippines, 2012-2018" by Nel Jason Haw

**The repository contains the following:**
1. Stata and R codes for the analysis and figures
2. Stata log files
3. Publicly available data on the Philippine provincial urban/rural poverty thresholds summarized in a spreadsheet

**The repository does not contain the public use files (PUF) of the Family Income and Expenditure Survey 2012, 2015, and 2018, as well as all intermediate data files used for the analysis.** The PUF may be requested through an electronic Freedom of Information request to the Philippine Statistics Authority via [foi.gov.ph](https://www.foi.gov.ph). Ateneo de Manila University-affiliated employees may access the PUFs through the Rizal Library.

The analysis was written on August 2021 using Stata 17 and R 4.1.0, so some code modifications may be needed if there are any updates to the PUFs since.

The analysis can be replicated in full by conducting the following steps:
1. Clone the repository (or download the ZIP file) on the local computer without changing any file names.
2. Access the PUF and store them in a folder called **PUF**.
3. Create a new folder called **01_Intermediate_Extracts**. This is where the intermediate data files will be stored as the Stata and R codes are run.
4. Read the Stata do files and identify any user-defined package that needs to be installed first. Instructions are provided in the comments.
5. Run the Stata do files in order first. This will overwrite the log files, and replenish all intermediate data files and figures.
6. Read the R script files inside the **03_Figures** folder and identify any packages that need to be installed first before they can be loaded in the library.
7. Run the R script files, first running the dumbbell plot and Pen's parade script files before running their sensitivty analysis counterparts under subfolder **Supplementary_Figures**.

Comments are welcome via Twitter [@jasonhaw_](https://www.twitter.com/jasonhaw_).

