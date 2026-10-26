// 1. Išveskite darbuotojų pavardes ir skyrių, kuriuose jie dirba, pavadinimus. Informaciją
// surūšiuokite pagal skyrių pavadinimus.

SELECT ENAME, DEPTNO, DEPARTMENT_NAME
FROM EMP NATURAL JOIN DEPARTMENTS
WHERE DEPTNO = DEPARTMENT_ID
ORDER BY DEPARTMENT_NAME;

SELECT ENAME

// 2. Išveskite visų darbuotojų pavardes, skyrių pavadinimus ir skyrių numerius. 

SELECT ENAME, DEPARTMENT_NAME, DEPTNO
FROM EMP NATURAL JOIN DEPARTMENTS
WHERE DEPTNO = DEPARTMENT_ID;

// 3. Išveskite darbuotojų, kurių mėnesinis atlyginimas didesnis už 1500, pavardes, miestų ir
// skyrių, kuriuose jie dirba, pavadinimus. 

SELECT LAST_NAME as ENAME, CITY, DEPARTMENT_NAME
FROM EMPLOYEES JOIN DEPARTMENTS USING (DEPARTMENT_ID) JOIN LOCATIONS USING(LOCATION_ID)
WHERE SALARY > 1500;

// 4. Patikrinkite darbuotojų sąrašą (pavardę, pareigas, atlyginimą), parodantį atlyginimų lygius(Grade).

SELECT ENAME, JOB, SAL, GRADE
FROM EMP JOIN SALGRADE
ON(SAL BETWEEN LOSAL AND HISAL);
