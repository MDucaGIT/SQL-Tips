--- physical files that a logical file depends on
SELECT system_table_name, number_based_on_files, based_on_files
FROM   qsys2.sysfiles a
WHERE  1=1
  AND  SYSTEM_TABLE_SCHEMA = 'MDUCA1'
  AND  NATIVE_TYPE = 'LOGICAL'
  AND  SYSTEM_TABLE_NAME = 'CUSMAS01L'
;
--- BASED_ON_FILE column parsed  
WITH f (file, based) AS (
SELECT system_table_name, based_on_files
FROM   qsys2.sysfiles a
WHERE  1=1
  AND  SYSTEM_TABLE_SCHEMA = 'MDUCA1'
  AND  NATIVE_TYPE = 'LOGICAL'
  AND  SYSTEM_TABLE_NAME = 'CUSMAS01L'
)
SELECT 
f.file, j.libPF, j.filePF
FROM f,
JSON_TABLE(
based,
'$.BASED_ON_FILES[*]'
COLUMNS(
libPF   CHAR(10) PATH '$.LIBRARY',
filePF  CHAR(10) PATH '$.FILE'
)
) AS j
;
