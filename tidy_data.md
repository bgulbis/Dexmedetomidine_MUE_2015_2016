Working with Data
========================================================
author: Brian Gulbis
date: April 4, 2016
autosize: true

Big Data
========================================================

![big data](figures/howmuch.png)

<small>http://mashable.com/2011/06/28/data-infographic</small>

Big Data
========================================================

* 90% of the world's data was generated over the past two years
* Data comes from everywhere: 
    - Sensors used to gather climate information
    - Posts to social media sites
    - Digital pictures and videos
    - Purchase transaction records
    - Cell phone GPS signals
    - Electronic Medical Records

<small>http://www-01.ibm.com/software/data/bigdata/what-is-big-data.html</small>

Data in Research
========================================================

* Data is the second most important thing when doing research
* The question is the most important
    - Data may limit or enable certain questions
    - Having data does not matter if you are not asking the right question
* Big or small, you need the right data

Sources of Data
========================================================

* Manual collection
* Hospital / system databases
    - EDW, TheraDoc, Cardinal DCOA
* Organizations
    - UHC CDB/RM
* Public Data
    - Hospital Compare, Registries

Categories of Data
========================================================

* Data comes in all shapes and sizes, but rarely does it come in a format ready for analysis
* Raw data
    - Original source of data
    - Hard to use for analysis
* Processed data
    - Ready for analysis
    - Performed merging, subsetting, transforming, etc. on data
    - All processing steps should be recorded

Data Preparation
========================================================

* Estimated that 80% of data analysis is spent on cleaning and preparing data
* Major limiting factor for using large sets of data

<small>Dasu T, Johnson T (2003). Exploratory Data Mining and Data Cleaning. Wiley-IEEE.</small>

Raw Data Example
========================================================

* MUE medication administration data


```
Observations: 1,440,702
Variables: 6
$ PowerInsight Encounter Id    (int) 118754970, 118754970, 118754970, ...
$ Clinical Event End Date/Time (chr) "2014/07/16 10:11:00", "2014/07/1...
$ Clinical Event               (chr) "Administration Information", "HY...
$ Infusion Rate                (dbl) 0, 0, 0, 0, 0, 0, 0, 125, 125, 0,...
$ Infusion Rate Unit           (chr) "ml/hr", "", "", "", "", "", "", ...
$ Event ID                     (dbl) 12714562560, 12714562562, 1271604...
```

Principles of Tidy Data
========================================================

* Each variable should be in one column
    - Data within the column should be of the same type
* Each observation of that variable should be in a different row
* Variables of different “kinds” should be in different tables
    - Each table should be stored in it’s own **file**
    - Multiple tables should have a column which allows them to be linked
* Variable names should be stored in the first row
    - Names should be readable
    - Use minimal abbreviations
        + Good: clinical_event, clinicalEvent
        + Bad: clnevnt, ce, 

<small>Wickham, H. Tidy data. J Stat Software 2014; 59 (10)</small>

Data Processing Tools
========================================================

* Basic
    - Spreadsheets (Excel, etc.)
* Intermediate
    - Advanced spreadsheet functions
    - Databases (Access, MySQL, etc.)
* Advanced
    - Programming languages (R, Python, Julia, etc.)

Sharing Data
========================================================

* For faster anlaysis turnaround, include the following
    - Raw data
    - Tidy data
    - Code book describing each variable
    - List of instructions describing how you went from raw data to tidy data

<small>https://github.com/jtleek/datasharing</small>

Code Book
========================================================

* Information about the variables
    - Units of measure
* Information about the summary choices made
* Information about the experimental study design used

<small>https://github.com/jtleek/datasharing</small>

Data Types
========================================================

* Continuous
* Ordinal
* Categorical
* Missing
    - Should be coded as NA
* Censored
    - Know something about the missing data
    - Example: lab value outside detectable range
    - Still coded as NA, but add a new column which indicates the data is censored

<small>https://github.com/jtleek/datasharing</small>
    
File Formats for Sharing Data
========================================================

* Excel
    - Usually works but not ideal
    - All data should be on a single worksheet
    - No columns or cells should be highlighted
    - No macros should be used
* Text Files
    - Examples: CSV, TAB-delimited
    - Highest degree of compatibility
    - Only information in "cells" is retained

<small>https://github.com/jtleek/datasharing</small>

Sharing Data Example
========================================================

![messy shared data](figures/data_sharing_messy.png)

Sharing Data Example
========================================================


```
                     Diagnosis    Alcohol use  Illicit drug use
 COPD exacerbation        : 36   No     :133   No     :145     
 Acute respiratory failure: 25   no     :108   no     :115     
 Pneumonia                : 18   NK     : 91   NK     : 87     
 Respiratory failure      : 15   Yes    : 54   nk     : 36     
 Sepsis                   : 15   nk     : 32   Yes    : 31     
 Angioedema               : 13   (Other): 29   (Other): 32     
 (Other)                  :333   NA's   :  8   NA's   :  9     
    smoking   Number of packs/day number of years      Pak year        
 Current:93   Length:455          Length:455         Length:455        
 NK     :85   Class :character    Class :character   Class :character  
 None   :85   Mode  :character    Mode  :character   Mode  :character  
 none   :68                                                            
 nk     :38                                                            
 (Other):77                                                            
 NA's   : 9                                                            
      ARF      Severe organ insufficiency or immunocompromised 
 No     :172   No     :153                                     
 Yes    :124   Yes    :137                                     
 no     : 93   no     : 91                                     
 yes    : 47   yes    : 53                                     
 NO     :  9   NO     :  5                                     
 (Other):  7   (Other):  7                                     
 NA's   :  3   NA's   :  9                                     
     If yes   
 No     :159  
 medical: 96  
 Medical: 80  
 no     : 80  
 NO     : 16  
 (Other): 16  
 NA's   :  8  
```

