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
