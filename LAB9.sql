// Sukurkite hierarchinę ataskaitą, kuri pateiktų darbuotojų numerius, viršininko numerį, pseudostulpelį LEVEL ir kiekvieno darbuotojo pavardę. Stulpeliui, kur bus pateikta darbuotojo pavardė, panaudokite tabuliaciją.

SELECT empno, mgr, LEVEL,
       LPAD(' ', 4 * (LEVEL - 1)) || ename AS name
FROM emp
CONNECT BY PRIOR mgr = empno;

// Išveskite visus tiesioginius viršininkus darbuotojui Jones.

SELECT empno, ename, mgr, LEVEL
FROM emp
WHERE LEVEL > 1
START WITH ename = 'JONES'
CONNECT BY PRIOR mgr = empno;

// Išveskite tiesioginius pavaldinius darbuotojui King.

SELECT empno, ename, mgr, LEVEL
FROM emp
WHERE LEVEL = 2
START WITH ename = 'KING'
CONNECT BY PRIOR empno = mgr;

// Išveskite tiesioginius pavaldinius darbuotojui Blake.

SELECT empno, ename, mgr, LEVEL
FROM emp
WHERE LEVEL = 2
START WITH ename = 'BLAKE'
CONNECT BY PRIOR empno = mgr;

// Išveskite pavaldumo struktūrą įmonėje pradedant nuo prezidento.

SELECT empno, mgr, LEVEL,
       LPAD(' ', 4 * (LEVEL - 1)) || ename AS name,
       job
FROM emp
START WITH job = 'PRESIDENT'
CONNECT BY PRIOR empno = mgr
ORDER SIBLINGS BY ename;
