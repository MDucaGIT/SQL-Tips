--- Table for collecting spool file data
CREATE OR REPLACE TABLE SQT13001T (
Progr     NUMERIC(9, 0),
Whs       CHAR(3),
ItemType  CHAR(1),
ItemCode  CHAR(40),
UM        CHAR(2),
Quantity  NUMERIC(9, 2)
)
;

--- Get data from a single spool file
SELECT *
FROM   TABLE(systools.spooled_file_data(
JOB_NAME => '403737/MDUCA/QPADEV002J',
SPOOLED_FILE_NAME => 'SQT13001P',
SPOOLED_FILE_NUMBER => 3
)) 
WHERE MOD(ordinal_position, 60) BETWEEN 6 AND 59 
  AND SUBSTR(spooled_data, 1, 5) <> '     '
;

-- Get data from most recent spool file in the given OUTQ 
--  and populate database table
INSERT INTO mduca1.sqt13001t 
WITH sp AS (
SELECT SPOOLED_FILE_NAME, JOB_NAME, FILE_NUMBER 
FROM   TABLE(qsys2.output_queue_entries(
OUTQ_LIB => 'QGPL',
OUTQ_NAME => 'MDUCA'
))
WHERE  SPOOLED_FILE_NAME = 'SQT13001P'
ORDER BY create_timestamp DESC
LIMIT 1
)
, sp2 AS (
SELECT spooled_data AS line
FROM   sp
JOIN TABLE(systools.spooled_file_data(
JOB_NAME => sp.JOB_NAME,
SPOOLED_FILE_NAME => sp.SPOOLED_FILE_NAME,
SPOOLED_FILE_NUMBER => sp.FILE_NUMBER
)) ON 1=1
WHERE MOD(ordinal_position, 60) BETWEEN 6 AND 59 
  AND SUBSTR(spooled_data, 1, 5) <> '     '
)
, sp3 AS (
SELECT 
SUBSTR(line, 2, 9) progr,
SUBSTR(line, 12, 3) whs,
SUBSTR(line, 18, 1) TYPE,
SUBSTR(line, 20, 40) item,
SUBSTR(line, 62, 2) UM,
COALESCE(
CAST(
--- TO_NUMBER returns a DECFLOAT, we cast it to numeric 
TO_NUMBER(SUBSTR(line, 65, 13), '9999999D99MI')  
AS NUMERIC(9, 2))
, 0) qty
FROM  sp2
)
SELECT 
*
FROM  sp3
ORDER BY progr
;
