# SQL konspektas: 30–41 temos

**Turinys:** [30. INSERT sakiniai](#30-tema-insert-sakiniai) · [31. UPDATE ir DELETE](#31-tema-update-ir-delete) · [32. DEFAULT, MERGE ir kelių lentelių INSERT](#32-tema-default-merge-ir-kelių-lentelių-insert) · [33. Lentelės kūrimas](#33-tema-lentelės-kūrimas) · [34. Duomenų tipai](#34-tema-duomenų-tipai) · [35. Lentelių modifikavimas](#35-tema-lentelių-modifikavimas) · [36. Apribojimai: įvadas, NOT NULL ir UNIQUE](#36-tema-apribojimai-įvadas-not-null-ir-unique) · [37. PRIMARY KEY, FOREIGN KEY ir CHECK](#37-tema-primary-key-foreign-key-ir-check) · [38. Apribojimų valdymas](#38-tema-apribojimų-valdymas) · [39. Rodiniai](#39-tema-rodiniai) · [40. DML operacijos ir rodiniai](#40-tema-dml-operacijos-ir-rodiniai) · [41. Rodinių valdymas](#41-tema-rodinių-valdymas)

---

## 30 tema. INSERT sakiniai

INSERT įterpia naujas eilutes – po vieną su VALUES arba daug iš karto su subužklausa. DML (duomenų manipuliavimo kalba) – duomenų įterpimas, atnaujinimas, trynimas.

### Lentelės kopija prieš keičiant duomenis

- Kopiją vadinti `copy_lentelėspavadinimas`. Dirbama su kopija, originalas lieka kopijai atkurti.
- Kopija **nepaveldi** pirminio/išorinio rakto apribojimų, bet **paveldi** stulpelių duomenų tipus.

```sql
CREATE TABLE copy_tablename
   AS (SELECT * FROM tablename);

CREATE TABLE copy_employees
AS (SELECT * FROM employees);

CREATE TABLE copy_departments
AS (SELECT * FROM departments);
```

Patikrinimas:

```sql
DESCRIBE copy_employees;
SELECT * FROM copy_employees;
DESCRIBE copy_departments;
SELECT * FROM copy_departments;
```

### INSERT su VALUES (viena eilutė)

Reikia 3 dalykų: lentelės pavadinimo, stulpelių pavadinimų, reikšmių kiekvienam stulpeliui.

**Tiesioginis įterpimas** – stulpeliai išvardinti, reikšmės ta pačia tvarka, skaičiai be kabučių:

```sql
INSERT INTO copy_departments
   (department_id, department_name, manager_id, location_id)
VALUES (200,'Human Resources', 205, 1500);
```

**Netiesioginis įterpimas** – be stulpelių sąrašo; reikšmės turi tiksliai atitikti stulpelių tvarką (kaip DESCRIBE) ir būti pateiktos kiekvienam stulpeliui:

```sql
INSERT INTO copy_departments
VALUES
  (210,'Estate Management', 102, 1700);
```

Aiškumo dėlei geriau visada nurodyti stulpelius.

### Lentelės suvestinė (DESCRIBE)

- Rodo: ar leidžiami pasikartojimai, duomenų tipą, leidžiamą kiekį, ar leidžiama NULL.
- Simboliniams tipams Length = maks. simbolių skaičius: `first_name VARCHAR2(20)` → iki 20 simbolių.
- Skaitiniams: tikslumas (precision) = visų skaitmenų skaičius, skalė (scale) = skaitmenys po kablelio. `salary` (8,2) → didžiausia reikšmė 999999,99.

### Eilutės su NULL reikšmėmis

- NULL leidžiančius stulpelius galima praleisti – jie automatiškai gaus NULL.
- Praleidus NOT NULL stulpelį – klaida. Pvz., EMAIL yra NOT NULL:

```sql
INSERT INTO copy_employees
  (employee_id, first_name, last_name, phone_number,
hire_date,
   job_id, salary)
VALUES
  (302,'Grigorz','Polanski', '8586667641', '15-Jun-2017',
   'IT_PROG',4200);
```

→ `ORA-01400: cannot insert NULL into (..."COPY_EMPLOYEES"."EMAIL")`

- NULL galima įrašyti tiesiogiai žodžiu `NULL` VALUES sąraše arba tuščiomis kabutėmis `''` (be tarpo):

```sql
INSERT INTO copy_employees
   (employee_id, first_name, last_name, email, phone_number,
    hire_date, job_id, salary)
VALUES
   (302,'Grigorz','Polanski', 'gpolanski', '', '15-Jun-2017',
    'IT_PROG',4200);
```

Rezultatas: PHONE\_NUMBER tuščias; COMM\_PCT, MGR\_ID, DEPT\_ID, BONUS – NULL.

### Specialiosios reikšmės: SYSDATE ir USER

- `SYSDATE` – dabartinė data ir laikas; `USER` – sesijos vartotojo vardas (Oracle APEX – `APEX_PUBLIC_USER`).

```sql
INSERT INTO copy_employees
   (employee_id, first_name, last_name, email, phone_number,
hire_date,
    job_id, salary)
VALUES
   (304,'Test',USER, 't_user', 4159982010, SYSDATE,
'ST_CLERK',2500);
```

Rezultatas: LAST\_NAME = APEX\_PUBLIC\_USER, HIRE\_DATE = šiandienos data.

### Konkrečios datos reikšmės

- Numatytasis formatas `DD-Mon-YYYY`, laikas pagal nutylėjimą – vidurnaktis (00:00:00).
- Rodyti datą kitu formatu – `TO_CHAR`:

```sql
SELECT first_name, TO_CHAR(hire_date,'Month, fmdd, yyyy')
FROM employees
WHERE employee_id = 101;
```

→ Neena | September, 21, 1989

- Įterpti datą ne numatytuoju formatu – `TO_DATE`:

```sql
INSERT INTO copy_employees
   (employee_id, first_name, last_name, email, phone_number,
hire_date,job_id, salary)
VALUES
   (301,'Katie','Hernandez', 'khernandez','8586667641',
    TO_DATE('July 8, 2017', 'Month fmdd, yyyy'),
   'MK_REP',4200);
```

- Su konkrečiu paros laiku (vietoj vidurnakčio):

```sql
INSERT INTO copy_employees
  (employee_id, first_name, last_name, email, phone_number,
hire_date, job_id, salary)
VALUES
  (303,'Angelina','Wright', 'awright','4159982010',
   TO_DATE('July 10, 2017 17:20', 'Month fmdd, yyyy HH24:MI'),
   'MK_REP', 3600);

SELECT first_name, last_name,
   TO_CHAR(hire_date, 'dd-Mon-YYYY HH24:MI') As "Date and Time"
FROM copy_employees
WHERE employee_id = 303;
```

→ Angelina | Wright | 10-Jul-2017 17:20

### Eilučių kopijavimas subužklausa

- Su subužklausa įterpiamos visos jos grąžintos eilutės (100 ar 1000 eilučių vienu sakiniu).
- **VALUES nenaudojamas**, subužklausa **nerašoma skliaustuose**.
- Stulpelių skaičius ir tipai INSERT sąraše turi atitikti subužklausos stulpelius.

```sql
INSERT INTO sales_reps(id, name, salary, commission_pct)
    SELECT employee_id, last_name, salary, commission_pct
    FROM   employees
    WHERE  job_id LIKE '%REP%';
```

Visos eilutės ir stulpeliai (veikia tik jei abiejose lentelėse tiek pat stulpelių, tų pačių tipų, ta pačia tvarka):

```sql
INSERT INTO sales_reps
   SELECT *
   FROM   employees;
```

**Sąvokos:** INSERT INTO, USER, tiesioginis įterpimas, netiesioginis įterpimas.

## 31 tema. UPDATE ir DELETE

UPDATE keičia esamas eilutes, DELETE jas šalina; be WHERE abu paveikia **visas** lentelės eilutes.

### UPDATE

Reikia 4 dalykų: lentelės, keičiamo stulpelio (-ių), naujos reikšmės, sąlygos (kurios eilutės). Nauja reikšmė gali būti vienos eilutės subužklausos rezultatas.

Vieno darbuotojo telefono keitimas (rekomenduojama kiekvieną sakinio dalį rašyti atskiroje eilutėje):

```sql
UPDATE copy_employees
SET phone_number = '123456'
WHERE employee_id = 303;
```

Keli stulpeliai ir kelios eilutės vienu sakiniu:

```sql
UPDATE copy_employees
SET phone_number = '654321', last_name = 'Jones'
WHERE employee_id >= 303;
```

→ 303 Angelina ir 304 Test gauna Jones / 654321.

**Be WHERE atnaujinamos VISOS eilutės:**

```sql
UPDATE copy_employees
SET phone_number = '654321', last_name = 'Jones';
```

→ visi darbuotojai (Steven, Neena, Lex, Jennifer…) tampa Jones su 654321.

### UPDATE su subužklausa

Pirmiausia įvykdoma subužklausa (gaunamas darbuotojo 100 atlyginimas), tada juo atnaujinamas 101:

```sql
UPDATE copy_employees
SET salary = (SELECT salary
              FROM copy_employees
              WHERE employee_id = 100)
WHERE employee_id = 101;
```

→ Neena Kochhar salary = 24000 (kaip Steven King).

Du stulpeliai – po vieną subužklausą kiekvienam:

```sql
UPDATE copy_employees
SET salary = (SELECT salary
              FROM copy_employees
              WHERE employee_id = 205),
    job_id = (SELECT job_id
              FROM copy_employees
              WHERE employee_id = 205)
WHERE employee_id = 206;
```

→ 206 Gietz gauna 12000 ir AC\_MGR, kaip 205 Higgins.

Atnaujinimas pagal kitą lentelę (reikšmė imama iš originalios `employees`, atnaujinama `copy_employees`):

```sql
UPDATE  copy_employees
SET salary  = (SELECT salary
               FROM employees
               WHERE employee_id = 205)
WHERE employee_id  = 202;
```

### UPDATE su koreliuojančia subužklausa

Eilutė atnaujinama pagal reikšmę, susietą su ta pačia eilute. Pirmiausia pridedamas stulpelis, tada užpildomas iš `departments`:

```sql
ALTER TABLE  copy_employees
ADD  (department_name varchar2(30) NOT NULL);

UPDATE  copy_employees e
SET e.department_name  = (SELECT d.department_name
                          FROM departments d
                          WHERE e.department_id =
                                d.department_id);
```

### DELETE

Reikia 2 dalykų: lentelės ir sąlygos, kurios eilutės trinamos.

```sql
DELETE from copy_employees
WHERE employee_id = 303;
```

**Be WHERE ištrinamos visos lentelės eilutės.**

### DELETE su subužklausa

Visi Shipping skyriaus darbuotojai (pvz., skyrius pervadintas ar uždarytas):

```sql
DELETE FROM copy_employees
WHERE  department_id =
   (SELECT department_id
    FROM   departments
    WHERE  department_name = 'Shipping');
```

→ 5 row(s) deleted

Vadovai, vadovaujantys mažiau nei 2 darbuotojams:

```sql
DELETE FROM copy_employees e
WHERE  e.manager_id IN
      (SELECT d.manager_id
       FROM employees d
       HAVING count (d.department_id) < 2
       GROUP BY d.manager_id);
```

### Vientisumo apribojimų klaidos

Apribojimai tikrinami automatiškai vykdant DML; pažeidus taisyklę lentelė neatnaujinama, grąžinama klaida.

NOT NULL pažeidimas – id 999 neegzistuoja, todėl subužklausa grąžina NULL:

```sql
UPDATE copy_employees
SET last_name = (SELECT last_name
                 FROM copy_employees
                 WHERE employee_id = 999)
WHERE employee_id = 101;
```

→ `ORA-01407: cannot update (..."COPY_EMPLOYEES"."LAST_NAME") to NULL`

Pirminio/išorinio rakto pavyzdys: `EMPLOYEES.department_id` – išorinis raktas į `DEPARTMENTS.department_id`. DEPARTMENTS turi 10 ir 20, bet neturi 15. Kuris sakinys grąžins klaidą?

```sql
1.  UPDATE employees SET department_id = 15
    WHERE employee_id = 100;

2.  DELETE FROM departments WHERE department_id = 10;

3.  UPDATE employees SET department_id = 10
    WHERE  department_id = 20;
```

- 1 – klaida: skyriaus 15 nėra, pažeidžiamas išorinis raktas.
- 2 – klaida, jei skyriuje 10 yra darbuotojų: jie liktų rodantys į neegzistuojantį skyrių.
- 3 – veikia: skyrius 10 egzistuoja.

Keičiant kopijas (COPY\_EMPLOYEES) matysite NOT NULL klaidas, bet **ne** PK–FK klaidas – kopijos jų nepaveldi.

### FOR UPDATE SELECT sakinyje

- Įprastas SELECT eilučių neužrakina. Su `FOR UPDATE` grąžintoms eilutėms uždedami išskirtiniai eilučių lygio užraktai, kol bus įvykdyta COMMIT arba ROLLBACK.
- Jei SELECT jungia kelias lenteles – užrakinamos eilutės visose lentelėse.

```sql
SELECT e.employee_id, e.salary, d.department_name
FROM employees e JOIN departments d  USING (department_id)
WHERE job_id = 'ST_CLERK'  AND location_id = 1500
  FOR UPDATE
ORDER BY e.employee_id;
```

→ užrakinamos 4 eilutės: 141 (3500), 142 (3100), 143 (2600), 144 (2500) – visi Shipping.

**Sąvokos:** DELETE, vientisumo apribojimas, UPDATE, koreliuota užklausa ir UPDATE / DELETE, FOR UPDATE ir SELECT.

## 32 tema. DEFAULT, MERGE ir kelių lentelių INSERT

DEFAULT pakeičia NULL numatyta reikšme, MERGE vienu sakiniu atlieka INSERT ir UPDATE, o kelių lentelių INSERT vienos užklausos eilutes įrašo į kelias lenteles.

### DEFAULT

- Jei įterpiant stulpeliui nepriskirta reikšmė, vietoj NULL įrašoma numatytoji.
- Numatytoji reikšmė: reikšmė, išraiška arba SQL funkcija (SYSDATE, USER), bet **ne kito stulpelio pavadinimas**; turi atitikti stulpelio duomenų tipą.
- Nurodoma kuriant arba keičiant lentelę.

```sql
CREATE TABLE my_employees (
       hire_date      DATE DEFAULT SYSDATE,
       first_name     VARCHAR2(15),
       last_name      VARCHAR2(15));
```

Kiekvienai eilutei be nurodytos hire\_date bus priskirta SYSDATE.

Tiesioginis DEFAULT su INSERT:

```sql
INSERT INTO my_employees
   (hire_date, first_name, last_name)
VALUES
   (DEFAULT, 'Angelina','Wright');
```

Netiesioginis DEFAULT (stulpelis tiesiog praleidžiamas):

```sql
INSERT INTO my_employees
   (first_name, last_name)
VALUES
   ('Angelina','Wright');
```

Tiesioginis DEFAULT su UPDATE – jei kuriant stulpelį numatytoji reikšmė nenurodyta, bus priskirta NULL:

```sql
UPDATE my_employees
SET hire_date = DEFAULT
WHERE last_name = 'Wright';
```

### MERGE

- MERGE = INSERT ir UPDATE vienu metu: jei eilutė yra – atnaujinama, jei nėra – įterpiama.
- Reikia INSERT ir UPDATE teisių paskirties lentelei ir SELECT – šaltinio lentelei. Galima naudoti pseudonimus.
- Iš šaltinio imama po vieną eilutę ir lyginama su paskirties eilutėmis pagal atitikimo sąlygą.

```sql
MERGE INTO destination-table USING source-table
  ON matching-condition
WHEN MATCHED THEN UPDATE
    SET ......
WHEN NOT MATCHED THEN INSERT
    VALUES (......);
```

Pavyzdys: EMPLOYEES (`e`) – šaltinis, COPY\_EMP (`c`) – paskirtis.

```sql
MERGE INTO copy_emp c  USING employees e
  ON (c.employee_id = e.employee_id)
WHEN MATCHED THEN UPDATE
     SET
        c.last_name     = e.last_name,
        c.department_id    = e.department_id
WHEN NOT MATCHED THEN INSERT
     VALUES   (e.employee_id, e.last_name, e.department_id);
```

| EMPLOYEE\_ID | EMPLOYEES (šaltinis) | COPY\_EMP prieš | COPY\_EMP po |
| --- | --- | --- | --- |
| 100 | King, 90 | Smith, 40 | King, 90 (atnaujinta) |
| 103 | Hunold, 60 | Chang, 30 | Hunold, 60 (atnaujinta) |
| 142 | Davies, 50 | – | Davies, 50 (įterpta) |

### Kelių lentelių INSERT (multi-table inserts)

- Kai tie patys šaltinio duomenys įterpiami į kelias lenteles – aktualu duomenų saugyklose: vieną kartą SELECT, tada replikuojama (geresnis našumas).
- **Besąlyginis:** visos subužklausos eilutės įterpiamos į visas INTO lenteles.
- **Sąlyginis:** su `ALL` arba `FIRST`.
  - `ALL` – tikrinama kiekviena WHEN sąlyga nepriklausomai; kiekvienai teisingai vykdomas jos INTO.
  - `FIRST` – WHEN tikrinamos iš eilės; įvykdomas tik pirmas teisingas, likusieji praleidžiami.
  - `ELSE` – jei nė viena WHEN neteisinga, vykdomas ELSE INTO; jei ELSE nėra – eilutei nieko nedaroma.

Sintaksė:

```sql
INSERT ALL INTO clause VALUES clause SUBQUERY
```

Besąlyginis pavyzdys:

```sql
INSERT ALL
  INTO my_employees
     VALUES (hire_date, first_name, last_name)
  INTO copy_my_employees
     VALUES (hire_date, first_name, last_name)
SELECT hire_date, first_name, last_name
FROM employees;
```

Sąlyginis pavyzdys (skambučių duomenys):

```sql
INSERT ALL
  WHEN call_ format IN ('tlk','txt','pic') THEN
  INTO all_calls
     VALUES (caller_id, call_timestamp, call_duration, call_format)
  WHEN call_ format IN ('tlk','txt') THEN
  INTO police_record_calls
     VALUES (caller_id, call_timestamp, recipient_caller)
  WHEN call_duration < 50 AND call_type = 'tlk' THEN
  INTO short_calls
     VALUES (caller_id, call_timestamp, call_duration)
  WHEN call_duration > = 50 AND call_type = 'tlk' THEN
  INTO long_calls
     VALUES (caller_id, call_timestamp, call_duration)
SELECT  caller_id, call_timestamp, call_duration, call_format,
        recipient_caller
FROM calls
WHERE TRUNC(call_timestamp ) = TRUNC(SYSDATE);
```

**Sąvokos:** DEFAULT, MERGE, kelių lentelių insert'ai, ALL, FIRST ir ELSE.

## 33 tema. Lentelės kūrimas

Lentelė kuriama su CREATE TABLE (DDL), kiekvienam stulpeliui parenkant tipą; visų objektų aprašai saugomi duomenų žodyne.

### Duomenų bazės schemos objektai

- Pagrindiniai: **lentelė, indeksas, apribojimas, rodinys, seka, sinonimas**. Kai kurie egzistuoja savarankiškai, kiti – ne.
- **Segmentai** – objektai, užimantys vietą saugykloje: lentelės ir indeksai.
- Rodiniai, apribojimai, sekos, sinonimai saugomi tik kaip apibrėžimas – duomenų eilučių neturi.
- Duomenų žodyne saugomi visų objektų apibrėžimai. Pvz., `SELECT * FROM jobs` – Oracle randa lentelės apibrėžimą ir „\*“ išverčia į visų stulpelių sąrašą.
- Žodynu Oracle tikrina, ar lentelės egzistuoja, ar stulpeliai teisingi, ar turite teises, ir parenka vykdymo planą. Žodyną gali pasiekti visi vartotojai.

```sql
DESCRIBE  jobs;
```

→ JOB\_ID VARCHAR2(10) PK, JOB\_TITLE VARCHAR2(35), MIN\_SALARY NUMBER(6,0), MAX\_SALARY NUMBER(6,0).

### Pavadinimų taisyklės

- Prasideda raide; 1–30 simbolių; tik A–Z, a–z, 0–9, `_`, `$`, `#`; nedubliuoja kito to paties vartotojo objekto; ne Oracle rezervuotas žodis.
- Aprašomieji pavadinimai: STUDENTS, o ne PEOPLE ar CHILDREN. Raidžių dydis neskiriamas (STUDENTS = STuDents = students).
- Pavadinimai daugiskaita: STUDENTS, ne student.

### CREATE TABLE

- DDL dalis; kiti DDL: ALTER, DROP, RENAME, TRUNCATE.
- Reikia CREATE TABLE privilegijos ir saugojimo srities (suteikia DBA DCL sakiniais).
- Kito vartotojo lentelė – su savininko priešdėliu (reikia prieigos):

```sql
SELECT *
FROM mary.students;
```

Sintaksė (DEFAULT – reikšmė, jei INSERT ją praleidžia):

```sql
CREATE TABLE table
(column data type [DEFAULT expression],
(column data type [DEFAULT expression],
(......[ ] );
```

Pavyzdžiai:

```sql
CREATE TABLE my_cd_collection
 (cd_number NUMBER(3),
  title VARCHAR2(20),
  artist VARCHAR2(20),
  purchase_date DATE DEFAULT SYSDATE);

CREATE TABLE my_friends
 (first_name VARCHAR2(20),
  last_name VARCHAR2(30),
  email VARCHAR2(30),
  phone_num VARCHAR2(12),
  birth_date DATE);
```

### Išorinės lentelės

- Duomenų eilutės laikomos ne DB failuose, o **plokščiame faile už DB ribų**; pasiekiamos tik kai reikia.
- Naudojamos duomenims iš senų sistemų, kurie naudojami retai ir tik skaitymui.
- Atsarginė kopija daroma vieną kartą (operacinės sistemos lygmenyje), nebent pasikeičia failo turinys.
- Papildoma sintaksė (pabaigoje):
  - `ORGANIZATION EXTERNAL` – kurti išorinę lentelę
  - `TYPE ORACLE_LOADER` – Oracle Loader tipas
  - `DEFAULT DIRECTORY def_dir1` – failo katalogas
  - `ACCESS PARAMETERS` – kaip skaityti failą
  - `RECORDS DELIMITED BY NEWLINE` – kaip atpažinti naujos eilutės pradžią
  - `FIELDS` – laukų pavadinimai ir tipai
  - `LOCATION` – duomenų failo pavadinimas

```sql
CREATE TABLE emp_load
  (employee_number CHAR(5),
   employee_dob CHAR(20),
   employee_last_name CHAR(20),
   employee_first_name CHAR(15),
   employee_middle_name CHAR(15),
   employee_hire_date DATE)
ORGANIZATION EXTERNAL
   (TYPE ORACLE_LOADER
    DEFAULT DIRECTORY def_dir1
    ACCESS PARAMETERS
   (RECORDS DELIMITED BY NEWLINE
    FIELDS (employee_number CHAR(2),
            employee_dob CHAR(20),
            employee_last_name CHAR(18),
            employee_first_name CHAR(11),
            employee_middle_name CHAR(11),
            employee_hire_date CHAR(10) date_format DATE mask "mm/dd/yyyy"))
   LOCATION ('info.dat'));
```

### Duomenų žodynas

- Dvi lentelių rūšys: **vartotojų** (EMPLOYEES, DEPARTMENTS, JOBS…) ir **duomenų žodyno** (DICTIONARY, USER\_OBJECTS, USER\_TABLES, USER\_SEGMENTS, USER\_INDEXES…).
- Žodyno lentelės priklauso vartotojui **SYS**; leidžiamas tik SELECT (INSERT/UPDATE/DELETE draudžiami – pakenktų DB vientisumui). Pasiekiamos per rodinius.
- Pavadinimai: `USER_xxx` arba `ALL_xxx`, kur xxx – objekto tipas (USER\_INDEXES, USER\_SEQUENCES ir pan.).

```sql
SELECT table_name, status
FROM USER_TABLES;

SELECT table_name, status
FROM ALL_TABLES;

SELECT *
FROM user_indexes;

SELECT *
FROM user_objects
WHERE object_type = 'SEQUENCE';
```

**Sąvokos:** CREATE TABLE, duomenų žodynas, lentelė, išorinė lentelė, schema, DEFAULT.

## 34 tema. Duomenų tipai

Kiekviename stulpelyje gali būti tik vieno tipo duomenys; datoms ir laikui yra DATE, TIMESTAMP (su laiko juosta ar be) ir INTERVAL tipai.

### Kodėl duomenų tipai

- Vieno tipo stulpelis duoda nuoseklius rezultatus (DATE stulpelyje visada datos).
- Neįterpsi netinkamo tipo duomenų (DATE stulpelis nepriims NUMBER). Tipų maišyti stulpelyje negalima.

### Dažniausi tipai

| Paskirtis | Tipas | Dydis |
| --- | --- | --- |
| Simboliai | CHAR | fiksuotas, iki 2000 simbolių |
| Simboliai | VARCHAR2 | kintamas, iki 32 767 simbolių |
| Simboliai | CLOB | kintamas, iki 128 TB |
| Skaičiai | NUMBER | kintamas, tikslumas iki 38 skaitmenų |
| Data ir laikas | DATE, TIMESTAMP…, INTERVAL… | – |
| Dvejetainiai (JPG, WAV, MP3) | RAW | kintamas, iki 2000 baitų |
| Dvejetainiai | BLOB | kintamas, iki 128 TB |

- VARCHAR2 / CLOB taupo vietą: „Chang“ VARCHAR2(30) stulpelyje saugo 5 simbolius, o CHAR(30) – dar 25 tarpus.
- Skaičiai gali būti teigiami ir neigiami: NUMBER(6,2) saugo nuo –9999,99 iki +9999,99.

### DATE ir TIMESTAMP

- DATE saugo nuo šimtmečių iki sekundžių, be sekundės dalių: „21-Aug-2003 17:25:30“ – tinka, „21-Aug-2003 17:25:30.255“ – ne.
- TIMESTAMP – DATE plėtinys su sekundės dalimis; TIMESTAMP(3) – iki milisekundžių.

```sql
CREATE TABLE time_ex1
(exact_time TIMESTAMP);

INSERT INTO time_ex1
VALUES ('10-Jun-2017 10:52:29.123456');

INSERT INTO time_ex1
VALUES (SYSDATE);

INSERT INTO time_ex1
VALUES (SYSTIMESTAMP);

SELECT *
FROM time_ex1;
```

| EXACT\_TIME |
| --- |
| 10-JUN-17 10.52.29.123456 AM |
| 20-NOV-20 01.36.33.000000 PM |
| 20-NOV-20 01.36.46.873234 PM |

SYSDATE eilutėje sekundės dalys nuliai, SYSTIMESTAMP – su dalimis.

### TIMESTAMP WITH TIME ZONE

- „17:30“ – bet kurioje laiko juostoje? Niujorko, Pekino, Stambulo? Globaliose organizacijose tai svarbu.
- Saugo laiko juostą kaip poslinkį nuo UTC: „2003-08-21 08:00:00 –5:00“ = 8 val., 5 val. atsilieka nuo UTC (JAV Rytų standartinis laikas).

```sql
CREATE TABLE time_ex2
(time_with_offset TIMESTAMP WITH TIME ZONE);

INSERT INTO time_ex2
VALUES (SYSTIMESTAMP);

INSERT INTO time_ex2
VALUES ('10-Jun-2017 10:52:29.123456 AM +2:00');

SELECT *
FROM time_ex2;
```

→ 20-NOV-20 01.30.55.904850 PM +00:00 ir 10-JUN-17 10.52.29.123456 AM +02:00

### TIMESTAMP WITH LOCAL TIME ZONE

Kaip ir su laiko juosta, tačiau renkant duomenis laikas automatiškai konvertuojamas į **renkančio vartotojo** laiko juostą.

```sql
CREATE TABLE time_ex3
( first_column TIMESTAMP WITH TIME ZONE,
  second_column TIMESTAMP WITH LOCAL TIME ZONE);

INSERT INTO time_ex3
  (first_column, second_column)
VALUES
  ('15-Jul-2017 08:00:00 AM -07:00', '15-Nov-2007 08:00:00');
```

Abi reikšmės įrašytos su poslinkiu –07:00 (PST). Vartotojas Stambule vykdo:

```sql
SELECT *
FROM time_ex3;
```

| FIRST\_COLUMN | SECOND\_COLUMN |
| --- | --- |
| 15-JUL-15 08.00.00.000000 AM -07:00 | 15-NOV-07 05.00.00.000000 PM |

Stambulas 9 val. lenkia PST: kai Los Andžele 8 val., Stambule 17 val. Pirmas stulpelis nesikeičia, antras parodomas Stambulo laiku.

### Intervaliniai tipai

Saugo praėjusį laiką arba intervalą tarp dviejų datos ir laiko reikšmių.

**INTERVAL YEAR TO MONTH** – metais ir mėnesiais. `year_precision` – maks. skaitmenų YEAR elemente, pagal nutylėjimą 2.

```sql
INTERVAL YEAR [(year_precision)] TO MONTH

CREATE TABLE time_ex4
(loan_duration1 INTERVAL YEAR(3) TO MONTH,
 loan_duration2 INTERVAL YEAR(2) TO MONTH);

INSERT INTO time_ex4 (loan_duration1, loan_duration2)
VALUES (INTERVAL '120' MONTH(3),
        INTERVAL '3-6' YEAR TO MONTH);
```

Tarkime, šiandien 17-Jul-2017:

```sql
SELECT SYSDATE + loan_duration1 AS "120 months from now",
       SYSDATE + loan_duration2 AS "3 years 6 months from now"
FROM time_ex4;
```

→ 17-Jul-2027 | 17-Jan-2021

**INTERVAL DAY TO SECOND** – dienomis, valandomis, minutėmis, sekundėmis (tikslesniam skirtumui). `day_precision` – maks. skaitmenų DAY elemente, pagal nutylėjimą 2; `fractional_seconds_precision` – sekundžių trupmeninės dalies skaitmenys, pagal nutylėjimą 6.

```sql
INTERVAL DAY [day_precision)] TO SECOND
[(fractional seconds precision)]

CREATE TABLE time_ex5
(day_duration1 INTERVAL DAY(3) TO SECOND,
 day_duration2 INTERVAL DAY(3) TO SECOND);

INSERT INTO time_ex5 (day_duration1, day_duration2)
VALUES (INTERVAL '25' DAY(2), INTERVAL '4 10:30:10' DAY TO SECOND);

SELECT SYSDATE + day_duration1 AS  "25 Days from now",
   TO_CHAR(SYSDATE + day_duration2, 'dd-Mon-yyyy hh:mi:ss')
   AS  "precise days and time from now"
FROM time_ex5;
```

→ 11-Aug-2017 | 21-Jul-2017 01:13:17

**Sąvokos:** CLOB, BLOB, TIMESTAMP, TIMESTAMP WITH TIME ZONE, TIMESTAMP WITH LOCAL TIME ZONE, INTERVAL DAY TO SECOND, INTERVAL YEAR TO MONTH.

## 35 tema. Lentelių modifikavimas

ALTER TABLE keičia stulpelius, DROP / RENAME / TRUNCATE – visą lentelę, o FLASHBACK leidžia atkurti lentelę ar pažiūrėti senas eilučių versijas.

### ALTER TABLE ADD – naujas stulpelis

ALTER TABLE naudojamas: pridėti stulpelį, modifikuoti stulpelį, apibrėžti DEFAULT, panaikinti stulpelį.

- Vietos nurodyti negalima – **naujas stulpelis visada tampa paskutiniu**.
- Jei lentelėje jau yra eilučių, naujas stulpelis joms iš pradžių bus NULL.

```sql
ALTER TABLE tablename
ADD (column name data type [DEFAULT expression],
column name data type [DEFAULT expression], ...

ALTER TABLE my_cd_collection
ADD (release_date DATE DEFAULT SYSDATE);

ALTER TABLE my_friends
ADD (favorite_game VARCHAR2(30));
```

### ALTER TABLE MODIFY – stulpelio keitimas

Keičiamas tipas, dydis ir DEFAULT. Taisyklės:

- Galima **padidinti** skaitinio stulpelio plotį ar tikslumą ir simbolinio stulpelio plotį.
- NUMBER plotį sumažinti galima tik jei stulpelyje tik NULL arba lentelėje nėra eilučių.
- VARCHAR plotį galima sumažinti iki didžiausios stulpelyje esančios reikšmės.
- Duomenų tipą keisti galima tik jei stulpelyje NULL reikšmės.
- CHAR ↔ VARCHAR2 – tik jei stulpelyje NULL arba dydis nemažinamas žemiau bet kurios reikšmės.
- DEFAULT pakeitimas veikia tik **vėlesnius** įterpimus.

Pavyzdys – lentelė su dviem stulpeliais:

```sql
CREATE TABLE mod_emp
  (last_name VARCHAR2(20),
   salary NUMBER(8,2));
```

Kurie pakeitimai leidžiami?

```sql
ALTER TABLE mod_emp
     MODIFY (last_name VARCHAR2(30));
ALTER TABLE mod_emp
     MODIFY (last_name VARCHAR2(10));
ALTER TABLE mod_emp
     MODIFY (salary NUMBER(10,2));
ALTER TABLE mod_emp
     MODIFY (salary NUMBER(8,2) DEFAULT 50);
```

| Pakeitimas | Ar leidžiama | Kodėl |
| --- | --- | --- |
| last\_name VARCHAR2(10) | Tik jei stulpelis tuščias arba didžiausia reikšmė ≤ 10 simbolių | Plotis mažinamas |
| last\_name VARCHAR2(30) | Taip, su duomenimis ar be jų | Plotis didinamas |
| salary NUMBER(10,2) | Taip, su duomenimis ar be jų | Didinamas tikslumas |
| salary NUMBER(8,2) DEFAULT 50 | Taip, su duomenimis ar be jų | Pridedama tik DEFAULT reikšmė |

### ALTER TABLE DROP COLUMN

Taisyklės: stulpelį su duomenimis galima panaikinti; vienu metu – tik vienas stulpelis; bent vienas stulpelis turi likti; reikšmių atstatyti negalima.

```sql
ALTER TABLE tablename
DROP COLUMN column name;

ALTER TABLE my_cd_collection
DROP COLUMN release_date;

ALTER TABLE my_friends
DROP COLUMN favorite_game;
```

### SET UNUSED

- Didelėje lentelėje naikinimas gali užtrukti – greitesnė alternatyva yra pažymėti stulpelį nenaudojamu.
- Reikšmės lieka DB, bet nepasiekiamos jokiu būdu (efektas kaip ištrynus). Stulpeliai yra, bet nematomi; galima pridėti naują stulpelį tuo pačiu pavadinimu.

```sql
ALTER TABLE tablename SET UNUSED (column name);

ALTER TABLE copy_employees
   SET UNUSED (email);
```

`DROP UNUSED COLUMNS` pašalina visus UNUSED stulpelius – kai norima atgauti vietos diske:

```sql
ALTER TABLE copy_employees
   DROP UNUSED COLUMNS;
```

### ALTER TABLE santrauka

| Sintaksė | Rezultatas | Perspėjimai |
| --- | --- | --- |
| ADD (column data type \[DEFAULT expr\], …) | Prideda naują stulpelį | Vietos nurodyti negalima – tampa paskutiniu |
| MODIFY (column data type \[DEFAULT expr\], …) | Keičia tipą, dydį, DEFAULT | DEFAULT pakeitimas veikia tik vėlesnius įterpimus |
| DROP COLUMN column | Pašalina stulpelį | Turi likti bent vienas stulpelis; atstatyti neįmanoma |
| SET UNUSED (column) | Pažymi stulpelius vėlesniam šalinimui | Vietos diske neatlaisvina; laikomi panaikintais |
| DROP UNUSED COLUMNS | Pašalina visus UNUSED stulpelius | Duomenų nerodoma, atstatyti negalima |

### DROP TABLE

- Pašalina lentelę: visi duomenys ištrinami, aprašymas šalinamas iš duomenų žodyno, prarandami ir susiję indeksai.
- Oracle neklausia patvirtinimo – šalina iškart.
- Gali tik lentelės kūrėjas arba vartotojas su DROP ANY TABLE (paprastai DBA).

```sql
DROP TABLE tablename;

DROP TABLE copy_employees;
```

### FLASHBACK TABLE

- Kiekvienas vartotojas turi **šiukšliadėžę**; per klaidą pašalintą lentelę, rodinį ar indeksą galima atkurti (negarantuojama). Atkuriami ir lentelės indeksai.

```sql
FLASHBACK TABLE tablename TO BEFORE DROP;

FLASHBACK TABLE copy_employees TO BEFORE DROP;
```

Ką galima atkurti – rodinys `USER_RECYCLEBIN`:

```sql
SELECT original_name, operation, droptime
FROM user_recyclebin
```

| ORIGINAL\_NAME | OPERATION | DROPTIME |
| --- | --- | --- |
| EMPLOYEES | DROP | 2007-12-05:12.34.24 |
| EMP\_PK | DROP | 2007-12-05:12.34.24 |

Atkurta lentelė iš USER\_RECYCLEBIN dingsta. Visiškai pašalinti apeinant šiukšliadėžę (saugumo sumetimais) – `PURGE`:

```sql
DROP TABLE copy_employees PURGE;
```

### RENAME

Gali tik objekto savininkas arba DBA (vėliau – ir rodiniai, sekos, sinonimai):

```sql
RENAME old_name to new_name;

RENAME my_cd_collection TO my_music;
```

### TRUNCATE

- Pašalina visas eilutes **ir atlaisvina vietą** saugykloje; atšaukti negalima.
- Reikia būti savininku arba turėti DROP ANY TABLE.
- DELETE taip pat šalina eilutes, bet vietos neatlaisvina. TRUNCATE greitesnis, nes negeneruoja atšaukimo informacijos.

```sql
TRUNCATE TABLE tablename;
```

### COMMENT ON TABLE

Iki 2000 simbolių komentaras stulpeliui, lentelei ar rodiniui.

```sql
COMMENT ON TABLE tablename | COLUMN table.column
     IS 'place your comment here';

COMMENT ON TABLE employees
     IS 'Western Region only';

SELECT table_name, comments
FROM user_tab_comments;
```

→ EMPLOYEES | Western Region Only

Komentaro pašalinimas – tuščia eilutė:

```sql
COMMENT ON TABLE employees IS ' ' ;
```

### FLASHBACK QUERY

- Leidžia pažiūrėti eilučių duomenis tam tikru laiko momentu (pvz., kas nors per klaidą įvykdė DML ir COMMIT).
- Oracle visada išsaugo duomenų kopiją prieš pakeitimą: UPDATE – seną stulpelio reikšmę, DELETE – visą eilutę, INSERT – nieko. Kopijos laikomos **UNDO tablespace**.
- Senos versijos peržiūrimos `VERSIONS` sąlyga SELECT sakinyje. **SCN** – sistemos pakeitimo numeris, tikslus laiko identifikatorius DB (nuoseklus, didinamas pačios DB).

```sql
SELECT employee_id,first_name ||' '|| last_name AS "NAME",
    versions_operation AS "OPERATION",
    versions_starttime AS "START_DATE",
    versions_endtime  AS "END_DATE", salary
FROM employees
  VERSIONS BETWEEN SCN MINVALUE AND MAXVALUE
WHERE  employee_id = 1;
```

Demonstracija žingsniais (po kiekvieno žingsnio vykdoma ta pati VERSIONS užklausa):

1. Pradžioje employee\_id = 1 nėra → `no data found`.
2. Sukuriamas darbuotojas:

```sql
INSERT INTO copy_employees
VALUES (1, 'Natacha', 'Hansen', 'NHANSEN', '4412312341234',
        '07-SEP-1998', 'AD_VP', 12000, null, 100, 90, NULL);
```

3. Atnaujinama:

```sql
UPDATE copy_employees
SET salary = 1
WHERE employee_id = 1;
```

4. Pašalinama:

```sql
DELETE from copy_employees
WHERE employee_id = 1;
```

VERSIONS rezultatas po DELETE (naujausia viršuje):

| EMPLOYEE\_ID | NAME | OPERATION | START\_DATE | END\_DATE | SALARY |
| --- | --- | --- | --- | --- | --- |
| 1 | Natacha Hansen | D | 07-SEP-1998 07.00.10 AM | – | 1 |
| 1 | Natacha Hansen | U | 07-SEP-1998 06.57.01 AM | 07-SEP-1998 07.00.10 AM | 1 |
| 1 | Natacha Hansen | I | 07-SEP-1998 06.51.58 AM | 07-SEP-1998 06.57.01 AM | 12000 |

Po INSERT buvo tik I eilutė (END\_DATE tuščias), po UPDATE – U ir I.

5. Įprasta užklausa po DELETE grąžina `No Data Found` – istorija pasiekiama tik per VERSIONS:

```sql
SELECT employee_id, salary
FROM copy_employees
WHERE employee_id = 1;
```

**Sąvokos:** ALTER TABLE (ADD, MODIFY, DROP), DROP TABLE, RENAME, TRUNCATE, FLASHBACK TABLE, FLASHBACK QUERY, SET UNUSED, COMMENT ON TABLE.

## 36 tema. Apribojimai: įvadas, NOT NULL ir UNIQUE

Apribojimai – DB taisyklės, neleidžiančios įvesti neteisingų duomenų; NOT NULL rašomas tik stulpelio lygmenyje, sudėtinis UNIQUE – tik lentelės lygmenyje.

### Kas yra apribojimas

- Taisyklės, saugančios nuo neteisingų duomenų (neigiamo atlyginimo, šešių studentų su tuo pačiu pažymėjimu).
- Visų apribojimų apibrėžimai saugomi duomenų žodyne.
- Neleidžia ištrinti lentelės, jei yra priklausomybių nuo kitų lentelių.
- Tikrinami eilutę įterpiant, atnaujinant ar trinant.
- Penki tipai: **NOT NULL, UNIQUE, PRIMARY KEY, FOREIGN KEY, CHECK**.

### Kur apibrėžiami CREATE TABLE sakinyje

- **Stulpelio lygmenyje** – šalia stulpelio pavadinimo ir tipo; nurodo vieną stulpelį.
- **Lentelės lygmenyje** – po visų stulpelių apibrėžimų (paskutinė sakinio eilutė).

Lentelė be apribojimų:

```sql
CREATE TABLE clients
(client_number NUMBER(4),
 first_name        VARCHAR2(14),
 last_name         VARCHAR2(13));
```

Stulpelio lygmens apribojimas – client\_number yra pirminis raktas, pavadinimas `clients_client_num_pk`:

```sql
CREATE TABLE clients
(client_number NUMBER(4) CONSTRAINT clients_client_num_pk
                                    PRIMARY KEY,
 first_name          VARCHAR2(14),
 last_name          VARCHAR2(13));
```

### Apribojimų pavadinimai

- Kiekvienas apribojimas turi pavadinimą; nesuteikus – sistema suteikia, pvz., `SYS_C00585417` (sunku atpažinti).
- Konvencija: `lentelė_stulpelis_tipas` (sutrumpinimai), iki 30 simbolių.
- Naudojant žodį `CONSTRAINT` – pavadinimas **privalomas**.
- Priesagos: `_pk`, `_nn`, `_uk`, `_fk`, `_ck`.

Pagal konvenciją: clients\_client\_number\_pk, clients\_last\_name\_nn, clients\_email\_uk.

```sql
CREATE TABLE clients
(client_number   NUMBER(4),
 last_name       VARCHAR2(13),
 email           VARCHAR2(80));

CREATE TABLE clients
(client_number NUMBER(4) CONSTRAINT clients_cient_num_pk PRIMARY KEY,
 last_name     VARCHAR2(13) CONSTRAINT clients_last_name_nn NOT NULL,
 email         VARCHAR2(80) CONSTRAINT clients_emil_uk UNIQUE);
```

Vartotojo ir sistemos pavadinimai kartu:

```sql
CREATE TABLE clients
 (client_number NUMBER(4) CONSTRAINT clients_client_num_pk PRIMARY KEY,
  last_name     VARCHAR2(13) NOT NULL,
  email         VARCHAR2(80));
```

Sukurti du apribojimai: `clients_client_num_pk` (vartotojo pavadintas PK) ir `SYS_Cn` (sistemos pavadintas NOT NULL ant last\_name, n – unikalus skaičius).

### Lentelės lygmuo ir pagrindinės taisyklės

- Apribojimai, apimantys **kelis stulpelius (sudėtinis raktas)**, – tik lentelės lygmenyje.
- **NOT NULL – tik stulpelio lygmenyje.**
- UNIQUE, PRIMARY KEY, FOREIGN KEY, CHECK – stulpelio arba lentelės lygmenyje.

UNIQUE lentelės lygmenyje (paskutinis sakinyje):

```sql
CREATE TABLE clients (
  client_number NUMBER(6) NOT NULL,
  first_name    VARCHAR2(20),
  last_name     VARCHAR2(20),
  phone         VARCHAR2(20),
  email         VARCHAR2(10) NOT NULL,
CONSTRAINT clients_phone_email_uk UNIQUE (email,phone));
```

### Pažeidimų nagrinėjimas

Kas blogai šiame sakinyje?

```sql
CREATE TABLE clients(
        client_number  NUMBER(6),
        first_name     VARCHAR2(20),
        last_name      VARCHAR2(20),
        phone          VARCHAR2(20) CONSTRAINT phone_email_uk
                            UNIQUE(email,phone),
        email          VARCHAR2(10) CONSTRAINT NOT NULL,
     CONSTRAINT emailclients_email NOT NULL,
     CONSTRAINT clients_client_num_pk PRIMARY KEY (client_number));
```

| Pažeidimas | Kur | Taisyklė |
| --- | --- | --- |
| Sudėtinio unikalaus rakto | `UNIQUE(email,phone)` prie phone stulpelio | Sudėtiniai raktai – tik lentelės lygmenyje |
| Pavadinimo | `CONSTRAINT NOT NULL` prie email | Naudojant CONSTRAINT, pavadinimas privalomas |
| NOT NULL | `CONSTRAINT emailclients_email NOT NULL` lentelės lygmenyje | NOT NULL – tik stulpelio lygmenyje |

### NOT NULL

- Kiekvienoje eilutėje stulpelis privalo turėti reikšmę (jei email NOT NULL – kiekvienas darbuotojas privalo turėti el. paštą).
- Priesaga `_nn`, pvz., `emp_email_nn`.

### UNIQUE

- Jokios dvi eilutės negali turėti tos pačios reikšmės stulpelyje ar stulpelių derinyje. Toks stulpelis (-iai) – **unikalus raktas** (žodis „raktas“ reiškia stulpelius, ne apribojimo pavadinimą).
- Priesaga `_uk`, pvz., `emp_email_uk`.
- **Sudėtinis unikalus raktas** – unikalus kelių stulpelių derinys (pvz., visi email + pavardės deriniai); apibrėžiamas tik lentelės lygmenyje.
- UNIQUE leidžia NULL (nebent yra ir NOT NULL). NULL niekam nelygus, todėl eilutė su NULL visuose rakto stulpeliuose visada tenkina apribojimą.

Pavyzdys – email yra UNIQUE. Lentelė CLIENTS:

| CLIENT\_NUMBER | FIRST\_NAME | LAST\_NAME | PHONE | EMAIL |
| --- | --- | --- | --- | --- |
| 5922 | Hiram | Peters | 3715832249 | hpeters@yahoo.com |
| 5857 | Serena | Jones | 7035335900 | serena.jones@jones.com |
| 6133 | Lauren | Vigil | 4072220090 | lbv@lbv.net |

```sql
INSERT INTO clients (client_number, first_name, Last_name, phone, email)
   VALUES (7234, 'Lonny', 'Vigil', 4072220091, 'lbv@lbv.net');
```

→ `ORA-00001: unique constraint (USWA_SKHS_SQL01_T01.CLIENT_EMAIL_UK) violated`

Ką daryti, jei du klientai (tame pačiame name) turi bendrą el. paštą? – sudėtinis unikalus raktas:

```sql
CONSTRAINT clients_phone_email_uk UNIQUE(email,phone)
```

Tada 6133 Lauren (4072220090, lbv@lbv.net) ir 7234 Lonny (4072220091, lbv@lbv.net) gali egzistuoti kartu – unikali turi būti **phone + email kombinacija**.

### Apribojimai, sukurti kuriant lentelę

NOT NULL pridedant kuriant lentelę, Oracle nepastebimai sukuria **CHECK** apribojimą. Rodomas tik pranešimas „Table created“ – be informacijos, kiek ir kokių apribojimų sukurta.

**Sąvokos:** apribojimas, stulpelio lygmens apribojimas, NOT NULL, UNIQUE, PRIMARY KEY, FOREIGN KEY, CHECK.

## 37 tema. PRIMARY KEY, FOREIGN KEY ir CHECK

PK unikaliai identifikuoja eilutę, FK sieja vaiko lentelę su tėvo lentelės PK, CHECK tikrina sąlygą; sudėtiniai PK ir kelių stulpelių CHECK – tik lentelės lygmenyje.

### PRIMARY KEY

- Reikšmė stulpelyje (ar derinyje) **unikaliai identifikuoja kiekvieną eilutę**; pasikartoti negali.
- Sąlygos: jokiame PK stulpelyje negali būti NULL; lentelėje tik **vienas** pirminis raktas.
- Stulpelio arba lentelės lygmenyje; **sudėtinis PK – tik lentelės lygmenyje**.
- Priesaga `_pk`, pvz., `clients_client_num_pk`.

Stulpelio lygmuo:

```sql
CREATE TABLE clients
(client_number NUMBER(4) CONSTRAINT clients_client_num_pk
                         PRIMARY KEY,
first_name VARCHAR2(14),
last_name VARCHAR2(13));
```

Lentelės lygmuo – PK stulpelio pavadinimas po apribojimo tipo, skliaustuose:

```sql
CREATE TABLE clients
 (client_number NUMBER(4),
  first_name VARCHAR2(14),
  last_name VARCHAR2(13),
CONSTRAINT clients_client_num_pk PRIMARY KEY
(client_number));
```

Sudėtinis PK:

```sql
CREATE TABLE copy_job_history
(employee_id NUMBER(6,0),
 start_date DATE,
 job_id VARCHAR2(10),
 department_id NUMBER(4,0),
CONSTRAINT copy_jhist_id_st_date_pk PRIMARY KEY(employee_id,
start_date));
```

### FOREIGN KEY (nuorodų vientisumas)

- Nurodo stulpelį (-ius) kaip išorinį raktą, rodantį į kitos lentelės **pirminį (arba unikalų) raktą** – tai lentelių ryšio pagrindas.
- Lentelė su išoriniu raktu – **vaiko (child)**, į kurią rodoma – **tėvo / pagrindinė (parent)**.
- FK reikšmė turi atitikti esamą tėvo lentelės reikšmę **arba būti NULL**.
- PK reikšmė gali egzistuoti be FK reikšmės, bet FK turi turėti atitinkamą PK.
- Taisyklė: **pirmiausia** tėvo lentelėje apibrėžiamas PK / UNIQUE, tik tada vaiko lentelėje – FK.
- Priesaga `_fk`, pvz., `emps_dept_id_fk`.

Pavyzdys – DEPARTMENTS PK `department_id` yra EMPLOYEES FK stulpelis:

| DEPARTMENTS (Parent) | DEPT\_NAME | EMPLOYEES (Child), kurie rodo į jį |
| --- | --- | --- |
| 90 | Executive | 100 King, 101 Kochhar, 102 De Haan |
| 110 | Accounting | 205 Higgins, 206 Gietz |
| 190 | Contracting | – |

Stulpelio lygmuo (be žodžių FOREIGN KEY – tik REFERENCES):

```sql
CREATE TABLE copy_employees
(employee_id NUMBER(6,0) CONSTRAINT copy_emp_pk PRIMARY KEY,
 first_name VARCHAR2(20),
 last_name VARCHAR2(25),
 department_id NUMBER(4,0) CONSTRAINT c_emps_dept_id_fk
                     REFERENCES departments(department_id),
 email VARCHAR2(25));
```

Lentelės lygmuo:

```sql
CREATE TABLE copy_employees
(employee_id NUMBER(6,0) CONSTRAINT copy_emp_pk PRIMARY KEY,
 first_name VARCHAR2(20),
 last_name VARCHAR2(25),
 department_id NUMBER(4,0),
 email VARCHAR2(25),
 CONSTRAINT c_emps_dept_id_fk FOREIGN KEY (department_id)
                     REFERENCES departments(department_id));
```

### ON DELETE CASCADE

- Ištrinant tėvo eilutę, kartu ištrinamos priklausomos vaiko eilutės.
- Be šio parametro tėvo eilutės, į kurią rodo vaikai, ištrinti negalima.

Be ON DELETE CASCADE:

```sql
CREATE TABLE copy_employees
(employee_id NUMBER(6,0) CONSTRAINT copy_emp_pk PRIMARY KEY,
 first_name VARCHAR2(20),
 last_name VARCHAR2(25),
 department_id NUMBER(4,0),
 email VARCHAR2(25),
 CONSTRAINT cdept_dept_id_fk FOREIGN KEY (department_id)
       REFERENCES copy_departments(department_id));
```

Bandymas ištrinti department\_id 110 nepavyks (yra priklausomų darbuotojų):

→ `ORA-02292: integrity constraint (...CDEPT_DEPT_ID_FK) violated - child record found`

Su ON DELETE CASCADE:

```sql
CREATE TABLE copy_employees
(employee_id NUMBER(6,0) CONSTRAINT copy_emp_pk PRIMARY KEY,
 first_name VARCHAR2(20),
 last_name VARCHAR2(25),
 department_id NUMBER(4,0),
 email VARCHAR2(25),
 CONSTRAINT cdept_dept_id_fk FOREIGN KEY (department_id)
    REFERENCES copy_departments(department_id) ON DELETE CASCADE);
```

Ištrinti 110 pavyks, kartu ištrinamos ir priklausomos darbuotojų eilutės → `1 row(s) deleted`.

### ON DELETE SET NULL

Vietoj vaiko eilučių trynimo jų FK reikšmė nustatoma į NULL. Naudinga, kai tėvo reikšmė keičiama nauja (pvz., atsargų numeriai keičiami brūkšniniais kodais) ir nenorima trinti vaiko eilučių – vėliau naujus numerius galima įrašyti ir į vaiko lentelę.

```sql
CREATE TABLE copy_employees
(employee_id NUMBER(6,0) CONSTRAINT copy_emp_pk PRIMARY KEY,
 first_name VARCHAR2(20),
 last_name VARCHAR2(25),
 department_id NUMBER(4,0),
 email VARCHAR2(25),
 CONSTRAINT cdept_dept_id_fk FOREIGN KEY (department_id)
    REFERENCES copy_departments(department_id) ON DELETE SET NULL);
```

### CHECK

- Aiškiai apibrėžia sąlygą; kiekvienoje eilutėje ji turi būti **teisinga arba nežinoma (dėl NULL)**.
- Gali naudoti bet kurį **tos pačios** lentelės stulpelį, bet ne kitų lentelių.
- Galioja tik toje eilutėje, kurioje apibrėžtas; negali remtis reikšmėmis kitose eilutėse.
- **Negalima:** SYSDATE, UID, USER, USERENV (`CHECK(SYSDATE >'05-May-1999')` – neleidžiama) ir pseudostulpeliai CURRVAL, NEXTVAL, LEVEL, ROWNUM (`CHECK(NEXTVAL > 0)` – neleidžiama).
- Vienam stulpeliui CHECK apribojimų skaičius neribojamas.

end\_date turi būti vėlesnė nei start\_date – susiję du stulpeliai, todėl **privaloma lentelės lygmenyje**:

```sql
CREATE TABLE copy_job_history
(employee_id NUMBER(6,0),
 start_date DATE,
 end_date DATE,
 job_id VARCHAR2(10),
 department_id NUMBER(4,0),
 CONSTRAINT cjhist_emp_id_st_date_pk
          PRIMARY KEY(employee_id, start_date),
 CONSTRAINT cjhist_end_ck CHECK (end_date > start_date));
```

Stulpelio lygmens sintaksė:

```sql
salary NUMBER(8,2) CONSTRAINT employees_min_sal_ck CHECK
                                (salary > 0)
```

Lentelės lygmens sintaksė:

```sql
CONSTRAINT employees_min_sal_ck CHECK (salary > 0)
```

**Sąvokos:** CHECK, FOREIGN KEY, REFERENCES, NOT NULL, ON DELETE CASCADE, ON DELETE SET NULL, PRIMARY KEY.

## 38 tema. Apribojimų valdymas

ALTER TABLE apribojimus prideda, šalina, išjungia ir įjungia, bet jų struktūros nekeičia; visus apribojimus parodo USER\_CONSTRAINTS.

### Gairės

- Galima **pridėti, pašalinti, įjungti, išjungti**, bet **ne keisti struktūros**.
- NOT NULL pridedamas su `MODIFY` (tai stulpelio lygmens pakeitimas) – tik jei lentelė tuščia arba kiekviena eilutė stulpelyje turi reikšmę.
- ALTER sakiniui reikia: lentelės pavadinimo, apribojimo pavadinimo, tipo, stulpelio pavadinimo.

### Apribojimo pridėjimas

```sql
ALTER TABLE table_name
ADD [CONSTRAINT constraint_name] type of constraint
                              (column_name);
```

PK pridėjimas po lentelės sukūrimo:

```sql
ALTER TABLE employees
ADD CONSTRAINT  emp_id_pk PRIMARY KEY (employee_id);
```

FOREIGN KEY – būtinas žodis `REFERENCES`:

```sql
ALTER TABLE tablename
ADD CONSTRAINT constraint_name FOREIGN KEY(column_name)
     REFERENCES tablename(column_name);
```

DEPARTMENTS PK įvedamas į EMPLOYEES kaip FK:

```sql
ALTER TABLE employees
ADD CONSTRAINT emp_dept_fk FOREIGN KEY (department_id)
   REFERENCES departments (department_id) ON DELETE CASCADE;
```

NOT NULL – su MODIFY vietoj ADD:

```sql
ALTER TABLE table_name
MODIFY (column_name CONSTRAINT constraint_name NOT NULL);

ALTER TABLE employees
MODIFY (email CONSTRAINT emp_email_nn NOT NULL);
```

### Kodėl išjungti / įjungti apribojimus

Taisyklėms įgyvendinti apribojimai turi būti įjungti, bet dėl našumo kartais laikinai išjungiami:

- įkeliant didelius duomenų kiekius;
- atliekant paketines operacijas su didžiuliais pakeitimais (pvz., kiekvieno darbuotojo numeriui pridedant 1 000).

### Apribojimo šalinimas (DROP CONSTRAINT)

- Reikia žinoti pavadinimą; jei nežinote – USER\_CONSTRAINTS ir USER\_CONS\_COLUMNS.
- `CASCADE` pašalina ir visus priklausomus apribojimus.
- Pašalinus apribojimą duomenys neištrinami; Oracle jo nebevykdo ir jo nebėra duomenų žodyne.

```sql
ALTER TABLE table_name
DROP CONSTRAINT  name [CASCADE}

ALTER TABLE copy_departments
DROP CONSTRAINT  c_dept_dept_id_pk CASCADE;
```

### Išjungimas (DISABLE)

- Pagal nutylėjimą apribojimas įjungiamas automatiškai, nebent sukurtas su DISABLE.
- DISABLE išjungia nepašalinus; leidžia bet kokius duomenis (pvz., vaiko eilutes be atitikmens tėvo lentelėje).
- Galima ir CREATE TABLE, ir ALTER TABLE sakinyje.
- Išjungus UNIQUE ar PK – unikalus indeksas pašalinamas.

```sql
CREATE TABLE copy_employees
( employee_id NUMBER(6,0) PRIMARY KEY DISABLE,
   ...
   ...);

ALTER TABLE copy_employees
DISABLE CONSTRAINT c_emp_dept_id_fk;
```

`CASCADE` išjungia ir priklausomus apribojimus; vėliau įjungus pagrindinį, priklausomi **automatiškai neįsijungia**:

```sql
ALTER TABLE table_name
DISABLE CONSTRAINT constraint_name [CASCADE];

ALTER TABLE copy_departments
DISABLE CONSTRAINT c_dept_dept_id_pk CASCADE;
```

### Įjungimas (ENABLE)

- Visi lentelės duomenys turi atitikti apribojimą; taikomas visiems duomenims.
- Įjungus UNIQUE / PK – automatiškai sukuriamas atitinkamas indeksas.
- Įjungus PK, išjungtą su CASCADE, priklausomi FK **neįjungiami**.
- Galima CREATE TABLE ir ALTER TABLE sakinyje.

```sql
ALTER TABLE table_name
ENABLE CONSTRAINT constraint_name;

ALTER TABLE copy_departments
ENABLE CONSTRAINT c_dept_dept_id_pk;
```

### Kaskadiniai apribojimai (CASCADE CONSTRAINTS)

- Naudojama su `DROP COLUMN`: pašalina visus nuorodų vientisumo apribojimus, susijusius su pašalintų stulpelių PK / UNIQUE, ir kelių stulpelių apribojimus.
- Be CASCADE CONSTRAINTS bandymas pašalinti PK ar kelių stulpelių apribojimą nepavyks. PK reikšmės ištrinti negalima, jei kitose lentelėse yra ją nurodančių FK reikšmių.

```sql
ALTER TABLE table_name
DROP(column name(s)) CASCADE CONSTRAINTS;
```

**Kada CASCADE nebūtinas:** jei pašalinami visi stulpeliai, į kuriuos nurodo apribojimai, ir jokių kitų lentelių apribojimai nerodo į PK stulpelį:

```sql
ALTER TABLE tablename DROP
(pk_column_name(s));
```

Jei į apribojimą rodo kitų lentelių ar likusieji tos lentelės stulpeliai – CASCADE CONSTRAINTS būtinas.

### Apribojimų peržiūra

- `DESCRIBE` parodo tik **NOT NULL** (duomenų žodyne jis rodomas kaip CHECK).
- Visi apribojimai – `USER_CONSTRAINTS`:

```sql
SELECT constraint_name, table_name, constraint_type, status
FROM USER_CONSTRAINTS
WHERE table_name ='COPY_EMPLOYEES';
```

| CONSTRAINT\_NAME | TABLE\_NAME | CONSTRAINT\_TYPE | STATUS |
| --- | --- | --- | --- |
| COPY\_EMP\_PK | COPY\_EMPLOYEES | P | ENABLED |
| CDEPT\_DEPT\_ID\_FK | COPY\_EMPLOYEES | R | ENABLED |

Tipų raidės: **P** – PRIMARY KEY, **R** – REFERENCES (išorinis raktas), **C** – CHECK (įskaitant NOT NULL), **U** – UNIQUE.

**Sąvokos:** ALTER TABLE, CASCADE, CASCADE CONSTRAINTS, DISABLE CONSTRAINT, DROP COLUMN, DROP CONSTRAINT, ENABLE CONSTRAINT.

## 39 tema. Rodiniai

Rodinys (VIEW) – duomenų žodyne saugomas SELECT sakinys, per kurį matomi ar keičiami bazinių lentelių duomenys; savo duomenų neturi.

### Kas yra rodinys

- DB objektas kaip lentelė, bet ne „tikra“ lentelė – loginis esamų lentelių ar kito rodinio atvaizdas.
- Nuosavų duomenų neturi; veikia kaip **langas**, per kurį peržiūrimi ar keičiami lentelių duomenys.
- Lentelės, kuriomis jis grindžiamas, – **bazinės lentelės**.

```sql
CREATE VIEW view_employees
AS SELECT employee_id,first_name, last_name, email
   FROM employees
   WHERE employee_id BETWEEN 100 and 124;

SELECT *
FROM view_employees;
```

| EMPLOYEE\_ID | FIRST\_NAME | LAST\_NAME | EMAIL |
| --- | --- | --- | --- |
| 100 | Steven | King | SKING |
| 101 | Neena | Kochhar | NKOCHHAR |
| 102 | Lex | De Haan | LDEHAAN |
| 124 | Kevin | Mourgos | KMOURGOS |
| 103 | Alexander | Hunold | AHUNOLD |
| 104 | Bruce | Ernst | BERNST |
| 107 | Diana | Lorentz | DLORENTZ |

### Kodėl naudoti rodinius

- Apriboja prieigą – rodomi tik tam tikri lentelės stulpeliai.
- Sumažina užklausų sudėtingumą: kūrėjas parašo sujungimus, o vartotojas nemato kodo ir naudoja paprastas užklausas.
- Duomenys iš kelių lentelių – vartotojams suteikiama duomenų nepriklausomybė.
- Tuos pačius duomenis galima matyti skirtingais būdais; vartotojų grupėms – prieiga pagal jų leidimus ar kriterijus.

### CREATE VIEW sintaksė

```sql
CREATE [OR REPLACE] [FORCE| NOFORCE] VIEW view  [(alias [,
   alias]...)] AS subquery
[WITH CHECK OPTION [CONSTRAINT constraint]]
[WITH READ ONLY [CONSTRAINT constraint]];
```

| Dalis | Reikšmė |
| --- | --- |
| OR REPLACE | Iš naujo sukuria rodinį, jei jis jau yra |
| FORCE | Sukuria rodinį, nesvarbu, ar bazinės lentelės yra |
| NOFORCE | Sukuria tik jei bazinė lentelė yra (numatytoji) |
| view | Rodinio pavadinimas |
| alias | Pavadinimas kiekvienai rodinio užklausos išraiškai |
| subquery | Pilnas SELECT sakinys (gali būti sudėtinis, su pseudonimais) |
| WITH CHECK OPTION | Eilutės turi likti pasiekiamos rodiniui po INSERT / UPDATE |
| CONSTRAINT | CHECK OPTION apribojimo pavadinimas |
| WITH READ ONLY | Rodinyje negalima jokia DML operacija |

Pavyzdys:

```sql
CREATE OR REPLACE VIEW view_euro_countries
AS SELECT country_id, region_id, country_name, capitol
   FROM wf_countries
   WHERE location LIKE '%Europe';

SELECT * FROM view_euro_countries
ORDER BY country_name;
```

| COUNTRY\_ID | REGION\_ID | COUNTRY\_NAME | CAPITOL |
| --- | --- | --- | --- |
| 22 | 155 | Bailiwick of Guernsey | Saint Peter Port |
| 203 | 155 | Bailiwick of Jersey | Saint Helier |
| 387 | 39 | Bosnia and Herzegovina | Sarajevo |
| 420 | 151 | Czech Republic | Prague |
| 298 | 154 | Faroe Islands | Torshavn |
| 49 | 155 | Federal Republic of Germany | Berlin |
| 33 | 155 | French Republic | Paris |

### Kūrimo gairės

- Subužklausoje gali būti sudėtinė SELECT sintaksė.
- Dėl našumo subužklausoje **neturi būti ORDER BY** – ORDER BY naudojamas renkant duomenis iš rodinio (kaip aukščiau).
- `OR REPLACE` pakeičia apibrėžimą jo netrinant ir iš naujo nesuteikiant privilegijų.
- Stulpeliams subužklausoje galima naudoti pseudonimus.

### Paprastas ir sudėtinis rodinys

| Ypatybė | Paprastas | Sudėtinis |
| --- | --- | --- |
| Lentelių skaičius | Viena | Viena ar daugiau |
| Gali turėti funkcijų | Ne | Taip |
| Gali turėti duomenų grupių | Ne | Taip |
| DML (INSERT, UPDATE, DELETE) rodinyje | Taip | Ne visada |

### Paprastas rodinys

Duomenys iš vienos lentelės, be sujungimų ir grupinių funkcijų – galimi INSERT, UPDATE, DELETE ir MERGE, veikiantys bazinę lentelę:

```sql
CREATE OR REPLACE VIEW view_euro_countries
AS SELECT country_id, country_name, capitol
   FROM wf_countries
   WHERE location LIKE '%Europe';
```

Pseudonimai SELECT sakinyje:

```sql
CREATE OR REPLACE VIEW view_euro_countries
AS SELECT country_id AS "ID", country_name AS "Country",
      capitol AS "Capitol City"
   FROM wf_countries
   WHERE location LIKE '%Europe';
```

Pseudonimai po CREATE VIEW, prieš SELECT subužklausą:

```sql
CREATE OR REPLACE VIEW view_euro_countries("ID", "Country",
    "Capitol City")
 AS SELECT country_id, country_name, capitol
    FROM wf_countries
    WHERE location LIKE '%Europe';
```

**FORCE** sukuria rodinį net jei bazinės lentelės nėra – DBA naudinga kuriant DB, kai laukiama privilegijų tam objektui. **NOFORCE** – numatytoji.

### Sudėtinis rodinys

Naudoja sujungimus ir grupines funkcijas. Duomenys iš dviejų lentelių:

```sql
CREATE OR REPLACE VIEW view_euro_countries
    ("ID", "Country", "Capitol City", "Region")
AS SELECT c.country_id, c.country_name, c.capitol,
r.region_name
   FROM wf_countries c JOIN wf_world_regions r
   USING (region_id)
   WHERE location LIKE '%Europe';

SELECT *
FROM view_euro_countries;
```

| ID | Country | Capitol City | Region |
| --- | --- | --- | --- |
| 375 | Republic of Belarus | Minsk | Eastern Europe |
| 48 | Republic of Poland | Warsaw | Eastern Europe |
| 421 | Slovak Republic | Bratislava | Eastern Europe |
| 36 | Republic of Hungary | Budapest | Eastern Europe |
| 90 | Republic of Turkey | Ankara | Eastern Europe |
| 40 | Romania | Bucharest | Eastern Europe |
| 373 | Republic of Moldova | Chisinau | Eastern Europe |
| 370 | Republic of Lithuania | Vilnius | Eastern Europe |
| 371 | Republic of Latvia | Riga | Eastern Europe |
| 372 | Republic of Estonia | Tallinn | Eastern Europe |

Su grupine funkcija:

```sql
CREATE OR REPLACE VIEW view_high_pop
   ("Region ID", "Highest
population")
AS SELECT region_id, MAX(population)
   FROM wf_countries
   GROUP BY region_id;

SELECT * FROM view_high_pop;
```

| Region ID | Highest population |
| --- | --- |
| 5 | 188078227 |
| 9 | 20264082 |
| 11 | 131859731 |
| 13 | 107449525 |
| 14 | 74777981 |
| 15 | 78887007 |
| 17 | 62660551 |
| 18 | 44187637 |
| 21 | 298444215 |

### Rodinio keitimas

Norėdami pakeisti rodinį jo nepanaikinus, kuriame jį iš naujo su `OR REPLACE` – senas rodinys pakeičiamas nauja versija:

```sql
CREATE OR REPLACE VIEW view_euro_countries
AS SELECT country_id, region_id, country_name, capitol
   FROM wf_countries
   WHERE location LIKE '%Europe';
```

**Sąvokos:** pseudonimas, sudėtinis rodinys, CREATE VIEW, FORCE, NOFORCE, REPLACE, paprastas rodinys.

## 40 tema. DML operacijos ir rodiniai

Per paprastą rodinį galima INSERT, UPDATE ir DELETE – keičiama bazinė lentelė; WITH CHECK OPTION neleidžia eilutės „atšokti“ už rodinio ribų, WITH READ ONLY draudžia bet kokį DML.

### DML per rodinį

- DML su paprastais rodiniais keičia duomenis bazinėse lentelėse.
- Net jei rodinys WHERE sąlyga riboja matomą informaciją, vartotojai vis tiek gali atlikti DML visuose rodinio stulpeliuose – net taip, kad eilutė nebebūtų rodinio dalis. Tai gali būti ne tai, ko siekė DBA.

Rodinys 50 skyriaus vadovams – kad matytų tik savo darbuotojus:

```sql
CREATE VIEW view_dept50
AS SELECT department_id, employee_id,first_name, last_name,
salary
 FROM copy_employees
 WHERE department_id = 50;

SELECT * FROM view_dept50;
```

| DEPARTMENT\_ID | EMPLOYEE\_ID | FIRST\_NAME | LAST\_NAME | SALARY |
| --- | --- | --- | --- | --- |
| 50 | 124 | Kevin | Mourgos | 5800 |
| 50 | 141 | Trenna | Rajs | 3500 |
| 50 | 142 | Curtis | Davies | 3100 |
| 50 | 143 | Randall | Matos | 2600 |
| 50 | 144 | Peter | Vargas | 2500 |

Prieigą valdo dvi CREATE VIEW parinktys: **WITH CHECK OPTION** ir **WITH READ ONLY**.

### Be WITH CHECK OPTION

```sql
CREATE VIEW view_dept50
AS SELECT department_id, employee_id, first_name, last_name,
salary
   FROM copy_employees
   WHERE department_id = 50;

UPDATE view_dept50
SET department_id = 90
WHERE employee_id = 124;
```

→ `1 row(s) updated.` – darbuotojo 124 skyrius pakeistas į 90, nors jis nebe rodinio dalis.

### WITH CHECK OPTION

- DML per rodinį turi likti **rodinio domene** – bet koks bandymas pakeisti eilutės skyriaus numerį nepavyks.
- Apribojimas pavadintas `view_dept50_check`.

```sql
CREATE OR REPLACE VIEW view_dept50
AS SELECT department_id, employee_id, first_name, last_name,
salary
   FROM employees
   WHERE department_id = 50
WITH CHECK OPTION CONSTRAINT view_dept50_check;

UPDATE view_dept50
SET department_id = 90
WHERE employee_id = 124;
```

→ `ORA-01402: view WITH CHECK OPTION where-clause violation`

### WITH READ ONLY

Rodinyje negalima jokia DML operacija – bet koks INSERT, UPDATE ar DELETE sukels Oracle serverio klaidą.

```sql
CREATE OR REPLACE VIEW view_dept50
AS SELECT department_id, employee_id, first_name, last_name,
salary
 FROM employees
 WHERE department_id = 50
WITH READ ONLY;
```

### DML apribojimai rodiniuose

Paprastiems rodiniams DML galima, sudėtiniams – ne visada. Trys taisyklės:

| Jei rodinyje yra… | DELETE (šalinti) | UPDATE (keisti) | INSERT (pridėti) |
| --- | --- | --- | --- |
| Grupinės funkcijos | Negalima | Negalima | Negalima |
| GROUP BY | Negalima | Negalima | Negalima |
| DISTINCT | Negalima | Negalima | Negalima |
| Pseudostulpelis ROWNUM | Negalima | Negalima | Negalima |
| Stulpeliai, apibrėžti išraiškomis | Galima | Negalima | Negalima |
| Ne visi bazinės lentelės NOT NULL stulpeliai | Galima | Galima | Negalima |

**Sąvokos:** WITH CHECK OPTION, WITH READ ONLY.

## 41 tema. Rodinių valdymas

DROP VIEW pašalina tik rodinio apibrėžimą, įdėtas rodinys – tai subužklausa FROM dalyje, o TOP-N analizė = įdėtas rodinys su ORDER BY + ROWNUM <= n išorėje.

### Rodinio šalinimas

- Rodinys neturi savo duomenų, todėl jo šalinimas bazinių lentelių duomenų nepaveikia.
- Jei per rodinį buvo įterpiami, atnaujinami ar trinami duomenys – tie pakeitimai lentelėse išlieka.
- Iš DB pašalinamas tik apibrėžimas (SELECT sakinys duomenų žodyne).
- Šalinti gali tik kūrėjas arba vartotojas su teise DROP ANY VIEW.

```sql
DROP VIEW viewname;
```

### Įdėti rodiniai (inline view)

- Tai **subužklausos FROM dalyje** – subužklausa rašoma lyg būtų lentelės pavadinimas.
- Naudojami sudėtingoms užklausoms supaprastinti: pašalinami sujungimai, kelios užklausos sutraukiamos į vieną.
- Subužklausos rezultatui suteikiamas pseudonimas (`d`), kuriuo pagrindinė užklausa ima stulpelius iš abiejų šaltinių.

```sql
SELECT e.last_name, e.salary, e.department_id, d.maxsal
FROM employees e,
       (SELECT department_id, max(salary) maxsal
        FROM employees
        GROUP BY department_id) d
WHERE e.department_id = d.department_id
AND e.salary = d.maxsal;
```

### TOP-N analizė

- SQL operacija rezultatams reitinguoti – gauti 5 (ar n) geriausius įrašus.
- Įdėtas rodinys pateikia surikiuotą rinkinį, `ROWNUM` priskiria eilučių numerius, išorinė užklausa paima pirmuosius penkis.
- Išorinės užklausos WHERE turi naudoti `<` arba `<=`.

Be įdėto rodinio (ilgiausiai dirbantys):

```sql
SELECT ROWNUM AS "Longest employed", last_name, hire_date
FROM employees
WHERE ROWNUM <=5
ORDER BY hire_date;
```

| Longest employed | LAST\_NAME | HIRE\_DATE |
| --- | --- | --- |
| 1 | King | 17-Jun-1987 |
| 4 | Whalen | 17-Sep-1987 |
| 2 | Kochhar | 21-Sep-1989 |
| 3 | De Haan | 13-Jan-1993 |
| 5 | Higgins | 07-Jun-1994 |

Numeriai sumaišyti – ROWNUM priskirtas prieš ORDER BY, todėl tai ne tikras TOP 5.

Su įdėtu rodiniu:

```sql
SELECT ROWNUM AS "Longest employed", last_name, hire_date
FROM (SELECT last_name, hire_date
      FROM employees
      ORDER BY hire_date)
WHERE ROWNUM <=5;
```

| Longest employed | LAST\_NAME | HIRE\_DATE |
| --- | --- | --- |
| 1 | King | 17-Jun-1987 |
| 2 | Whalen | 17-Sep-1987 |
| 3 | Kochhar | 21-Sep-1989 |
| 4 | Hunold | 03-Jan-1990 |
| 5 | Ernst | 21-May-1991 |

Kaip veikia:

1. `(SELECT last_name, hire_date FROM employees...` – įdėtas rodinys parenka pavardes ir įdarbinimo datas.
2. `...ORDER BY hire_date)` – surikiuoja nuo seniausių iki naujausių.
3. `WHERE ROWNUM <=5` – išorinė užklausa apriboja iki 5 eilučių.

**Sąvokos:** DROP VIEW, įdėtas rodinys (inline view), TOP-N ANALYSIS, ROWNUM.
