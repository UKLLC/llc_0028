cd "S:/LLC_0028/data/cluster_comparison"
import delim using "no_covid_mlr_complete_dta.csv", clear

encode study, gen(study2)
recode lca_cluster (-10=99)
recode functional_limitation_cat (-1=99)

xtset study2

cd "S:/LLC_0028/data/cluster_comparison/stata_results"

foreach num of numlist 1/4 {
	gen cluster`num' = 0 if lca_cluster==99
	replace cluster`num' = 1 if lca_cluster==`num'

	foreach var of varlist llc_sex age_cat_numeric llc_ethnic3 functional_limitation_cat{

		xtlogit cluster`num' ib0.`var', re or
		etable, cstat(_r_b) cstat(_r_se) cstat(_r_ci) cstat(_r_p) showstars showstarsnote title(Cluster `num'.  No ) export(cluster`num'_`var'_no_complete.xlsx, replace)
	}

}