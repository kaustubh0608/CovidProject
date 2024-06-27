use portfolioProject


select location , date, total_cases,new_cases,population
from CovidDeathsCsv
order by 1,2


-- total cases vs total deaths

Select location, date, total_cases,total_deaths, 
(round(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0),5) * 100) AS Deathpercentage
from covidDeathsCsv
where location like '%India%'
order by 1,2

-- total cases vs population
Select location, date, population,total_cases, 
(round(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0),5) * 100) AS InfectionRate
from covidDeathsCsv
where location like '%India%'
order by 1,2

-- highest infection rate according to their population
select location, population,max(total_cases) as HighestInfectionCount,MAX((round(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0),5) * 100)) as MaxInfectionRate
from covidDeathsCsv 
group by location, population
order by MaxInfectionRate desc


-- showing countries with highest death count as per population

select Location, max(cast(Total_deaths as int)) as TotalDeathCount
from covidDeathsCsv
where continent is not null
group by Location
order by TotalDeathCount desc


--breaking things by continent



--showing continents with highest death count
select continent, max(cast(Total_deaths as int)) as TotalDeathCount
from covidDeathsCsv
where continent is not null
group by continent
order by TotalDeathCount desc


--global numbers
Select location, date, total_cases,total_deaths, 
(round(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0),5) * 100) AS Deathpercentage
from covidDeathsCsv
where continent is not null
order by 1,2


SELECT 
    
    SUM(CAST(new_cases AS int)) AS total_cases, 
    SUM(CAST(new_deaths AS int)) AS total_deaths, 
    CASE 
        WHEN SUM(CAST(new_cases AS int)) = 0 THEN 0
        ELSE SUM(CAST(new_deaths AS int)) * 1.0 / SUM(CAST(new_cases AS int))
    END AS deathPercentage
FROM 
    covidDeathsCsv
WHERE 
    continent IS NOT NULL
GROUP BY 
    date
ORDER BY 
    1,2;



--joins

--total populatoin vs total vaccination

select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
from covidDeathsCsv dea
join CovidVaccinations1 vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
order by 1,2,3


select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from covidDeathsCsv dea
join CovidVaccinations1 vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
order by 2,3


--using CTE
with PopVsVac(Continent,Location,Date,Population,NewVacs,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from covidDeathsCsv dea
join CovidVaccinations1 vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null

)
select *, (RollingPeopleVaccinated/convert(bigint, Population))*100 
from PopVsVac



--temp Table

create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from covidDeathsCsv dea
join CovidVaccinations1 vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
select *, (RollingPeopleVaccinated/convert(bigint, Population))*100 
from #PercentPopulationVaccinated


