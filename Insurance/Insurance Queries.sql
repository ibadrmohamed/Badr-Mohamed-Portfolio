-- First Step : Exploraing Data so we can make relations and getting better knowledge of Data --
select * 
from insurance;

-- Summary of statistics --
Select 
count(*) as Total_records ,
avg(age) as Avg_age, 
min(age) as Youngest_Client,
Max(age) as Oldest_Client,
avg(bmi) as avg_bmi,
Min(bmi) as min_bmi,
Max(bmi) as max_bmi,
avg(children) as Avg_children_count,
sum(children) as Total_children_count,
avg(charges) as avg_charges,
min(charges) as min_charges,
Max(charges) as max_charges
From insurance;

-- Categorizing Distribution and percentage of total records --
Select
sex,count(*) as Total_records , 
AVG(charges) as avg_charger,
ROUND(count(*) *100.0 / (select count(*) from insurance),2) as ratio 
From insurance
group by sex
order by Total_records desc;

-- Categorizing Distribution by smoker status --
Select
smoker,count(*) as Total_records , 
AVG(charges) as avg_charges, 
Min(charges) as min_charges, 
max(charges) as max_charges,
ROUND(count(*) *100.0 / (select count(*) from insurance),2) as percentage 
From insurance
group by smoker
order by avg_charges desc;

-- Distribution by region --
select region , count(*) as Total_records ,
ROUND(count(*) *100.0 / (select count(*) from insurance),2) as percentage ,
AVG(charges) as avg_charges,
AVG(bmi) as avg_bmi
from insurance
group by region
order by avg_charges desc;

-- Smokers impact of charges --
Select
smoker, count(*) as Total_records,
avg(charges) as avg_charges,
max(charges) as max_charges,
min(charges) as min_charges
from insurance
group by smoker;

-- Smokers related to other factors --
Select 
smoker, sex , count(*) as Total_records,
avg(charges) as avg_charges,
avg(bmi) as avg_bmi,
avg(age) as avg_age
from insurance
group by smoker , sex
order by smoker , avg_charges desc;

-- Comapring Smokers vs Non-Smokers --
select region,smoker,
count(*) as Total_records,
avg(charges) as avg_charges,
Round(avg(charges) / avg(case when smoker= 'no' then charges end) over(Partition by region) *100, 2) as avg_percentage_of_non_smokers
from insurance
group by region , smoker , charges
order by region , smoker;

-- Grouping records by Age --
select
    case
	 when age < 20 then 'Under 20'
	 when age between 20 and 29 then '20-29'
	 when age between 30 and 39 then '30-39'
	 when age between 40 and 49 then '40-49'
	 when age between 50 and 59 then '50-59'
	 else '60+'
	End as Age_group,
	count(*) as Total_records,
	avg(charges) as avg_charges,
	avg(bmi) as avg_bmi,
	sum(case when smoker = 'yes' then 1 else 0 end ) as smokers_count,
	round(avg(case when smoker = 'yes' then charges else Null end),2) as avg_smoker_charges,
	round(avg(case when smoker = 'no' then charges else Null end),2) as avg_non_smoker_charges
From insurance
group by 
case
	 when age < 20 then 'Under 20'
	 when age between 20 and 29 then '20-29'
	 when age between 30 and 39 then '30-39'
	 when age between 40 and 49 then '40-49'
	 when age between 50 and 59 then '50-59'
	 else '60+'
	End 
order by Min(age);

-- BMI Category Analysis --
select 
    case 
        when bmi < 18.5 then 'Underweight'
        when bmi between 18.5 AND 24.9 then 'Normal'
        when bmi BETWEEN 25 AND 29.9 then 'Overweight'
        Else 'Obese'
    End as bmi_category,
    count(*) as customers,
    avg(charges) as avg_charges,
    avg(age) as avg_age,
    sum(case when smoker = 'yes' then 1 Else 0 end) as smokers
from insurance
group by 
    case 
        when bmi < 18.5 then 'Underweight'
        when bmi BETWEEN 18.5 AND 24.9 then 'Normal'
        when bmi BETWEEN 25 AND 29.9 then 'Overweight'
        Else 'Obese'
    End
order by avg_charges desc;

-- Average charges by region --
select 
    region,
    count(*) as customers,
    avg(charges) as avg_charges,
    avg(bmi) as avg_bmi,
    sum(case when smoker = 'yes' then 1 else 0 END) as smokers
from insurance
group by region
order by avg_charges desc;

-- Smokers impact by region --
select 
    region,
    smoker,
    count(*) as Total_records,
    avg(charges) as avg_charges
from insurance
group by region, smoker
order by region, smoker;

-- Children Analysis --
select 
    children,
    count(*) as families,
    avg(charges) as avg_charges,
    avg(age) as avg_age,
    avg(case when smoker = 'yes' then 1 else 0 end) as smoking_parents
from insurance
group by children
order by children;

-- Smokers who are obese --
select 
    count(*) as high_risk_count,
    avg(charges) as avg_charges,
    avg(age) as avg_age,
    avg(bmi) as avg_bmi
from insurance
where smoker = 'yes' and bmi >= 30;

-- Top 10 most expensive customers --
Select top 10
    age,
    sex,
    bmi,
    children,
    smoker,
    region,
    charges
from insurance
order by charges desc;

-- Top 10 cheapest customers --
select top 10
    age,
    sex,
    bmi,
    children,
    smoker,
    region,
    charges
from insurance
order by charges ;

--  Gender Analysis -- 
select 
    sex,
    count(*) as Total_records,
    avg(charges) as avg_charges,
    avg(bmi) as avg_bmi,
    avg(age) as avg_age,
    sum(case when smoker = 'yes' then 1 else 0 end) as smokers
from insurance
group by sex;

-- Gender & smokers combination --
select 
    sex,
    smoker,
    count(*) as Total_records,
    avg(charges) as avg_charges
from insurance
group by sex, smoker
order by sex, avg_charges desc;

-- Risk levels -- 
select 
    risk_level,
    count(*) as Total_records,
    avg(charges) as avg_charges
from (
    select *,
        case 
            when smoker = 'yes' and bmi >= 30 then 'High Risk'
            when smoker = 'yes' then 'Medium Risk'
            when bmi >= 30 then 'Medium Risk'
            else 'Low Risk'
        End as risk_level
    from insurance
) risky
group by risk_level
order by avg_charges desc;

-- Age & smokers combination --
select 
    case 
        when age < 30 then 'Young'
        when age between 30 and 50 then 'Adult'
        else 'Senior'
    end as age_category,
    smoker,
    count(*) as Total_records,
    avg(charges) as avg_charges
from insurance
group by 
    case 
        when age < 30 then 'Young'
        when age between 30 and 50 then 'Adult'
        else 'Senior'
    end,
    smoker
order by age_category, smoker desc;
--------------------------------------------------------------------------- End ---------------------------------------------------------------------------
