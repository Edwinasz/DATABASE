// 1. Išveskite darbuotojų pavardes ir skyrių, kuriuose jie dirba, pavadinimus. Informaciją
// surūšiuokite pagal skyrių pavadinimus.

SELECT ENAME, DEPTNO, DEPARTMENT_NAME
FROM EMP NATURAL JOIN DEPARTMENTS
WHERE DEPTNO = DEPARTMENT_ID
ORDER BY DEPARTMENT_NAME;

SELECT e.ENAME, e.DEPTNO, d.DEPARTMENT_NAME
FROM EMP e, DEPARTMENTS d
WHERE e.deptno = d.department_id
order by d.department_NAME;

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

// 5. Išveskite tą pačią informaciją apie darbuotojus, kurių 3 atlyginimo lygis

SELECT ENAME, JOB, SAL, GRADE
FROM EMP JOIN SALGRADE
ON(SAL BETWEEN LOSAL AND HISAL)
WHERE GRADE >= 3;

SELECT CITY
from LOCATIONS;

// 6. Išveskite informaciją apie darbuotojus, dirbančius Seattle (pavardes, atlyginimus, miestą, kuriame dirba darbuotojas).
SELECT LAST_NAME, SALARY, CITY
FROM EMPLOYEES JOIN DEPARTMENTS USING (DEPARTMENT_ID) JOIN LOCATIONS USING(LOCATION_ID)
WHERE CITY = 'Seattle';

// 7. Išvardinkite skyrius, kuriuose nedirba nei vienas darbuotojas. 

SELECT d.DEPTNO, d.DNAME
FROM DEPT d
WHERE NOT EXISTS (SELECT 1 FROM EMP WHERE DEPTNO = d.DEPTNO);
