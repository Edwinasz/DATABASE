-- 1-2. HR schemos sukūrimas (REGIONS, COUNTRIES, LOCATIONS, DEPARTMENTS, JOBS, EMPLOYEES,
-- JOB_GRADES, JOB_HISTORY) paleidžiant pateiktą skriptą savo paskyroje (F5 / Run Script).
-- Patikrinimas: turi būti 20 darbuotojų, 8 skyriai, 6 JOB_GRADES eilutės.

SELECT 'employees', COUNT(*) FROM employees UNION ALL
SELECT 'departments', COUNT(*) FROM departments UNION ALL
SELECT 'job_grades', COUNT(*) FROM job_grades;

-- 3. Sukurkite lentelių (REGIONS, COUNTRIES, LOCATIONS, DEPARTMENTS, JOBS, EMPLOYEES, JOB_GRADES,
-- JOB_HISTORY) kopijas (CREATE TABLE... AS...), kurių pavadinimai turi būti sukurti pagal tokį
-- šabloną: COPY_TABLENAME.

CREATE TABLE copy_regions     AS SELECT * FROM regions;
CREATE TABLE copy_countries   AS SELECT * FROM countries;
CREATE TABLE copy_locations   AS SELECT * FROM locations;
CREATE TABLE copy_departments AS SELECT * FROM departments;
CREATE TABLE copy_jobs        AS SELECT * FROM jobs;
CREATE TABLE copy_employees   AS SELECT * FROM employees;
CREATE TABLE copy_job_grades  AS SELECT * FROM job_grades;
CREATE TABLE copy_job_history AS SELECT * FROM job_history;

-- 4. Į kiekvieną lentelės kopiją įkelkite po vieną naują eilutę.

INSERT INTO copy_regions (region_id, region_name)
VALUES (5, 'Baltics');

INSERT INTO copy_countries (country_id, country_name, region_id)
VALUES ('LT', 'Lithuania', 1);

INSERT INTO copy_locations (location_id, street_address, postal_code, city, state_province, country_id)
VALUES (3300, 'Sauletekio al. 11', '10223', 'Vilnius', NULL, 'LT');

INSERT INTO copy_departments (department_id, department_name, manager_id, location_id)
VALUES (280, 'Research', NULL, 3300);

INSERT INTO copy_jobs (job_id, job_title, min_salary, max_salary)
VALUES ('DB_ADMIN', 'Database Administrator', 6000, 12000);

INSERT INTO copy_employees (employee_id, first_name, last_name, email, phone_number,
                            hire_date, job_id, salary, commission_pct, manager_id, department_id)
VALUES (207, 'Jonas', 'Jonaitis', 'JJONAITIS', '370.600.12345',
        DATE '2024-03-01', 'DB_ADMIN', 7000, NULL, 100, 280);

INSERT INTO copy_job_grades (grade_level, lowest_sal, highest_sal)
VALUES ('G', 40001, 60000);

INSERT INTO copy_job_history (employee_id, start_date, end_date, job_id, department_id)
VALUES (207, DATE '2022-01-10', DATE '2024-02-28', 'IT_PROG', 60);

COMMIT;

-- 5. Įvykdykite šiuos 3 sakinius, kad sukurtumėte 3 naujas lenteles, skirtas naudoti kelių
-- lentelių įterpimo sakinius. Kuriant, visos 3 lentelės turi būti tuščios.

CREATE TABLE sal_history (employee_id, hire_date, salary)
AS SELECT employee_id, hire_date, salary
FROM employees
WHERE 1=2;

CREATE TABLE mgr_history (employee_id, manager_id, salary)
AS SELECT employee_id, manager_id, salary
FROM employees
WHERE 1=2;

CREATE TABLE special_sal (employee_id, salary)
AS SELECT employee_id, salary
FROM employees
WHERE 1=2;

-- 6. Parašykite kelių lentelių įterpimo sakinį, kad pirmiausia pasirinktumėte visų darbuotojų
-- employee_id, hire_date, salary ir manager_id. Jei atlyginimas didesnis nei 20 000, į special_sal
-- lentelę įrašykite employee_id ir salary. Įveskite employee_id, hire_date ir salary į sal_history
-- lentelę. Įveskite employee_id, manager_id ir salary į lentelę mgr_history.
-- Turi būti įterptos 39 eilutės: sal_history 19, mgr_history 19, special_sal 1.

INSERT ALL
  WHEN sal > 20000 THEN
    INTO special_sal VALUES (empid, sal)
  ELSE
    INTO sal_history VALUES (empid, hiredate, sal)
    INTO mgr_history VALUES (empid, mgr, sal)
SELECT employee_id empid,
       hire_date   hiredate,
       salary      sal,
       manager_id  mgr
FROM employees;

SELECT 'sal_history', COUNT(*) FROM sal_history UNION ALL
SELECT 'mgr_history', COUNT(*) FROM mgr_history UNION ALL
SELECT 'special_sal', COUNT(*) FROM special_sal;

COMMIT;

-- 7. Sukurkite lenteles naudodami kiekvieną iš išvardintų laiko juostų duomenų tipų, panaudokite
-- savo laiko juostą ir dar vieną pasirinktinai iš pateikto sąrašo:
-- a. TIMESTAMP WITH LOCAL TIME ZONE
-- b. INTERVAL YEAR TO MONTH
-- c. INTERVAL DAY TO SECOND

-- a.
CREATE TABLE web_orders
( order_id   NUMBER,
  order_date TIMESTAMP WITH LOCAL TIME ZONE );

ALTER SESSION SET TIME_ZONE = 'Europe/Vilnius';

