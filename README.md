# Final-Project-Transforming-and-Analyzing-Data-with-SQL

## Project/Goals
The goal of the project is to clean and analyze the database provided, and use this to practise skills learned this week. 
There are 5 csv files: analytics, all_sessions, products, sales_by_sku and sales_report.
The data varies from 1K to 1M (analytics).


## Process
### Creating the Database 
- Creating the ecommerce database using the provided instructions.
- Creating tables for each csv file.
- Loading the csv file into each table. 
- Challenge/learning experience: I realized that some of the columns had integer values that were too long to be stored as numbers. I had to store them as varchar/text.
### Analyzing the data
I used Excel's Data Filters to analyze the data in each table. I tried to understand what the columns meant and the information they gave. I discovered patterns like the relationship between Visitorstarttime and visitId, between ratio (in sales_report and the units sold/inventory), the totalTransactionRevenue in all_sessions was a sum of the revenues in the analysis_table, etc.
### Cleaning the data
I removed unnecessary data in the all_sessions and analysis_tables e.g. data with empty columns, or single values.
### Restructuring the data
I created 2 new tables. 
A Products table that had the SKU and the name of each product, and the category taken from all_sessions. I made the SKU the product key for this table, and linked it to other tables as a foreign key.
A VisitorLog table that paired the fullVisitorIds with each VisitorId. This was used as a composite foreign key for tables like all_session and analysis. 
### Answering the Questions
I attempted to answer the questions, stating my assumptions. 


## Results
Please see the attached

## Challenges 
* Lack of information about what the data meant. There were columns that seemed to be indicate the same information (productRevenue, itemRevenue) but gave different values. I had to assume what each column represented, and this might affect the results.

* Missing data and the significance of missing data e.g. the revenue column in analysis was empty for several rows, and it was not clear whether this meant that the data was missing by mistake, or if this meant that revenue = 0. 

* Tables providing overlapping information - it's not clear what the difference between analysis and all_Sessions means as they both give data about the visitor log and the products viewed and purchased. As the tables provided similar information but this information also contradicted each other, I had to assume which provided more accurate information and I may be wrong.

* Repeated data e.g. the productCategory classed the products in several ways with items appearing under 'apparel' and then a similar or related item appearing under 'Brand'. 


## Future Goals
- Develop the 'Category' section by splitting into 2 values - "Function" and "Brand".
- Populate the products_inventory table with more information about category, stock quantity and restocking time.
- Investigate the patterns I noticed between totalTransactionrevenue in 'all_sessions' and revenue in Analysis. 
- Create a separate transaction table with columns for visitorID, date, order placed, etc. There are order numbers in all_sessions but this was not provided for each data entry. Either use this as a Key or develop a unique Key.
- Split the all_sessions tables between a table for site_specific information and a table for inventory information.

