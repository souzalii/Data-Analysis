/*============================================================================
Developed by: Aline de Souza Andrade
Student number: 23247513

Project 1 - CITS5504

Sql script to create tables
============================================================================*/

/*--create data base--*/
PRINT '';
PRINT '*** Dropping Database';
GO
IF EXISTS (SELECT [name] FROM [master].[sys].[databases] WHERE [name] = N'ProjectDW2')
DROP DATABASE ProjectDW2;
GO
PRINT '';
PRINT '*** Creating Database';
GO
Create database ProjectDW2
Go
Use ProjectDW2
Go

/*--Create tables to receive csv content--*/
PRINT '';
PRINT '*** Creating raw_seek table';
GO
DROP TABLE IF EXISTS raw_seek
CREATE TABLE [dbo].[raw_seek](
	[category] [nvarchar](50) NULL,
	[city] [nvarchar](50) NULL,
	[company_name] [nvarchar](100) NULL,
	[geo] [nvarchar](50) NULL,
	[job_board] [nvarchar](50) NULL,
	[job_description] [nvarchar](max) NULL,
	[job_title] [nvarchar](max) NULL,
	[job_type] [nvarchar](50) NULL,
	[post_date] [nvarchar](50) NULL,
	[salary_offered] [nvarchar](100) NULL,
	[state] [nvarchar](50) NULL,
	[url] [nvarchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


PRINT '';
PRINT '*** Creating raw_reed table';
GO
DROP TABLE IF EXISTS raw_reed
CREATE TABLE [dbo].[raw_reed](
	[category] [nvarchar](50) NULL,
	[city] [nvarchar](50) NULL,
	[company_name] [nvarchar](100) NULL,
	[geo] [nvarchar](50) NULL,
	[job_board] [nvarchar](50) NULL,
	[job_description] [nvarchar](max) NULL,
	[job_requirements] [nvarchar](max) NULL,
	[job_title] [nvarchar](max) NULL,
	[job_type] [nvarchar](50) NULL,
	[post_date] [nvarchar](50) NULL,
	[salary_offered] [nvarchar](100) NULL,
	[state] [nvarchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/*--insert content--*/
-- import the file reed

PRINT '';
PRINT '*** Inserting content from csv into tables (raw_reed)';
GO
BULK INSERT raw_reed
FROM 'C:\Users\aline\Documents\master\CITS5504 - Data warehousing\project-dw2\csv_files\reed_uk.csv'
WITH
(
	FORMAT='CSV',
	FIRSTROW=2,
	CODEPAGE='65001',
	DATAFILETYPE='char',
	FIELDTERMINATOR=',',
	ROWTERMINATOR='\n'
)


PRINT '';
PRINT '*** Inserting content from csv into tables (raw_seek)';
GO
-- import the file reed
BULK INSERT raw_seek
FROM 'C:\Users\aline\Documents\master\CITS5504 - Data warehousing\project-dw2\csv_files\seek_australia.csv'
WITH
(
	FORMAT='CSV',
	FIRSTROW=2,
	CODEPAGE='65001',
	DATAFILETYPE='char',
	FIELDTERMINATOR=',',
	ROWTERMINATOR='\n'
)

/*--Create stage tables--*/
PRINT '';
PRINT '*** Creating stage table';
GO
DROP TABLE IF EXISTS stageJobs
CREATE TABLE [dbo].[stageJobs](
	[row_number] [int] IDENTITY(1,1) NOT NULL,
	[category] [nvarchar](50) NULL,
	[city] [nvarchar](50) NULL,
	[company_name] [nvarchar](100) NULL,
	[geo] [nvarchar](50) NULL,
	[job_board] [nvarchar](50) NULL,
	[job_description] [nvarchar](max) NULL,
	[job_requirements] [nvarchar](max) NULL,
	[job_title] [nvarchar](max) NULL,
	[job_type] [nvarchar](50) NULL,
	[job_type_hours] [nvarchar](50) NULL,
	[post_date_hour] [nvarchar](50) NULL,
	[post_date] [nvarchar](50) NULL,
	[post_hour] [nvarchar](50) NULL,
	[salary_offered] [nvarchar](100) NULL,
	[salary_information] [nvarchar](100) NULL,
	[state] [nvarchar](50) NULL,
	[url] [nvarchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

/*--insert content in stage tables--*/
PRINT '';
PRINT '*** Inserting content from raw_seek into stage table';
GO
insert into stageJobs (
	category
	,city
	,company_name
	,geo
	,job_board
	,job_description
	,job_title
	,job_type
	,post_date_hour
	,salary_offered
	,state
	,url
)
Select distinct 
	category
	,city
	,company_name
	,geo
	,job_board
	,job_description
	,job_title
	,job_type
	,post_date
	,salary_offered
	,state
	,url
from raw_seek


PRINT '';
PRINT '*** Inserting content from raw_reed into stage table';
GO
insert into stageJobs (
	category
	,city
	,company_name
	,geo
	,job_board
	,job_description
    ,job_requirements
	,job_title
	,job_type
	,post_date_hour
	,salary_offered
	,state
)
Select distinct 
	category
	,city
	,company_name
	,geo
	,job_board
	,job_description
    ,job_requirements
	,job_title
	,job_type
	,post_date
	,salary_offered
	,state
from raw_reed

/*--create error tables--*/
PRINT '';
PRINT '*** Creating error table';
GO
DROP TABLE IF EXISTS error_stage_location
CREATE TABLE [dbo].[error_stage_location](
	[row_number] [int] NOT NULL,
	[state_error] [nvarchar](50),
	[city_error] [nvarchar](50)
) 

/*--creating dim and fact tables--*/
PRINT '';
PRINT '*** Creating dimension tables';
PRINT '*** Creating dimension Board';
GO

CREATE TABLE [dbo].[dimBoard](
	[JobBoardID] [int] IDENTITY(1,1) NOT NULL,
	[BoardName] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Source] PRIMARY KEY CLUSTERED 
(
	[JobBoardID] ASC
))

PRINT '';
PRINT '*** Creating dimension Company';
GO

CREATE TABLE [dbo].[dimCompany](
	[CompanyID] [int] IDENTITY(1,1) NOT NULL,
	[CompanyName] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_Company] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC
))

PRINT '';
PRINT '*** Creating dimension Date';
GO

CREATE TABLE [dbo].[dimDate](
	[DateID] [int] NOT NULL,
	[Date] [date] NOT NULL,
	[Year_yyyy] [smallint] NOT NULL,
	[Month_mm] [smallint] NOT NULL,
 CONSTRAINT [PK_Date] PRIMARY KEY CLUSTERED 
(
	[DateID] ASC
))

PRINT '';
PRINT '*** Creating dimension Hour';
GO

CREATE TABLE [dbo].[dimHour](
	[HourID] [int] IDENTITY(1,1) NOT NULL,
	[Hour] [nvarchar](50) NULL,
	[DayPeriod] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_dimHour] PRIMARY KEY CLUSTERED 
(
	[HourID] ASC
))


PRINT '';
PRINT '*** Creating dimension Job Category';
GO

CREATE TABLE [dbo].[dimJobCategory](
	[JobCategoryID] [int] IDENTITY(1,1) NOT NULL,
	[CategoryName] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_JobCategory] PRIMARY KEY CLUSTERED 
(
	[JobCategoryID] ASC
))

PRINT '';
PRINT '*** Creating dimension Job Salary';
GO

CREATE TABLE [dbo].[dimJobSalary](
	[SalaryID] [int] IDENTITY(1,1) NOT NULL,
	[SalaryType] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_SalaryID] PRIMARY KEY CLUSTERED 
(
	[SalaryID] ASC
))

