 // 1. Sukurkite užklausą, pateikiančią informaciją apie visus darbuotojus dirbančius nurodytose
 // pareigose. Pareigas aprašykite pasinaudoję kintamuoju. Patikrinimo tikslu įvykdykite šią
 // užklausą kelis kartus. 
 SELECT * from EMP
 WHERE JOB = '&JOB';
 
 // 2. Apibrėžkite kintamąjį darbuotojų metiniam atlyginimui skaičiuoti. Panaudokite šį kintamąjį
 // užklausoje, kuri išvardintų visus darbuotojus, uždirbančius per metus 30 000 ir daugiau. (Pavardė
 // ir metinis atlyginimas). 
  
 SELECT ENAME, SAL * 12 YEARLY_SALARY
 from EMP
 WHERE SAL * 12 >= &atlyginamas;
 
 // 3. Sukurkite užklausą, kuri nustatytų darbuotojus, priimtus į darbą tam tikrame intervale tarp
 //dviejų datų. Intervalai turi būti apibrėžti kintamųjų pagalba. Įvykdykite užklausą du kartus.
 // Modifikuokite užklausą, panaudodami kintamąjį su dviem ampersando ženklais.
 
 SELECT ENAME, HIREDATE
 from EMP
 WHERE HIREDATE between TO_DATE('&&pradz', 'DD-MM-YYYY') and TO_DATE('&&paba', 'DD-MM-YYYY');
 
 // 4. Pasinaudokite komanda ACCEPT su visais galimais parametrais ir sukurkite kintamuosius. 
 ACCEPT EMPNO NUMBER FORMAT 9999 PROMPT 'EMP id: ' Default 1000
 ACCEPT ENAME CHAR PROMPT 'EMPLOYEE SURNAME: ' Default 'No surname'
 ACCEPT JOB CHAR PROMPT 'JOB: ' Default 'CLERK'
 ACCEPT MGR NUMBER FORMAT 9999 PROMPT 'MGR id ' Default 9999
 ACCEPT HIREDATE DATE PROMPT 'Priemimo data' Default '01-JAN-1980'
 ACCEPT SAL NUMBER FORMAT 9999999 PROMPT 'SALARY: ' Default 1750
 ACCEPT COMM NUMBER FORMAT 99999 PROMPT 'COMMISIONS: ' Default 0
 ACCEPT DEPTNO NUMBER FORMAT 99 PROMPT 'DEPT NO: ' Default 10
  
 SELECT * from EMP
 WHERE EMPNO = &empno
 AND ENAME = '&ename'
 AND JOB = '&job'
 AND MGR = &mgr
 AND HIREDATE >= TO_DATE('&hiredate', 'DD-MON-YYYY')
 AND SAL = &sal
 AND COMM = &comm
 AND DEPTNO = &deptno;
  
  // 5. Panaikinkite visus savo sesijos metu sukurtus kintamuosius.
 UNDEFINE empno
 UNDEFINE ename
 UNDEFINE job
 UNDEFINE mgr
 UNDEFINE hiredate
 UNDEFINE sal
 UNDEFINE comm
 UNDEFINE deptno
