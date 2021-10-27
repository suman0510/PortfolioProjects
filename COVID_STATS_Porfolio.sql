----------------------------------EXPLORING DATA-----------------------------------------------
------main tables------------------------------------------------------------------------------
--AS ON 24th OCT 2021----------------------------------------

--deaths table
SELECT *
FROM PortfolioProject..covidDeaths
WHERE continent is not null
ORDER BY 3,4;

--vaccinations table
SELECT *
FROM PortfolioProject..covidVaccinations
WHERE continent is not null
ORDER BY 3,4;

--select the data that will be used-------------------------------------------------------------

SELECT Location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..covidDeaths
WHERE continent is not null
ORDER BY 1,2;

--deaths vs cases

SELECT Location,date,total_cases,total_deaths,round((total_deaths/total_cases)*100,3) AS dvc
FROM PortfolioProject..covidDeaths
WHERE location='India'
ORDER BY 1,2

--Looking at Total Cases vs Population,% people affected 
SELECT Location,date,total_cases,population,round((total_cases/population)*100,3) AS cvp
FROM PortfolioProject..covidDeaths
ORDER BY 1,2


--Looking at Total Cases vs Population,% people affected ---in India--
SELECT Location,date,total_cases,population,round((total_cases/population)*100,3) AS cvp
FROM PortfolioProject..covidDeaths
WHERE location='India'
ORDER BY 1,2

--countries with highest Infection Rate
SELECT Location,MAX(total_cases) AS HIR,population,MAX(round((total_cases/population)*100,3)) AS percentPopulationInfected
FROM PortfolioProject..covidDeaths
GROUP BY Location,population
ORDER BY percentPopulationInfected DESC

--countries with highest Death Rate
SELECT Location,MAX(total_deaths) AS HDR,population,MAX(round((total_deaths/population)*100,3)) AS percentPopulationDead
FROM PortfolioProject..covidDeaths
GROUP BY Location,population
ORDER BY percentPopulationDead DESC

--things by continent -----------
SELECT continent,MAX(cast(total_deaths AS int)) AS totalDeath
FROM PortfolioProject..covidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY totalDeath DESC;

--things by location(countries) -----------
SELECT location,MAX(cast(total_deaths AS int)) AS totalDeath
FROM PortfolioProject..covidDeaths
GROUP BY location
ORDER BY totalDeath DESC;
 
--GLOBAL stats
SELECT SUM(new_cases) AS totalNewCases,SUM(cast(new_deaths AS int)) AS totalNewDeaths,ROUND(SUM(CAST(new_deaths AS int))/SUM(new_cases)*100,3) AS DeathPercentage
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2;


--total population vs vaccination
SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,SUM(CONVERT(BIGINT,cv.new_vaccinations)) OVER (Partition by cd.location ORDER BY cd.location,cd.date) as Rollingpplvaccinated
FROM PortfolioProject..covidDeaths AS cd
JOIN PortfolioProject..covidVaccinations AS cv 
ON cd.location=cv.location and   cd.date=cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3;
 

 --use CTE-----------------
 with PopvaVac (continent,location,date,population,new,RollingVaccinations)as (
  SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
  SUM(CONVERT(BIGINT,cv.new_vaccinations)) OVER (Partition by cd.location ORDER BY cd.location,cd.date) as Rollingpplvaccinated
FROM PortfolioProject..covidDeaths AS cd
JOIN PortfolioProject..covidVaccinations AS cv 
ON cd.location=cv.location and   cd.date=cv.date
WHERE cd.continent IS NOT NULL
 )
 SELECT *,ROUND((RollingVaccinations/population)*100,2) as percentageRV
 FROM PopvaVac



 --using TEMP table---------
 DROP TABLE if exists #PercentPplVacc
 CREATE Table #PercentPplVacc(
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 New_ppl_vacc numeric,
 RollingPplVacc numeric
 )
 Insert into #PercentPplVacc
 SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,SUM(CONVERT(bigint,cv.new_vaccinations)) OVER 
 (Partition by cd.location ORDER BY cd.location,cd.date) as RollingPplVacc
FROM PortfolioProject..covidDeaths AS cd
JOIN PortfolioProject..covidVaccinations AS cv 
ON cd.location=cv.location and   cd.date=cv.date
--WHERE cd.continent IS NOT NULL

 SELECT *,ROUND((RollingPplVacc/population)*100,2) as percentageRV
 FROM #PercentPplVacc

 --CONTINENT 
SELECT continent,MAX(cast(total_deaths AS int)) AS totalDeath
FROM PortfolioProject..covidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY totalDeath DESC;

--create view to store data for later
CREATE VIEW PerPopVacci as
SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations
,SUM(CONVERT(bigint,cv.new_vaccinations)) OVER 
 (Partition by cd.location ORDER BY cd.location,cd.date) as RollingPplVacc
FROM PortfolioProject..covidDeaths AS cd
JOIN PortfolioProject..covidVaccinations AS cv 
ON cd.location=cv.location and   cd.date=cv.date
WHERE cd.continent is not null


select *
from PerPopVacci



