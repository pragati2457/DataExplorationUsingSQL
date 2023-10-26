select * from PortfolioProject..CovidDeaths
WHERE continent is not null
order by 3,4

--select * from PortfolioProject..CovidVaccinations
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- LOOKING AT Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2


-- Looking at Total Cases vs Population
-- shows what percentage of population got covid

Select location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%India%'
and continent is not null
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as
PercentagePopulationInfected
From PortfolioProject..CovidDeaths
WHERE continent is not null
Group by location, Population
order by PercentagePopulationInfected desc

-- Showing countries with highest death count per population

SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE continent is not null
Group by location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- showing continents with highest death count per population

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

SELECT date, SUM (new_cases) as total_cases, SUM(cast(new_deaths as int)) as totalDeaths, SUM(cast(new_deaths as int))/
SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
WHERE continent is not null
Group by date
order by 1,2

-- Looking at Total Population vs Vaccinations

   SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
   SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition by dea.location Order by dea.location,
   dea.Date) as RollingPeopleVaccinated
   FROM PortfolioProject..CovidDeaths dea
   JOIN PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3


-- USE CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations,  RollingPeopleVaccinated)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
   SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition by dea.location Order by dea.location,
   dea.Date) as RollingPeopleVaccinated
   FROM PortfolioProject..CovidDeaths dea
   JOIN PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
SELECT * , (RollingPeopleVaccinated/Population) * 100
From PopvsVac


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated 
CREATE Table #PercentPopulationVaccinated 
(
Continent nvarchar (255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
   SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition by dea.location Order by dea.location,
   dea.Date) as RollingPeopleVaccinated
   FROM PortfolioProject..CovidDeaths dea
   JOIN PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null

SELECT * , (RollingPeopleVaccinated/Population) * 100
From #PercentPopulationVaccinated 

-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
   SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition by dea.location Order by dea.location,
   dea.Date) as RollingPeopleVaccinated
   FROM PortfolioProject..CovidDeaths dea
   JOIN PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 WHERE dea.continent is not null

	 SELECT *
	 From PercentPopulationVaccinated
	 
