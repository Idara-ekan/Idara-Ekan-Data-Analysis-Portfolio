-- Looking at the tables created
Select * 
from CovidDeaths

Select * 
from CovidVaccinations


--Select  Data that we are going to use

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
order by 1, 2

-- Finding the countries represented in the Dataset
Select Distinct location
from CovidDeaths
order by 1

-- Looking at the Total Cases vs Total Deaths in Nigeria
-- Shows the likelihood of dying from Covid in Nigeira
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
From CovidDeaths
Where location like 'Nigeria'
order by 1, 2

-- Looking at toal Death rate in Nigeria
Select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_cases, (sum(cast(new_deaths as int))/sum(new_cases))*100 as TotalDeathRate
From CovidDeaths
Where location = 'Nigeria'
order by 1, 2

-- Looking at the Total Cases Vs the Population in Nigeria
Select Location, date, population, total_cases, (total_cases/population)*100 as InfectionRate
From CovidDeaths
Where location like 'Nigeria'
order by 1, 2

--Looking at Countries with Highest Infection Rate compared to Population
Select Location, population, Max(total_cases) as HighestInfectionRate, Max((total_cases/population)*100) as MaxInfectionRate
From CovidDeaths
Group by Location, Population
order by 4 desc


--Looking at the Countries with the highest Death Count
Select Location, population, Max(Cast(total_deaths as int)) as HighestDeathCount 
From CovidDeaths
where continent is not null
Group by Location, Population
order by 3 desc

--Looking at the Countries with the highest Death Rate compared to Population
Select Location, population, Max(Cast(total_deaths as int)) as HighestDeathCount, Max((total_deaths/population)*100) as MaxDeathRate
From CovidDeaths
where continent is not null
Group by Location, Population
order by 3 desc

-- Looking at this breakdown by Continents - Continents with the highest Deatch Count
Select location,  Max(Cast(total_deaths as int)) as HighestDeathCount 
From CovidDeaths
where continent is null
Group by location
order by 2 desc

-- Global Numbers
--Looking at Global Death Rate
Select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_cases, (sum(cast(new_deaths as int))/sum(new_cases))*100 as GlobalDeathRate
From CovidDeaths
Where Continent is not null
order by 1, 2


--Looking at Total Population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as CummulativeVaccinations
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 
order by 1, 2, 3

--Using CTE
With PopsvsVac (Continent, Location, Date, Population, New_Vaccinations, CummulativeVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as CummulativeVaccinations
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 
)

Select *, (CummulativeVaccinations/Population)*100 as PercentPopulationVaccinated
from PopsvsVac

--Using a Temp Table

Drop Table if exists #PercentPopulationVaccinanted
Create Table #PercentPopulationVaccinanted
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
CummulativeVaccinations numeric
)

Insert into #PercentPopulationVaccinanted
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as CummulativeVaccinations
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 

Select *, (CummulativeVaccinations/Population)*100 as PercentPopulationVaccinated
from #PercentPopulationVaccinanted

--Creating a View to store data for visualisations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as CummulativeVaccinations
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 


Create View GlobalDeathCount as
Select location,  Max(Cast(total_deaths as int)) as HighestDeathCount 
From CovidDeaths
where continent is null
Group by location

Create View DeathRate_Nigeria as
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
From CovidDeaths
Where location like 'Nigeria'

Create View InfectionRate_Nigeria as
Select Location, date, population, total_cases, (total_cases/population)*100 as InfectionRate
From CovidDeaths
Where location like 'Nigeria'

Create View DeathRate_AllCountries as
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
From CovidDeaths
Where Continent is not null

Create View InfectionRate_AllCountries as 
Select Location, date, population, total_cases, (total_cases/population)*100 as InfectionRate
From CovidDeaths
Where Continent is not null