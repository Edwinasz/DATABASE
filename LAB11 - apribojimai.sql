-- 1. Patikrinkite šių lentelių turimus apribojimus:
-- REGIONS, COUNTRIES, LOCATIONS, DEPARTMENTS, JOBS, EMPLOYEES, JOB_GRADES, JOB_HISTORY

SELECT table_name,
       constraint_name,
       constraint_type,
       search_condition,
       r_constraint_name,
       status
FROM user_constraints
WHERE table_name IN ('REGIONS','COUNTRIES','LOCATIONS','DEPARTMENTS',
                     'JOBS','EMPLOYEES','JOB_GRADES','JOB_HISTORY')
ORDER BY table_name, constraint_type;

-- su stulpeliais, kuriems taikomas apribojimas
SELECT c.table_name,
       c.constraint_name,
       c.constraint_type,
       cc.column_name,
       c.status
FROM user_constraints c
JOIN user_cons_columns cc ON c.constraint_name = cc.constraint_name
WHERE c.table_name IN ('REGIONS','COUNTRIES','LOCATIONS','DEPARTMENTS',
                       'JOBS','EMPLOYEES','JOB_GRADES','JOB_HISTORY')
ORDER BY c.table_name, c.constraint_type, cc.position;

-- 2. Sukurkite visus nustatytus apribojimus savo sukurtose lentelių kopijose.
-- (NOT NULL jau perkelti per CREATE TABLE ... AS; pirmiau PK, tada UNIQUE/CHECK, tada FK)

-- PRIMARY KEY
ALTER TABLE copy_regions     ADD CONSTRAINT copy_reg_id_pk         PRIMARY KEY (region_id);
ALTER TABLE copy_countries   ADD CONSTRAINT copy_country_c_id_pk   PRIMARY KEY (country_id);
ALTER TABLE copy_locations   ADD CONSTRAINT copy_loc_id_pk         PRIMARY KEY (location_id);
ALTER TABLE copy_departments ADD CONSTRAINT copy_dept_id_pk        PRIMARY KEY (department_id);
ALTER TABLE copy_jobs        ADD CONSTRAINT copy_job_id_pk         PRIMARY KEY (job_id);
ALTER TABLE copy_employees   ADD CONSTRAINT copy_emp_emp_id_pk     PRIMARY KEY (employee_id);
ALTER TABLE copy_job_history ADD CONSTRAINT copy_jhist_emp_st_pk   PRIMARY KEY (employee_id, start_date);

-- UNIQUE ir CHECK
ALTER TABLE copy_employees   ADD CONSTRAINT copy_emp_email_uk      UNIQUE (email);
ALTER TABLE copy_employees   ADD CONSTRAINT copy_emp_salary_min    CHECK (salary > 0);
ALTER TABLE copy_job_history ADD CONSTRAINT copy_jhist_date_int    CHECK (end_date > start_date);

-- FOREIGN KEY
ALTER TABLE copy_countries   ADD CONSTRAINT copy_countr_reg_fk
      FOREIGN KEY (region_id)     REFERENCES copy_regions (region_id);

ALTER TABLE copy_locations   ADD CONSTRAINT copy_loc_c_id_fk
      FOREIGN KEY (country_id)    REFERENCES copy_countries (country_id);

ALTER TABLE copy_departments ADD CONSTRAINT copy_dept_loc_fk
      FOREIGN KEY (location_id)   REFERENCES copy_locations (location_id);

ALTER TABLE copy_employees   ADD CONSTRAINT copy_emp_dept_fk
      FOREIGN KEY (department_id) REFERENCES copy_departments (department_id);

ALTER TABLE copy_employees   ADD CONSTRAINT copy_emp_job_fk
      FOREIGN KEY (job_id)        REFERENCES copy_jobs (job_id);

ALTER TABLE copy_employees   ADD CONSTRAINT copy_emp_manager_fk
      FOREIGN KEY (manager_id)    REFERENCES copy_employees (employee_id);

ALTER TABLE copy_departments ADD CONSTRAINT copy_dept_mgr_fk
      FOREIGN KEY (manager_id)    REFERENCES copy_employees (employee_id);

ALTER TABLE copy_job_history ADD CONSTRAINT copy_jhist_job_fk
      FOREIGN KEY (job_id)        REFERENCES copy_jobs (job_id);

ALTER TABLE copy_job_history ADD CONSTRAINT copy_jhist_dept_fk
      FOREIGN KEY (department_id) REFERENCES copy_departments (department_id);

-- originale JHIST_EMP_FK yra DISABLED (job_history turi darbuotojus 114 ir 122,
-- kurių employees lentelėje nebėra), todėl ir kopijoje DISABLE
ALTER TABLE copy_job_history ADD CONSTRAINT copy_jhist_emp_fk
      FOREIGN KEY (employee_id)   REFERENCES copy_employees (employee_id) DISABLE;

-- patikrinimas
SELECT table_name, constraint_name, constraint_type, status
FROM user_constraints
WHERE table_name LIKE 'COPY%' AND constraint_type <> 'C'
ORDER BY table_name, constraint_type;


-- =====================================================================
-- PASTABOS
-- =====================================================================
-- CONSTRAINT_TYPE:  P = PRIMARY KEY, R = FOREIGN KEY, U = UNIQUE, C = CHECK / NOT NULL
-- Apribojimų vardai unikalūs visoje schemoje, todėl kopijoms priešdėlis COPY_
-- FK gali rodyti tik į PK arba UNIQUE, todėl PK kuriami pirmiausia
-- JOB_GRADES apribojimų neturi (nei originalas, nei kopija)
--
-- Dažnos klaidos:
-- ORA-02298 parent keys not found   vaikinėje lentelėje yra reikšmė, kurios nėra tėvinėje;
--                                   rasti: SELECT DISTINCT job_id FROM copy_employees
--                                          WHERE job_id NOT IN (SELECT job_id FROM copy_jobs);
-- ORA-02437 / ORA-00001             PK/UNIQUE stulpelyje yra pasikartojančių reikšmių
-- ORA-02264 name already used       toks apribojimo vardas jau yra
--
-- Įjungti / išjungti:
-- ALTER TABLE copy_job_history DISABLE CONSTRAINT copy_jhist_emp_fk;
-- ALTER TABLE copy_job_history ENABLE NOVALIDATE CONSTRAINT copy_jhist_emp_fk;  -- tikrina tik naujas eil.
-- ALTER TABLE copy_regions DROP CONSTRAINT copy_reg_id_pk CASCADE;              -- kartu ir priklausomus FK
