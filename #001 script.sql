WITH l AS (
SELECT * FROM (
VALUES ('MDUCA1'), ('MDUCA2')
) AS l2 (lib)
)  
, a AS (
SELECT 
objlib lib, objname, objtext, objattribute, DATE(LAST_USED_TIMESTAMP) last_used, 
 DATE(objcreated) created, objdefiner, objsize
FROM  l
JOIN TABLE	(QSYS2.object_statistics(
object_schema => lib,
objtypelist => 'ALL'
)) s 
ON 1=1
WHERE 1=1
  AND (DATE(LAST_USED_TIMESTAMP) < '2020-03-01' OR 
      (days_used_count = 0 AND DATE(objcreated) < '2020-03-01'))
  AND  objattribute NOT IN ('PF', 'LF', ' ')  
)
, cmd AS (
SELECT CASE 
 WHEN objattribute IN ('RPG', 'RPGLE', 'CLP', 'CLLE') 
 THEN 'DLTPGM PGM(' CONCAT TRIM(lib) CONCAT '/' CONCAT TRIM(objname) CONCAT ')' 
 WHEN objattribute IN ('DSPF', 'PRTF') 
 THEN 'DLTF FILE(' CONCAT TRIM(lib) CONCAT '/' CONCAT TRIM(objname) CONCAT ')' 
 END command, 
 lib, objname, objattribute, last_used, created, objdefiner "Created by"
FROM  a
ORDER BY objdefiner, last_used
)
SELECT 
cmd.*
--, qsys2.qcmdexc(command) status
FROM  cmd
WHERE command IS NOT NULL 
ORDER BY "Created by", LAST_USED