PRINT '';
PRINT '*** Creating dimension Job Type';
GO

CREATE TABLE [dbo].[dimJobType](
	[JobTypeID] [int] IDENTITY(1,1) NOT NULL,
	[JobType] [nvarchar](50) NOT NULL,
	[JobHours] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_JobType] PRIMARY KEY CLUSTERED 
(
	[JobTypeID] ASC
))

PRINT '';
PRINT '*** Creating dimension Job Location';
GO

CREATE TABLE [dbo].[dimLocation](
	[LocationID] [int] IDENTITY(1,1) NOT NULL,
	[Country] [nvarchar](50) NOT NULL,
	[State] [nvarchar](50) NULL,
	[City] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Location] PRIMARY KEY CLUSTERED 
(
	[LocationID] ASC
))

PRINT '';
PRINT '*** Creating fact JobPost table';
GO

CREATE TABLE [dbo].[factJobPost](
	[JobCombination] [int] IDENTITY(1,1) NOT NULL,
	[JobPostDateID] [int] NOT NULL,
	[JobCategoryID] [int] NOT NULL,
	[CompanyID] [int] NOT NULL,
	[JobLocationID] [int] NOT NULL,
	[JobTypeID] [int] NOT NULL,
	[JobBoardID] [int] NOT NULL,
	[SalaryID] [int] NOT NULL,
	[HourID] [int] NOT NULL,
 CONSTRAINT [PK_factJob] PRIMARY KEY CLUSTERED 
(
	[JobCombination] ASC,
	[JobPostDateID] ASC,
	[JobCategoryID] ASC,
	[CompanyID] ASC,
	[JobLocationID] ASC,
	[JobTypeID] ASC,
	[JobBoardID] ASC,
	[SalaryID] ASC,
	[HourID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[factJobPost]  WITH CHECK ADD  CONSTRAINT [FK_factJobPost_dimBoard] FOREIGN KEY([JobBoardID])
REFERENCES [dbo].[dimBoard] ([JobBoardID])
GO

ALTER TABLE [dbo].[factJobPost] CHECK CONSTRAINT [FK_factJobPost_dimBoard]
GO

ALTER TABLE [dbo].[factJobPost]  WITH CHECK ADD  CONSTRAINT [FK_factJobPost_dimCompany] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[dimCompany] ([CompanyID])
GO

ALTER TABLE [dbo].[factJobPost] CHECK CONSTRAINT [FK_factJobPost_dimCompany]
GO

ALTER TABLE [dbo].[factJobPost]  WITH CHECK ADD  CONSTRAINT [FK_factJobPost_dimDate] FOREIGN KEY([JobPostDateID])
REFERENCES [dbo].[dimDate] ([DateID])
GO

ALTER TABLE [dbo].[factJobPost] CHECK CONSTRAINT [FK_factJobPost_dimDate]
GO

ALTER TABLE [dbo].[factJobPost]  WITH CHECK ADD  CONSTRAINT [FK_factJobPost_dimHour] FOREIGN KEY([HourID])
REFERENCES [dbo].[dimHour] ([HourID])
GO

ALTER TABLE [dbo].[factJobPost] CHECK CONSTRAINT [FK_factJobPost_dimHour]
GO

ALTER TABLE [dbo].[factJobPost]  WITH CHECK ADD  CONSTRAINT [FK_factJobPost_dimJobCategory] FOREIGN KEY([JobCategoryID])
REFERENCES [dbo].[dimJobCategory] ([JobCategoryID])
GO

ALTER TABLE [dbo].[factJobPost] CHECK CONSTRAINT [FK_factJobPost_dimJobCategory]
GO

ALTER TABLE [dbo].[factJobPost]  WITH CHECK ADD  CONSTRAINT [FK_factJobPost_dimJobSalary] FOREIGN KEY([SalaryID])
REFERENCES [dbo].[dimJobSalary] ([SalaryID])
GO

ALTER TABLE [dbo].[factJobPost] CHECK CONSTRAINT [FK_factJobPost_dimJobSalary]
GO

ALTER TABLE [dbo].[factJobPost]  WITH CHECK ADD  CONSTRAINT [FK_factJobPost_dimJobType] FOREIGN KEY([JobTypeID])
REFERENCES [dbo].[dimJobType] ([JobTypeID])
GO

ALTER TABLE [dbo].[factJobPost] CHECK CONSTRAINT [FK_factJobPost_dimJobType]
GO

ALTER TABLE [dbo].[factJobPost]  WITH CHECK ADD  CONSTRAINT [FK_factJobPost_dimLocation] FOREIGN KEY([JobLocationID])
REFERENCES [dbo].[dimLocation] ([LocationID])
GO

ALTER TABLE [dbo].[factJobPost] CHECK CONSTRAINT [FK_factJobPost_dimLocation]
GO
