select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

select *
from PortfolioProject..CovidDeaths
where location = 'United States'
order by 3,4

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%states%' 
order by 1,2

--Looking at total cases vs populations
-- Shows what percentage of population get Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
FROM PortfolioProject..CovidDeaths
Where location like '%states%' 
order by 1,2


--Looking at Countries with highest infection rate compared to population

SELECT continent, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by continent, population
ORDER BY PercentPopulationInfected DESC


--Countries with the highest death count per Population

SELECT continent, MAX(cast(total_deaths as INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
WHERE continent is not null
Group by continent
ORDER BY TotalDeathCount DESC


-- Lets break things up by continent

SELECT continent, MAX(cast(total_deaths as INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
WHERE continent is not null
Group by continent
ORDER BY TotalDeathCount DESC


-- Showing the continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
WHERE continent is not null
Group by continent
ORDER BY TotalDeathCount DESC





-- Global numbers





SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
FROM PortfolioProject..CovidDeaths
--Where continent like '%states%'
where continent is not null
Group by date
order by 1,2

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
FROM PortfolioProject..CovidDeaths
--Where continent like '%states%'
where continent is not null
--Group by date
order by 1,2



-- LOOKING AT TOTAL POPULATION VS VACCINATIONS

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- Use CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



--TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
 CREATE TABLE #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

 INSERT INTO #PercentPopulationVaccinated
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Create view to store data later for visualization

CREATE VIEW PercentPopulationVaccinated as
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


CREATE VIEW TotalCasesvsTotalDeaths as
SELECT continent, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where continent like '%states%' 
--order by 1,2



CREATE VIEW CasePercentage as
SELECT location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
FROM PortfolioProject..CovidDeaths
Where location like '%states%' 
--order by 1,2

CREATE VIEW PercentPopulationInfected as
SELECT continent, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by continent, population
--ORDER BY PercentPopulationInfected DESC

CREATE VIEW TotalDeathCount AS
SELECT continent, MAX(cast(total_deaths as INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
WHERE continent is not null
Group by continent
--ORDER BY TotalDeathCount DESC

select *
from CasePercentage
