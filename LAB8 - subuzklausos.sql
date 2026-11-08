// Suraskite darbuotojus, gaunančius daugiausiai pagal savo pareigas. Duomenis surūšiuokite atlyginimo mažėjimo tvarka

SELECT e.ename, e.job, e.sal
FROM EMP e
WHERE e.sal = (SELECT MAX(sal) FROM EMP WHERE job = e.job)
ORDER BY e.sal DESC;

//  Suraskite visus darbuotojus, gaunančius mažiausiai pagal savo pareigas. Duomenis surūšiuokite atlyginimo didėjimo tvarka.

SELECT e.ename, e. job, e.sal
from EMP e
WHERE e.sal = (SELECT min(sal) from EMP WHERE job = e.job)
ORDER BY e.sal;

// Nustatykite kas iš darbuotojų kiekviename skyriuje buvo priimtas į darbą paskutinis

SELECT ENAME, DEPTNO, HIREDATE
from EMP
WHERE (DEPTNO, HIREDATE) 
IN
(SELECT DEPTNO, max(HIREDATE)
from EMP
group by DEPTNO);

// Išveskite informaciją apie darbuotojus, gaunančius daugiau negu vidutinį atlyginimą jų
//skyriuje. Rezultatus surūšiuokite pagal skyrių numerius.

SELECT e.DEPTNO, e.ENAME, e.SAL
FROM EMP e
WHERE SAL > (SELECT ROUND(AVG(SAL), 2) from EMP WHERE DEPTNO = e.DEPTNO)
order by e.DEPTNO;

// Suraskite visus skyrius, neturinčius darbuotojus (turite panaudoti subužklausas).

SELECT deptno, dname
from dept d
WHERE not exists
(SELECT * from emp
where deptno=d.deptno);

// Gaukite pavaizduotus duomenis skyriui, kuriame visų darbuotojų suminės metinės pajamos maksimalios.

def ysal = 'sal * 12 + NVL(comm, 0)'
SELECT deptno, SUM(&ysal) compensation
from EMP
GROUP BY DEPTNO
having sum(&ysal) = (select max(sum(&ysal)) from emp group by deptno);

// Kas įeina į trejetuką labiausiai apmokamų darbuotojų sąrašą? Suraskite jų vardus ir atlyginimus.

SELECT ename, sal
FROM (SELECT ename, sal
      FROM EMP
      ORDER BY sal DESC)
WHERE ROWNUM <= 3;
    
-- where 3 > (SELECT count(*) from emp where e.sal < sal)

// Kokiais metais įmonė priėmė daugiausiai žmonių. Išveskite metus ir įdarbintų žmonių kiekį.

SELECT extract(year from hiredate) metai, count(empno) kiekis
from emp
group by extract(year from hiredate)
having count(empno) = (select max(count(empno)) from emp group by extract(year from hiredate));

// Modifikuokite 4 užduoties komandą taip, kad būtų papildomai išvestas vidutinis atlyginimas kiekviename skyriuje.

SELECT e.DEPTNO, e.ENAME, e.SAL, d.AVG_SAL
FROM EMP e
JOIN (SELECT DEPTNO, ROUND(AVG(SAL), 2) AS AVG_SAL
      FROM EMP
      GROUP BY DEPTNO) d ON d.DEPTNO = e.DEPTNO
WHERE e.SAL > d.AVG_SAL
ORDER BY e.DEPTNO;

//  Pateikite užklausą, kurioje būtų spausdinamas simbolis žvaigždutė (*) priešais darbuotojo
// pavardę, kuris buvo priimtas į darbą paskutinis. Rezultate informacija turi būti pateikta
// stulpeliuose ENAME, HIREDATE ir MAXDATE (jame turi būti žvaigždutė).

SELECT e.ENAME, e.HIREDATE,
       CASE 
            WHEN e.HIREDATE = (SELECT MAX(HIREDATE) FROM EMP) THEN '*'
       END AS MAXDATE
FROM EMP e
ORDER BY e.HIREDATE;


-- =====================================================================
-- ŠPARGALKĖ: subužklausos (LAB8)
-- =====================================================================
-- Jei vertinimo kriterijų pirma reikia apskaičiuoti (MAX, AVG, "paskutinis",
-- "daugiausiai"), reikia subužklausos.
--   Vienos reikšmės  = > < >= <=     sal > (SELECT AVG(sal) FROM emp)
--   Kelių reikšmių   IN, ANY, ALL    sal > ALL (SELECT sal FROM emp WHERE deptno = 30)
--   Porų             (a, b) IN       (deptno, hiredate) IN (SELECT deptno, MAX(hiredate) ...)
--   Koreliuota       išorės aliasas  WHERE job = e.job
--   Egzistavimo      EXISTS / NOT EXISTS
--   Inline view      FROM (SELECT ...)   top-N, vidurkis šalia eilutės
-- Jei subužklausa su = grąžina kelias eilutes → ORA-01427; naudok IN / ANY / ALL arba MAX/MIN.

-- 3a. Daugiausiai / mažiausiai pagal grupę (pareigas, skyrių)
-- koreliuota (MIN mažiausiam)
SELECT e.ename, e.job, e.sal
FROM emp e
WHERE e.sal = (SELECT MAX(sal) FROM emp WHERE job = e.job)
ORDER BY e.sal DESC;

-- poromis (veikia ir su MIN, MAX(hiredate) ir pan.)
SELECT ename, job, sal
FROM emp
WHERE (job, sal) IN (SELECT job, MAX(sal) FROM emp GROUP BY job);

-- paskutinis priimtas kiekviename skyriuje
SELECT ename, deptno, hiredate
FROM emp
WHERE (deptno, hiredate) IN (SELECT deptno, MAX(hiredate) FROM emp GROUP BY deptno);

-- 3b. Daugiau už vidurkį (bendrą arba savo skyriaus)
-- už bendrą vidurkį
SELECT ename, sal FROM emp
WHERE sal > (SELECT AVG(sal) FROM emp);

-- už savo skyriaus vidurkį (koreliuota)
SELECT e.deptno, e.ename, e.sal
FROM emp e
WHERE e.sal > (SELECT AVG(sal) FROM emp WHERE deptno = e.deptno)
ORDER BY e.deptno;

-- tas pats + vidurkio stulpelis (inline view)
SELECT e.deptno, e.ename, e.sal, d.avg_sal
FROM emp e
JOIN (SELECT deptno, ROUND(AVG(sal), 2) AS avg_sal
      FROM emp GROUP BY deptno) d ON d.deptno = e.deptno
WHERE e.sal > d.avg_sal
ORDER BY e.deptno;

-- skaliarinė subužklausa SELECT'e
SELECT e.ename, e.sal,
       (SELECT ROUND(AVG(sal)) FROM emp WHERE deptno = e.deptno) AS skyr_vid
FROM emp e;

-- 3c. EXISTS / NOT EXISTS / NOT IN
-- skyriai be darbuotojų
SELECT deptno, dname FROM dept d
WHERE NOT EXISTS (SELECT 1 FROM emp WHERE deptno = d.deptno);

SELECT deptno, dname FROM dept
WHERE deptno NOT IN (SELECT deptno FROM emp WHERE deptno IS NOT NULL);

-- darbuotojai, kurie yra kieno nors vadovai
SELECT ename FROM emp e
WHERE EXISTS (SELECT 1 FROM emp WHERE mgr = e.empno);

-- darbuotojai, kurie NIEKAM nevadovauja
-- (be "WHERE mgr IS NOT NULL" NOT IN grąžintų 0 eilučių, nes sąraše yra NULL)
SELECT ename FROM emp
WHERE empno NOT IN (SELECT mgr FROM emp WHERE mgr IS NOT NULL);

-- daugiau už VISUS 30 skyriaus (ALL) / bent už vieną (ANY)
SELECT ename, sal FROM emp
WHERE sal > ALL (SELECT sal FROM emp WHERE deptno = 30);

-- 3d. Grupė su didžiausia suma ar kiekiu: MAX(SUM(...)) / MAX(COUNT(...))
-- skyrius, kurio metinės pajamos didžiausios
SELECT deptno, SUM(sal*12 + NVL(comm,0)) AS compensation
FROM emp
GROUP BY deptno
HAVING SUM(sal*12 + NVL(comm,0)) =
       (SELECT MAX(SUM(sal*12 + NVL(comm,0))) FROM emp GROUP BY deptno);

-- metai, kuriais priimta daugiausiai žmonių
SELECT EXTRACT(YEAR FROM hiredate) AS metai, COUNT(*) AS kiekis
FROM emp
GROUP BY EXTRACT(YEAR FROM hiredate)
HAVING COUNT(*) = (SELECT MAX(COUNT(*)) FROM emp GROUP BY EXTRACT(YEAR FROM hiredate));

-- 3e. TOP-N (trys daugiausiai uždirbantys ir pan.)
-- ROWNUM + inline view (rikiuoti BŪTINA viduje; ROWNUM priskiriamas prieš ORDER BY)
SELECT ename, sal
FROM (SELECT ename, sal FROM emp ORDER BY sal DESC)
WHERE ROWNUM <= 3;
-- ROWNUM = 2 arba ROWNUM > 1 niekada nepasitaiko → naudok DENSE_RANK()

-- Oracle 12c+ (WITH TIES vietoj ONLY, jei reikia ir lygių algų)
SELECT ename, sal FROM emp ORDER BY sal DESC
FETCH FIRST 3 ROWS ONLY;

-- koreliuota, įtraukia lygias algas
SELECT ename, sal FROM emp e
WHERE 3 > (SELECT COUNT(*) FROM emp WHERE sal > e.sal)
ORDER BY sal DESC;

-- analitinė funkcija (TOP-N kiekvienai grupei per PARTITION BY)
SELECT * FROM (
  SELECT ename, job, sal,
         DENSE_RANK() OVER (PARTITION BY job ORDER BY sal DESC) AS r
  FROM emp)
WHERE r <= 2;

-- antras pagal dydį atlyginimas
SELECT MAX(sal) FROM emp WHERE sal < (SELECT MAX(sal) FROM emp);

-- 3f. Žymė prie eilutės (žvaigždutė paskutiniam priimtam)
-- variantai: MIN(hiredate) pirmam priimtam; sal = (SELECT MAX(sal) ...) didžiausiai algai
SELECT ename, hiredate,
       CASE WHEN hiredate = (SELECT MAX(hiredate) FROM emp) THEN '*' END AS maxdate
FROM emp
ORDER BY hiredate;

-- 3g. WITH: pavadinta subužklausa, kai ta pati naudojama kelis kartus
WITH skyr AS (
  SELECT deptno, SUM(sal) AS suma FROM emp GROUP BY deptno
)
SELECT * FROM skyr
WHERE suma = (SELECT MAX(suma) FROM skyr);
