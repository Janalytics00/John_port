USE PROJECTS;


SELECT * FROM HR;

ALTER TABLE HR
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL; 


DESCRIBE HR;

SELECT hire_date FROM HR;


UPDATE HR
SET birthdate = CASE
	WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE HR
MODIFY COLUMN birthdate date;

UPDATE HR
SET hire_date = CASE
	WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

SELECT termdate FROM HR;

UPDATE hr
SET termdate = IF(termdate IS NOT NULL AND termdate != '', str_to_date(termdate, '%Y-%m-%d %H:%i:%s'), '0000-00-00')
WHERE true;

SET SQL_MODE = ' ';



SELECT termdate from hr;

SET sql_mode = 'ALLOW_INVALID_DATES';

ALTER TABLE hr
MODIFY COLUMN termdate DATE;
SELECT termdate from hr;



ALTER TABLE HR
MODIFY COLUMN termdate DATE;

ALTER TABLE HR
MODIFY COLUMN hire_date DATE;

SELECT
	MIN(age) AS youngest, 
    MAX(age) AS oldest
FROM HR;

SELECT count(*) AS total_age_18 
FROM HR
WHERE age < 18;

UPDATE HR
SET age = CAST(TIMESTAMPDIFF(YEAR, STR_TO_DATE(birthdate, '%Y-%m-%d'), CURDATE()) AS UNSIGNED);

update hr
SET age = timestampdiff(YEAR, birthdate, CURDATE());

SET sql_safe_updates = 0;



ALTER TABLE HR ADD COLUMN age INT;

-- QUESTIONS

-- 1. What is the gender breakdown of employees in the company?

SELECT gender, count(*) AS count_of_employees
FROM HR
WHERE age>= 18 AND termdate = '0000-00-00'
GROUP BY gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?

SELECT race, count(*) AS count
FROM HR
WHERE age>= 18 AND termdate = '0000-00-00'
GROUP BY race
ORDER BY count(*) DESC;

-- 3. What is the age distribution of employees in the company?

SELECT 
	MIN(age) AS youngest,
    MAX(age) AS oldest
FROM HR
WHERE age>= 18 AND termdate = '0000-00-00';

SELECT 
	CASE 
		WHEN age BETWEEN 18 AND 24 THEN '18-24'
        WHEN age BETWEEN 25 AND 34 THEN '25-34'
        WHEN age BETWEEN 35 AND 44 THEN '35-44'
        WHEN age BETWEEN 45 AND 54 THEN '45-54'
        WHEN age BETWEEN 55 AND 64 THEN '55-64'
        ELSE '65+'
	END AS age_group,
    COUNT(*) AS count
FROM HR
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY age_group
ORDER BY age_group;

SELECT 
	CASE 
		WHEN age BETWEEN 18 AND 24 THEN '18-24'
        WHEN age BETWEEN 25 AND 34 THEN '25-34'
        WHEN age BETWEEN 35 AND 44 THEN '35-44'
        WHEN age BETWEEN 45 AND 54 THEN '45-54'
        WHEN age BETWEEN 55 AND 64 THEN '55-64'
        ELSE '65+'
	END AS age_group, gender,
    COUNT(*) AS count 
FROM HR
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY age_group, gender
ORDER BY age_group, gender;

-- 4. How many employees work at headquarters versus remote locations?

SELECT location, count(*) AS count
FROM HR
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY location;

-- 5. What is the average length of employment for employees who have been terminated?

SELECT 
	round(avg(datediff(termdate, hire_date))/365,0) AS avg_len_emplymt
FROM HR
WHERE termdate <= curdate() AND termdate <> '0000-00-00' AND age >= 18;

-- 6. How does the gender distribution vary across departments and job titles?

SELECT department, gender, count(*) AS count
FROM HR
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY department, gender
ORDER BY department;

-- 7. What is the distribution of job titles across the company?

SELECT jobtitle, count(*) AS count
FROM HR
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY jobtitle
ORDER BY jobtitle DESC;

-- 8. Which department has the highest turnover rate?

SELECT department,
	total_count,
    terminated_count,
    terminated_count/total_count AS termination_rate
FROM (
	SELECT department,
    count(*) AS total_count,
    sum(CASE WHEN termdate <> '0000-00-00' AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminated_count
    FROM HR
    WHERE age >= 18
    GROUP BY department
) AS subquery
ORDER BY termination_rate DESC;

-- 9. What is the distribution of employees across locations by city and state?

SELECT location_state, count(*) AS count
FROM HR
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY location_state
ORDER BY count DESC;

-- 10. How has the company's employee count changed over time based on hire and term dates?

SELECT
	year,
    hires,
    terminations,
    hires - terminations AS net_change,
    round((hires - terminations)/hires * 100,2) AS net_change_percent
FROM(
	SELECT YEAR(hire_date) AS year,
    count(*) AS hires,
    sum(CASE WHEN termdate <> '0000-00-00' AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminations
    FROM HR
    WHERE age >= 18
    GROUP BY YEAR(hire_date)
) AS subquery
ORDER BY year asc;

-- 11. What is the tenure distribution for each department?

SELECT department, round(avg(datediff(termdate, hire_date)/365),0) AS avg_tenure
FROM HR
WHERE termdate <= curdate() AND termdate <> '0000-00-00' AND age >= 18
GROUP BY department;