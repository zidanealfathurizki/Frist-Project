SELECT *
FROM master..CovidDeaths
Where continent is not null
order by 3,4 


--SELECT *
--FROM master..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

SELECT location, date, total_cases, total_deaths, population
FROM master..CovidDeaths
order by 1,2 

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select location,date, total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpecentage
from master..CovidDeaths
Where Location like '%states%'
order by 1,2

Select location,date, total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpecentage
from master..CovidDeaths
Where Location like '%indonesia%'
order by 1,2

-- Looking at the total cases vs population
-- Shows what percentage of population got covid
Select location,date,population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
from master..CovidDeaths
--Where Location like  '%states%'
order by 1,2 

-- Looking at countries with hingest infection rate compared to population

Select location,population,Max(total_cases) as Hingesinfectioncount,max(total_cases/population)*100 as PercentPopulationInfected
from master..CovidDeaths
--Where Location like  '%states%'
Group by location, population
order by PercentPopulationInfected desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from master..CovidDeaths
--Where Location like  '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- SHOWING CONTINTENTS WITH THE HIGHEST DEATH COUNT PER POPULATION



-- GLOBAL NUMBERS

Select date, sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpecentage
from master..CovidDeaths
--Where Location like '%states%'
Where continent is not null
Group by date
order by 1,2


Select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpecentage
from master..CovidDeaths
--Where Location like '%states%'
Where continent is not null
--Group by date
order by 1,2


-- looking at total population vs vaccinations

SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from master..CovidVaccinations vac
join master..CovidDeaths dea
     on dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
order by 2,3


-- Use CTE

With PopvsVac(Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from master..CovidVaccinations vac
join master..CovidDeaths dea
     on dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac






-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from master..CovidVaccinations vac
join master..CovidDeaths dea
     on dea.location = vac.location
	 and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 
from #PercentPopulationVaccinated



--Creating view to store data for later visualizations
Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from master..CovidVaccinations vac
join master..CovidDeaths dea
     on dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated

