/*

script name: llc_0028_collating_EHR_data_infection.do
date created: 13/06/23
date last edited: 13/06/23
script author: Rachel Denholm
script purpose: to collate and clean EHR data from multiple sources to define COVID-19 infection among study participants
definition based on CCU013_01 COVID-IMPACT consortium project

*/

cd "S:\LLC_0028\data\processed_EHR"
clear

* appending minimised EHR data sources
gen llc_0028_stud_id = ""
gen date = ""
save "S:\LLC_0028\data\processed_EHR\EHR_infection_v2", replace

foreach files in sgss death gdppr hesapc hescc {
	import delimited using "`files'.csv", stringcols(_all) clear
	gen `files' = "1"
	append using "S:\LLC_0028\data\processed_EHR\EHR_infection_v2"
	save "S:\LLC_0028\data\processed_EHR\EHR_infection_v2", replace
}

* Formatting date
gen date_temp = date(date, "YMD")
format date_temp %td
drop date
rename date_temp EHR_COVIDdate

*sum date EHR_COVIDdate
drop if EHR_COVIDdate < mdy(1,1,2020) /* removing if recorded prior to 2020 */

*Generating categorical source variable
gen EHRdata_source = 1 if sgss=="1"
replace EHRdata_source = 2 if gdppr=="1" 
replace EHRdata_source = 3 if hesapc=="1" 
replace EHRdata_source = 4 if hescc=="1" 
replace EHRdata_source = 5 if death=="1"
lab def EHRdata_source 1"sgss" 2"gdppr" 3"hesapc" 4"hescc" 5"death"
lab val EHRdata_source data_source

save "S:\LLC_0028\data\processed_EHR\EHR_infection_v2", replace

use "S:\LLC_0028\data\processed_EHR\EHR_infection_v2", clear

*Generating file with only first recording of COVID-19 infection
gsort llc_0028_stud_id EHR_COVIDdate
by llc_0028_stud_id EHR_COVIDdate: keep if _n==1
by llc_0028_stud_id: keep if _n==1
keep llc_0028_stud_id EHR_COVIDdate EHRdata_source
lab var EHR_COVIDdate "First COVID-19 EHR record"

save "S:\LLC_0028\data\processed_EHR\EHR_infection_first_v2", replace
export delimited using "S:\LLC_0028\data\processed_EHR\EHR_infection_first_v2", datafmt replace


