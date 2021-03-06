Working with Data
========================================================
author: Brian Gulbis
date: April 4, 2016
autosize: true

Objectives
========================================================

* Discuss why we need data
* Discuss data preparation 
* Identify ways to facilitate data analysis

Big Data
========================================================

![big data](figures/howmuch.png)

<small>http://mashable.com/2011/06/28/data-infographic</small>

***

* Gigabyte
* Terabyte
* Petabyte
* Exabyte
* __Zettabyte__
* Yottabyte

Big Data
========================================================

* 90% of data was generated over the past two years
* Data comes from everywhere: 
    - Sensors used to gather climate information
    - Posts to social media sites
    - Digital pictures and videos
    - Purchase transaction records
    - Cell phone GPS signals
    - __Electronic Medical Records__

<small>http://www-01.ibm.com/software/data/bigdata/what-is-big-data.html</small>

Big Data in Healthcare
========================================================

* Preventative medicine
    - Combine data from multiple sources to create predictive models
        + Fitness trackers, medical and insurance records, genetic data, etc.
* Clinical trials
    - Data often kept in silos
        + 96% of potentially available data on cancer patients has not been analyzed
    - Data-sharing will allow for new discoveries which otherwise would not be apparent

<small>[Forbes](http://www.forbes.com/sites/bernardmarr/2015/04/21/how-big-data-is-changing-healthcare/#ee268ec32d91)</small>

Big Data in Healthcare
========================================================

* Personalized medicine
    - Tailor medicine to an individuals genetic makeup
* Preventing spread of epidemics
    - Mobile phone location data used to track population movements

<small>[Forbes](http://www.forbes.com/sites/bernardmarr/2015/04/21/how-big-data-is-changing-healthcare/#ee268ec32d91)</small>

Data in Research
========================================================

* Data is the second most important thing in research
* The question being asked is the first
* Data may limit or enable certain questions
* It does not matter how much data you have if you are not asking the right question

<small>[The Data Scientist's Toolbox - Coursera](https://www.coursera.org/learn/data-scientists-tools)</small>

Sources of Data
========================================================

* Hospital / system databases
    - Care4, Sovera (manual)
    - EDW, TheraDoc, Cardinal DCOA
* National organizations
    - UHC Clinical Data Base / Resource Manager
* Public Data
    - Hospital Compare, Registries
    
The Problem
========================================================

* Having all of this data is great!
    - Allows for studies with much larger scopes to be completed in reasonable time frames
    - Can perform more in-depth analysis
* Unfortunately, data rarely comes "ready-to-use"
* Preparing the data requires some technical know-how and additional tools

Data Processing Tools
========================================================

* Basic
    - Spreadsheets (Microsoft Excel, Google Sheets, etc.)
* Intermediate
    - Advanced spreadsheet functions
    - Databases (Microsoft Access, MySQL, etc.)
* Advanced
    - Programming languages (R, Python, Julia, etc.)

Data Preparation
========================================================

* Estimated that 80% of data analysis is spent on cleaning and preparing data
* Major limiting factor for most "amateur" researchers
* Adequately preparing data will facilitate data analysis
    - Allows data to be input into various anlaysis tools
    - Some analysis cannot be performed without cleaning or transforming raw data

<small>Dasu T, Johnson T (2003). Exploratory Data Mining and Data Cleaning. Wiley-IEEE.</small>

Raw Data
========================================================
* Original source of data
* Usually "messy"
* Difficult, if not impossible, to use for analysis

Raw Data Example
========================================================





![raw data](figures/raw_data.png)

* Contains 1,440,702 rows of data
* Multiple observations for each patient and medication

Most Common Problems with Messy Data
========================================================

* Column headers are values, not variable names
* Multiple variables are stored in one column
* Variables are stored in both rows and columns
* Multiple types of observational units are stored in the same table
* A single observational unit is stored in multiple tables

<small>Wickham, H. Tidy data. J Stat Software 2014; 59 (10)</small>

Headers are Values
========================================================

religion|<$10k|$10-20k|$20-30k|$30-40k|$40-50k|$50-75k
--------|-----|-------|-------|-------|-------|-------
Agnostic|27|34|60|81|76|137 
Atheist|12|27|37|52|35|70 
Buddhist|27|21|30|34|33|58
Catholic|418|617|732|670|638|1116
Don't know/refused|15|14|15|11|10|35
Evangelical Prot|575|869|1064|982|881|1486
Hindu|1|9|7|9|11|34
Historically Black Prot|228|244|236|238|197|223
Jehovah's Witness|20|27|24|24|21|30
Jewish|19|19|25|25|30|95

<small>Data from: [Pew Research Center](http://pewforum.org/Datasets/Dataset-Download.aspx)</small>

<small>Wickham, H. Tidy data. J Stat Software 2014; 59 (10)</small>

Multiple Variables in Each Column
========================================================

country|year|m014|m1524|m2534|m3544|m4554|m5564|m65|f014
-------|----|----|-----|-----|-----|-----|-----|---|----
AD|2000|0|0|1|0|0|0|0|-
AE|2000|2|4|4|6|5|12|10|3
AF|2000|52|228|183|149|129|94|80|93
AG|2000|0|0|0|0|0|0|1|1
AL|2000|2|19|21|14|24|19|16|3
AM|2000|2|152|130|131|63|26|21|1
AN|2000|0|0|1|2|0|0|0|0
AO|2000|186|999|1003|912|482|312|194|247
AR|2000|97|278|594|402|419|368|330|121
AS|2000|-|-|-|-|1|1|-|-

<small>Data from: World Health Organization</small>

<small>Wickham, H. Tidy data. J Stat Software 2014; 59 (10)</small>

Variables Stored in Rows and Columns
========================================================

id|year|month|element|d1|d2|d3|d4|d5|d6|d7|d8
---|----|-----|-------|---|---|---|---|---|---|---|---
MX17004|2010|1|tmax|-|-|-|-|-|-|-|-
MX17004|2010|1|tmin|-|-|-|-|-|-|-|-
MX17004|2010|2|tmax|-|27.3|24.1|-|-|-|-|-
MX17004|2010|2|tmin|-|14.4|14.4|-|-|-|-|-
MX17004|2010|3|tmax|-|-|-|-|32.1|-|-|-
MX17004|2010|3|tmin|-|-|-|-|14.2|-|-|-
MX17004|2010|4|tmax|-|-|-|-|-|-|-|-
MX17004|2010|4|tmin|-|-|-|-|-|-|-|-
MX17004|2010|5|tmax|-|-|-|-|-|-|-|-
MX17004|2010|5|tmin|-|-|-|-|-|-|-|-

<small>Data from: Global Historical Climatology Network</small>

<small>Wickham, H. Tidy data. J Stat Software 2014; 59 (10)</small>

Tidy data
========================================================
* Data has been processed and is ready for analysis
* Manipulations include 
    - Filtering
    - Transforming
    - Aggregating
    - Sorting
* All processing steps should be recorded

Data Manipulation
========================================================

* Filter
    - Remove observations based on some condition
        + Remove patients who are < 18 years old
        + Find all patients admitted between January 1, 2015 and December 31, 2015
* Transform
    - Add or modify variables
        + Convert all weights to same units
        + Calculating CrCl and storing in new column

<small>Wickham, H. Tidy data. J Stat Software 2014; 59 (10)</small>

Data Manipulation
========================================================

* Aggregate
    - Collapse multiple values into a single value
        + Mean of a group of observations
        + Total number of patients who experienced an adverse event
* Sort
    - Change the order of observations
        + From highest to lowest
        + From first to last

<small>Wickham, H. Tidy data. J Stat Software 2014; 59 (10)</small>

Tidy Data Example
========================================================



![tidy data](figures/tidy_data.png)

* Data has been transformed and aggregated
* Contains one observation per patient

Principles of Tidy Data
========================================================

* Each variable should be in one column
    - Data within the column should be of the same type
* Each observation of that variable should be in a different row
* Variables of different “kinds” should be in different tables
    - Each table should be stored in it’s **own file**
    - Multiple tables should have a column which allows them to be linked

<small>Wickham, H. Tidy data. J Stat Software 2014; 59 (10)</small>

Principles of Tidy Data
========================================================

* Variable names should be stored in the first row
    - Names should be descriptive and readable
    - Use minimal abbreviations
    - Avoid having spaces in name
        + Good: med_name, sedativeRate
        + Bad: clnevnt, ce, clinical event

<small>Wickham, H. Tidy data. J Stat Software 2014; 59 (10)</small>

Data Types
========================================================

* Continuous
* Ordinal and Categorical
    - In general, avoid coding as numbers
        + Sex should be "female" or "male"
        + Hypertension should be "true" or "false"
    - Will avoid coding errors when entering data
    - Will avoid confusion when interpreting data
    - Some programs may interpret numbers as continuous data

<small>https://github.com/jtleek/datasharing</small>

Missing Data
========================================================

* Missing data should be coded as NA
* Censored data
    - Know something about the missing data
        + Lab value outside detectable range
    - Still coded as NA, but add a new column which indicates the data is censored

<small>https://github.com/jtleek/datasharing</small>
    
Data Tidying
========================================================

* Each researcher should tidy data to the best of their ability
    - First row contains variable names
    - Column names are readable
    - Data storage is organized appropriately
    - Thorough documentation describing the data is available
    - Manually collected data is recorded in a consistent manner
* Will facilitate sharing data for advanced tidying and/or analysis

Sharing Data
========================================================

* For faster analysis turnaround, include the following
    - Raw data
    - Tidy data
    - Code book
    - Instruction list

<small>https://github.com/jtleek/datasharing</small>

Code Book
========================================================

* Describes each variables in the data set
    - Units of measure
* Provides information about the summary choices made
* Includes information about the experimental study design used

<small>https://github.com/jtleek/datasharing</small>

Instruction List
========================================================

* Step-by-step instructions which describe how to
    - Process raw data into tidy data 
    - Analyze tidy data and produce final results
* Results should be reproducible by others
    - Reviewers, readers, future self, etc.
    - Given your raw data, they should be able to replicate the analysis performed 

<small>https://github.com/jtleek/datasharing</small>

Sharing Data Example
========================================================

![messy shared data](figures/data_sharing_messy.png)

Sharing Data Example Examined
========================================================



* Diagnosis
    - Number of distinct values: 172
* Alcohol Use


```
   0   NA   nk   Nk   NK   no   nO   No   NO Past  yes  Yes NA's 
   2    1   32    4   91  108    1  133    3    1   17   54    8 
```

* Number of packs/day
    - Contains numeric and non-numeric data
* Column P heading: "If yes"
    - Unclear what this data represents

File Formats for Sharing Data
========================================================

* Excel
    - Usually works, but not ideal
        + May be compatibility issues with the analysis tool
        + Calculated cells may not be read correctly
        + Limits on number of rows that can be stored
    - All data should be in a single worksheet
    - No columns or cells should be highlighted
    - No macros should be used

<small>https://github.com/jtleek/datasharing</small>

File Formats for Sharing Data
========================================================

* Text Files
    - Examples: CSV, TAB-delimited
    - Highest degree of compatibility
    - Only the information in "cells" is retained

<small>https://github.com/jtleek/datasharing</small>

Advice for Data Collection and Storage
========================================================

* Create separate tool for each step
    - Data collection, data storage, and data analysis
* Design with the next step in mind
    - Collection form should facilitate getting data into storage
    - Storage should facilitate getting into analysis tool
* Improves efficiency and prevents errors
    - Calculated columns not importing correctly for analysis
    - Prevents accidentally overwriting data
    
Using Microsoft Excel
========================================================

* Excel should be used primarily for data storage
    - Requires a lot of scrolling to visualize all data points
    - Columns generally not ordered to facilitate data entry
    - Does not keep different kinds of data in separate files
* Consider using Excel's built-in form feature for data entry
    - Can create more advanced forms using Visual Basic
    - Google Docs allows for easy, robust form creation
* Can be used for limited data analysis
    - Create a new file which imports data from storage
    - Can import from multiple files

Applying What We've Learned
========================================================

* MUE Data Collection Form
