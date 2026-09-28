// 1.
SELECT ENAME,
       TO_CHAR(HIREDATE, 'FMMonth, DD "d." YYYY') AS DATE_HIRED
FROM EMP
WHERE DEPTNO = 20;

// 2. a)
SELECT ENAME, SAL,
       CASE
           WHEN SAL < 1500 THEN 'Below 1500'
           WHEN SAL = 1500 THEN 'On Target'
           ELSE TO_CHAR(SAL)
           END AS SALARY_INFO
FROM EMP;

// 2. b)
SELECT ENAME, SAL,
       DECODE(
           SIGN(SAL - 1500),
           -1, 'Below 1500',
            0, 'On Target',
           TO_CHAR(SAL)
       ) AS SALARY_INFO
FROM EMP;
// 3. 
SELECT TO_CHAR(
           TO_DATE('&anydate', 'DD.MM.YYYY'), 'fmDAY') AS DAY
FROM DUAL;