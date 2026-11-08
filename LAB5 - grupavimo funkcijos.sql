desc EMP;

// Suraskite mažiausią darbuotojų atlyginimą. 
SELECT MIN(SAL) as LowestSalary
from EMP;

// Suraskite darbuotojų didžiausią, mažiausią ir vidutinį atlyginimus. 
SELECT MIN(SAL) as Lowest_Salary, MAX(SAL) as Highest_Salary, ROUND(AVG(SAL)) as Avarage_Salary
from EMP;

// Pateikite mažiausią ir didžiausią atlyginimus kiekvienoms pareigoms.
SELECT JOB, MAX(SAL) as Highest_Salary, MIN(SAL) as Lowest_Salary
from EMP
GROUP BY JOB;

// Suraskite, kiek yra vadybininkų, neišvardinant jų. 
SELECT COUNT(*)
from EMP
WHERE JOB = 'MANAGER';

// Paskaičiuokite atlyginimų vidurkį ir visų pajamų vidurkį kiekvienoms pareigoms.
// Nepamirškite, kad pardavėjai uždirba komisinius.

SELECT JOB, ROUND(AVG(SAL)) as AVG_SALARY, ROUND(AVG(SAL + NVL(COMM, 0))) as AVG_INCOME
from EMP
GROUP BY JOB;

// Suraskite skirtumą tarp didžiausio ir mažiausio darbo užmokesčio. 

SELECT MAX(SAL)-MIN(SAL) as Diffrence_in_Salary
from EMP;

// Suraskite visus skyrius, kuriuose dirba daugiau kaip 3 darbuotojai. 
SELECT DEPTNO
from EMP
GROUP BY DEPTNO
HAVING COUNT(*) > 3;

// Patikrinkite, ar darbuotojų numeriai iš tikrųjų nepasikartoja. 
SELECT COUNT(EMPNO), COUNT(UNIQUE(EMPNO))
from EMP;

// Pateikite kiekvieno vadovo mažiausiai apmokamo darbuotojo atlyginimą. Neįtraukite tų
// grupių, kur atlyginimas yra mažesnis už 1000. Informaciją pateikite atlyginimų didėjimo
// tvarka. 

SELECT MGR, MIN(SAL)
from EMP
WHERE MGR IS NOT NULL
GROUP BY MGR
HAVING MIN(SAL) > 1000
ORDER BY MIN(SAL);

// Suraskite bendrą atlyginimą, kurį uždirba vadybininkai.

SELECT SUM(SAL)as SUM_MANAGER_SAL
from EMP
WHERE JOB = 'MANAGER';

// Išveskite kiek žmonių kokiose pareigose dirba kiekviename skyriuje.
SELECT DEPTNO, JOB, COUNT(*)
from EMP
GROUP BY DEPTNO, JOB
ORDER BY DEPTNO;



-- =====================================================================
-- ŠPARGALKĖ: grupavimo funkcijos (LAB5)
-- =====================================================================
-- COUNT(*)               visos eilutės
-- COUNT(stulp)           tik ne NULL reikšmės
-- COUNT(DISTINCT stulp)  unikalios reikšmės
-- SUM / AVG / MIN / MAX  NULL ignoruojami; AVG(NVL(comm, 0)) skaičiuoja visus
-- MAX(COUNT(*))          įdėtinė: būtinas GROUP BY, šalia negalima rodyti kitų stulpelių
--
-- Taisyklės:
--   * visi SELECT stulpeliai be agregatų turi būti GROUP BY (kitaip ORA-00979)
--   * eilučių filtras → WHERE (be agregatų); grupių filtras → HAVING (su agregatais)
--   * WHERE AVG(sal) > 2000 yra KLAIDA (ORA-00934), rašyk HAVING AVG(sal) > 2000

SELECT deptno, job, COUNT(*) AS kiek, MIN(sal), MAX(sal), ROUND(AVG(sal))
FROM emp
WHERE mgr IS NOT NULL          -- eilučių filtras
GROUP BY deptno, job           -- VISI ne agreguoti SELECT stulpeliai
HAVING COUNT(*) > 1            -- grupių filtras
ORDER BY deptno;

-- skirtumas tarp didžiausio ir mažiausio
SELECT MAX(sal) - MIN(sal) AS difference FROM emp;

-- ar reikšmės nesikartoja
SELECT COUNT(empno), COUNT(DISTINCT empno) FROM emp;

-- vidutinės pajamos su komisiniais (komisiniai gali būti NULL)
SELECT job, ROUND(AVG(sal)), ROUND(AVG(sal + NVL(comm, 0)))
FROM emp
GROUP BY job;

-- grupė su daugiausiai eilučių (įdėtinė agregatinė funkcija)
SELECT job, COUNT(*)
FROM emp
GROUP BY job
HAVING COUNT(*) = (SELECT MAX(COUNT(*)) FROM emp GROUP BY job);
