### Microsoft-R
#### Analyzing Big Data with Microsoft R Saint Louis RUG Presentation
#### The following is designed to set up a R environment in order to be able to run the
#### R markdown presentation on Analyzing Big Data with Microsoft R
#### Visual Studio Enterprise 2015
#### R Server 3.3.2

#### Prerequisites
1. R Server or R client. I have not tested this with R client but it should get you in the ballpark.
2. NYC First 6 months of data from here
 2016 Taxi data from NY.
http://www.nyc.gov/html/tlc/html/about/trip_record_data.shtml
3. It is assumed that the data is stored in a subdirectory folder called Data which is a subfolder of the working directory.
4. CreateSampleFile.ps1 is a Powershell script to select 130,000 random rows of the 2016-01 dataset.
5. A localhost instance of SQL Server 2016 with R Server installed is needed to run the SQL Server Compute context. 
	I think that is out of the scope of this as that may not be available in your environment. The latter sections of the markdown can then be commented out.
6. Install pandoc from pandoc.org
7. The necessary libraries can be sourced from SetupEnvironment.R

#### Preview the markdown document.

Todd Robinson
eMail: todd@biarachitect.com