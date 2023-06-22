SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

ALTER TABLE CovidDeaths
ALTER COLUMN total_cases numeric

ALTER TABLE CovidVaccinations
ALTER COLUMN new_vaccinations numeric


-- Total Case vs Total Deaths
-- Shows likelihood of dying if infected with COVID
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 AS death_rate
FROM PortfolioProject..CovidDeaths
WHERE continent is not null AND location like '%states' --looks specifically at the US
ORDER BY 1,2

-- Total Cases vs Population
-- Shows likelihood of being infected with COVID
SELECT location, date, total_cases, population, (total_cases/population) *100 AS infection_rate
FROM PortfolioProject..CovidDeaths
WHERE continent is not null AND location like '%states' --looks specifically at the US
ORDER BY 1,2

-- Countries with Highest Infecton Rate relative to Population
SELECT location, population, MAX(total_cases) as highest_infection_count
, MAX(total_cases/population) *100 AS infection_rate
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY infection_rate desc

-- Countries with the Highest Death Count relative to Population
SELECT location, MAX(total_deaths) as death_count
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location 
ORDER BY death_count desc

-- GLOBAL

-- Numbers by Date
SELECT date, SUM(new_cases) as total_cases, SUM(total_deaths) as total_deaths
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Total Cases and Deaths relative to Death Rate
SELECT date, SUM(new_cases) as total_cases, SUM(total_deaths) as total_deaths
, SUM(new_deaths)/SUM(new_cases) * 100 as death_rate
FROM PortfolioProject..CovidDeaths
WHERE continent is not null and new_cases > 0
GROUP BY date
ORDER BY 1,2


-- VACCINATIONS

-- Population compared to New Vaccinations each day with count of Total Vaccinations
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) total_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3


-- Common Table Expression
-- Vaccination Rate (does not take into account individuals that receive multiple rounds of vaccination)
WITH PopulationvsVaccination (continent, location, date, population, new_vaccinations, total_vaccinations) 
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) total_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (total_vaccinations/population) * 100 as vaccination_rate
FROM PopulationvsVaccination

