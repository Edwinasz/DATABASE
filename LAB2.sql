 -- 1. Sukurkite užklausą, pateikiančią informaciją apie visus darbuotojus dirbančius nurodytose
 -- pareigose. Pareigas aprašykite pasinaudoję kintamuoju. Patikrinimo tikslu įvykdykite šią
 -- užklausą kelis kartus. 
 SELECT * from EMP
 WHERE JOB = '&JOB';
 
 -- 2. Apibrėžkite kintamąjį darbuotojų metiniam atlyginimui skaičiuoti. Panaudokite šį kintamąjį
 -- užklausoje, kuri išvardintų visus darbuotojus, uždirbančius per metus 30 000 ir daugiau. (Pavardė
 -- ir metinis atlyginimas). 
  
 DEFINE metinis = "SAL * 12"

 SELECT ENAME, &metinis YEARLY_SALARY
 from EMP
 WHERE &metinis >= 30000;
 
 -- 3. Sukurkite užklausą, kuri nustatytų darbuotojus, priimtus į darbą tam tikrame intervale tarp
 -- dviejų datų. Intervalai turi būti apibrėžti kintamųjų pagalba. Įvykdykite užklausą du kartus.
 -- Modifikuokite užklausą, panaudodami kintamąjį su dviem ampersando ženklais.
 
 SELECT ENAME, HIREDATE
 from EMP
 WHERE HIREDATE between TO_DATE('&&pradz', 'DD-MM-YYYY') and TO_DATE('&&paba', 'DD-MM-YYYY');
 
 -- 4. Pasinaudokite komanda ACCEPT su visais galimais parametrais ir sukurkite kintamuosius. 
 ACCEPT EMPNO NUMBER FORMAT 9999 Default 1000 PROMPT 'EMP id: '
 ACCEPT ENAME CHAR Default 'No surname' PROMPT 'EMPLOYEE SURNAME: '
 ACCEPT JOB CHAR Default 'CLERK' PROMPT 'JOB: '
 ACCEPT MGR NUMBER FORMAT 9999 Default 9999 PROMPT 'MGR id '
 ACCEPT HIREDATE DATE FORMAT 'DD-MM-YYYY' Default '01-01-1980' PROMPT 'Priemimo data'
 ACCEPT SAL NUMBER FORMAT 9999999 Default 1750 PROMPT 'SALARY: '
 ACCEPT COMM NUMBER FORMAT 99999 Default 0 PROMPT 'COMMISIONS: '
 ACCEPT DEPTNO NUMBER FORMAT 99 Default 10 PROMPT 'DEPT NO: '
  
 SELECT * from EMP
 WHERE EMPNO = &empno
 AND ENAME = '&ename'
 AND JOB = '&job'
 AND MGR = &mgr
 AND HIREDATE >= TO_DATE('&hiredate', 'DD-MM-YYYY')
 AND SAL = &sal
 AND COMM = &comm
 AND DEPTNO = &deptno;
  
  -- 5. Panaikinkite visus savo sesijos metu sukurtus kintamuosius.
 UNDEFINE empno
 UNDEFINE ename
 UNDEFINE job
 UNDEFINE mgr
 UNDEFINE hiredate
 UNDEFINE sal
 UNDEFINE comm
 UNDEFINE deptno
 UNDEFINE pradz
 UNDEFINE paba
 UNDEFINE metinis
