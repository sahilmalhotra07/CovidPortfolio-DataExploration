
--Total cases as percentage of population with time
Select  Location,date,total_cases,population,(total_cases/population)*100 as CovidPercentage
From DeathCovid
Where continent is not null
order by 1,2

--Total death as percentage of population with time

Select  Location,date,CAST(total_cases as INT) as TotalDeath,population,(CAST(total_cases as INT)/population)*100 as CovidPercentage
From DeathCovid
Where continent is not null
order by 1,2

-- Likelihood of a death on conctracting covid ( Death vs Covid ) TOP 15 
Select TOP 15 Location,MAX(CAST(total_deaths AS INT)) AS TotalDeath,MAX(total_cases) AS TotalCases, (MAX(CAST(total_deaths AS INT))/MAX(total_cases))*100 as DeathPercentage
From DeathCovid
Where continent is not null 
Group By Location
order by 4 DESC


--Country with Highest percentage of inefected population ( population >1 million)
Select Location, MAX(total_cases) as TotalAbsoluteCases,population, MAX(total_cases/population)*100 as PercentInfected
From DeathCovid
Where continent is not null 
Group By Location,population
order by 4 DESC


-- Total vaccines administered countrywise with time

SELECT	dea.continent,dea.location,dea.date,dea.population,CAST(vac.new_vaccinations as bigint) as NewVaccination,vac.total_vaccinations,
		SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location) as RollingVaccination
FROM DeathCovid as dea INNER JOIN
	VaccinationCovid AS vac 
	ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3




-- Percentage of population which is Fully Vaccinated in Descending order

select location,MAX(CAST(people_fully_vaccinated_per_hundred AS float))
from VaccinationCovid
group by location
order by 2 desc


--Final table with relevant columns. CTE is used to find the Rolling Vaccination numbers with date (Country level)

WITH Vaccination(location,date,new_death,new_cases,population,total_cases,fully_vac_percent,rollingVaccinations) AS 
(
	Select	dea.location,dea.date,new_deaths,new_cases,dea.population,dea.total_cases,
		CAST(people_fully_vaccinated_per_hundred AS float) as fully_vac_percent,
		MAX(CAST (vac.people_fully_vaccinated as bigint)) OVER (partition by vac.location ORDER BY vac.location,vac.date) as rollingVaccinations
	FROM	DeathCovid dea Join VaccinationCovid vac
			On dea.location = vac.location AND dea.date = vac.date

)

SELECT	*,(total_cases/population)*100 AS TotalPopulationInfected,
		(rollingVaccinations/population)*100 as TotalVaccPercent
FROM Vaccination
order by 1,2


