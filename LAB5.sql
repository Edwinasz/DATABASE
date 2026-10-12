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

