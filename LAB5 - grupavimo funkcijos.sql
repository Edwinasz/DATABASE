desc EMP;

-- 1. Suraskite mažiausią darbuotojų atlyginimą.
SELECT MIN(SAL) as LowestSalary
from EMP;

-- 2. Suraskite darbuotojų didžiausią, mažiausią ir vidutinį atlyginimus.
SELECT MIN(SAL) as Lowest_Salary, MAX(SAL) as Highest_Salary, ROUND(AVG(SAL)) as Avarage_Salary
from EMP;

-- 3. Pateikite mažiausią ir didžiausią atlyginimus kiekvienoms pareigoms.
SELECT JOB, MAX(SAL) as Highest_Salary, MIN(SAL) as Lowest_Salary
from EMP
GROUP BY JOB;

-- 4. Suraskite, kiek yra vadybininkų, neišvardinant jų.
SELECT COUNT(*)
from EMP
WHERE JOB = 'MANAGER';

-- 5. Paskaičiuokite atlyginimų vidurkį ir visų pajamų vidurkį kiekvienoms pareigoms.
-- Nepamirškite, kad pardavėjai uždirba komisinius.

SELECT JOB, ROUND(AVG(SAL)) as AVG_SALARY, ROUND(AVG(SAL + NVL(COMM, 0))) as AVG_INCOME
from EMP
GROUP BY JOB;

-- 6. Suraskite skirtumą tarp didžiausio ir mažiausio darbo užmokesčio.

SELECT MAX(SAL)-MIN(SAL) as Diffrence_in_Salary
from EMP;

-- 7. Suraskite visus skyrius, kuriuose dirba daugiau kaip 3 darbuotojai.
SELECT DEPTNO
from EMP
GROUP BY DEPTNO
HAVING COUNT(*) > 3;

-- 8. Patikrinkite, ar darbuotojų numeriai iš tikrųjų nepasikartoja.
SELECT COUNT(EMPNO), COUNT(UNIQUE(EMPNO))
from EMP;

-- 9. Pateikite kiekvieno vadovo mažiausiai apmokamo darbuotojo atlyginimą. Neįtraukite tų
-- grupių, kur atlyginimas yra mažesnis už 1000. Informaciją pateikite atlyginimų didėjimo
-- tvarka.

SELECT MGR, MIN(SAL)
from EMP
WHERE MGR IS NOT NULL
GROUP BY MGR
HAVING MIN(SAL) > 1000
ORDER BY MIN(SAL);

-- 10. Suraskite bendrą atlyginimą, kurį uždirba vadybininkai.

SELECT SUM(SAL)as SUM_MANAGER_SAL
from EMP
WHERE JOB = 'MANAGER';

-- 11. Išveskite kiek žmonių kokiose pareigose dirba kiekviename skyriuje.
SELECT DEPTNO, JOB, COUNT(*)
from EMP
GROUP BY DEPTNO, JOB
ORDER BY DEPTNO;



-- =====================================================================
-- PAPILDOMI PAVYZDŽIAI: grupavimo funkcijos
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

-- 1. Kiek kartų buvo įvykdytas kiekvienas nusikaltimo tipas? Rodykite tik tipus,
-- kurie kartojasi bent 9 kartus.
SELECT crime_type, COUNT(*) AS kiekis
FROM crimes
GROUP BY crime_type
HAVING COUNT(*) >= 9;

-- 2. Kiekvienai lyčiai išveskite įtariamųjų skaičių, jauniausio ir vyriausio amžių
-- bei vidutinį amžių, suapvalintą iki 1 skaitmens.
SELECT sex, COUNT(*), MIN(age), MAX(age), ROUND(AVG(age), 1)
FROM suspects
GROUP BY sex;

-- 3. Kiekvienam kalėjimui išveskite vidutinę bausmės trukmę dienomis (sveikas skaičius).
-- Nusikaltimų be bausmės neįtraukite.
SELECT prison, ROUND(AVG(end_date - start_date)) AS vid_dienos
FROM crimes
WHERE prison IS NOT NULL
GROUP BY prison;

-- 4. Kiek nusikaltimų turi kiekvieno elgesio įvertinimą (NULL rodykite kaip 'Nenurodytas')?
SELECT NVL(behavior, 'Nenurodytas') AS elgesys, COUNT(*) AS kiekis
FROM crimes
GROUP BY NVL(behavior, 'Nenurodytas');

-- 5. Kiekvienais metais įvykdytų nusikaltimų skaičius, surikiuotas pagal metus.
SELECT EXTRACT(YEAR FROM committed_date) AS metai, COUNT(*) AS kiekis
FROM crimes
GROUP BY EXTRACT(YEAR FROM committed_date)
ORDER BY metai;
