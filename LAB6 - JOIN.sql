-- 1. Išveskite darbuotojų pavardes ir skyrių, kuriuose jie dirba, pavadinimus. Informaciją
-- surūšiuokite pagal skyrių pavadinimus.

SELECT ENAME, DEPTNO, DEPARTMENT_NAME
FROM EMP NATURAL JOIN DEPARTMENTS
WHERE DEPTNO = DEPARTMENT_ID
ORDER BY DEPARTMENT_NAME;

SELECT e.ENAME, e.DEPTNO, d.DEPARTMENT_NAME
FROM EMP e, DEPARTMENTS d
WHERE e.deptno = d.department_id
order by d.department_NAME;

-- 2. Išveskite visų darbuotojų pavardes, skyrių pavadinimus ir skyrių numerius.

SELECT ENAME, DEPARTMENT_NAME, DEPTNO
FROM EMP NATURAL JOIN DEPARTMENTS
WHERE DEPTNO = DEPARTMENT_ID;



-- 3. Išveskite darbuotojų, kurių mėnesinis atlyginimas didesnis už 1500, pavardes, miestų ir
-- skyrių, kuriuose jie dirba, pavadinimus.

SELECT LAST_NAME as ENAME, CITY, DEPARTMENT_NAME
FROM EMPLOYEES JOIN DEPARTMENTS USING (DEPARTMENT_ID) JOIN LOCATIONS USING(LOCATION_ID)
WHERE SALARY > 1500;

-- 4. Patikrinkite darbuotojų sąrašą (pavardę, pareigas, atlyginimą), parodantį atlyginimų lygius(Grade).

SELECT ENAME, JOB, SAL, GRADE
FROM EMP JOIN SALGRADE
ON(SAL BETWEEN LOSAL AND HISAL);

-- 5. Išveskite tą pačią informaciją apie darbuotojus, kurių 3 atlyginimo lygis

SELECT ENAME, JOB, SAL, GRADE
FROM EMP JOIN SALGRADE
ON(SAL BETWEEN LOSAL AND HISAL)
WHERE GRADE >= 3;

SELECT CITY
from LOCATIONS;

-- 6. Išveskite informaciją apie darbuotojus, dirbančius Seattle (pavardes, atlyginimus, miestą,
-- kuriame dirba darbuotojas).
SELECT LAST_NAME, SALARY, CITY
FROM EMPLOYEES JOIN DEPARTMENTS USING (DEPARTMENT_ID) JOIN LOCATIONS USING(LOCATION_ID)
WHERE CITY = 'Seattle';

-- 7. Išvardinkite skyrius, kuriuose nedirba nei vienas darbuotojas.

SELECT d.DEPTNO, d.DNAME
FROM DEPT d
WHERE NOT EXISTS (SELECT 1 FROM EMP WHERE DEPTNO = d.DEPTNO);


-- =====================================================================
-- PAPILDOMI PAVYZDŽIAI: JOIN – lentelių jungimas
-- =====================================================================
-- Lentelės ir ryšiai
--   EMP (empno, ename, job, mgr, hiredate, sal, comm, deptno)
--       deptno → DEPT.deptno;  mgr → EMP.empno (self join)
--   DEPT (deptno, dname, loc)       10 ACCOUNTING, 20 RESEARCH, 30 SALES, 40 OPERATIONS (be darbuotojų)
--   SALGRADE (grade, losal, hisal)  sal BETWEEN losal AND hisal
--   HR: EMPLOYEES (employee_id, last_name, salary, department_id, manager_id, ...)
--       → DEPARTMENTS (department_id, department_name, location_id)
--       → LOCATIONS (location_id, city, street_address, ...)
-- Jei užduotyje reikia stulpelių iš kelių lentelių (pavardė + skyriaus pavadinimas,
-- miestas, GRADE), reikia JOIN.

-- 1a. Paprastas sujungimas: keturi užrašymo būdai, rezultatas vienodas
-- ON (universaliausias)
SELECT e.ename, d.dname, e.deptno
FROM emp e JOIN dept d ON e.deptno = d.deptno
ORDER BY d.dname;

-- USING (kai stulpelio pavadinimas vienodas; prie jo NERAŠYK aliaso, kitaip ORA-25154)
SELECT ename, dname, deptno
FROM emp JOIN dept USING (deptno);

-- senas būdas per WHERE
SELECT e.ename, d.dname
FROM emp e, dept d
WHERE e.deptno = d.deptno;

-- NATURAL JOIN jungia pagal VISUS vienodai vadinamus stulpelius
-- (jei tokių nėra, pvz. EMP ir DEPARTMENTS, gaunama Dekarto sandauga)
SELECT ename, dname FROM emp NATURAL JOIN dept;

-- 1b. Trys lentelės (HR): darbuotojas → skyrius → miestas
SELECT e.last_name, d.department_name, l.city
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN locations   l ON d.location_id   = l.location_id
WHERE e.salary > 1500;          -- arba: WHERE l.city = 'Seattle'

