Select *
From CovidDataAnalysis..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From CovidDataAnalysis..CovidVaccinations
--order by 3,4

--Select Data that we are going to Use

Select Location, Date, total_cases,new_cases, total_deaths, population
From CovidDataAnalysis..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at the Total Cases vs Total Deaths
-- Shows liklihood of dying if you contract covid in your country
Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDataAnalysis..CovidDeaths
Where location like '%states%'
--and Where continent is not null
order by 1,2

-- Looking at the total cases vs the Population
-- Shows what % of population got covid
Select Location, Date, Population, (total_cases/population)*100 asPercentPopulationInfected
From CovidDataAnalysis..CovidDeaths
--Where location like '%Pakistan%'
Where continent is not null
order by 1,2

-- Which country have highest contracting virus rate
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidDataAnalysis..CovidDeaths
--Where location like '%Pakistan%'
group by Location, Population
order by PercentPopulationInfected desc


--Showing Countries with Highest Death Count per Population
Select Location,MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDataAnalysis..CovidDeaths
--Where location like '%Pakistan%'
Where continent is not null
group by Location, Population
order by TotalDeathCount desc


--Let's Break things Down by Contnents


-- SHowing the continent with Highest Deaths
Select continent,MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDataAnalysis..CovidDeaths
--Where location like '%Pakistan%'
Where continent is not null
group by continent
order by TotalDeathCount desc


-- Global Numbers 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM
(new_cases)*100 as DeathPercentage
From CovidDataAnalysis..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by date
order by 1,2


-- Looking at Total Population Vs Vaccinations
-- Use CTE
With PopVsVac (Continent, Location, date,Poplulation, New_Vaccinations, RollingPeopleVaccinated) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
 -- ,(RollingPeopleVaccinated/population)*100
From CovidDataAnalysis..CovidDeaths dea
Join CovidDataAnalysis..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)  
Select *, (RollingPeopleVaccinated/Poplulation)*100
From PopVsVac


--TEMP Table
Drop Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
 -- ,(RollingPeopleVaccinated/population)*100
From CovidDataAnalysis..CovidDeaths dea
Join CovidDataAnalysis..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

Select *, (RollingPeopleVaccinated/Population)*100
From  #PercentPopulationVaccinated


-- Creating View for Store Data for Later Visualization
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
 -- ,(RollingPeopleVaccinated/population)*100
From CovidDataAnalysis..CovidDeaths dea
Join CovidDataAnalysis..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

Select *
From PercentPopulationVaccinated