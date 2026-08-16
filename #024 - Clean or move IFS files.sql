--- List all STMF unused for more than 6 months
SELECT CAST(path_name AS CHAR(256)) path, object_type, 
  DATE(LAST_USED_TIMESTAMP) date_last_used
FROM TABLE(qsys2.ifs_object_statistics(
START_PATH_NAME => '/home/MDUCA/.npm/_cacache',
OBJECT_TYPE_LIST => '*ALLSTMF',
SUBTREE_DIRECTORIES => 'YES'
))
WHERE DATE(LAST_USED_TIMESTAMP) <= CURRENT_DATE - 6 MONTHS
;
--- Cleanup IFS directories from unused files
WITH a AS (
SELECT CAST(path_name AS CHAR(256)) path, object_type, 
  DATE(LAST_USED_TIMESTAMP) date_last_used
FROM TABLE(qsys2.ifs_object_statistics(
START_PATH_NAME => '/home/MDUCA/.npm/_cacache',
OBJECT_TYPE_LIST => '*ALLSTMF',
SUBTREE_DIRECTORIES => 'YES'
))
WHERE DATE(LAST_USED_TIMESTAMP) <= CURRENT_DATE - 6 MONTHS
)
, b AS (
SELECT 
'RMVLNK OBJLNK(''' CONCAT TRIM(path) CONCAT ''')'  cmd
FROM   a
ORDER BY PATH
LIMIT 10
)
SELECT cmd
, qsys2.qcmdexc(cmd)
FROM  b
;
--- Move unused files to trash directory
WITH a AS (
SELECT CAST(path_name AS CHAR(256)) path, object_type, 
  DATE(LAST_USED_TIMESTAMP) date_last_used
FROM TABLE(qsys2.ifs_object_statistics(
START_PATH_NAME => '/home/MDUCA/.npm/_cacache',
OBJECT_TYPE_LIST => '*ALLSTMF',
SUBTREE_DIRECTORIES => 'YES'
))
WHERE DATE(LAST_USED_TIMESTAMP) <= CURRENT_DATE - 6 MONTHS
)
, b AS (
SELECT 
'MOV OBJ(''' CONCAT TRIM(path) CONCAT ''') TODIR(''/home/MDUCA/trash'')'  cmd
FROM   a
ORDER BY PATH
LIMIT 10
)
SELECT cmd
, qsys2.qcmdexc(cmd)
FROM  b
;