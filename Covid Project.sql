Select *
From PortfolioProject..CovidDeaths
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, Population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at total cases vs Total Deaths

SELECT location, date, total_cases, total_deaths,
(CONVERT (float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to Population

SELECT continent, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY continent, population
ORDER BY PercentPopulationInfected desc

--Looking at Countries with Highest Death Count per Population

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


SELECT continent, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is null
GROUP BY continent
ORDER BY TotalDeathCount desc

--Global numbers

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--GROUP BY date
ORDER BY 1,2


--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, NULLIF(CONVERT(float, vac.new_vaccinations),0) AS new_vaccinations,
SUM(NULLIF(CONVERT(float, vac.new_vaccinations),0)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3


--USE CTE
With PopvsVac(Continent,Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as 
(SELECT dea.continent, dea.location, dea.date, dea.population, NULLIF(CONVERT(float, vac.new_vaccinations),0) AS new_vaccinations,
SUM(NULLIF(CONVERT(float, vac.new_vaccinations),0)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
SELECT*, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)
INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, NULLIF(CONVERT(float, vac.new_vaccinations),0) AS new_vaccinations,
SUM(NULLIF(CONVERT(float, vac.new_vaccinations),0)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

SELECT*, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Creating view to store data for later Visualizations	

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, NULLIF(CONVERT(float, vac.new_vaccinations),0) AS new_vaccinations,
SUM(NULLIF(CONVERT(float, vac.new_vaccinations),0)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3


SELECT *
FROM PercentPopulationVaccinated