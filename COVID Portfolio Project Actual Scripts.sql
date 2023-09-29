SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2

-- Looking at Total Cases vs Total Deads
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%states%'
ORDER BY 1, 2


-- looking at Total Cases vs Total Population
-- shows what Percentage got Covid
SELECT Location, date, Population, total_cases, (total_cases/population)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%states%'
ORDER BY 1, 2


-- Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
WHERE continent in not NULL
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population
SELECT Location, MAX(CAST(total_deaths as INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENTS
-- Showing the continents with highest DeathCount per population
SELECT Location , MAX(CAST(total_deaths as INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
WHERE continent IS NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- Global Numbers
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS INT)) as total_deaths, SUM(CAST(new_deaths AS INT))/SUM(New_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
WHERE continent IS NOT NULL
--GROUP BY Date
ORDER BY 1, 2


-- joining both tables on Location and Date
SELECT *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.Location = vac.Location
	AND dea.date = vac.date

-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(new_vaccinations AS INT)) OVER (PARTITION BY dea.Location Order BY dea.Location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.Location = vac.Location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
order by 2,3

--USE CTE
DROP TABLE IF EXIST 
With PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(new_vaccinations AS INT)) OVER (PARTITION BY dea.Location Order BY dea.Location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.Location = vac.Location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL)
--order by 2,3)

Select *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(new_vaccinations AS INT)) OVER (PARTITION BY dea.Location Order BY dea.Location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.Location = vac.Location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--order by 2,3)

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create view PercentPopulationVaccinateddd AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(new_vaccinations AS INT)) OVER (PARTITION BY dea.Location Order BY dea.Location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.Location = vac.Location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--order by 2,3)

SELECT *
FROM PercentPopulationVaccinateddd