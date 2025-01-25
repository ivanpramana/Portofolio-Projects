SELECT *
FROM coviddeaths;

SELECT *
FROM covid
;
SELECT location, date, total_cases,new_cases, total_deaths, population
FROM coviddeaths
;
# Total Cases vs Total Deaths (Death Percentage) 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM coviddeaths
WHERE location = "Indonesia";

# Total Cases vs Population
# Shows what percentage of population infected with Covid
Select location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
from coviddeaths
where location = "Indonesia";

#Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
FROM coviddeaths
GROUP BY location, population
ORDER BY 4 DESC;

# Countries with Highest Death Count per Population
SELECT location, continent, MAX(total_deaths) as TotalDeathCount
FROM coviddeaths
## WHERE continent IS NOT NULL and continent = "Asia"
WHERE continent IS NOT NULL
GROUP BY location, continent
ORDER BY TotalDeathCount DESC;

# Showing contintents with the highest death count per population
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


SET SQL_SAFE_UPDATES = 0;
UPDATE coviddeaths
SET date = STR_TO_DATE(date, '%d/%m/%Y')
WHERE date LIKE '%/%/%';

SET SQL_SAFE_UPDATES = 0;
UPDATE covidvaccinations
SET date = STR_TO_DATE(date, '%d/%m/%Y')
WHERE date LIKE '%/%/%';

ALTER TABLE coviddeaths
MODIFY COLUMN date date;

ALTER TABLE covidvaccinations
MODIFY COLUMN date date;

# GLOBAL NUMBERS
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM coviddeaths
WHERE continent is not null 
GROUP BY date
ORDER BY 1,2;

# Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
SELECT de.continent, de.location, de.date, de.population, va.new_vaccinations,
SUM(va.new_vaccinations) over (partition by de.location order by de.location
, de.date) as rollingpeople_vaccinated
FROM coviddeaths de
JOIN covidvaccinations va
	ON de.location = va.location
    AND de.date = va.date
WHERE de.continent IS NOT NULL;

-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT de.continent, de.location, de.date, de.population, va.new_vaccinations,
SUM(va.new_vaccinations) over (partition by de.location order by de.location
, de.date) as rollingpeople_vaccinated
FROM coviddeaths de
JOIN covidvaccinations va
	ON de.location = va.location
    AND de.date = va.date
WHERE de.continent IS NOT NULL
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;

-- Using Temp Table to perform Calculation on Partition By in previous query
DROP Table if exists PercentPopulationVaccinated;
Create Table PercentPopulationVaccinated
(
Continent TEXT,
Location TEXT,
Date datetime,
Population BIGINT,
New_vaccinations BIGINT,
RollingPeopleVaccinated BIGINT
);

Insert into PercentPopulationVaccinated
SELECT de.continent, de.location, de.date, de.population, va.new_vaccinations,
SUM(va.new_vaccinations) over (partition by de.location order by de.location
, de.date) as rollingpeople_vaccinated
FROM coviddeaths de
JOIN covidvaccinations va
	ON de.location = va.location
    AND de.date = va.date;

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated;

-- Creating View to store data for later visualizations
DROP Table if exists PercentPopulationVaccinated;
Create View PercentPopulationVaccinated as
SELECT de.continent, de.location, de.date, de.population, va.new_vaccinations,
SUM(va.new_vaccinations) over (partition by de.location order by de.location
, de.date) as rollingpeople_vaccinated
FROM coviddeaths de
JOIN covidvaccinations va
	ON de.location = va.location
    AND de.date = va.date
WHERE de.continent IS NOT NULL;

SELECT *
FROM percentpopulationvaccinated
