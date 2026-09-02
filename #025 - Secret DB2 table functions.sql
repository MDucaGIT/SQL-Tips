--- Retrieve UDTF parameters
SELECT 
    ORDINAL_POSITION,
    PARAMETER_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH AS CHAR_LEN,
    NUMERIC_PRECISION        AS NUM_PREC,
    NUMERIC_SCALE            AS SCALE,
    PARAMETER_MODE
FROM QSYS2.SYSPARMS 
WHERE SPECIFIC_SCHEMA = 'QSYS2'
  AND SPECIFIC_NAME   = 'OBJECT_LOCK_INFO'
  AND PARAMETER_MODE  IN ('IN', 'INOUT')
ORDER BY ORDINAL_POSITION
;
--- Retrieve who is locking source members
SELECT DISTINCT member_name, job_name
FROM TABLE(qsys2.object_lock_info(
LIBRARY_NAME => 'MDUCA1',
OBJECT_NAME => 'QRPGLESRC',
OBJECT_TYPE => '*FILE',
IASP_NUMBER => 0
))
WHERE member_name IS NOT NULL
;
--- Retrieve all source member locked for a library
WITH f AS ( 
SELECT table_name, table_schema
FROM   qsys2.systables
WHERE  table_schema = 'MDUCA1'
  AND  table_type = 'P'
  AND  file_type = 'S'
)
SELECT DISTINCT member_name, table_name, job_name, v_authorization_name username
FROM   f
JOIN TABLE (qsys2.object_lock_info(
LIBRARY_NAME => table_schema, 
OBJECT_NAME  => table_name, 
OBJECT_TYPE  => '*FILE', 
IASP_NUMBER  => 0))
ON 1=1
JOIN TABLE (qsys2.get_job_info(
job_name, 'NO'
) ) j 
ON 1=1
WHERE member_name IS NOT NULL
;
--- Retrieve all source member locked for a library with member text
WITH f AS ( 
SELECT table_name, table_schema
FROM qsys2.systables
WHERE  table_schema = 'MDUCA1'
  AND  table_type = 'P'
  AND  file_type = 'S'
)
, f2 AS (
SELECT DISTINCT member_name, table_name, table_schema, job_name, 
 v_authorization_name username
FROM   f
JOIN TABLE (qsys2.object_lock_info(
LIBRARY_NAME => table_schema, 
OBJECT_NAME  => table_name, 
OBJECT_TYPE  => '*FILE', 
IASP_NUMBER  => 0))
ON 1=1
JOIN TABLE (qsys2.get_job_info(
job_name, 'NO'
) ) j 
ON 1=1
WHERE member_name IS NOT NULL
)
SELECT f2.*, p.text
FROM   f2
JOIN TABLE (qsys2.PARTITION_STATISTICS(
SYSTEM_TABLE_SCHEMA => CAST(table_schema AS CHAR(10)),
SYSTEM_TABLE_NAME => CAST(table_name AS CHAR(10))
)) p  
ON table_partition = member_name
;


--- Retrieve parameters for QSYS2.PARTITION_STATISTICS
SELECT specific_schema, specific_name, routine_schema, routine_name
FROM qsys2.sysfuncs
WHERE routine_schema = 'QSYS2'
AND   routine_name = 'PARTITION_STATISTICS'
ORDER BY specific_name
;
