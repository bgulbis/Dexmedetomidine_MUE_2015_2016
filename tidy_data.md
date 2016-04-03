Working with Data
========================================================
author: Brian Gulbis
date: April 4, 2016

Objectives
========================================================

* Discuss why we need data
* Describe raw and tidy data
* Identify ways to improve data management and sharing

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
    - Allows for larger studies much more quickly
    - Can perform more in-depth analysis
* Unfortunately, data rarely comes "ready-to-use"
* Preparing the data requires some technical know-how and additional tools

Data Preparation
========================================================

* Estimated that 80% of data analysis is spent on cleaning and preparing data
* Major limiting factor for many "amateur" researchers
* Adequately preparing data will facilitate data analysis
    - Allows data to be input into various anlaysis tools
    - Some analysis cannot be performed without transforming raw data

<small>Dasu T, Johnson T (2003). Exploratory Data Mining and Data Cleaning. Wiley-IEEE.</small>

Raw and Tidy Data
========================================================

* Raw data
    - Original source of data
    - Usually "messy"
    - Hard to use for analysis
* Tidy data
    - Data has been processed and is ready for analysis
    - Performed merging, sub-setting, transforming, etc. on data
    - All processing steps should be recorded

Raw Data Example
========================================================





![raw data](figures/raw_data.png)

* Contains 1,440,702 rows of data
* Multiple observations for each patient and medication

Tidy Data Example
========================================================



![tidy data](figures/tidy_data.png)

* Data has been transformed and aggregated
* Contains one observation per patient

Most Common Problems with Messy Data
========================================================

* Column headers are values, not variable names
* Multiple variables are stored in one column
* Variables are stored in both rows and columns
* Multiple types of observational units are stored in the same table
* A single observational unit is stored in multiple tables

<small>Wickham, H. Tidy data. J Stat Software 2014; 59 (10)</small>

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

Data Processing Tools
========================================================

* Basic
    - Spreadsheets (Excel, etc.)
* Intermediate
    - Advanced spreadsheet functions
    - Databases (Access, MySQL, etc.)
* Advanced
    - Programming languages (R, Python, Julia, etc.)

Data Manipulation
========================================================

* Filter
    - Remove observations based on some condition
        + Remove patients who are < 18 years old
        + Find all patients admitted between January 1, 2015 and December 31, 2015
* Transform
    - Add or modify variables
        + Convert all weights to same units
        + Calculating CrCl

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
    
File Formats for Sharing Data
========================================================

* Excel
    - Usually works, but not ideal
        + May be compatibility issues with the analysis tool
        + Calculated cells may not be read correctly
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

Data Collection and Storage
========================================================

* Separate data collection form and data storage tool
* Design with the next step in mind
    - Design data collection form to facilitate getting data into storage
    - Design data storage to facilitate getting into analysis tool
* Do not include data aggregation in data storage
    - Calculated columns may not import correctly into analysis tools
    
Using Microsoft Excel
========================================================

* Excel should be used primarily for data storage
    - Requires a lot of scrolling to visualize all data points
    - Columns generally not ordered to facilitate data entry
    - Violates the rule to keep different kinds of data in separate files
* Consider using Excel's built-in form feature for data entry
    - Can create more advanced forms using Visual Basic
    - Google Docs allows for easy, robust form creation
* Can be used for limited data analysis
