/*============================================================================
Developed by: Aline de Souza Andrade
Student number: 23247513

Project 1 - CITS5504

Sql insert content into dimension tables
============================================================================*/
/*--select data base--*/
Use ProjectDW2
Go

PRINT '';
PRINT '*** Inserting data into dimension tables';
GO

/*--dimDate--*/
insert into dimDate
select distinct replace(post_date,'-',''), post_date, format(convert(date, post_date),'yyyy'),format(convert(date, post_date),'MM') from stageJobs

/*--dimCompany name--*/
insert into dimCompany
select distinct company_name from stageJobs order by company_name

/*--dimJobCategory--*/
insert into dimJobCategory
select distinct category from stageJobs order by category

/*--dimJobType--*/
insert into dimJobType
select distinct job_type, job_type_hours from stageJobs 

/*--dimBoard--*/
insert into dimBoard
select distinct job_board from stageJobs 

/*--dimHour--*/
insert into dimHour(Hour,DayPeriod)
select distinct post_hour ,
case
	when post_hour between '00:00:00' and '04:59:59' then 'night'
	when post_hour between '05:00:00' and '11:59:59' then 'morning'
	when post_hour between '12:00:00' and '17:59:59' then 'afternoon'
	when post_hour between '18:00:00' and '21:59:59' then 'evening'
	when post_hour between '22:00:00' and '23:59:59' then 'night'
	else 'Not informed'
end
from stageJobs order by post_hour 

/*--dimLocation--*/
insert into dimLocation
select distinct geo,state,city from stageJobs where row_number not in (select row_number from error_stage_location) order by geo,state,city

/*--salary--*/
insert into dimJobSalary
select distinct salary_information from stageJobs

/*------update stage table----------*/

PRINT '';
PRINT '*** Updating stage tables';
GO

--category
update st
set st.category = dim.JobCategoryID
from stageJobs st
inner join dimJobCategory dim
on dim.CategoryName = st.category

--company name
update st
set st.company_name = dim.CompanyID
from stageJobs st
inner join dimCompany dim
on dim.CompanyName = st.company_name

--job board
update st
set st.job_board = dim.JobBoardID
from stageJobs st
inner join dimBoard dim
on dim.BoardName = st.job_board

--job_type
update st
set st.job_type = dim.jobTypeID
from stageJobs st
inner join dimJobType dim
on dim.JobType = st.job_type

--date
update st
set st.post_date = dim.DateID
from stageJobs st
inner join dimDate dim
on dim.Date = st.post_date

--hour
update st
set st.post_hour = dim.HourID
from stageJobs st
inner join dimHour dim
on dim.Hour = st.post_hour

update st
set st.post_hour = 1
from stageJobs st
where st.post_hour IS NULL

--location
update st
set st.city = dim.LocationID
from stageJobs st
inner join dimLocation dim
on dim.City = st.City
where (dim.State = st.state) and (dim.Country = st.geo)

--salary
update st
set st.salary_information = dim.SalaryID
from stageJobs st
inner join dimJobSalary dim
on dim.SalaryType = st.salary_information


/*--insert data fact table--*/
PRINT '';
PRINT '*** Inserting data in fact table';
GO

insert into factJobPost(
	JobPostDateID,
	JobCategoryID,
	CompanyID,
	JobLocationID,
	JobTypeID,
	JobBoardID,
	SalaryID,
	HourID
)
select 
post_date, 
category, 
company_name, 
city, 
job_type, 
job_board, 
salary_information, 
post_hour 
from stageJobs where row_number not in (select row_number from error_stage_location)