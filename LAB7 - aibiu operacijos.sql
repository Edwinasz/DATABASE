-- 1. Suraskite skyrių, kuriame nėra darbuotojų

SELECT DEPTNO
from DEPT
minus
SELECT DEPTNO from EMP;

-- 2. Suraskite pareigas, į kurias buvo skiriami darbuotojai pirmoje 1983 metų pusėje ir 1984
-- metų pusėje

SELECT JOB
from EMP
WHERE HIREDATE BETWEEN '01-JAN-81' AND '31-DEC-81'
intersect
SELECT JOB
from EMP
WHERE HIREDATE BETWEEN '01-JAN-82' AND '31-DEC-82';

-- 3. Suraskite visus darbuotojus, kurie buvo priimti į darbą anksčiau už savo viršininkus.
SELECT e.ename, e.hiredate, m.ename as manager, m.hiredate as mgr_hiredate
from EMP e JOIN EMP m
  ON e.mgr = m.empno
WHERE e.hiredate < m.hiredate;


-- =====================================================================
-- PAPILDOMI PAVYZDŽIAI: aibių operacijos
-- =====================================================================
-- MINUS      yra pirmoje, bet nėra antroje    ("skyriai be darbuotojų", "yra A, bet ne B")
-- INTERSECT  yra abiejose                     ("buvo ir 1981, ir 1982")
-- UNION      abi kartu, be dublikatų          (sujungti du sąrašus)
-- UNION ALL  abi kartu, su dublikatais (greičiau)
-- Taisyklės: abiejose užklausose tiek pat stulpelių ir tie patys tipai;
--   ORDER BY tik pačiame gale; stulpelių pavadinimai imami iš pirmosios užklausos.

-- skyriai be darbuotojų
SELECT deptno FROM dept
MINUS
SELECT deptno FROM emp;

-- su pavadinimu: MINUS kaip subužklausa
SELECT deptno, dname FROM dept
WHERE deptno IN (SELECT deptno FROM dept MINUS SELECT deptno FROM emp);

-- pareigos, į kurias skirta ir 1983 m. I pusėje, ir 1984 m. I pusėje
SELECT job FROM emp
WHERE hiredate BETWEEN DATE '1983-01-01' AND DATE '1983-06-30'
INTERSECT
SELECT job FROM emp
WHERE hiredate BETWEEN DATE '1984-01-01' AND DATE '1984-06-30';

-- pareigos, kurios yra 10-ame, bet nėra 30-ame skyriuje
SELECT job FROM emp WHERE deptno = 10
MINUS
SELECT job FROM emp WHERE deptno = 30;

-- darbuotojų numeriai, kurie kartu yra ir vadovų numeriai
SELECT empno FROM emp
INTERSECT
SELECT mgr FROM emp;

-- UNION su žyme ir rikiavimu pagal stulpelio numerį
SELECT ename, sal, 'Daug' AS grupe FROM emp WHERE sal >= 2500
UNION
SELECT ename, sal, 'Mazai' FROM emp WHERE sal < 2500
ORDER BY 2 DESC;

-- priimti anksčiau už savo viršininką (self join)
SELECT e.ename, e.hiredate, m.ename AS manager, m.hiredate AS mgr_hiredate
FROM emp e JOIN emp m ON e.mgr = m.empno
WHERE e.hiredate < m.hiredate;

-- Datų filtrai, kurie tinka visur
-- (literalas '01-JAN-81' veikia tik su angliškais NLS nustatymais, saugiau DATE 'YYYY-MM-DD'):
--   WHERE hiredate BETWEEN DATE '1981-01-01' AND DATE '1981-12-31'
--   WHERE hiredate BETWEEN TO_DATE('01.01.1981','DD.MM.YYYY') AND TO_DATE('31.12.1981','DD.MM.YYYY')
--   WHERE EXTRACT(YEAR FROM hiredate) = 1981
--   WHERE TO_CHAR(hiredate, 'YYYY') = '1981' AND TO_CHAR(hiredate, 'MM') <= '06'   -- I pusė (II: > '06')
--   WHERE TO_CHAR(hiredate, 'Q') = '1'                                            -- ketvirtis
