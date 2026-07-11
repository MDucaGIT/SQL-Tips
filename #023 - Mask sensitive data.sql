--- Query the Customer master file
SELECT * FROM mduca1.cusmas00f
;
---- Checking users authorized as DB security administrators
SELECT 	*
FROM 	qsys2.function_usage
WHERE	function_id = 'QIBM_DB_SECADM'
;
---- Activate RCAC on the table column
ALTER TABLE mduca1.cusmas00f        
ACTIVATE COLUMN ACCESS CONTROL 
;
---- Create a basic mask on customer name 
CREATE MASK mask00001 ON mduca1.cusmas00f       
FOR COLUMN  cmname RETURN                       
CASE WHEN (SESSION_USER NOT IN ('QSECOFR', 'SUPERUSER'))           
     THEN REGEXP_REPLACE(cmname, '[^ ]', '*')   
     ELSE cmname                                
END                                             
ENABLE                                          
;
------- UDF for getting authorized users --------------
--- 1: create Authorized users table
DROP TABLE  AutUser00f
;
--- 2: Create the UDF 
CREATE TABLE AutUser00f (
Annul 		CHAR(1)	  NOT NULL DEFAULT ' ',
TimeIns		TIMESTAMP ,
UserIns		VARCHAR(18)  ,
TimeUpd		TIMESTAMP NOT NULL
	FOR EACH ROW ON UPDATE AS ROW CHANGE TIMESTAMP ,
UserUpd		VARCHAR(18)  GENERATED ALWAYS AS (USER),
AuthUser	CHAR(10)  NOT NULL
)
RCDFMT AutUserR
;
 LABEL ON COLUMN AutUser00f            
 ( Annul        TEXT IS 'A=Annulled' ,      
   AuthUser     TEXT IS 'Authorized user' 
  )
;  
--- Query authorized users
SELECT annul, authuser FROM AutUser00f
;
DROP SPECIFIC FUNCTION IF EXISTS isUserAuth
;
--- Create the UDF
CREATE OR REPLACE FUNCTION isUserAuth (
pUser	CHAR(10)
)
RETURNS CHAR(1)
LANGUAGE SQL
SPECIFIC isUserAuth
DETERMINISTIC
NO EXTERNAL ACTION
SECURED	
READS SQL DATA
RETURNS NULL ON NULL INPUT
BEGIN
	DECLARE v_Auth CHAR(1);
	SET 	v_Auth = '0';
	SELECT  '1'
	INTO    v_Auth
	FROM   	AutUser00f
	WHERE	authUser = pUser
	  AND   annul = ' '
	LIMIT	1
	;
	RETURN  v_Auth;
END
;
---- Create a mask on customer name 
---  check authorized users with a UDF
DROP MASK mduca1.mask00001 
;
CREATE MASK mduca1.mask00001 ON mduca1.cusmas00f       
FOR COLUMN  cmname RETURN                       
CASE WHEN (isUserAuth(SESSION_USER) <> '1')           
     THEN REGEXP_REPLACE(cmname, '[^ ]', '*')   
     ELSE cmname                                
END                                             
ENABLE                                          
;
---- Assign a description to mask
COMMENT ON MASK mduca1.mask00001 
IS 'Mask for column: CUSMAS00F.CMNAME'
;
---- Query masks 
SELECT RCAC_NAME, RCAC_SCHEMA, CONTROL_TYPE, LONG_COMMENT 
FROM QSYS2.SYSCONTROLS
;
--- Constraint to avoid updating the column with all '*' 
ALTER TABLE mduca1.cusmas00f 
  ADD CONSTRAINT mduca1.chk_cmname_no_mask 
  CHECK ( 
    TRIM(TRANSLATE(cmname, ' ', '*')) <> '' 
  ) 
  ON UPDATE VIOLATION PRESERVE cmname
;
--- Query constraints
SELECT * 
FROM QSYS2.SYSCST 
WHERE	1=1
  AND CONSTRAINT_SCHEMA = 'MDUCA1'
;
