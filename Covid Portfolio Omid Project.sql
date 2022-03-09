/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


select *
from PortfolioOmid..CovidDeaths
where continent is not null


select *
from PortfolioOmid..CovidVaccination
where continent is not null


-- Select Data that we are going to be starting with

select location, date, population, total_cases, total_deaths
from PortfolioOmid..CovidDeaths
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths*1.0/total_cases*1.0)*100 as DeathPercentage
from PortfolioOmid..CovidDeaths
where location like '%state%' and continent is not NULL
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

select location, date, population, total_cases, (total_cases*1.0/population*1.0)*100 as PercentPopulationInfected
from PortfolioOmid..CovidDeaths
where location like '%state%' and continent is not NULL
order by 1,2


-- Countries with Highest Infection Rate compared to Population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as 
PercentPopulationInfected
from PortfolioOmid..CovidDeaths
-- where location like '%state%' and continent is not NULL
group by location, population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

select location, max(total_deaths) as TotalDeathCount
from PortfolioOmid..CovidDeaths
-- where location like '%state%'
where continent is not null
group by location
order by TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

select continent, max(total_deaths) as TotalDeathsCount
from PortfolioOmid..CovidDeaths
where continent is not NULL
group by continent
order by TotalDeathsCount desc


-- GLOBAL NUMBERS

select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, 
(sum(new_deaths*1.0)/ sum(new_cases*1.0))*100 as DeathsPercentage
from portfolioOmid..covidDeaths
where continent is not NULL
group by DATE
order by 1,2


-- Skills used: Joins

select *
from portfolioOmid..CovidDeaths dea
join portfolioOmid..CovidVaccination vac
    on dea.location = vac.location and dea.date = vac.date


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as
RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from portfolioOmid..CovidDeaths dea
join portfolioOmid..CovidVaccination vac
    on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

with PopvsVac(Continent, Location, Date, Population, new_Vaccination, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as
RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from portfolioOmid..CovidDeaths dea
join portfolioOmid..CovidVaccination vac
    on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolioOmid..CovidDeaths dea
Join portfolioOmid..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolioOmid..CovidDeaths dea
Join portfolioOmid..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated