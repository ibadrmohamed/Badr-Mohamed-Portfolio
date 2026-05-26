-- First Step : Exploraing Data so we can make relations and getting better knowledge of Data --
select *
from CovidDeaths
where continent is not null
order by 3,4

select *
from CovidVaccinations
order by 3,4

-- Select the Data We wil start on --

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

-- Comparing Total Cases With Total Death --

select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentages
from CovidDeaths
where total_cases > 0 and location like '%egypt%'
order by 1,2

-- Comparing Total Cases With Popultaion --

select location, date,population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
where total_cases > 0 and location like '%egypt%'
order by 1,2

-- Checking Which country has the highest Infection rate compared to Population --

select location,population, max(total_cases) as HighestInfection,max((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths
where total_cases > 0 and population > 0
group by location , population
order by 1,2

-- Checking which country has the highest Death Count by population --
select location,Max(total_deaths) as TotalDeathCount
from CovidDeaths
where location NOT IN ('World', 'Europe', 'North America', 'South America', 'Asia', 'Africa', 'European Union', 'Oceania', 'Antarctica')
group BY location
order BY TotalDeathCount desc;

-- Checking which Continent has the highest Death Count by population --
select continent,Max(total_deaths) as TotalDeathCount
from CovidDeaths
where continent IS NOT NULL 
   and continent != ''
   and continent != '0'
group by continent
order by TotalDeathCount desc;

-- Providing GLobal Numbers as total --
select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths) * 100.0 / NULLIF(SUM(new_cases), 0)) as DeathPercentage
from CovidDeaths
where continent IS NOT NULL
   and continent != ''
   and continent != '0';

   -- Connecting Covid Vaccinations with Covid Deaths --
   select *
   from CovidDeaths dea 
   join CovidVaccinations vac
   on dea.location = vac.location 
   and dea.date = vac.date;

   -- Checking Total population versus Vaccinations
   select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations , SUM(vac.new_vaccinations) over (partition by dea.location) as Cumulative_vaccinated_people
   from CovidDeaths dea 
   join CovidVaccinations vac
   on dea.location = vac.location 
   and dea.date = vac.date
  where dea.continent IS NOT NULL
   AND dea.continent != ''
   AND dea.continent != '0'
   order by 2,3;
   --------------------------------------------------
-- Show how many people got vaccinated each day in each country
select 
    dea.location,
    dea.date,
    dea.population,
    vac.people_vaccinated,
    vac.people_fully_vaccinated
from CovidDeaths dea 
join CovidVaccinations vac
    on dea.location = vac.location 
    AND dea.date = vac.date
where dea.continent IS NOT NULL
    AND dea.location = 'Egypt'
order by dea.date desc;
-- Simple query to find countries with highest % of population infected --
select top 10
    location,
    population,
    MAX(total_cases) as TotalCases,
    CASE 
        WHEN MAX(population) > 0 
        THEN ROUND(MAX((total_cases/population))*100, 2)
        ELSE 0 
    END as InfectionRate
from CovidDeaths
where continent IS NOT NULL
    AND total_cases IS NOT NULL
    AND population > 0  -- This line fixes the error!
group by location, population
order by InfectionRate desc;

-- See COVID trends by month in Egypt --
select 
    YEAR(date) as Year,
    MONTH(date) as Month,
    SUM(new_cases) as MonthlyCases,
    SUM(new_deaths) as MonthlyDeaths,
    ROUND(SUM(new_deaths)*100.0/NULLIF(SUM(new_cases),0), 2) as MonthlyDeathRate
from CovidDeaths
where location = 'Egypt'
    AND new_cases IS NOT NULL
group by YEAR(date), MONTH(date)
order by Year, Month;

-- Find Egypt's worst day(s) for new cases --
select top 5
    date,
    new_cases,
    new_deaths,
    total_cases,
    total_deaths
from CovidDeaths
where location = 'Egypt'
    AND new_cases IS NOT NULL
order by new_cases desc;

-- Compare Egypt with nearby countries --
select 
    location,
    MAX(total_cases) as TotalCases,
    MAX(total_deaths) as TotalDeaths,
    ROUND(MAX((total_deaths/population))*100000, 2) as DeathsPer100K
from CovidDeaths
where location IN ('Egypt', 'Sudan', 'Libya', 'Saudi Arabia', 'Jordan')
    AND continent IS NOT NULL
group by location
order by TotalCases desc;

-- Find countries that reported zero deaths (if any) --
select distinct
    location,
    MAX(total_deaths) as TotalDeaths,
    MAX(total_cases) as TotalCases
from CovidDeaths
where continent IS NOT NULL
group by location
having MAX(total_deaths) = 0 OR MAX(total_deaths) IS NULL
order by location;

-- Basic relationship between cases and deaths --
select 
    location,
    MAX(total_cases) as TotalCases,
    MAX(total_deaths) as TotalDeaths,
    ROUND(MAX(total_deaths)*100.0/MAX(total_cases), 2) as DeathPercentage
from CovidDeaths
where continent IS NOT NULL
    AND total_cases > 1000  -- Only countries with significant cases
group by location
order by DeathPercentage desc;

-- Find when Egypt reached vaccination milestones --
select 
    date,
    people_vaccinated,
    case 
        when people_vaccinated >= 1000000 then 'Reached 1 Million!'
        when people_vaccinated >= 500000 then 'Reached 500K'
        when people_vaccinated >= 100000 then 'Reached 100K'
        else 'Below 100K'
    end as Milestone
from CovidVaccinations
where location = 'Egypt'
    AND people_vaccinated IS NOT NULL
order by date;

-- Weekly summary of cases in Egypt --
select 
    DATEPART(WEEK, date) as WeekNumber,
    MIN(date) as WeekStart,
    MAX(date) as WeekEnd,
    SUM(new_cases) as WeeklyCases,
    SUM(new_deaths) as WeeklyDeaths
from CovidDeaths
where location = 'Egypt'
    AND new_cases IS NOT NULL
group by DATEPART(WEEK, date)
order by WeekNumber;

-- Compare first half of 2020 vs first half of 2021 in Egypt --
select 
    '2020 First Half' as Period,
    SUM(new_cases) as TotalCases,
    SUM(new_deaths) as TotalDeaths
from CovidDeaths
where location = 'Egypt'
    AND date BETWEEN '2020-01-01' AND '2020-06-30'

UNION ALL

select 
    '2021 First Half' as Period,
    SUM(new_cases) as TotalCases,
    SUM(new_deaths) as TotalDeaths
from CovidDeaths
where location = 'Egypt'
    AND date BETWEEN '2021-01-01' AND '2021-06-30';
	--------------------------------------------------------------------------- End ---------------------------------------------------------------------------
