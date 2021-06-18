-- Look at the data
select location, date, total_cases, new_cases, total_deaths, population
from deaths
order by 1,2;

-- what percentage died that got covid
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageOfDeath
from deaths
where location like '%urke%'
order by 1, 2;

-- what percentage of the population had covid
select location, date, total_cases, population, (total_cases/population)*100 as GotCovid
from deaths
where location like '%urke%'
order by 1, 2;

-- countries with the highest infection rate vs population
select location, population, MAX(total_cases) as highestInfection, MAX((total_cases/population))*100 as PercentagePopulationInfected
from deaths
where (total_cases, population) is not NULL
GROUP BY location, population
order by PercentagePopulationInfected desc;

-- showing continents with the highest death count
select location, MAX(total_deaths) as TotalDeathCount
from deaths
where continent is NULL
GROUP BY location
order by TotalDeathCount desc;

-- Global death percentage of total cases
select SUM(new_cases) as totalCases, sum(new_deaths) as totalDeaths , SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
from deaths
where continent is not null
order by 1, 2;

-- Total population vs Vaccines
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location Order by dea.location, dea.date) as Vaccinated
from deaths dea
join vaccines vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- TEMP TABLE
DROP table if exists PercentageVaccinated
CREATE TABLE PercentageVaccinated
(
continent varchar(255),
location varchar(255),
date date,
population numeric,
new_vaccinations numeric,
Vaccinated numeric)
Insert into PercentageVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location Order by dea.location, dea.date) as Vaccinated
from deaths dea
join vaccines vac
    on dea.location = vac.location
    and dea.date = vac.date

select * , (Vaccinated/population)*100
from PercentageVaccinated


-- Creating View to store data
Create VIEW DeathContinent as
select location, MAX(total_deaths) as TotalDeathCount
from deaths
where continent is NULL
GROUP BY location
order by TotalDeathCount desc;

select *
from DeathContinent


Create VIEW PercentagePopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location Order by dea.location, dea.date) as Vaccinated
from deaths dea
join vaccines vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null

select *
from PercentagePopulationVaccinated