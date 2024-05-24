

select *
from PortofolioProject1..CovidDeaths
where continent is not null
order by 3,4

-- Select Data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population
from PortofolioProject1..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Show the likelihood of dying if you contract covid in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortofolioProject1..CovidDeaths
where location like '%indonesia%'
order by 1,2 

-- Loking at total cases vs population
-- shows what percentage of population got covid
select Location, date, population, (total_cases/population)*100 as PercenPopulationinfected
from PortofolioProject1..CovidDeaths
--where location like '%indonesia%'
order by 1,2

-- looking at countries with highest infection rate compared to population
select Location, population, MAX(total_cases) as HighestInfectionCountry, MAX(total_cases/population)*100 as PercenPopulationinfected
from PortofolioProject1..CovidDeaths
--where location like '%indonesia%'
group by location, population
order by PercenPopulationinfected desc
 
-- Let break things down by continent
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortofolioProject1..CovidDeaths
--where location like '%indonesia%'
where continent is null
group by location
order by TotalDeathCount desc

-- showing countries with the highest death count per population
select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortofolioProject1..CovidDeaths
--where location like '%indonesia%'
where continent is not null
group by location
order by TotalDeathCount desc

-- showing continent with highest death count per population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortofolioProject1..CovidDeaths
--where location like '%indonesia%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- global numbers
select sum(new_cases) as total_cases, sum (cast(new_deaths as int)) as total_deaths, 
	sum(cast(new_deaths as int))/sum(new_cases)*100 as  DeathPercentage
from PortofolioProject1..CovidDeaths
--where location like '%indonesia%'
where continent is not null
--group by date
order by 1,2 

--- join table covid death and vac
select*
from PortofolioProject1..CovidDeaths dea
join PortofolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date


-- USE CTE
with PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated) 
as
(
-- lokung at total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order 
by dea.location, dea.date) as RollingPeopleVaccinated
--, RollingPeopleVaccinated/population) *100
from PortofolioProject1..CovidDeaths dea
join PortofolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*, (RollingPeopleVaccinated/Population)*100
from PopvsVac

--temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order 
by dea.location, dea.date) as RollingPeopleVaccinated

--, RollingPeopleVaccinated/population) *100
from PortofolioProject1..CovidDeaths dea
join PortofolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select*, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



-- Creating view to store data for later visualizations
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order 
by dea.location, dea.date) as RollingPeopleVaccinated

--, RollingPeopleVaccinated/population) *100
from PortofolioProject1..CovidDeaths dea
join PortofolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3



select*
from PercentPopulationVaccinated