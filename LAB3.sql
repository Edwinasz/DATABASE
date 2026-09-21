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
from EMP;

/* 4. Parašykite užklausą, pateikiančią, kiek laiko darbuotojas dirba įmonėje. Galite naudoti
DEFINE komandą, kad nereikėtų pakartotinai suvedinėti išraiškų. */

SELECT ENAME, ROUND(trunc(months_between(sysdate, HIREDATE)/12 , 0), 0) || ' YEARS ' || Round(months_between(sysdate, HIREDATE) - (ROUND(trunc(months_between(sysdate, HIREDATE)/12 , 0), 0) * 12), 0) || ' MONTHS' as "YEARS OF SERVICE"
from EMP;

/* 5.  Darbuotojams, kurie priimti į darbą iki mėnesio 15-os dienos, pirmas darbo užmokestis
mokamas paskutinį to mėnesio penktadienį. Darbuotojams, kurie priimti į darbą vėliau
15-os mėnesio dienos, pirmas darbo užmokestis mokamas kito mėnesio paskutinį
penktadienį. Pateikite informaciją apie darbuotojus, jų priėmimo į darbą ir pirmo darbo
užmokesčio gavimo datas. Surūšiuokite pagal priėmimo į darbą datą. */

SELECT ENAME, NEXT_DAY(LAST_DAY(round(HIREDATE, 'Month')) - 7, 'Friday') as PAYDAY
ORDER by HIREDATE
from EMP;

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

