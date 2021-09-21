
select *
from PorfolioProject..Coviddeaths
where continent is not null
order by 3,4

--select *
--from PorfolioProject..Covidvacinations
--order by 3,4

-- select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
	from PorfolioProject..Coviddeaths
	where continent is not null
	order by 1,2

-- looking at Total Cases vs Total Deaths
-- shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
	from PorfolioProject..Coviddeaths
	where location like '%Vietnam%'
	and continent is not null
	order by 1,2

--looking at Total Cases vs Population
--shows what percentge of population got Covid

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
	from PorfolioProject..Coviddeaths
	where location like '%Vietnam%'
	and continent is not null
	order by 1,2

--looking at Country with Highest Infection Rate compared to Population

select location, population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as PercentPopulationInfected
	from PorfolioProject..Coviddeaths
-- where location like '%Vietnam%'
	group by location, population
	order by PercentPopulationInfected desc

--showing the Countries with Highest Death Count per Population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
	from PorfolioProject..Coviddeaths
-- where location like '%Vietnam%'
	where continent is not null 
	group by location
	order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
	from PorfolioProject..Coviddeaths
-- where location like '%Vietnam%'
	where continent is not null 
	group by continent
	order by TotalDeathCount desc

-- showing the continent with the highest death count

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
	from PorfolioProject..Coviddeaths
-- where location like '%Vietnam%'
	where continent is null 
	group by location
	order by TotalDeathCount desc


-- global numbers per day

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PorfolioProject..Coviddeaths
--where location like '%Vietnam%'
where continent is not null
group by date
order by 1,2

--deathpercentage all over the world

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PorfolioProject..Coviddeaths
--where location like '%Vietnam%'
where continent is not null
--group by date
order by 1,2

--joinning the two tables

select *
from PorfolioProject..Coviddeaths dea
join PorfolioProject..Covidvacinations vac
	on dea.location = vac.location
	and dea.date = vac.date

--Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
  dea.date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
from PorfolioProject..Coviddeaths dea
join PorfolioProject..Covidvacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE or temp table where you can't use column just created to do the next calculation

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
  dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PorfolioProject..Coviddeaths dea
join PorfolioProject..Covidvacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/population)*100 as RollingPercentage
from PopvsVac

-- Temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
  dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PorfolioProject..Coviddeaths dea
join PorfolioProject..Covidvacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100 as RollingPercentage
from #PercentPopulationVaccinated

--creating View to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
  dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PorfolioProject..Coviddeaths dea
join PorfolioProject..Covidvacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPopulationVaccinated