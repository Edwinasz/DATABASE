// Suraskite skyrių, kuriame nėra darbuotojų

SELECT DEPTNO
from DEPT
minus
SELECT DEPTNO from EMP;

// Suraskite pareigas, į kurias buvo skiriami darbuotojai pirmoje 1983 metų pusėje ir 1984
//metų pusėje

SELECT JOB
from EMP
WHERE HIREDATE BETWEEN '01-JAN-81' AND '31-DEC-81'
intersect
SELECT JOB
from EMP
WHERE HIREDATE BETWEEN '01-JAN-82' AND '31-DEC-82';

// Suraskite visus darbuotojus, kurie buvo priimti į darbą anksčiau už savo viršininkus.
SELECT e.ename, e.hiredate, m.ename as manager, m.hiredate as mgr_hiredate
from EMP e JOIN EMP m 
  ON e.mgr = m.empno
WHERE e.hiredate < m.hiredate;
