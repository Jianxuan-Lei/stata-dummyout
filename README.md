---
title: 'Dummy out Categorical Variables in Stata'
date: 2022-10-09
permalink: /posts/2022/10/dummyout/
tags:
  - Stata
  - Tables
  - Resources
---

Summary statistics for categorical variables in Stata
------
It is somewhat painful to produce a table to summarize categorical variables in Stata. The issue is that the popular user-written package [estout/esttab](http://repec.sowi.unibe.ch/stata/estout/) does not accept factor notations for summary statistics. In other words, you won't get a neat table by simply typing the following in Stata:


	.	eststo: estpost sum i.x


An obvious solution is to create dummy variables before you summarize them. Stata's system command can help you do this:

	.	tab x, gen(x_)


However, such a approach is cumbersome when you have multiple categorical variables, since you probably need to write a loop:

	.	foreach var of varlist x y z {
	.		tab(`var'), gen(`var'_)
	.	}
	
Moreover, the generated dummy variables do not have nice labels that you can use later. If you want a descriptive table with approproaite variable names, you need to modify the labels for all the dummy variables or use esttab's "varlabel()" option. In my mind, both are quite troublesome.

	.	sysuse auto, clear
	.	tab(foreign), gen(foreign_)
	.	describe foreign_*
	
	
		      storage   display    value
	variable name   type    format     label      variable label
	---------------------------------------------------------------------------
	foreign_1       byte    %8.0g                 foreign==Domestic
	foreign_2       byte    %8.0g                 foreign==Foreign
	
This label problem is also why the command below does not work ideally:

	.	eststo: xi: estpost sum i.x i.y

In short, various minor but annoying issues motivate me to write a simple program "dummyout" to avoid inconvenience, which I will introduce in the next section.

The "dummyout" command
------
The "dummyout" command improves Stata's "tab(), gen()" in the following ways:
* It accepts multiple variables and does not require a loop
* It uses actual values to label generated dummies, instead of using the sequence in which dummies are generated

The ado file for "dummyout" can be downloaded [here](https://github.com/Jianxuan-Lei/stata-dummyout). You are ready to go once you put it in your Stata's personal ado-file path (type adopath in Stata to see your path).

	.	dummyout x y z


An example
------
The following example illustrates these points using a dataset from CPS ASEC 2021.

	. 	* import data
	. 	use CPS2021_union_good, clear

	. 
	. 	* describe the categorical variable: firmsize
	. 	d    firmsize race

		      storage   display    value
	variable name   type    format     label      variable label
	---------------------------------------------------------------------------------
	firmsize        byte    %10.0g     firmsize_lbl
						      Number of employees
	race            float   %9.0g      newrace    Race (4 categories)
	

	. 
	. 	* add numbers to the value labels & tabulate
	. 	numlabel firmsize_lbl newrace, add

	. tab1     firmsize race

	-> tabulation of firmsize  

	    Number of |
	    employees |      Freq.     Percent        Cum.
	--------------+-----------------------------------
	  1. Under 10 |      1,014       11.45       11.45
	  2. 10 to 24 |      1,136       12.82       24.27
	  5. 25 to 99 |        665        7.51       31.78
	7. 100 to 499 |      1,125       12.70       44.48
	8. 500 to 999 |        543        6.13       50.61
	     9. 1000+ |      4,375       49.39      100.00
	--------------+-----------------------------------
		Total |      8,858      100.00

	-> tabulation of race  

	    Race (4 |
	categories) |      Freq.     Percent        Cum.
	------------+-----------------------------------
	   1. White |      7,127       80.46       80.46
	   2. Black |        893       10.08       90.54
	   3. Asian |        558        6.30       96.84
	   4. Other |        280        3.16      100.00
	------------+-----------------------------------
	      Total |      8,858      100.00
	      
	      
	      
	.	* dummyout: as you will see, the suffix matches the values for firmsize
	. 	dummyout firmsize race
	
	dummy variable(s) created for: firmsize
	dummy variable(s) created for: race

	. d firmsize_* race_*

		      storage   display    value
	variable name   type    format     label      variable label
	------------------------------------------------------------------
	firmsize_1      float   %9.0g                 1. Under 10
	firmsize_2      float   %9.0g                 2. 10 to 24
	firmsize_5      float   %9.0g                 5. 25 to 99
	firmsize_7      float   %9.0g                 7. 100 to 499
	firmsize_8      float   %9.0g                 8. 500 to 999
	firmsize_9      float   %9.0g                 9. 1000+
	race_1          float   %9.0g                 1. White
	race_2          float   %9.0g                 2. Black
	race_3          float   %9.0g                 3. Asian
	race_4          float   %9.0g                 4. Other

	
	. 	* alternatively, the suffix does match the values for firmsize when using tab(),gen()
	. 	drop firmsize_* race_*

	. 
	.	  foreach var of varlist firmsize race {
	.         	qui tab(`var'), gen(`var'_)
	.	  }

	. 
	. 	d firmsize_1 firmsize_2 firmsize_3 firmsize_4 firmsize_5 firmsize_6 race_1 race_2 race_3 race_4

		      storage   display    value
	variable name   type    format     label      variable label
	------------------------------------------------------------------
	firmsize_1      byte    %8.0g                 firmsize==1. Under 10
	firmsize_2      byte    %8.0g                 firmsize==2. 10 to 24
	firmsize_3      byte    %8.0g                 firmsize==5. 25 to 99
	firmsize_4      byte    %8.0g                 firmsize==7. 100 to 499
	firmsize_5      byte    %8.0g                 firmsize==8. 500 to 999
	firmsize_6      byte    %8.0g                 firmsize==9. 1000+
	race_1          byte    %8.0g                 race==1. White
	race_2          byte    %8.0g                 race==2. Black
	race_3          byte    %8.0g                 race==3. Asian
	race_4          byte    %8.0g                 race==4. Other
