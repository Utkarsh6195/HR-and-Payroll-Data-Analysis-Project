SELECT * FROM hr_and_payroll_dataset

-- 1) Salary and Hiring Analysis
-- A company is concerned that some departments are taking too long to hire employees. They suspect this might affect
-- salary allocation. They want a report showing average salaries and bonus percentages for departments that generally
-- hire faster than others. Departments hiring slower than 40 days should be excluded. Can you help identify such 
-- departments and provide the required salary insights?

SELECT depart_ment, AVG(salary) AS average_salary, AVG(bonus_pct) AS average_bonus_pct FROM hr_and_payroll_dataset
WHERE time2hire_dayz < 40 GROUP BY depart_ment;

-- 2) Job Title Code Analysis
-- The HR department wants to create a system where job titles can be represented by a unique code derived from the job 
-- titles themselves. They have requested a report showing a shortened version (first three letters) of each job title. 
-- Additionally, only employees earning above their department's average salary should be included. How can you prepare
-- this list for them?

SELECT empl0yee_id, fir_t_name, l_st_name AS Full_name, SUBSTRING(job_t1tle,1,3) AS Job_title_code FROM hr_and_payroll_dataset 
GROUP BY empl0yee_id, fir_t_name, l_st_name, job_t1tle, salary, depart_ment HAVING salary > (SELECT AVG(salary) FROM hr_and_payroll_dataset WHERE depart_ment = hr_and_payroll_dataset.depart_ment);
                                   
								   -----------------------------------------------------

WITH DepartmentAverage AS 
(SELECT depart_ment, AVG(salary) AS avg_salary FROM hr_and_payroll_dataset GROUP BY depart_ment)
SELECT empl0yee_id,fir_t_name, l_st_name, SUBSTRING(job_t1tle, 1, 3) AS job_title_code FROM hr_and_payroll_dataset AS e
JOIN 
DepartmentAverage AS d ON e.depart_ment = d.depart_ment
WHERE 
e.salary > d.avg_salary;

--3) Leave Balance Issue
-- Some employees’s leave balances are missing, and the company wants to know how big the issue is in each department. 
-- Can you find out how many employees in each department have no recorded leave balance? Also, the HR team is curious
-- about the roles of these employees. Prepare a summary for them.

SELECT depart_ment, COUNT(empl0yee_id) AS no_leave_balance_count, STRING_AGG(job_t1tle, ', ') AS roles_with_no_leave_balance
FROM hr_and_payroll_dataset
WHERE leave_bal_days IS NULL OR leave_bal_days = 0 GROUP BY depart_ment;

-- 4) Performance Review and Salary Update
-- Employees who haven’t received a salary bump in the last two years might need attention. Similarly, they want to know 
-- how long it’s been since each employee’s last performance review. The goal is to identify employees potentially overdue
-- for an appraisal. Can you prepare this list with the required details?

SELECT empl0yee_id, CONCAT(fir_t_name,' ' ,l_st_name) AS full_name, DATEDIFF(YEAR, last_perf_review, GETDATE()) AS years_since_review,
DATEDIFF(YEAR, last_salary_bump, GETDATE()) AS years_since_salary_bump FROM hr_and_payroll_dataset
WHERE DATEDIFF(YEAR, last_salary_bump, GETDATE()) >= 2;

-- 5) Identifying Top Performers
-- Management wants to reward the highest-paid employees in departments that contribute significantly to the payroll. 
-- For each department with a total payroll above $500,000, find the top 3 earners and include their details. How would
-- you determine this?

WITH DepartmentPayroll AS (SELECT depart_ment, SUM(salary) AS total_payroll FROM hr_and_payroll_dataset
GROUP BY depart_ment HAVING SUM(salary) > 500000),
TopEarners AS (SELECT empl0yee_id, CONCAT(fir_t_name,' ' ,l_st_name) AS full_name, salary, depart_ment, 
ROW_NUMBER() OVER (PARTITION BY depart_ment ORDER BY salary DESC) AS rank FROM hr_and_payroll_dataset)
SELECT t.empl0yee_id, t.full_name, t.salary, t.depart_ment FROM TopEarners t
JOIN DepartmentPayroll d ON t.depart_ment = d.depart_ment
WHERE t.rank <= 3;

SELECT * FROM hr_and_payroll_dataset
