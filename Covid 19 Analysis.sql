--select * from dbo.CovidDeaths$

--order by 3,4

--select * from dbo.CovidVaccinations$

--order by 3,4;

--- Data that wil be used

select location,date,total_cases,new_cases,total_deaths,population   
from [Portfolio Project].dbo.CovidDeaths$

order by 1,2;

-- total cases vs total deaths 
select location,date,total_cases,total_deaths   
from [Portfolio Project].dbo.CovidDeaths$
where location like '%states%'
order by 1,2;

-- total cases vs population
---shoing percentage of population get covid
select location,date,total_cases,population,(total_cases/population)*100 as CasesPercentage   
from [Portfolio Project].dbo.CovidDeaths$
where location like '%states%'
order by 1,2;

--countries with highes infection rate compared to population
select location,population,max(total_cases) as highestInfectioRate,population,max((total_cases/population))*100 as CasesPercentage   
from [Portfolio Project].dbo.CovidDeaths$
--where location like '%states%'
group by location,population
order by 1,2;

--Countries with most amount of deaths

select location,max(cast(total_deaths as int)) as TotalCountDeaths  
from [Portfolio Project].dbo.CovidDeaths$
where continent is not null
group by location
order by TotalCountDeaths    desc ;

--Continent with most amount of deaths
select continent,max(cast(total_deaths as int)) as TotalCountDeaths  
from [Portfolio Project].dbo.CovidDeaths$
where continent is not  null
group by continent
order by TotalCountDeaths    desc ;

--Global Numbers 
select date,sum(new_cases) as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths ,(sum(cast(new_deaths as int)) /sum(new_cases)*100) as DeathPercentage  
from [Portfolio Project].dbo.CovidDeaths$
where continent is not null
group by date
order by 1,2;

--Joining Death and Vaccination tables 
select d.continent,d.location,d.date,d.population,v.new_vaccinations,SUM(CONVERt(int,new_vaccinations)) over (partition by d.location order by d.location,d.date)
as vacinnatedAgreegated
from [Portfolio Project].dbo.CovidDeaths$ d
join [Portfolio Project].dbo.CovidVaccinations$ v
on d.location=v.location
and d.date=v.date
where d.continent is not null 
order by 2,3


--use CTE 
with PopVsVac(continent,location,date,population,new_vaccinations,vacinnatedAgreegated)
as 
(
select d.continent,d.location,d.date,d.population,v.new_vaccinations,SUM(CONVERt(int,new_vaccinations)) over (partition by d.location order by d.location,d.date)
as vacinnatedAgreegated
from [Portfolio Project].dbo.CovidDeaths$ d
join [Portfolio Project].dbo.CovidVaccinations$ v
on d.location=v.location
and d.date=v.date
where d.continent is not null
)
select *,(vacinnatedAgreegated/population)*100 as vacPercentage from PopVsVac

--Temporary table 
create table #aggregatedVac(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
vacinnatedAgreegated numeric)

insert into #aggregatedVac 

select d.continent,d.location,d.date,d.population,v.new_vaccinations,SUM(CONVERt(int,new_vaccinations)) over (partition by d.location order by d.location,d.date)
as vacinnatedAgreegated
from [Portfolio Project].dbo.CovidDeaths$ d
join [Portfolio Project].dbo.CovidVaccinations$ v
on d.location=v.location
and d.date=v.date
where d.continent is not null

select * from #aggregatedVac


--View Creation to store data for visualization 

create view V_aggregatedVac as 
select d.continent,d.location,d.date,d.population,v.new_vaccinations,SUM(CONVERt(int,new_vaccinations)) over (partition by d.location order by d.location,d.date)
as vacinnatedAgreegated
from [Portfolio Project].dbo.CovidDeaths$ d
join [Portfolio Project].dbo.CovidVaccinations$ v
on d.location=v.location
and d.date=v.date
where d.continent is not null