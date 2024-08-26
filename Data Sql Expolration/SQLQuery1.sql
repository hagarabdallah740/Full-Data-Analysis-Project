Select *
FROM Covid20.dbo.CovidDeaths
order by 3,4

--Select *
--FROM CovidVaccinations
--order by 3,4

-----> Select data that I can use in this project 
Select location,date,total_cases,new_cases,total_deaths,population 
from CovidDeaths

------>  TO Compare Between Total cases and Total deaths
Select location,date,total_cases,total_deaths,(total_deaths/total_cases) * 100 as DeathPercentage
from CovidDeaths
------> Shows percentage of dying if covid in our country
where location like '%states%'
order by 1,2

-------> Looking at Total Cases vs Population 
Select location,date,total_cases,population,(total_cases/population) * 100 as TotalPercentage
from CovidDeaths
where location like '%states%'
order by 1,2

--------> Looking At Countries With Highest Infection Rate Compared To Population 
Select location,population,MAX(total_cases) as HighestInfection ,MAX(total_cases/population) * 100 as PopulationInfactedPercentage
from CovidDeaths
---where location like '%states%'
Group by location,population
order by PopulationInfactedPercentage desc
---------> Show Countery with highest death per population
Select location ,population,MAX (total_deaths)as HighestDeath , MAX(total_deaths/population) * 100 as Highestpopualtiondeath 
from CovidDeaths
group by location,population
order by Highestpopualtiondeath desc
----------------------------------------->DEATH
Select location ,MAX (total_deaths)as HighestDeath 
from CovidDeaths
where continent is not null
group by location
order by HighestDeath desc
-----------> BREAKING DOWN BY CONTINENT
Select continent,MAX (cast(total_deaths as int)) as HighestDeath 
from CovidDeaths
where continent is not null
group by continent
order by HighestDeath desc
----------------------------->NULL
Select location ,MAX (cast(total_deaths as int)) as HighestDeath 
from CovidDeaths
where continent is null
group by location
order by HighestDeath desc
----> Show high continents death per populaion
Select continent ,MAX (cast(total_deaths as int)) as Totaldeathcount
from CovidDeaths
where continent is null
group by continent
order by Totaldeathcount desc
------------> GLOBAL NUMBERS
Select date,sum(new_cases),sum(cast(new_deaths as int)), sum(cast(new_deaths as int ))/sum(cast(new_Cases as int))*100 as deathpercentage
from CovidDeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2
--------------------- *Covid Vaccinations* ------------------------
-------LOOKING AT TOTAL POPULATION VS VACCINATION
WITH PopvsVac AS (
    SELECT 
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CONVERT(int, vac.new_vaccinations)) OVER (
            PARTITION BY dea.location 
            ORDER BY dea.location, dea.date
        ) AS RollingPeopleVaccinated
    FROM 
        CovidDeaths dea
    JOIN 
        CovidVaccinations vac
    ON 
        dea.location = vac.location
        AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL
)
-- You can now use the CTE in a subsequent SELECT query
SELECT * 
FROM PopvsVac;


--------------> TEMP TABLE
Drop table if exists #PercentPopulationVaccinated 
Create table #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent ,dea.location,dea.date,dea.population ,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location Order by dea.location
,dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
join CovidVaccinations vac
    on dea.location=vac.location
	and dea.date=vac.date
Select *,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--> Creating View To Store Data For Later Visualization

Create View PercentPopulationVaccinated as 
Select dea.continent ,dea.location,dea.date,dea.population ,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location Order by dea.location
,dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
join CovidVaccinations vac
    on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null

Select * from PercentPopulationVaccinated