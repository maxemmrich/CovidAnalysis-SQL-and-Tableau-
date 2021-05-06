

-- Shows the death rate of covid. In other words: The overall likelyhood of dying when you get infected.

SELECT
	YEAR(date) AS year,
	MONTH(date) AS month, 
	ROUND(MAX(total_cases),0) AS total_cases,
	ROUND(MAX(total_deaths),0) AS total_deaths,
	ROUND((MAX(total_deaths)/MAX(total_cases)),4)*100 AS death_rate
FROM 
	PortfolioProjectCovid..CovidDeaths
WHERE
	location='Germany'
GROUP BY 
	YEAR(date), MONTH(date)
ORDER BY 
	YEAR(date), MONTH(date);

-- Same querry as above, but without time aggregation (to use in tableau later)

SELECT
	location,
	date,
	total_cases,
	total_deaths,
	ROUND((total_deaths/total_cases)*100,4) AS death_rate
FROM 
	PortfolioProjectCovid..CovidDeaths
WHERE 
	continent != ''
ORDER BY
	1,2;


-- What percentage of the german population got covid (by month)?

SELECT
	YEAR(date) AS year,
	MONTH(date) AS month, 
	ROUND(MAX(total_cases),0) AS total_cases,
	ROUND((MAX(total_cases)/MAX(population)),4)*100 AS infection_rate
FROM 
	PortfolioProjectCovid..CovidDeaths
WHERE 
	location='Germany'
GROUP BY 
	YEAR(date), MONTH(date)
ORDER BY 
	YEAR(date), MONTH(date);


-- Same querry as above, but without time aggregation and filtering (to use in tableau later)

SELECT
	location,
	date,
	total_cases,
	ROUND((total_cases/population)*100,4) AS infection_rate
FROM 
	PortfolioProjectCovid..CovidDeaths
WHERE 
	continent != ''
ORDER BY
	1,2;


-- What counties have the highest infection rates compared to its population?

SELECT
	location,
	ROUND((MAX(total_cases)/MAX(population)),4)*100 AS infection_rate
FROM 
	PortfolioProjectCovid..CovidDeaths
WHERE 
	continent != ''
GROUP BY 
	location
ORDER BY 
	infection_rate desc;


-- Which countries have the most covid deaths?

SELECT
	location,
	MAX(total_deaths) AS total_covid_deaths,
	ROUND((MAX(total_deaths)/MAX(population)),4)*100 AS death_rate
FROM 
	PortfolioProjectCovid..CovidDeaths
WHERE continent != ''
GROUP BY 
	location
ORDER BY 
	total_covid_deaths desc;


-- Which continents have the most covid deaths?

SELECT
	continent,
	MAX(total_deaths) AS total_covid_deaths,
	ROUND((MAX(total_deaths)/MAX(population)),4)*100 AS death_rate
FROM 
	PortfolioProjectCovid..CovidDeaths
WHERE continent != ''
GROUP BY 
	continent
ORDER BY 
	total_covid_deaths desc;


-- Global Numbers

SELECT
	--date,
	SUM(new_cases) AS covid_cases,
	SUM(CAST(new_deaths AS int)) AS covid_deaths,
	ROUND(SUM(cast(new_deaths as int))/SUM(New_Cases)*100,4) as DeathPercentage
FROM 
	PortfolioProjectCovid..CovidDeaths
WHERE 
	continent != ''
--GROUP BY 
--	date
--ORDER BY 
--	date;


-- Percentage of Population that has recieved at least one Covid Vaccine. For demonstration purposes a CTE has been used

WITH CTE_cumulative_vac AS 
(
SELECT
	cd.continent,
	cd.location,
	cd.date,
	cd.population,
	cv.new_vaccinations,
	SUM(CONVERT(int,cv.new_vaccinations)) OVER (PARTITION BY cd.Location ORDER BY cd.location, cd.date) AS cumulative_vaccinations
	--(SUM(CONVERT(int,cv.new_vaccinations)) OVER (PARTITION BY cd.Location ORDER BY cd.location, cd.date)/cd.population)*100 AS vacrate
FROM
	PortfolioProjectCovid..CovidDeaths cd
		LEFT JOIN PortfolioProjectCovid..CovidVaccinations cv
			ON cd.location=cv.location
			AND cd.date=cv.date
WHERE 
	cd.continent != ''
--ORDER BY
--	2,3
)
SELECT 
	*, 
	(cumulative_vaccinations/population)*100 AS vac_rate
FROM 
	CTE_cumulative_vac;