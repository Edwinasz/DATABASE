CREATE OR REPLACE VIEW VIEW_salary_stats AS
SELECT d.department_id, d.department_name, min(e.salary) as min_atl, max(e.salary) as max_atl, round(avg(e.salary), 2) as vid_atl
FROM departments d JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
WITH READ ONLY;

SELECT * FROM VIEW_salary_stats;

--

SELECT ROWNUM as SALARY_RANKING, FIRST_NAME, LAST_NAME, SALARY
FROM (SELECT FIRST_NAME, LAST_NAME, SALARY FROM EMPLOYEES ORDER BY SALARY DESC)
ORDER BY SALARY;

--

SELECT e.LAST_NAME, e.SALARY, e.DEPARTMENT_ID, d.maxsal
FROM EMPLOYEES e, (SELECT department_id, MAX(salary) maxsal FROM employees GROUP BY department_id) d
WHERE e.department_id = d.department_id
ORDER BY DEPARTMENT_ID;

--

CREATE TABLE MY_DEPARTMENTS AS (SELECT * FROM DEPARTMENTS);
SELECT * FROM MY_DEPARTMENTS;

--

SELECT TABLE_NAME, STATUS, CONSTRAINT_NAME, CONSTRAINT_TYPE, search_condition
FROM user_constraints   
WHERE TABLE_NAME IN ('MY_DEPARTMENTS');

ALTER TABLE MY_DEPARTMENTS DISABLE CONSTRAINT SYS_C0071721;

--

CREATE OR REPLACE VIEW view_my_departments AS
SELECT department_id, department_name FROM departments;

SELECT * FROM view_my_departments;

--

INSERT INTO view_my_departments
    VALUES(105, 'Advertising');
INSERT INTO view_my_departments
    VALUES(120, 'Custodial');
INSERT INTO view_my_departments
    VALUES(130, 'Planning');
    
SELECT * FROM view_my_departments
ORDER BY department_id;

--

ALTER TABLE MY_DEPARTMENTS ADD CONSTRAINT my_departments_department_id_pk PRIMARY KEY(department_id);

SELECT TABLE_NAME, STATUS, CONSTRAINT_NAME, CONSTRAINT_TYPE, search_condition
FROM user_constraints   
WHERE TABLE_NAME IN ('MY_DEPARTMENTS');

--

INSERT INTO view_my_departments
    VALUES(220, 'Human Resources');
    
SELECT * FROM departments
ORDER BY department_id;

--

ALTER TABLE my_departments ADD (location_id NUMBER(4));

CREATE OR REPLACE VIEW view_my_departments AS
SELECT department_id, department_name, location_id FROM departments;

SELECT * FROM view_my_departments;

--
UPDATE my_departments SET location_id = 1700 WHERE location_id IS NULL;

ALTER TABLE my_departments
    MODIFY (location_id CONSTRAINT my_departments_loc_nn NOT NULL);
    
SELECT TABLE_NAME, STATUS, CONSTRAINT_NAME, CONSTRAINT_TYPE, search_condition
FROM user_constraints   
WHERE TABLE_NAME IN ('MY_DEPARTMENTS');





