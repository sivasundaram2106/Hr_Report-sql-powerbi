create database hr
use hr
select  termdate from hr_data
order by termdate desc
--remove time 
update hr_data
set termdate = FORMAT(convert(datetime,left(termdate,19),120),'yyyy-mm-dd')
select * from hr_data
--change datatype
alter table hr_data
add new_termdate date
update hr_data
set new_termdate =
case
when termdate is not null and isdate(termdate)=1
then cast(termdate as  datetime)
else null
end
select termdate,new_termdate from hr_data
--new age column 
alter table hr_data
add  age nvarchar(50)

update hr_data
set age = datediff(year,birthdate,getdate());

--age distribution

select 
min(age) as youngest,
max(age) as oldest
from hr_data

--age group by gender

select age_group,gender,
count(*) as count from
(select
case
when age <=21 and age <= 30 
then '21 to 30'
when age <=31 and age <= 40 
then '31 to 40'
when age <=41 and age <= 50 
then '51 to 50'
else '50+'
end age_group,gender
from hr_data
where new_termdate is null
)as subquery
group by age_group,gender
order by age_group,gender

--company gender

select top 5 * from hr_data
select gender,
count(gender) as count
from hr_data
where new_termdate  is null
group by gender
order by gender asc

-- gender vary across dept & job 

select department,jobtitle,gender,
count(gender) as count
from hr_data
where new_termdate  is null
group by gender,department,jobtitle
order by gender asc,department,jobtitle

--- race distribution in company

select race ,count(*) as count
from hr_data
where new_termdate is null
group by race
order by count desc
select top 5 * from hr_data

--avg lenght of employement in company

select avg(datediff(year,hire_date,new_termdate))as tenure
from hr_data
where new_termdate is not null and new_termdate <= getdate()

--high turnover rate 
--get total amount
--get terminated count 
--terminated count / total count 
select department,
total_count,
terminated_count,
round((
cast(
terminated_count as float)
/total_count),2)*100

as turn_over from
(
select department , count (*) as total_count,
sum( case 
when new_termdate is not null and new_termdate <= getdate()
then 1 
else 0
end
) as terminated_count
from hr_data
group by department
)
as subquery
order by turn_over desc

---tenure distribution for each department

select department,
avg(datediff(year,hire_date,new_termdate))as tenure
from hr_data
where new_termdate is not null and new_termdate <= getdate()
group by department
order by tenure desc

--- how many employee work remotely each dept

select top 5 * from hr_data

select location,count(*) as count
from hr_data
where new_termdate is null
group by location 

--distribution of employee across diff states

select location_state,
count(*) as count
from hr_data
where new_termdate is  null 
group by location_state
order by count desc

---how many jobtile in the company

select jobtitle,
count(*) as count
from hr_data
where new_termdate is  null 
group by jobtitle
order by count desc

---emoployee hire counts 
--calculate hires
--caculate termination
--hire-ter/higher per

select hire_year,
hires,
terminations,
hires-terminations as net_changes,
round((
cast(
hires-terminations as float)
/hires),2)*100

as percent_hire_change from
(
select year(hire_date) as hire_year,
count (*) as hires,
sum( case 
when new_termdate is not null and new_termdate <= getdate()
then 1 
else 0
end
) as terminations
from hr_data
group by year(hire_date)
)
as subquery
order by percent_hire_change asc
