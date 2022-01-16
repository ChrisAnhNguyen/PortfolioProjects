Select *
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 3,4




--Select *
--From PortfolioProject..CovidVaccinations$
--order by 3,4

--Select data that we are going to be using

Select Location, date, total_cases,new_cases, total_deaths,population
From PortfolioProject..CovidDeaths$
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract Covid in Canada
Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths$
Where location like '%canada%'
order by 1,2



---Looking at Total cases vs Population
---Shows what percentage of population got Covid (7% of population got covid in January 2022)
Select Location, date, total_cases, population,(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
Where location like '%canada%'
order by 1,2

---Looking at countries with the highest infection rate compared to population
Select Location, population,MAX(total_cases) As HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
Group by Location, population
order by PercentPopulationInfected desc


---LET'S BREAK THINGS DOWN BY CONTINENT
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is null
Group by location
order by TotalDeathCount desc



---Showing the countries with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by continent
order by TotalDeathCount desc


---Global Numbers/date
Select date,Sum(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths ,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths$
Where continent is not null
Group By date
order by 1,2
---Overal accross the world
Select Sum(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths ,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 1,2




---Look at table for vaccination
Select *
From PortfolioProject..CovidVaccinations$

---Join two tables together
Select *
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
On  dea.location=vac.location
and dea.date=vac.date


---Looking at Total Population vs Vaccinations
Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
On  dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3


--Partition techniques

--Partition by location(sum for specific location and not all area in general)
Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location)
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
On  dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3


---Partition and order by location and the date 
---Looking at Total Population vs Vaccinations
---USE CTE
With PopvsVac (Continent, Location, Date,Population, RollingPeopleVacinated, New_Vaccinations)
as(
Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,dea.Date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
On  dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVacinated/population)*100
From PopvsVac




---TEMP TABLE
Drop table if exists #percentPopulationVaccinated
Create Table #percentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #percentPopulationVaccinated
Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,dea.Date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
On  dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
From #percentPopulationVaccinated



---Creating View to store data for late visualisation
Create View percentPopulationVaccinated as

Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,dea.Date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
On  dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
