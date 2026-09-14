describe dept;

desc emp;

//1. Parašykite užklausą visai informacijai iš SALGRADE lentelės gauti.
SELECT * from salgrade;

SELECT grade, hisal
from salgrade;

SELECT * from dept;
// 2. Parašykite užklausą visai informacijai iš EMP lentelės gauti. 
SELECT * from EMP;

// 3. Pateikite darbuotojų, gaunančių atlyginimą nuo 1600 iki 3000, sąrašą (pavardė, skyriaus
numeris, atlyginimas). 
SELECT ENAME, DEPTNO, SAL
from EMP
WHERE SAL between 1600 and 3000;

SELECT ENAME, DEPTNO, SAL
from EMP
WHERE SAL >= 1600 and SAL <= 3000;

// 4. Pateikite skyrių numerių ir pavadinimų sąrašą, surūšiuotą pagal skyriaus pavadinimą abėcėlės tvarka. 
SELECT DEPTNO, DNAME
from DEPT
ORDER by DNAME;

// 5. Parodykite visas skirtingas pareigas. Surūšiuokite jas atbuline abėcėlei tvarka. 
desc EMP;
SELECT UNIQUE JOB
from EMP
ORDER by JOB desc;

// 6. Pateikite 10-o ir 30-o skyrių darbuotojų sąrašą, surūšiuotą pagal darbuotojo pavardę abėcėlės
// tvarka (darbuotojo numeris, pavardė, pareigos, viršininko numeris, priėmimo į darbą data,
// atlyginimas, komisiniai, skyriaus numeris). 

SELECT * from EMP
WHERE DEPTNO = 10 or DEPTNO = 30
ORDER by ENAME;

// 7. Pateikite visų pardavėjų (Salesman), kurių mėnesinis atlyginimas yra didesnis už komisinius,
// pavardę, metinį atlyginimą ir komisinius. Išveskite šią informaciją į ekraną, rūšiuodami pagal
// atlyginimo dydį, pradėdami nuo didžiausio. 
SELECT ENAME, SAL*12 Metinis_atlyginimas, COMM
from EMP
WHERE JOB ='SALESMAN' and SAL > COMM
ORDER by SAL desc;

// 8. Pateikite duomenis tokia tvarka: SMITH has held the position of CLERK in department 20 since 13-JUN-83 
SELECT ENAME || ' has held the position of ' || JOB || ' in department ' || DEPTNO || ' since ' || HIREDATE
from EMP;

// 9. Pateikite tarnautojų (CLERK), dirbančių 20-ame skyriuje, pavardes ir pareigas. 
SELECT ENAME, DEPTNO, JOB
from EMP
WHERE DEPTNO = 20 and JOB = 'CLERK';

// 10. Pateikite darbuotojų pavardes, kuriose yra raidės TH arba LL 
SELECT ENAME
from EMP
WHERE ENAME LIKE '%TH%' or ENAME LIKE '%LL%';

// 11. Pateikite informaciją apie darbuotojus (pavardė, pareigos, viršininko numeris, atlyginimas), kurie turi vadovą. 
SELECT ENAME, JOB, MGR, SAL
from EMP
WHERE MGR IS NOT NULL;

// 12. Pateikite darbuotojų pavardes ir jų metines pajamas. 
SELECT ENAME, SAL*12 as YEARLY_SALARY
from EMP;

// 13. Pateikite darbuotojų, priimtų į darbą 1983 metais, sąrašą (pavardė, skyriaus numeris, priėmimo į darbą data). 
SELECT ENAME, DEPTNO, EXTRACT(YEAR FROM HIREDATE) as HIREDATE
from EMP
WHERE EXTRACT(YEAR FROM HIREDATE) = 1983;








