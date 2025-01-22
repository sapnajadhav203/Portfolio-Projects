select *
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4
;


--select *
--from CovidVaccinations
--order by 3,4;

select Location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject.dbo.CovidDeaths
order by 1,2;

--Total_deaths vs Total_Cases
select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where location like '%india%'
order by 1,2;

--Total_Cases vs Population
-- Shows what percentage of poplation got covid
select Location,date,population,total_cases,(total_cases/population)*100 as PercentagePopulationInfected
from PortfolioProject.dbo.CovidDeaths
--where location like '%india%'
order by 1,2;

-- Looking at countries with Highest infection rate compared to population
select Location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentagePopulationInfected
from PortfolioProject.dbo.CovidDeaths
--where location like '%india%'
Group by location,population
order by PercentagePopulationInfected desc;


-- Showing countries with highest death count per population
select Location,MAX(CAST(total_deaths as int)) AS TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
--where location like '%india%'
where continent is not null
Group by location
order by TotalDeathCount desc;


-- Showing continent with highest death count per population
select continent,MAX(CAST(total_deaths as int)) AS TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
--where location like '%india%'
where continent is not  null
Group by continent
order by TotalDeathCount desc;


-- DeathPercent By date
select date,sum(new_cases) AS TotalNewCases,SUM(CAST(new_deaths AS INT)) AS TotalNewDeaths,(SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS DeathPercentage
from PortfolioProject.dbo.CovidDeaths
--where location like '%india%'
where continent is not  null
Group by date
order by 1,2;


-- CTE :Population Vs total People Vaccinated

WITH PopVsVAC (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
AS(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3;
)
SELECT *,(RollingPeopleVaccinated/population)*100 AS VaccinatedPercentage
FROM PopVsVAC;


--Temp Table
DROP TABLE IF EXISTS #PercentPoplationVaccinated
CREATE TABLE #PercentPoplationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPoplationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null
--order by 2,3;

SELECT *,(RollingPeopleVaccinated/population)*100 AS VaccinatedPercentage
FROM #PercentPoplationVaccinated;


--CREATE VIEW FOR LATER VISUALIZATION
CREATE VIEW PercentPoplationVaccinated AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null;
--order by 2,3;

SELECT * FROM PercentPoplationVaccinated;