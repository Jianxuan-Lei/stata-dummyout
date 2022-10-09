*****************************************************
*                                                   *
*           DUMMY OUT CATEGORICAL VARIABLES         *
*                                                   *
*****************************************************

/* This "dummyout" command is essentially same to "tab(), gen()", except that:

	* Dummyout accepts multiple variables and does not require a loop
	
	* Dummyout uses value label numbers to label created dummy variables, instead of the sequences
*/
	
program dummyout
	
	syntax varlist

		foreach i in `varlist' {
			qui levelsof `i', local(levels)                     // get levels of a categorical variable
			
				foreach L of local levels {
					qui gen `i'_`L' = (`i' == `L') if `i' != .  // dummy out variables
				}
			
			local vlblname: value label `i'                     // get value label name
				foreach L of local levels {
					local vlblvalue: label `vlblname' `L'       // get value label value
					la var `i'_`L' "`vlblvalue'"
				}
				
			di in green "dummy variable(s) created for: `i'"
		}

end 