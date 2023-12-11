--Data to Use

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
order by 1,2

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
order by 1,2

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location = 'Nigeria'
order by 1,2

--Total Cases vs Population
Select location, date, total_cases, population, (total_cases/population)*100 as DiseasedPercentage
From CovidDeaths
Where location = 'Nigeria'
order by 1,2

-- Countries with highest infection per population
Select location, max(total_cases) as HighestInfectionCount, population, max((total_cases/population))*100 as HighestDiseasedPercentage
From CovidDeaths
group by location, population
order by 4 desc

-- Countries with highest death per population
Select location, max(total_deaths) as HighestDeathCount, population, max((total_deaths/population))*100 as HighestDeathPercentage
From CovidDeaths
where continent is not null
group by location, population
order by 2 desc

-- Countries with highest death per population in each continent
Select continent, max(total_deaths) as HighestDeathCount, max((total_deaths/population))*100 as HighestDeathPercentage
From CovidDeaths
where continent is not null
group by continent
order by 2 desc

--Given continental values
Select location, max(total_deaths) as HighestDeathCount, max((total_deaths/population))*100 as HighestDeathPercentage
From CovidDeaths
where continent is null
group by location
order by 2 desc

-- Continental Death Rates
With CTE_Continent as 
(Select location, continent, max(total_deaths) as TotalDeaths, population
From CovidDeaths
group by location,continent, population
)

Select continent, sum(TotalDeaths)
From CTE_Continent
where continent is not null
Group by continent

--Global Numbers

Select date, sum(total_deaths) as GlobalDeaths, sum(total_cases) as GlobalCases, (sum(total_deaths)/sum(total_cases))*100 as DeathPercentage
From CovidDeaths
Where continent is not null
Group by date
order by 1

Select date, sum(new_deaths) as GlobalDeaths, sum(new_cases) as GlobalCases, (sum(new_deaths)/nullif(sum(new_cases),0))*100 as DeathPercentage
From CovidDeaths
where continent is not null
Group by date
order by 1

Select sum(new_deaths) as GlobalDeaths, sum(new_cases) as GlobalCases, (sum(new_deaths)/nullif(sum(new_cases),0))*100 as DeathPercentage
From CovidDeaths
where continent is not null
order by 1

--Covid Vaccinations
Select *
From CovidVaccinations

--Join Tables
Select *
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

Select dea.location, dea.date, dea.continent, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingSum
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2

-- Percentage of Popul;ation Vaccinated
Drop Table If exists #rollingVacs
Create Table #rollingVacs
(
Location nvarchar(255),
Date datetime,
Continent nvarchar(255),
Population numeric,
NewVaccinations numeric,
RollingSum numeric
)

Insert into #rollingVacs 
Select dea.location, dea.date, dea.continent, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingSum
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2

Select *, (RollingSum/Population)*100 as PercentageVaccinated
From #rollingVacs

--Creating Views for Visualization
Create View NigerianSituation as
(
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location = 'Nigeria'
--order by 1,2
)

Create View InfectionRankings as
(
Select location, max(total_cases) as HighestInfectionCount, population, max((total_cases/population))*100 as HighestDiseasedPercentage
From CovidDeaths
group by location, population
)

Create View DeathRanking as 
(
Select location, max(total_deaths) as HighestDeathCount, population, max((total_deaths/population))*100 as HighestDeathPercentage
From CovidDeaths
where continent is not null
group by location, population
)

Create View ContinentalAggregates as
With CTE_Continent as 
(Select location, continent, max(total_deaths) as TotalDeaths, population
From CovidDeaths
group by location,continent, population
)

Select continent, sum(TotalDeaths) as TotalDeaths
From CTE_Continent
where continent is not null
Group by continent

Create View PopulationVaccinated as
(
Select dea.location, dea.date, dea.continent, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingSum
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)