INSERT INTO web_orders VALUES (1, TIMESTAMP '2026-11-16 10:55:00 Europe/Vilnius');
INSERT INTO web_orders VALUES (2, CURRENT_TIMESTAMP);

SELECT * FROM web_orders;            -- rodoma Vilniaus laiku

ALTER SESSION SET TIME_ZONE = 'America/New_York';

SELECT * FROM web_orders;            -- tie patys įrašai, 7 val. anksčiau

ALTER SESSION SET TIME_ZONE = 'Europe/Vilnius';

-- b.
CREATE TABLE warranty
( prod_id       NUMBER,
  warranty_time INTERVAL YEAR(3) TO MONTH );

INSERT INTO warranty VALUES (123, INTERVAL '8' MONTH);
INSERT INTO warranty VALUES (155, INTERVAL '200' YEAR(3));
INSERT INTO warranty VALUES (678, INTERVAL '2-6' YEAR TO MONTH);

SELECT * FROM warranty;

-- c.
CREATE TABLE lab
( exp_id    NUMBER,
  test_time INTERVAL DAY(2) TO SECOND );

INSERT INTO lab VALUES (100012, INTERVAL '90 00:00:00' DAY TO SECOND);
INSERT INTO lab VALUES (56098,  INTERVAL '6 03:30:16' DAY TO SECOND);

SELECT * FROM lab;

COMMIT;

-- 8. Įveskite naujas Human Resources pareigas į COPY_JOBS lentelę.

INSERT INTO copy_jobs (job_id, job_title, min_salary, max_salary)
VALUES ('HR_MAN', 'Human Resources Manager', 4500, 5500);

COMMIT;

-- 9. Įveskite tris naujus darbuotojus (pareigos HR_MAN) į lentelę COPY_EMPLOYEES.

INSERT INTO copy_employees (employee_id, first_name, last_name, email, hire_date, job_id)
VALUES (210, 'Ramon', 'Sanchez', 'RSANCHEZ', SYSDATE, 'HR_MAN');

INSERT INTO copy_employees (employee_id, first_name, last_name, email, hire_date, job_id)
VALUES (211, 'Laura', 'Kim', 'LKIM', SYSDATE, 'HR_MAN');

INSERT INTO copy_employees (employee_id, first_name, last_name, email, hire_date, job_id)
VALUES (212, 'Tomas', 'Petrauskas', 'TPETRAUS', SYSDATE, 'HR_MAN');

COMMIT;

-- 10. Įveskite naują skyrių (Human Resources) į lentelę COPY_DEPARTMENTS.

INSERT INTO copy_departments (department_id, department_name, manager_id, location_id)
VALUES (300, 'Human Resources', 210, 1700);

COMMIT;

-- 11. Lentelėje copy_employees sukurkite naują stulpelį pavadinimu Termination. Naujo stulpelio
-- duomenų tipas turi būti VARCHAR2. Šiam stulpeliui nustatykite DEFAULT SYSDATE, kad jis būtų
-- rodomas kaip simbolių duomenys tokiu formatu: 2023 m. spalio 20 d.

ALTER TABLE copy_employees
ADD termination VARCHAR2(40 CHAR)
DEFAULT TO_CHAR(SYSDATE, 'YYYY') || ' m. ' ||
        DECODE(TO_CHAR(SYSDATE, 'MM'),
               '01', 'sausio',    '02', 'vasario',  '03', 'kovo',
               '04', 'balandžio', '05', 'gegužės',  '06', 'birželio',
               '07', 'liepos',    '08', 'rugpjūčio','09', 'rugsėjo',
               '10', 'spalio',    '11', 'lapkričio','12', 'gruodžio')
        || ' ' || TO_CHAR(SYSDATE, 'FMDD') || ' d.';

SELECT employee_id, last_name, termination FROM copy_employees;

-- 12. Sukurkite naują stulpelį start_date lentelėje copy_employees. Duomenų tipą naudokite
-- TIMESTAMP WITH LOCAL TIME ZONE.

ALTER TABLE copy_employees
ADD start_date TIMESTAMP WITH LOCAL TIME ZONE;

DESC copy_employees;


-- =====================================================================
-- PASTABOS
-- =====================================================================
-- CREATE TABLE ... AS SELECT   kopijuoja stulpelius, duomenis ir NOT NULL;
--                              PK, FK, UNIQUE, CHECK, indeksų ir trigerių NEkopijuoja
-- ... WHERE 1=2 (arba 1=0)      tik struktūra, be duomenų
-- INSERT ALL + WHEN ... ELSE   eilutė eina į pirmą tinkančią šaką arba į ELSE;
--                              be ELSE King (24000) patektų ir į sal_history/mgr_history -> 41 eil.
-- INSERT FIRST                 įrašo tik į PIRMĄ tenkinamą WHEN šaką
-- TIMESTAMP WITH LOCAL TZ      saugoma DB laiko juosta, rodoma SESIJOS laiko juosta
-- INTERVAL YEAR(3) TO MONTH    '2-6' = 2 metai 6 mėn.; (3) = iki 3 skaitmenų metams
-- INTERVAL DAY(2) TO SECOND    '6 03:30:16' = 6 d. 3 h 30 min 16 s; (2) = iki 99 dienų
-- ALTER TABLE ... ADD ... DEFAULT   esamos eilutės irgi gauna DEFAULT reikšmę
-- FMDD                         FM nuima priekinį nulį (5, o ne 05)
-- DATE '2024-03-01'            datos literalas, nepriklauso nuo NLS nustatymų
