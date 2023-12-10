Select *
from PortfolioProject..CovidDeaths
Order by 3,4

--Select *
--from PortfolioProject..CovidVaccinations
--Order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
Order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 AS DeathPrecentage
from PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
Select Location, date, Population, total_cases,  (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 AS PrecentPopulationInfected
from PortfolioProject..CovidDeaths
--Where location like '%states%'
Order by 1,2

-- Looking at Countries with Highest Infection Rate compared to population

Select Location, Population, Max(total_cases),  Max((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)))*100 AS PrecentPopulationInfected
from PortfolioProject..CovidDeaths
--Where location like '%states%'
--where location like '%armenia%'
Group by Location, Population
Order by PrecentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

Select Location, Max(cast(total_deaths as int)) AS TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population


Select Location, Max(cast(total_deaths as int)) AS TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null
Group by location
Order by TotalDeathCount desc

Select continent, Max(cast(total_deaths as int)) AS TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_death, SUM(cast(new_deaths as int))/NULLIF(SUM(New_Cases),0)*100 AS DeathPrecentage
from PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
--Group By date
Order by 1,2


-- Looking at Total Population vs Vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.date) AS RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)

as
(
Select dea.continent, dea.location, dea.date, dea.Population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.date) AS RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- TEMP TABLE
DROP Table if exists #PercentPopulationsVaccinated
Create Table #PercentPopulationsVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationsVaccinated
Select dea.continent, dea.location, dea.date, dea.Population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.date) AS RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationsVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationsVaccinated as
Select dea.continent, dea.location, dea.date, dea.Population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.date) AS RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationsVaccinated