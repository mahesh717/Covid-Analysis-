select * from covidDeaths;
select * from covidvaccinations;


-- Covid Deaths Table

select location,date,total_cases,new_cases,total_deaths,population 
from CovidDeaths 
order by 1,2;



-- Looking at Total Cases vs Total Deaths in India ?

select location,date,total_cases,total_deaths,(total_deaths / total_cases)*100 as Deaths_percent
from CovidDeaths 
where location like '%India%'
and continent is not null
order by 1,2 desc;



-- Looking at Total Cases vs Population & what percentage of population got affected?

select location,date,population,total_cases, (total_cases / population)*100 as Percent_of_Population_Affected
from CovidDeaths 
where location like '%India%'
order by 1,2 desc;



-- Looking at countries with Highest Infection Rate Compared to Population ?

select location,population, Max(total_cases) as Highest_Infection_Rate, Max((total_cases / population))*100 as Percent_of_Population_Affected
from CovidDeaths 
group by location,population
--where location like '%states%'
order by Percent_of_Population_Affected desc;



-- Looking at countries with Highest Death Count Per Population ?

select location, MAX(total_deaths) as Total_Deaths_Count
from CovidDeaths
group by location
order by Total_Deaths_Count desc;

-- Note :- After running the above query we get the ans in same no. (ie: starting with 9) bcoz,
-- the column total_deaths data-type is not integer!!!
-- now we have to change it using cast function.

select top 10 location, MAX(cast(total_deaths as int)) as Total_Deaths_Count
from CovidDeaths
where continent is not null
group by location
order by Total_Deaths_Count desc;



-- Looking at the continents with Highest Deaths_Count ?

select Continent, MAX(cast(total_deaths as int)) as Total_Deaths_Count
from CovidDeaths
where continent is not null
group by Continent
order by Total_Deaths_Count desc;



-- Global no. of Covid Cases
select SUM(new_cases) as total_cases,SUM(CAST(new_deaths as int)) as total_deaths,
SUM(CAST(new_deaths as int)) 
/
SUM(new_cases)*100 as Death_Percent 
from CovidDeaths
where continent is not null
order by 1,2;





-- Using Joins & Window Functions & CTE .....



-- Looking at Total Population vs Total Vaccinations taken by the Peoples ?
-- Rolling up

select cd.continent,cd.location,cd.date,cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations as int)) 
over(partition by cd.location order by cd.location,cd.date) as Rolling_People_Vaccinated

--,(Rolling_People_Vaccinated/population) *100  
--[we want to know how many people in that country are vaccinated]
-- as we can't do bcoz use the same column as we have created above....

from 
CovidDeaths as cd 
inner join 
CovidVaccinations as cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
order by 2,3;


-- Using CTE ....

with cte (continent,location,date,population,new_vaccinations,Rolling_People_Vaccinated)
as
(
select cd.continent,cd.location,cd.date,cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations as int)) 
over(partition by cd.location order by cd.location,cd.date) as Rolling_People_Vaccinated
from 
CovidDeaths as cd 
inner join 
CovidVaccinations as cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
-- order by 2,3;
)
select *,(Rolling_People_Vaccinated / population)*100 from cte;




-- Using Temp Table

create table PopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
Rolling_People_Vaccinated numeric
)

insert into PopulationVaccinated
select cd.continent,cd.location,cd.date,cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations as int)) 
over(partition by cd.location order by cd.location,cd.date) as Rolling_People_Vaccinated
from 
CovidDeaths as cd 
inner join 
CovidVaccinations as cv
on cd.location = cv.location
and cd.date = cv.date
-- where cd.continent is not null
-- order by 2,3;

select *,(Rolling_People_Vaccinated / population)*100 from PopulationVaccinated;



-- Using View for same Query (for further visualizations)

Create view Rolling_People_Vaccinated as (
select cd.continent,cd.location,cd.date,cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations as int)) 
over(partition by cd.location order by cd.location,cd.date) as Rolling_People_Vaccinated
from 
CovidDeaths as cd 
inner join 
CovidVaccinations as cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
-- order by 2,3;
)

select * from Rolling_People_Vaccinated ;