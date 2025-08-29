-- script 1
SELECT JSON_OBJECT (
'Emp ID'  VALUE emid,
'Surname' VALUE TRIM(emsurname),
'Name'    VALUE TRIM(emfirstnm),
'Address' VALUE TRIM(emaddr1),
'City'    VALUE TRIM(emcity),
'Dept ID' VALUE TRIM(emdept),
'Phone'	  VALUE TRIM(emphone1)
RETURNING CHAR(32000)
)
FROM  mduca1.employee 
;
-- script 1b
SELECT JSON_OBJECT (
'Emp ID'  : emid,
'Surname' : TRIM(emsurname),
'Name'    : TRIM(emfirstnm),
'Address' : TRIM(emaddr1),
'City'    : TRIM(emcity),
'Dept ID' : TRIM(emdept),
'Phone'	  : TRIM(emphone1)
RETURNING CHAR(32000)
)
FROM  mduca1.employee 
;
-- script 2
SELECT JSON_ARRAYAGG(
JSON_OBJECT (
'Emp ID'  VALUE emid,
'Surname' VALUE TRIM(emsurname),
'Name'    VALUE TRIM(emfirstnm),
'Address' VALUE TRIM(emaddr1),
'City'    VALUE TRIM(emcity),
'Dept ID' VALUE TRIM(emdept),
'Phone'	  VALUE TRIM(emphone1)
)
ORDER BY emsurname
RETURNING CHAR(32000)
)
FROM  mduca1.employee 
;
-- script 2b
SELECT JSON_ARRAYAGG(
JSON_OBJECT (
'Emp ID'  VALUE emid,
'Surname' VALUE TRIM(emsurname),
'Name'    VALUE TRIM(emfirstnm),
'Address' VALUE TRIM(emaddr1),
'City'    VALUE TRIM(emcity),
'Dept ID' VALUE TRIM(emdept),
'Phone'	  VALUE JSON_ARRAY(TRIM(emphone1), TRIM(emphone2))
)
ORDER BY emsurname
RETURNING CHAR(32000)
)
FROM  mduca1.employee 
;
-- script 3
SELECT JSON_OBJECT (
'employees' VALUE 
JSON_ARRAYAGG(
JSON_OBJECT (
'Emp ID'  VALUE emid,
'Surname' VALUE TRIM(emsurname),
'Name'    VALUE TRIM(emfirstnm),
'Address' VALUE TRIM(emaddr1),
'City'    VALUE TRIM(emcity),
'Dept ID' VALUE TRIM(emdept),
'Phone'	  VALUE JSON_ARRAY(TRIM(emphone1), TRIM(emphone2))
) 
ORDER BY emsurname
)
RETURNING CHAR(32000)
) 
FROM  mduca1.employee 
;
