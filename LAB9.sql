// Sukurkite hierarchinę ataskaitą, kuri pateiktų darbuotojų numerius, viršininko numerį, pseudostulpelį LEVEL ir kiekvieno darbuotojo pavardę. Stulpeliui, kur bus pateikta darbuotojo pavardė, panaudokite tabuliaciją.

SELECT empno, mgr, LEVEL,
       LPAD(' ', 4 * (LEVEL - 1)) || ename AS name
FROM emp
CONNECT BY PRIOR mgr = empno;

// Išveskite visus tiesioginius viršininkus darbuotojui Jones.

SELECT empno, ename, mgr, LEVEL
FROM emp
WHERE LEVEL > 1
START WITH ename = 'JONES'
CONNECT BY PRIOR mgr = empno;

// Išveskite tiesioginius pavaldinius darbuotojui King.

SELECT empno, ename, mgr, LEVEL
FROM emp
WHERE LEVEL = 2
START WITH ename = 'KING'
CONNECT BY PRIOR empno = mgr;

// Išveskite tiesioginius pavaldinius darbuotojui Blake.

SELECT empno, ename, mgr, LEVEL
FROM emp
WHERE LEVEL = 2
START WITH ename = 'BLAKE'
CONNECT BY PRIOR empno = mgr;

// Išveskite pavaldumo struktūrą įmonėje pradedant nuo prezidento.

SELECT empno, mgr, LEVEL,
       LPAD(' ', 4 * (LEVEL - 1)) || ename AS name,
       job
FROM emp
START WITH job = 'PRESIDENT'
CONNECT BY PRIOR empno = mgr
ORDER SIBLINGS BY ename;


-- =====================================================================
-- PAPILDOMI PAVYZDŽIAI: hierarchinės užklausos
-- =====================================================================
-- EMP hierarchija rezultatams pasitikrinti:
--   KING (7839, PRESIDENT)
--   ├── JONES (7566)
--   │   ├── SCOTT (7788) ── ADAMS (7876)
--   │   └── FORD (7902) ── SMITH (7369)
--   ├── BLAKE (7698) ── ALLEN, WARD, MARTIN, TURNER, JAMES
--   └── CLARK (7782) ── MILLER (7934)
--
-- Kryptį nulemia PRIOR vieta:
--   PRIOR empno = mgr   eina ŽEMYN (į pavaldinius)
--   PRIOR mgr = empno   eina AUKŠTYN (į viršininkus)
-- START WITH               nuo kurios eilutės pradėti (be jo kiekviena eilutė yra pradžia)
-- LEVEL                    gylis: 1 pradinis darbuotojas, 2 tiesioginis, 3 per vieną lygį
-- WHERE                    vykdomas PO medžio sudarymo, išmeta tik tą eilutę
-- CONNECT BY ... AND sąl.  nukerta visą šaką (eilutę ir viską po ja)
-- ORDER SIBLINGS BY        rikiuoja brolių lygyje, medžio nesugriauna

-- 4a. Ataskaita su tabuliacija (aukštyn nuo kiekvieno darbuotojo)
SELECT empno, mgr, LEVEL,
       LPAD(' ', 4*(LEVEL-1)) || ename AS name
FROM emp
CONNECT BY PRIOR mgr = empno;

-- 4b. Visa struktūra nuo prezidento (žemyn)
SELECT empno, mgr, LEVEL,
       LPAD(' ', 4*(LEVEL-1)) || ename AS name, job
FROM emp
START WITH mgr IS NULL            -- arba job = 'PRESIDENT'
CONNECT BY PRIOR empno = mgr
ORDER SIBLINGS BY ename;

-- 4c. Viršininkai (aukštyn nuo X)
-- visi viršininkai iki pat viršaus (tik tiesioginis: WHERE LEVEL = 2)
SELECT empno, ename, mgr, LEVEL
FROM emp
WHERE LEVEL > 1                   -- be paties X
START WITH ename = 'SMITH'
CONNECT BY PRIOR mgr = empno;

-- grandinė viena eilute: / SMITH / FORD / JONES / KING
SELECT SYS_CONNECT_BY_PATH(ename, ' / ') AS kelias
FROM emp
WHERE mgr IS NULL
START WITH ename = 'SMITH'
CONNECT BY PRIOR mgr = empno;

-- 4d. Pavaldiniai (žemyn nuo X)
-- tik tiesioginiai
--   VISI (ir netiesioginiai): WHERE LEVEL > 1
--   tik tam tikro lygio:      WHERE LEVEL = 3
--   tik neturintys pavaldinių: WHERE CONNECT_BY_ISLEAF = 1
SELECT empno, ename, mgr, LEVEL
FROM emp
WHERE LEVEL = 2
START WITH ename = 'KING'
CONNECT BY PRIOR empno = mgr;

-- tiesioginiai be CONNECT BY (paprasta subužklausa)
SELECT ename FROM emp
WHERE mgr = (SELECT empno FROM emp WHERE ename = 'BLAKE');

-- 4e. Kitos dažnos variacijos
-- struktūra be BLAKE ir visos jo šakos
SELECT LPAD(' ', 4*(LEVEL-1)) || ename AS name
FROM emp
START WITH mgr IS NULL
CONNECT BY PRIOR empno = mgr AND ename <> 'BLAKE';

-- struktūra be BLAKE, bet su jo pavaldiniais
SELECT LPAD(' ', 4*(LEVEL-1)) || ename AS name
FROM emp
WHERE ename <> 'BLAKE'
START WITH mgr IS NULL
CONNECT BY PRIOR empno = mgr;

-- viršininko pavardė šalia darbuotojo
SELECT ename, PRIOR ename AS virsininkas, LEVEL
FROM emp
START WITH mgr IS NULL
CONNECT BY PRIOR empno = mgr;

-- pilnas kelias nuo prezidento
SELECT ename, SYS_CONNECT_BY_PATH(ename, '/') AS kelias
FROM emp
START WITH mgr IS NULL
CONNECT BY PRIOR empno = mgr;

-- medžio gylis (kiek lygių)
SELECT MAX(LEVEL) FROM emp
START WITH mgr IS NULL
CONNECT BY PRIOR empno = mgr;

-- kiek darbuotojų kiekviename lygyje
SELECT LEVEL, COUNT(*) FROM emp
START WITH mgr IS NULL
CONNECT BY PRIOR empno = mgr
GROUP BY LEVEL ORDER BY LEVEL;

-- kiek iš viso (ir netiesioginių) pavaldinių turi kiekvienas
SELECT root, COUNT(*) - 1 AS pavaldiniai
FROM (SELECT CONNECT_BY_ROOT ename AS root
      FROM emp
      CONNECT BY PRIOR empno = mgr)
GROUP BY root
ORDER BY 2 DESC;

-- X pavaldinių atlyginimų suma
SELECT SUM(sal) FROM emp
WHERE LEVEL > 1
START WITH ename = 'JONES'
CONNECT BY PRIOR empno = mgr;
