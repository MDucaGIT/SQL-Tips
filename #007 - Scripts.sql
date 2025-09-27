--- Database relations 
SELECT * 
FROM TABLE(
SYSTOOLS.RELATED_OBJECTS(
  LIBRARY_NAME => 'MDUCA1', 
  FILE_NAME    => 'EMPLOYEE'
))
ORDER BY system_name
;
--- discover LF compiled in a different library or 
---  with different record format level from related PF 
WITH pf AS (
SELECT system_table_schema lib, system_table_name pf_name, format_level_id 
FROM   qsys2.sysfiles 
WHERE  system_table_schema = 'MDUCA1'
  AND  FILE_TYPE = 'DATA'
  AND  native_type = 'PHYSICAL'
)
, p2 AS (
SELECT pf.pf_name, source_schema_name pf_lib, 
  system_name lf_name, library_name lf_lib, 
  pf.format_level_id pf_level_id, lf.format_level_id lf_level_id
FROM   pf
JOIN TABLE (
SYSTOOLS.RELATED_OBJECTS(
  LIBRARY_NAME => pf.lib, 
  FILE_NAME    => pf.pf_name)) ro ON 1=1
JOIN   qsys2.sysfiles lf ON (lf.system_table_schema, lf.system_table_name) = 
  (library_name, system_name)
WHERE  native_type = 'LOGICAL'
   AND (library_name <> source_schema_name
   OR  pf.format_level_id <> lf.format_level_id)
)
SELECT p2.*, 
 CASE WHEN lf_lib <> pf_lib THEN '*** Different library'
      WHEN lf_level_id <> pf_level_id THEN '*** Different record level'
 END  alert
FROM  p2
ORDER BY pf_name, lf_name
;