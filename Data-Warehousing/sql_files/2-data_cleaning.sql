/*============================================================================
Developed by: Aline de Souza Andrade
Student number: 23247513

Project 1 - CITS5504

Sql data cleaning and normalization
============================================================================*/
/*--select data base--*/
Use ProjectDW2
Go

PRINT '';
PRINT '*** Starting cleaning data in stage table';
GO

/*--change categoriess--*/
update x
set x.category = 
  case x.category 
    when 'accountancy jobs' then 'Accounting'
	when 'accountancy qualified jobs' then 'Accounting'
	when 'admin secretarial pa jobs' then 'Administration & Office Support'
	when 'apprenticeships jobs' then 'Education & Training'
	when 'banking jobs' then 'Banking & Financial Services'
	when 'catering jobs' then 'Trades & Services'
	when 'construction property jobs' then 'Construction'
	when 'customer service jobs' then 'Call Centre & Customer Service'
	when 'education jobs' then 'Education & Training'
	when 'energy jobs' then 'Mining, Resources & Energy'
	when 'estate agent jobs' then 'Real Estate & Property'
	when 'factory jobs' then 'Manufacturing, Transport & Logistics'
	when 'finance jobs' then 'Banking & Financial Services'
	when 'fmcg jobs' then 'Sales'
	when 'general insurance jobs' then 'Insurance & Superannuation'
	when 'graduate training internships jobs' then 'Education & Training'
	when 'health jobs' then 'Healthcare & Medical'
	when 'hr jobs' then 'Human Resources & Recruitment'
	when 'it jobs' then 'Information & Communication Technology'
	when 'law jobs' then 'Legal'
	when 'leisure tourism jobs' then 'Hospitality & Tourism'
	when 'logistics jobs' then 'Manufacturing, Transport & Logistics'
	when 'marketing jobs' then 'Marketing & Communications'
	when 'media digital creative jobs' then 'Advertising, Arts & Media'
	when 'recruitment consultancy jobs' then 'Consulting & Strategy'
	when 'retail jobs' then 'Retail & Consumer Products'
	when 'science jobs' then 'Science & Technology'
	when 'social care jobs' then 'Community Services & Development'
	when 'strategy consultancy jobs' then 'Consulting & Strategy'
	when 'training jobs' then 'Education & Training'
	else x.category
end 
from stageJobs x

Update stageJobs
SET category = replace(category,' jobs','') 

UPDATE stageJobs
SET category=UPPER(LEFT(category,1))+LOWER(SUBSTRING(category,2,LEN(category)))


/*--change job type--*/
Update stageJobs
SET job_type_hours = lower(replace(replace(job_type,' ','-'),'/', ', ')) from stageJobs where geo='AU'

Update stageJobs
SET job_type_hours = replace(replace(replace(replace(job_type, 'Permanent, ',''),'Contract, ',''),'Temporary, ',''),' or ',', ') from stageJobs where geo='uk'

update x
set x.job_type = 
  case x.job_type 
    when 'Permanent, full-time or part-time' then 'Permanent'
	when 'Contract, full-time or part-time' then 'Contract'
	when 'Temporary, full-time or part-time' then 'Temporary'
	when 'Permanent, full-time' then 'Permanent'
	when 'Permanent, part-time' then 'Permanent'
	when 'Contract, full-time' then 'Contract'
	when 'Contract, part-time' then 'Contract'
	when 'Temporary, full-time' then 'Temporary'
	when 'Temporary, part-time' then 'Temporary'
	else x.category
end 
from stageJobs x where geo='uk' 

update x
set x.job_type = 
  case x.job_type 
    when 'Full Time' then 'Permanent'
	when 'Part Time' then 'Permanent'
	when 'Contract/Temp' then 'Contract'
	when 'Casual/Vacation' then 'Temporary'

	else x.category
end 
from stageJobs x where geo='AU'


/*--change geo--*/
Update stageJobs
SET geo = UPPER(geo)

/*--change date and hour--*/
Update stageJobs
SET post_hour = convert(time(0), post_date_hour) from stageJobs where geo='au'

Update stageJobs
SET post_date = convert(date, post_date_hour) from stageJobs

/*--salary--*/
UPDATE stageJobs
set salary_information = 
case 
	when salary_offered LIKE '%[0-9]%' then 'Salary provided'
	when salary_offered IS NULL then 'Information not provided'
	else 'Some information provided'
end
from stageJobs

/*--Check missing location values--*/
PRINT '';
PRINT '*** Inserting error rows in error table';
GO
UPDATE stageJobs
SET city = trim(city);

INSERT INTO error_stage_location(row_number,city_error) 
select row_number,'missing or invalid city' from stageJobs where (city LIKE '%[0-9]%') order by city

UPDATE stageJobs
SET state = trim(state);

INSERT INTO error_stage_location (row_number,state_error) 
SELECT row_number, 'missing or invalid state'
FROM stageJobs
WHERE state IS NULL OR
state = ' '

