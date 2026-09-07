describe dept;

desc dept;

//1.
SELECT * from salgrade;

SELECT grade, hisal
from salgrade;

SELECT * from dept;
// 2.
SELECT * from EMP;
// 3.
SELECT ENAME, DEPTNO, SAL
from EMP
WHERE SAL between 1600 and 3000;

SELECT ENAME, DEPTNO, SAL
from EMP
WHERE SAL >= 1600 and SAL <= 3000;
// 4.
SELECT DEPTNO, DNAME
from DEPT
ORDER by DNAME;

// 5.
desc EMP;
SELECT UNIQUE JOB
from EMP
ORDER by JOB desc;

// 6.
SELECT * from EMP
WHERE DEPTNO = 10 or DEPTNO = 30
ORDER by ENAME;

// 7.
SELECT ENAME, SAL*12 Metinis_atlyginimas, COMM
from EMP
WHERE JOB ='SALESMAN' and SAL > COMM
ORDER by SAL desc;

// 8.








