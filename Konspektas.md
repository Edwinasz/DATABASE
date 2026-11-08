# SQL (LAB6–9)

**Turinys:** [0. Lentelės](#0-lentelės-ir-ryšiai) · [1. JOIN](#1-join--lentelių-jungimas-lab6) · [2. Aibių operacijos](#2-aibių-operacijos-lab7) · [3. Subužklausos](#3-subužklausos-lab8) · [4. Hierarchinės](#4-hierarchinės-užklausos-lab9) · [5. Funkcijos](#5-funkcijų-žinynas-lab15) · [6. Dažnos klaidos](#6-dažnos-klaidos-ir-spąstai)

---

## 0. Lentelės ir ryšiai

| Lentelė | Stulpeliai | Jungiama per |
| --- | --- | --- |
| EMP | EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO | DEPTNO → DEPT; MGR → EMP.EMPNO |
| DEPT | DEPTNO, DNAME, LOC | DEPTNO |
| SALGRADE | GRADE, LOSAL, HISAL | SAL BETWEEN LOSAL AND HISAL |
| EMPLOYEES (HR) | EMPLOYEE_ID, FIRST_NAME, LAST_NAME, JOB_ID, SALARY, COMMISSION_PCT, MANAGER_ID, DEPARTMENT_ID, HIRE_DATE | DEPARTMENT_ID → DEPARTMENTS |
| DEPARTMENTS (HR) | DEPARTMENT_ID, DEPARTMENT_NAME, MANAGER_ID, LOCATION_ID | LOCATION_ID → LOCATIONS |
| LOCATIONS (HR) | LOCATION_ID, STREET_ADDRESS, CITY, STATE_PROVINCE, COUNTRY_ID | — |

EMP hierarchija rezultatams pasitikrinti:

```text
KING (7839, PRESIDENT)
├── JONES (7566)
│   ├── SCOTT (7788) ── ADAMS (7876)
│   └── FORD (7902) ── SMITH (7369)
├── BLAKE (7698) ── ALLEN, WARD, MARTIN, TURNER, JAMES
└── CLARK (7782) ── MILLER (7934)
```

Skyriai: 10 ACCOUNTING, 20 RESEARCH, 30 SALES, 40 OPERATIONS (40-ame nėra darbuotojų). EMP duomenys saugomi didžiosiomis raidėmis: `'JONES'`, `'SALESMAN'`.

---

## 1. JOIN – lentelių jungimas (LAB6)

Jei užduotyje reikia stulpelių iš kelių lentelių (pavardė ir skyriaus pavadinimas, miestas, GRADE), reikia JOIN.

### 1a. Paprastas sujungimas: keturi užrašymo būdai

```sql
-- ON (universaliausias)
SELECT e.ename, d.dname, e.deptno
FROM emp e JOIN dept d ON e.deptno = d.deptno
ORDER BY d.dname;

-- USING (kai stulpelio pavadinimas vienodas; prie jo NERAŠYK aliaso)
SELECT ename, dname, deptno
FROM emp JOIN dept USING (deptno);

-- Senas būdas per WHERE
SELECT e.ename, d.dname
FROM emp e, dept d
WHERE e.deptno = d.deptno;

-- NATURAL JOIN jungia pagal VISUS vienodai vadinamus stulpelius
SELECT ename, dname FROM emp NATURAL JOIN dept;
```

### 1b. Trys lentelės (HR): darbuotojas → skyrius → miestas

```sql
SELECT e.last_name, d.department_name, l.city
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN locations   l ON d.location_id   = l.location_id
WHERE e.salary > 1500;          -- arba: WHERE l.city = 'Seattle'

-- tas pats su USING
SELECT last_name, department_name, city
FROM employees JOIN departments USING (department_id)
               JOIN locations   USING (location_id);
```

### 1c. Non-equi join: atlyginimo lygis (SALGRADE)

```sql
SELECT e.ename, e.job, e.sal, s.grade
FROM emp e JOIN salgrade s ON e.sal BETWEEN s.losal AND s.hisal
WHERE s.grade = 3;              -- "3 lygis" yra = 3, ne >= 3
```

### 1d. OUTER JOIN: kai reikia ir eilučių be poros

```sql
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
```

### 1e. Self join: EMP sujungiama su pačia savimi (darbuotojas ir viršininkas)

```sql
-- darbuotojas + viršininko pavardė (LEFT, kad būtų ir KING)
SELECT e.ename AS darbuotojas, m.ename AS virsininkas
FROM emp e LEFT JOIN emp m ON e.mgr = m.empno;

-- priimti anksčiau už savo viršininką (LAB7)
SELECT e.ename, e.hiredate, m.ename AS manager, m.hiredate AS mgr_hiredate
FROM emp e JOIN emp m ON e.mgr = m.empno
WHERE e.hiredate < m.hiredate;

-- uždirba daugiau už savo viršininką
SELECT e.ename, e.sal, m.ename AS manager, m.sal AS mgr_sal
FROM emp e JOIN emp m ON e.mgr = m.empno
WHERE e.sal > m.sal;

-- kiek tiesioginių pavaldinių turi kiekvienas vadovas
SELECT m.ename, COUNT(*) AS pavaldiniai
FROM emp e JOIN emp m ON e.mgr = m.empno
GROUP BY m.ename;
```

### 1f. JOIN + GROUP BY (statistika pagal skyriaus pavadinimą ar miestą)

```sql
SELECT d.dname, COUNT(e.empno) AS kiekis, ROUND(AVG(e.sal), 2) AS vid_sal
FROM dept d LEFT JOIN emp e ON e.deptno = d.deptno
GROUP BY d.dname
ORDER BY d.dname;       -- COUNT(e.empno), ne COUNT(*), kad tuščias skyrius gautų 0
```

---

## 2. Aibių operacijos (LAB7)

Abiejose užklausose turi būti tiek pat stulpelių, o jų tipai turi sutapti. ORDER BY rašomas tik pačiame gale. Stulpelių pavadinimai imami iš pirmosios užklausos.

| Operatorius | Ką grąžina | Kada naudoti |
| --- | --- | --- |
| `MINUS` | yra pirmoje, bet nėra antroje | „skyriai be darbuotojų“, „yra A, bet ne B“ |
| `INTERSECT` | yra abiejose | „buvo ir 1981, ir 1982“ |
| `UNION` | abi kartu, be dublikatų | sujungti du sąrašus |
| `UNION ALL` | abi kartu, su dublikatais (greičiau) | kai dublikatai reikalingi ar neįmanomi |

```sql
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

-- UNION su žyme ir rikiavimu pagal poziciją
SELECT ename, sal, 'Daug' AS grupe FROM emp WHERE sal >= 2500
UNION
SELECT ename, sal, 'Mazai' FROM emp WHERE sal < 2500
ORDER BY 2 DESC;
```

Datų filtrai, kurie tinka visur:

```sql
WHERE hiredate BETWEEN DATE '1981-01-01' AND DATE '1981-12-31'   -- ISO literalas, nepriklauso nuo NLS
WHERE hiredate BETWEEN TO_DATE('01.01.1981','DD.MM.YYYY') AND TO_DATE('31.12.1981','DD.MM.YYYY')
WHERE EXTRACT(YEAR FROM hiredate) = 1981
WHERE TO_CHAR(hiredate, 'YYYY') = '1981' AND TO_CHAR(hiredate, 'MM') <= '06'   -- I pusė (II: > '06')
WHERE TO_CHAR(hiredate, 'Q') = '1'                                -- ketvirtis
```

> Literalas `'01-JAN-81'` veikia tik su angliškais NLS nustatymais, todėl saugiau rašyti `DATE 'YYYY-MM-DD'`.

---

## 3. Subužklausos (LAB8)

Jei vertinimo kriterijų pirma reikia apskaičiuoti (MAX, AVG, „paskutinis“, „daugiausiai“), reikia subužklausos.

| Tipas | Operatorius | Pavyzdys |
| --- | --- | --- |
| Vienos reikšmės | `= > < >= <=` | `sal > (SELECT AVG(sal) FROM emp)` |
| Kelių reikšmių | `IN`, `ANY`, `ALL` | `sal > ALL (SELECT sal FROM emp WHERE deptno = 30)` |
| Porų (keli stulpeliai) | `(a, b) IN` | `(deptno, hiredate) IN (SELECT deptno, MAX(hiredate) ...)` |
| Koreliuota | naudoja išorės aliasą | `WHERE job = e.job` |
| Egzistavimo | `EXISTS` / `NOT EXISTS` | skyriai be darbuotojų |
| Inline view | `FROM (SELECT ...)` | top-N, vidurkis šalia eilutės |

### 3a. Daugiausiai / mažiausiai pagal grupę (pareigas, skyrių)

```sql
-- koreliuota (LAB8)
SELECT e.ename, e.job, e.sal
FROM emp e
WHERE e.sal = (SELECT MAX(sal) FROM emp WHERE job = e.job)   -- MIN mažiausiam
ORDER BY e.sal DESC;

-- poromis (veikia ir su MIN, MAX(hiredate) ir pan.)
SELECT ename, job, sal
FROM emp
WHERE (job, sal) IN (SELECT job, MAX(sal) FROM emp GROUP BY job);

-- paskutinis priimtas kiekviename skyriuje
SELECT ename, deptno, hiredate
FROM emp
WHERE (deptno, hiredate) IN (SELECT deptno, MAX(hiredate) FROM emp GROUP BY deptno);
```

### 3b. Daugiau už vidurkį (bendrą arba savo skyriaus)

```sql
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
```

### 3c. EXISTS / NOT EXISTS / NOT IN

```sql
-- skyriai be darbuotojų
SELECT deptno, dname FROM dept d
WHERE NOT EXISTS (SELECT 1 FROM emp WHERE deptno = d.deptno);

SELECT deptno, dname FROM dept
WHERE deptno NOT IN (SELECT deptno FROM emp WHERE deptno IS NOT NULL);

-- darbuotojai, kurie yra kieno nors vadovai
SELECT ename FROM emp e
WHERE EXISTS (SELECT 1 FROM emp WHERE mgr = e.empno);

-- darbuotojai, kurie NIEKAM nevadovauja (NOT IN su NULL atveju grąžintų 0 eilučių)
SELECT ename FROM emp
WHERE empno NOT IN (SELECT mgr FROM emp WHERE mgr IS NOT NULL);
```

### 3d. Grupė su didžiausia suma ar kiekiu: MAX(COUNT(...)) / MAX(SUM(...))

```sql
-- skyrius, kurio metinės pajamos didžiausios (LAB8)
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

-- pareigos, kuriose dirba daugiausiai žmonių
SELECT job, COUNT(*) FROM emp GROUP BY job
HAVING COUNT(*) = (SELECT MAX(COUNT(*)) FROM emp GROUP BY job);
```

### 3e. TOP-N (trys daugiausiai uždirbantys ir pan.)

```sql
-- ROWNUM + inline view (rikiuoti BŪTINA viduje)
SELECT ename, sal
FROM (SELECT ename, sal FROM emp ORDER BY sal DESC)
WHERE ROWNUM <= 3;

-- Oracle 12c+
SELECT ename, sal FROM emp ORDER BY sal DESC
FETCH FIRST 3 ROWS ONLY;           -- WITH TIES vietoj ONLY, jei lygios algos

-- koreliuota, įtraukia lygias algas
SELECT ename, sal FROM emp e
WHERE 3 > (SELECT COUNT(*) FROM emp WHERE sal > e.sal)
ORDER BY sal DESC;

-- analitinė funkcija (ir TOP-N kiekvienai grupei per PARTITION BY)
SELECT * FROM (
  SELECT ename, job, sal,
         DENSE_RANK() OVER (PARTITION BY job ORDER BY sal DESC) AS r
  FROM emp)
WHERE r <= 2;

-- antras pagal dydį atlyginimas
SELECT MAX(sal) FROM emp WHERE sal < (SELECT MAX(sal) FROM emp);
```

### 3f. Žymė prie eilutės (žvaigždutė paskutiniam priimtam)

```sql
SELECT ename, hiredate,
       CASE WHEN hiredate = (SELECT MAX(hiredate) FROM emp) THEN '*' END AS maxdate
FROM emp
ORDER BY hiredate;

-- variantai: MIN(hiredate) pirmam priimtam; sal = (SELECT MAX(sal) ...) didžiausiai algai
```

### 3g. WITH: pavadinta subužklausa, kai ta pati naudojama kelis kartus

```sql
WITH skyr AS (
  SELECT deptno, SUM(sal) AS suma FROM emp GROUP BY deptno
)
SELECT * FROM skyr
WHERE suma = (SELECT MAX(suma) FROM skyr);
```

---

## 4. Hierarchinės užklausos (LAB9)

Kryptį nulemia `PRIOR` vieta: `PRIOR empno = mgr` eina žemyn (į pavaldinius), `PRIOR mgr = empno` eina aukštyn (į viršininkus).

| Dalis | Ką daro |
| --- | --- |
| `START WITH` | nuo kurios eilutės pradėti (be jo kiekviena eilutė yra pradžia) |
| `CONNECT BY PRIOR` | kaip pereiti į kitą lygį |
| `LEVEL` | gylis: 1 yra pradinis darbuotojas, 2 tiesioginis, 3 per vieną lygį |
| `WHERE` | vykdomas PO medžio sudarymo ir išmeta tik tą eilutę |
| `CONNECT BY ... AND sąlyga` | nukerta visą šaką (eilutę ir viską po ja) |
| `ORDER SIBLINGS BY` | rikiuoja brolių lygyje, medžio nesugriauna |

### 4a. Ataskaita su tabuliacija (aukštyn nuo kiekvieno darbuotojo)

```sql
SELECT empno, mgr, LEVEL,
       LPAD(' ', 4*(LEVEL-1)) || ename AS name
FROM emp
CONNECT BY PRIOR mgr = empno;
```

### 4b. Visa struktūra nuo prezidento (žemyn)

```sql
SELECT empno, mgr, LEVEL,
       LPAD(' ', 4*(LEVEL-1)) || ename AS name, job
FROM emp
START WITH mgr IS NULL            -- arba job = 'PRESIDENT'
CONNECT BY PRIOR empno = mgr
ORDER SIBLINGS BY ename;
```

### 4c. Viršininkai (aukštyn nuo X)

```sql
-- visi viršininkai iki pat viršaus
SELECT empno, ename, mgr, LEVEL
FROM emp
WHERE LEVEL > 1                   -- be paties X
START WITH ename = 'SMITH'
CONNECT BY PRIOR mgr = empno;

-- tik tiesioginis viršininkas: WHERE LEVEL = 2
-- grandinė viena eilute: SMITH / FORD / JONES / KING
SELECT SYS_CONNECT_BY_PATH(ename, ' / ') AS kelias
FROM emp
WHERE mgr IS NULL
START WITH ename = 'SMITH'
CONNECT BY PRIOR mgr = empno;
```

### 4d. Pavaldiniai (žemyn nuo X)

```sql
-- tik tiesioginiai
SELECT empno, ename, mgr, LEVEL
FROM emp
WHERE LEVEL = 2
START WITH ename = 'KING'
CONNECT BY PRIOR empno = mgr;

-- VISI pavaldiniai (ir netiesioginiai): WHERE LEVEL > 1
-- tik tam tikro lygio: WHERE LEVEL = 3
-- tik apatiniai (neturi pavaldinių): WHERE CONNECT_BY_ISLEAF = 1

-- tiesioginiai be CONNECT BY (paprasta subužklausa):
SELECT ename FROM emp
WHERE mgr = (SELECT empno FROM emp WHERE ename = 'BLAKE');
```

### 4e. Kitos dažnos variacijos

```sql
-- struktūra be BLAKE ir visos jo šakos
SELECT LPAD(' ', 4*(LEVEL-1)) || ename AS name
FROM emp
START WITH mgr IS NULL
CONNECT BY PRIOR empno = mgr AND ename <> 'BLAKE';

-- struktūra be BLAKE, bet su jo pavaldiniais
--   → tas pats, tik vietoj AND ... rašyk WHERE ename <> 'BLAKE'

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
```

---

## 5. Funkcijų žinynas (LAB1–5)

### Eilučių funkcijos

| Funkcija | Pavyzdys | Rezultatas |
| --- | --- | --- |
| `UPPER / LOWER / INITCAP` | `INITCAP('JONES')` | Jones |
| `\|\|` / `CONCAT(a,b)` | `ename \|\| ' (' \|\| LOWER(job) \|\| ')'` | SMITH (clerk) |
| `SUBSTR(s, nuo, kiek)` | `SUBSTR('SMITH', 1, 3)` | SMI |
| `INSTR(s, ko)` | `INSTR('SMITH', 'I')` | 3 |
| `LENGTH(s)` | `LENGTH('KING')` | 4 |
| `LPAD / RPAD(s, ilgis, simb)` | `RPAD(ename, 15)`, `LPAD(sal, 8, '*')` | lygiavimas, tabuliacija |
| `TRIM / LTRIM / RTRIM` | `TRIM(' A ')` | A |
| `REPLACE(s, ko, kuo)` | `REPLACE(job, 'SALESMAN', 'SALESPERSON')` | SALESPERSON |
| `LIKE` | `ename LIKE '%TH%'`, `'_A%'` | `%` bet kiek simbolių, `_` vienas |

### Skaičių funkcijos

| Funkcija | Pavyzdys | Rezultatas |
| --- | --- | --- |
| `ROUND(x, n)` | `ROUND(sal*1.15)`, `ROUND(45.926, 2)` | sveikas; 45.93 |
| `TRUNC(x, n)` | `TRUNC(45.926, 1)` | 45.9 |
| `MOD(a, b)` | `MOD(14, 12)` | 2 |
| `CEIL / FLOOR` | `CEIL(4.1)`, `FLOOR(4.9)` | 5, 4 |
| `SIGN(x)` | `SIGN(sal - 1500)` | -1 / 0 / 1 |
| `ABS / POWER / SQRT` | `POWER(2, 3)` | 8 |

### Datų funkcijos

| Funkcija | Pavyzdys | Ką duoda |
| --- | --- | --- |
| `SYSDATE` | `SYSDATE - hiredate` | dabar; skirtumas dienomis |
| `ADD_MONTHS(d, n)` | `ADD_MONTHS(hiredate, 12)` | +1 metai (review data) |
| `MONTHS_BETWEEN(d1, d2)` | `TRUNC(MONTHS_BETWEEN(SYSDATE, hiredate)/12)` | išdirbti metai |
| `NEXT_DAY(d, 'FRIDAY')` | `NEXT_DAY(LAST_DAY(hiredate) - 7, 'FRIDAY')` | paskutinis mėnesio penktadienis |
| `LAST_DAY(d)` | `LAST_DAY(hiredate)` | mėnesio paskutinė diena |
| `ROUND / TRUNC(d, 'MONTH')` | `ROUND(hiredate, 'MONTH')` | nuo 16 d. pereina į kitą mėn. |
| `EXTRACT(YEAR FROM d)` | taip pat `MONTH`, `DAY` | skaičius |
| `d + n` | `hiredate + 7` | data po savaitės |

```sql
-- išdirbtas laikas "X YEARS Y MONTHS" (LAB3)
SELECT ename,
       TRUNC(MONTHS_BETWEEN(SYSDATE, hiredate)/12) || ' YEARS ' ||
       MOD(TRUNC(MONTHS_BETWEEN(SYSDATE, hiredate)), 12) || ' MONTHS' AS "YEARS OF SERVICE"
FROM emp;

-- savaitės diena nuo NLS nepriklausomai: TO_CHAR(DATE '2000-01-07', 'DAY') = FRIDAY
```

### Konversija ir formatai

| Funkcija | Pavyzdys |
| --- | --- |
| `TO_CHAR(data, 'formatas')` | `TO_CHAR(hiredate, 'FMMonth, DD "d." YYYY', 'NLS_DATE_LANGUAGE=English')` |
| `TO_DATE('tekstas', 'formatas')` | `TO_DATE('&data', 'DD.MM.YYYY')` |
| `TO_CHAR(skaičius, 'formatas')` | `TO_CHAR(sal, '$99,999.00')` |
| `TO_NUMBER('tekstas')` | `TO_NUMBER('1500')` |

Datų formatai: `YYYY` metai, `MM` mėnuo skaičiumi, `MON` JAN, `Month` January, `DD` diena, `DAY` / `Dy` savaitės diena, `Q` ketvirtis, `HH24:MI:SS` laikas. Prefiksas `FM` pašalina tarpus ir nulius, o tekstas formate rašomas kabutėse `"d."`.

### NULL ir sąlygos

| Funkcija | Ką daro | Pavyzdys |
| --- | --- | --- |
| `NVL(a, b)` | jei a NULL, grąžina b | `sal + NVL(comm, 0)` |
| `NVL2(a, b, c)` | jei a ne NULL, grąžina b, kitaip c | `NVL2(comm, 'Turi', 'Neturi')` |
| `COALESCE(a, b, ...)` | pirmą ne NULL reikšmę | `COALESCE(comm, 0)` |
| `NULLIF(a, b)` | NULL, jei a = b | `NULLIF(comm, 0)` |
| `IS NULL / IS NOT NULL` | NULL tikrinimas (`= NULL` neveikia) | `WHERE mgr IS NOT NULL` |

```sql
-- CASE (LAB4)
SELECT ename, sal,
       CASE WHEN sal < 1500 THEN 'Below 1500'
            WHEN sal = 1500 THEN 'On Target'
            ELSE TO_CHAR(sal)
       END AS salary_info
FROM emp;

-- DECODE + SIGN (tas pats)
SELECT ename, sal,
       DECODE(SIGN(sal - 1500), -1, 'Below 1500', 0, 'On Target', TO_CHAR(sal)) AS salary_info
FROM emp;

-- DECODE lygybėms: DECODE(deptno, 10, 'ACC', 20, 'RES', 'Kita')
```

### Grupavimo funkcijos (LAB5)

| Funkcija | Pastaba |
| --- | --- |
| `COUNT(*)` | visos eilutės |
| `COUNT(stulp)` | be NULL |
| `COUNT(DISTINCT stulp)` | unikalios reikšmės |
| `SUM / AVG / MIN / MAX` | NULL ignoruojami: `AVG(NVL(comm,0))` skaičiuoja visus |
| `MAX(COUNT(*))` | įdėtinė: būtinas GROUP BY, o šalia jos negalima rodyti kitų stulpelių |

```sql
-- tvarka: SELECT → FROM → WHERE → GROUP BY → HAVING → ORDER BY
SELECT deptno, job, COUNT(*) AS kiek, MIN(sal), MAX(sal), ROUND(AVG(sal))
FROM emp
WHERE mgr IS NOT NULL          -- eilučių filtras (be agregatų)
GROUP BY deptno, job           -- VISI ne agreguoti SELECT stulpeliai
HAVING COUNT(*) > 1            -- grupių filtras (su agregatais)
ORDER BY deptno;

SELECT MAX(sal) - MIN(sal) FROM emp;                   -- skirtumas
SELECT COUNT(empno), COUNT(DISTINCT empno) FROM emp;   -- ar nesikartoja
```

### SQL\*Plus kintamieji (LAB2)

```sql
WHERE job = UPPER('&job')            -- klausia kiekvieną kartą
WHERE hiredate > TO_DATE('&&nuo', 'DD-MM-YYYY')   -- && įsimena sesijai
DEFINE metinis = "sal * 12"          -- tada naudok &metinis
UNDEFINE metinis
ACCEPT dept NUMBER FORMAT 99 DEFAULT 10 PROMPT 'Skyrius: '
COLUMN name FORMAT A25               -- stulpelio plotis išvedime
SELECT DISTINCT job FROM emp ORDER BY job DESC;   -- unikalios reikšmės
```

---

## 6. Dažnos klaidos ir spąstai

| Klaida | Teisingai |
| --- | --- |
| `NATURAL JOIN`, kai nėra vienodai vadinamų stulpelių (pvz. EMP ir DEPARTMENTS) | gaunama Dekarto sandauga; rašyk `JOIN ... ON` |
| „Visi darbuotojai“ su paprastu JOIN | darbuotojai be skyriaus dingsta; reikia `LEFT JOIN` |
| „3 lygis“ parašyta kaip `GRADE >= 3` | `GRADE = 3` |
| `NOT IN` subužklausa, kurioje yra NULL | grąžina 0 eilučių; dėk `WHERE x IS NOT NULL` arba naudok `NOT EXISTS` |
| Agregatas WHERE dalyje (`WHERE AVG(sal) > ...`) | agregatus filtruok `HAVING` dalyje |
| SELECT'e yra stulpelis, kurio nėra GROUP BY | įtrauk jį į GROUP BY |
| `ROWNUM <= 3` su ORDER BY tame pačiame lygyje | pirma surikiuok inline view'e, tada ROWNUM |
| `ROWNUM = 2` arba `ROWNUM > 1` | niekada nepasitaiko; naudok `DENSE_RANK()` |
| Stulpelio aliasas WHERE dalyje | aliasas veikia tik ORDER BY; WHERE kartok išraišką |
| `= NULL` | `IS NULL` |
| `sal*12 + comm` | `sal*12 + NVL(comm, 0)`, kitaip ne pardavėjams gaunamas NULL |
| `'01-JAN-81'` | `DATE '1981-01-01'` |
| `'jones'` arba `'Jones'` | `'JONES'` arba `UPPER(ename) = UPPER('&x')` |
| Hierarchijoje `WHERE ename <> 'X'` (norint išmesti visą šaką) | `CONNECT BY PRIOR ... AND ename <> 'X'` |
| Su USING rašomas aliasas (`e.deptno`) | su USING aliasų neliek: `deptno` |
| Komentarai `//` | `--` arba `/* */` veikia bet kuriame Oracle kliente |

**Greitas planas užduočiai spręsti:**

1. Kurios lentelės reikalingos (žr. [0 skyrių](#0-lentelės-ir-ryšiai)).
2. Ar reikia jungti (1), atimti / kirsti (2), lyginti su apskaičiuota reikšme (3), ar eiti per viršininkus (4).
3. Paimk šabloną ir pakeisk pavardes, skaičius, datas.
4. Patikrink rezultatą pagal hierarchijos medį ir skyrių sąrašą iš 0 skyriaus.