-- tas pats su USING
SELECT last_name, department_name, city
FROM employees JOIN departments USING (department_id)
               JOIN locations   USING (location_id);

-- 1c. Non-equi join: atlyginimo lygis (SALGRADE)
SELECT e.ename, e.job, e.sal, s.grade
FROM emp e JOIN salgrade s ON e.sal BETWEEN s.losal AND s.hisal
WHERE s.grade = 3;              -- "3 lygis" yra = 3, ne >= 3

-- 1d. OUTER JOIN: kai reikia ir eilučių be poros
-- visi skyriai, net ir be darbuotojų (40 OPERATIONS)
SELECT d.deptno, d.dname, e.ename
FROM dept d LEFT JOIN emp e ON e.deptno = d.deptno;

-- senas Oracle būdas: (+) dedamas toje pusėje, kurioje GALI trūkti
SELECT d.deptno, d.dname, e.ename
FROM dept d, emp e
WHERE e.deptno(+) = d.deptno;

-- tik skyriai BE darbuotojų (anti-join)
SELECT d.deptno, d.dname
FROM dept d LEFT JOIN emp e ON e.deptno = d.deptno
WHERE e.empno IS NULL;

-- RIGHT JOIN veikia veidrodiškai, FULL JOIN grąžina abi puses
-- "visi darbuotojai" su paprastu JOIN: darbuotojai be skyriaus dingsta → reikia LEFT JOIN

-- 1e. Self join: EMP sujungiama su pačia savimi (darbuotojas ir viršininkas)
-- darbuotojas + viršininko pavardė (LEFT, kad būtų ir KING)
SELECT e.ename AS darbuotojas, m.ename AS virsininkas
FROM emp e LEFT JOIN emp m ON e.mgr = m.empno;

-- uždirba daugiau už savo viršininką
SELECT e.ename, e.sal, m.ename AS manager, m.sal AS mgr_sal
FROM emp e JOIN emp m ON e.mgr = m.empno
WHERE e.sal > m.sal;

-- kiek tiesioginių pavaldinių turi kiekvienas vadovas
SELECT m.ename, COUNT(*) AS pavaldiniai
FROM emp e JOIN emp m ON e.mgr = m.empno
GROUP BY m.ename;

-- 1f. JOIN + GROUP BY (statistika pagal skyriaus pavadinimą ar miestą)
-- COUNT(e.empno), ne COUNT(*), kad tuščias skyrius gautų 0
SELECT d.dname, COUNT(e.empno) AS kiekis, ROUND(AVG(e.sal), 2) AS vid_sal
FROM dept d LEFT JOIN emp e ON e.deptno = d.deptno
GROUP BY d.dname
ORDER BY d.dname;


-- =====================================================================
-- PAPILDOMI PAVYZDŽIAI SU SUSPECTS / CRIMES LENTELĖMIS
-- =====================================================================
-- SUSPECTS (suspect_id, name, sex, age, height, hair_color, eye_color,
--           facial_hair, tattoos, glasses, scars, feet_size)
-- CRIMES   (crime_id, suspect_id, crime_type, committed_date, prison,
--           start_date, end_date, behavior)
-- Jungiama per suspect_id. Reikšmės: 'Yes' / 'No', 'Male' / 'Female',
-- akių spalva 'Blue', 'Green'... (ne didžiosiomis), behavior 'GOOD' / 'BAD' / NULL.
-- Bausmės trukmė dienomis: end_date - start_date

-- 1. Išveskite įtariamųjų su tatuiruotėmis vardus, nusikaltimų tipus ir įvykdymo datas
-- nusikaltimams, įvykdytiems 2023 metais.
SELECT s.name, c.crime_type, c.committed_date
FROM suspects s JOIN crimes c ON s.suspect_id = c.suspect_id
WHERE s.tattoos = 'Yes'
  AND EXTRACT(YEAR FROM c.committed_date) = 2023;

-- 2. Kiekvienam įtariamajam išveskite vardą ir nusikaltimų skaičių.
-- Įtariamieji be nusikaltimų turi būti sąraše su 0 (todėl LEFT JOIN ir COUNT(c.crime_id)).
SELECT s.name, COUNT(c.crime_id) AS kiekis
FROM suspects s LEFT JOIN crimes c ON s.suspect_id = c.suspect_id
GROUP BY s.suspect_id, s.name;

-- 3. Išveskite skirtingus įtariamuosius (vardas, amžius), kurie atliko bausmę 'Hill Prison'.
-- USING / NATURAL JOIN tinka, nes vienintelis bendras stulpelis yra suspect_id.
SELECT DISTINCT name, age
FROM suspects JOIN crimes USING (suspect_id)
WHERE prison = 'Hill Prison';

SELECT DISTINCT name, age
FROM suspects NATURAL JOIN crimes
WHERE prison = 'Hill Prison';
