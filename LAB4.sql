-- 1. 20-o skyriaus darbuotoju priemimo i darba datos.
SELECT ENAME,
       TO_CHAR(HIREDATE, 'FMMonth, DD "d." YYYY',
               'NLS_DATE_LANGUAGE=English') AS DATE_HIRED
FROM EMP
WHERE DEPTNO = 20;

-- 2. a) Atlyginimo informacija su CASE.
SELECT ENAME, SAL,
       CASE
           WHEN SAL < 1500 THEN 'Below 1500'
           WHEN SAL = 1500 THEN 'On Target'
           ELSE TO_CHAR(SAL)
       END AS SALARY_INFO
FROM EMP;

-- 2. b) Ta pati informacija su DECODE ir SIGN.
SELECT ENAME, SAL,
       DECODE(SIGN(SAL - 1500),
              -1, 'Below 1500',
               0, 'On Target',
              TO_CHAR(SAL)) AS SALARY_INFO
FROM EMP;

-- 3. Ivestos datos savaites diena be uzpildymo tarpu.
-- Data ivedama DD.MM.YYYY formatu, pvz., 04.10.2026.
SELECT TO_CHAR(TO_DATE('&anydate', 'DD.MM.YYYY'),
               'fmDAY', 'NLS_DATE_LANGUAGE=English') AS DAY
FROM DUAL;


-- =====================================================================
-- ŠPARGALKĖ: konversija, NULL ir sąlygos (LAB4)
-- =====================================================================
-- TO_CHAR(data, 'formatas')       TO_CHAR(hiredate, 'FMMonth, DD "d." YYYY', 'NLS_DATE_LANGUAGE=English')
-- TO_DATE('tekstas', 'formatas')  TO_DATE('&data', 'DD.MM.YYYY')
-- TO_CHAR(skaičius, 'formatas')   TO_CHAR(sal, '$99,999.00')  →  $1,600.00
-- TO_NUMBER('tekstas')            TO_NUMBER('1500')
--
-- Datų formatai: YYYY metai, MM mėnuo skaičiumi, MON = JAN, Month = January,
--   DD diena, DAY / Dy savaitės diena, Q ketvirtis, HH24:MI:SS laikas.
--   FM pašalina tarpus ir priekinius nulius; tekstas formate rašomas kabutėse "d."
-- Datos literalas, nepriklausantis nuo NLS: DATE '1981-01-01'  (vietoj '01-JAN-81')

SELECT ename,
       TO_CHAR(hiredate, 'YYYY-MM-DD') AS iso,
       TO_CHAR(hiredate, 'Q') AS ketvirtis,
       TO_CHAR(sal, '$99,999.00') AS alga
FROM emp
WHERE hiredate > DATE '1981-06-30';

-- NULL funkcijos
--   NVL(a, b)           jei a NULL → b                    sal + NVL(comm, 0)
--   NVL2(a, b, c)       jei a ne NULL → b, kitaip c       NVL2(comm, 'Turi', 'Neturi')
--   COALESCE(a, b, ...) pirma ne NULL reikšmė
--   NULLIF(a, b)        NULL, jei a = b
SELECT ename, comm, NVL(comm, 0), NVL2(comm, 'Turi', 'Neturi'), NULLIF(comm, 0)
FROM emp
WHERE deptno = 30;

-- CASE: bendra forma
SELECT ename, sal,
       CASE WHEN sal < 1500 THEN 'Below 1500'
            WHEN sal = 1500 THEN 'On Target'
            ELSE TO_CHAR(sal)          -- visos šakos turi grąžinti tą patį tipą
       END AS salary_info
FROM emp;

-- DECODE: tik lygybėms (paskutinis argumentas = "kitaip")
SELECT ename, deptno,
       DECODE(deptno, 10, 'ACC', 20, 'RES', 'Kita') AS skyrius
FROM emp;

-- DECODE + SIGN, kai reikia palyginimo < = >
SELECT ename, sal,
       DECODE(SIGN(sal - 1500), -1, 'Below 1500', 0, 'On Target', TO_CHAR(sal)) AS salary_info
FROM emp;
