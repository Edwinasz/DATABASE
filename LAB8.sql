// Suraskite darbuotojus, gaunančius daugiausiai pagal savo pareigas. Duomenis surūšiuokite atlyginimo mažėjimo tvarka

SELECT e.ename, e.job, e.sal
FROM EMP e
WHERE e.sal = (SELECT MAX(sal) FROM EMP WHERE job = e.job)
ORDER BY e.sal DESC;

//  Suraskite visus darbuotojus, gaunančius mažiausiai pagal savo pareigas. Duomenis surūšiuokite atlyginimo didėjimo tvarka.

SELECT e.ename, e. job, e.sal
from EMP e
WHERE e.sal = (SELECT min(sal) from EMP WHERE job = e.job)
ORDER BY e.sal;

// Nustatykite kas iš darbuotojų kiekviename skyriuje buvo priimtas į darbą paskutinis

SELECT ENAME, DEPTNO, HIREDATE
from EMP
WHERE (DEPTNO, HIREDATE) 
IN
(SELECT DEPTNO, max(HIREDATE)
from EMP
group by DEPTNO);

// Išveskite informaciją apie darbuotojus, gaunančius daugiau negu vidutinį atlyginimą jų
//skyriuje. Rezultatus surūšiuokite pagal skyrių numerius.

SELECT e.DEPTNO, e.ENAME, e.SAL
FROM EMP e
WHERE SAL > (SELECT ROUND(AVG(SAL), 2) from EMP WHERE DEPTNO = e.DEPTNO)
order by e.DEPTNO;

// Suraskite visus skyrius, neturinčius darbuotojus (turite panaudoti subužklausas).

SELECT deptno, dname
from dept d
WHERE not exists
(SELECT * from emp
where deptno=d.deptno);

// Gaukite pavaizduotus duomenis skyriui, kuriame visų darbuotojų suminės metinės pajamos maksimalios.

def ysal = 'sal * 12 + NVL(comm, 0)'
SELECT deptno, SUM(&ysal) compensation
from EMP
GROUP BY DEPTNO
having sum(&ysal) = (select max(sum(&ysal)) from emp group by deptno);

// Kas įeina į trejetuką labiausiai apmokamų darbuotojų sąrašą? Suraskite jų vardus ir atlyginimus.

SELECT ename, sal
FROM (SELECT ename, sal
      FROM EMP
      ORDER BY sal DESC)
WHERE ROWNUM <= 3;
    
-- where 3 > (SELECT count(*) from emp where e.sal < sal)

// Kokiais metais įmonė priėmė daugiausiai žmonių. Išveskite metus ir įdarbintų žmonių kiekį.

SELECT extract(year from hiredate) metai, count(empno) kiekis
from emp
group by extract(year from hiredate)
having count(empno) = (select max(count(empno)) from emp group by extract(year from hiredate));
