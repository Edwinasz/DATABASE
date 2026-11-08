/* 1 Pateikite darbuotojų pavardes ir atlyginimus, padidintus 15% ir išreikštus sveikais
skaičiais. */

SELECT ENAME, round(SAL * 1.15) as newSAL
from EMP;

/* 2. Išveskite į ekraną informaciją žemiau parodytu būdu.  */

SELECT concat(rpad(ENAME, 15, ' '), lpad(JOB, 15, ' ')) as EMPLOYEE_AND_JOB
from EMP;

/* 3. Išveskite į ekraną darbuotojų pavardes, jų priėmimo į darbą ir atlyginimo peržiūrėjimo
(REVIEW) datas. Tarkime, kad atlyginimo peržiūrėjimo data yra po metų nuo
priėmimo į darbą datos. Duomenis pateikite atlyginimo peržiūrėjimo datos didėjimo
tvarka. */

SELECT ENAME, HIREDATE, add_months(HIREDATE, 12) as Review
from EMP
ORDER by Review;

/* 4. Parašykite užklausą, pateikiančią, kiek laiko darbuotojas dirba įmonėje. Galite naudoti
DEFINE komandą, kad nereikėtų pakartotinai suvedinėti išraiškų. */

SELECT ENAME, trunc(months_between(sysdate, HIREDATE)/12) || ' YEARS ' || mod(trunc(months_between(sysdate, HIREDATE)), 12) || ' MONTHS' as "YEARS OF SERVICE"
from EMP;

/* 5.  Darbuotojams, kurie priimti į darbą iki mėnesio 15-os dienos, pirmas darbo užmokestis
mokamas paskutinį to mėnesio penktadienį. Darbuotojams, kurie priimti į darbą vėliau
15-os mėnesio dienos, pirmas darbo užmokestis mokamas kito mėnesio paskutinį
penktadienį. Pateikite informaciją apie darbuotojus, jų priėmimo į darbą ir pirmo darbo
užmokesčio gavimo datas. Surūšiuokite pagal priėmimo į darbą datą. */

SELECT ENAME, HIREDATE, NEXT_DAY(LAST_DAY(round(HIREDATE, 'Month')) - 7, TO_CHAR(DATE '2000-01-07', 'DAY')) as PAYDAY
from EMP
ORDER by HIREDATE;

/* 6. Išveskite į ekraną informaciją žemiau parodytu būdu: */

SELECT ENAME || '(' || lower(JOB) || ')' as EMPLOYEE
from EMP;

/* 7.  Parašykite užklausą, nepriklausančią nuo to, kaip bus nurodytos darbuotojų pareigos:
didžiosiomis ar mažosiomis raidėmis.  */

SELECT ENAME, JOB
FROM EMP
WHERE UPPER(JOB) = UPPER('&JOB');

/* 8.  Pastebėta, kad 30-ame skyriuje ne visi pardavėjai vyrai. Išveskite į ekraną informaciją,
kaip parodyta žemiau, pakeisdami SALESMAN į SALESPERSON. */

SELECT ENAME, DEPTNO, REPLACE(JOB, 'SALESMAN', 'SALESPERSON') as JOB
from EMP
WHERE DEPTNO = 30;


-- =====================================================================
-- ŠPARGALKĖ: eilučių, skaičių ir datų funkcijos (LAB3)
-- =====================================================================
-- Eilučių funkcijos                         rezultatas
--   UPPER / LOWER / INITCAP('JONES')        Jones
--   CONCAT(a, b)  arba  a || b              SMITHCLERK
--   SUBSTR('SMITH', 1, 3)                   SMI      (nuo, kiek)
--   INSTR('SMITH', 'I')                     3        (pozicija)
--   LENGTH('KING')                          4
--   LPAD(sal, 8, '*') / RPAD(ename, 15)     ****5000 (lygiavimas, tabuliacija)
--   TRIM(' A ') / LTRIM / RTRIM             A
--   REPLACE(job, 'SALESMAN', 'SALESPERSON') SALESPERSON
-- Skaičių funkcijos
--   ROUND(45.926, 2) = 45.93     ROUND(sal*1.15) = sveikas skaičius
--   TRUNC(45.926, 1) = 45.9      MOD(14, 12) = 2
--   CEIL(4.1) = 5   FLOOR(4.9) = 4   SIGN(sal - 1500) = -1 / 0 / 1   POWER(2, 3) = 8

SELECT INITCAP('JONES'), SUBSTR('SMITH', 1, 3), INSTR('SMITH', 'I'), LENGTH('KING'),
       LPAD(5000, 8, '*'), ROUND(45.926, 2), TRUNC(45.926, 1), MOD(14, 12)
FROM dual;

-- dviejų stulpelių lygiavimas
SELECT RPAD(ename, 15, ' ') || LPAD(job, 15, ' ') AS employee_and_job FROM emp;

-- Datų funkcijos
--   SYSDATE                         dabartinė data; SYSDATE - hiredate = dienų skaičius
--   ADD_MONTHS(hiredate, 12)        +1 metai (REVIEW data)
--   MONTHS_BETWEEN(d1, d2)          mėnesių skirtumas (gali būti trupmena)
--   NEXT_DAY(d, 'FRIDAY')           pirmas penktadienis PO datos d
--   LAST_DAY(d)                     mėnesio paskutinė diena
--   ROUND(d, 'MONTH')               nuo 16 d. pereina į kitą mėnesį; TRUNC(d, 'MONTH') = 1 d.
--   ROUND/TRUNC(d, 'YEAR')          metų pradžia (ROUND nuo liepos → kitų metų)
--   EXTRACT(YEAR FROM d)            taip pat MONTH, DAY
--   d + 7                           data po savaitės

-- atlyginimo peržiūra po metų
SELECT ename, hiredate, ADD_MONTHS(hiredate, 12) AS review
FROM emp
ORDER BY review;

-- išdirbtas laikas "X YEARS Y MONTHS"
SELECT ename,
       TRUNC(MONTHS_BETWEEN(SYSDATE, hiredate)/12) || ' YEARS ' ||
       MOD(TRUNC(MONTHS_BETWEEN(SYSDATE, hiredate)), 12) || ' MONTHS' AS "YEARS OF SERVICE"
FROM emp;

-- paskutinis mėnesio penktadienis
-- (TO_CHAR(DATE '2000-01-07', 'DAY') = FRIDAY bet kokiais NLS kalbos nustatymais)
SELECT ename, hiredate,
       NEXT_DAY(LAST_DAY(hiredate) - 7, TO_CHAR(DATE '2000-01-07', 'DAY')) AS payday
FROM emp;
