--- Send plain text mail
VALUES SYSTOOLS.SEND_EMAIL(                                         
TO_EMAIL   => 'mduca.exprivia@gmail.com',                           
SUBJECT    => 'Test mail 1',                              
BODY_TYPE  => '*PLAIN',                                              
BODY       => 'This is a plain text mail.'                                      
)                                                                   
;

--- Send HTML mail
VALUES SYSTOOLS.SEND_EMAIL(                                         
TO_EMAIL   => 'mduca.exprivia@gmail.com',                           
SUBJECT    => 'Test mail 2',                              
BODY_TYPE  => '*HTML',                                              
BODY       => '<h3>This is an HTML mail.</h3><br><br>Sent at:<b> ' CONCAT TIME(CURRENT_TIMESTAMP) CONCAT '</b>'                                      
)                                                                   
;

--- Send HTML mail with custom fonts
VALUES SYSTOOLS.SEND_EMAIL(                                         
TO_EMAIL   => 'mduca.exprivia@gmail.com',                           
SUBJECT    => 'Test mail 3',                              
BODY_TYPE  => '*HTML',                                              
BODY       => '<h3>This is another HTML mail.</h3><br><i>Sent at:</i><p span style="font-family:Consolas; font-weight:bold; font-size:28px; color:blue"> ' 
 CONCAT TIME(CURRENT_TIMESTAMP) CONCAT '</p>'                                      
)                                                                   
;

--- Send HTML mail with attached document
VALUES SYSTOOLS.SEND_EMAIL(                                         
TO_EMAIL   => 'mduca.exprivia@gmail.com',                           
SUBJECT    => 'Test mail 4',                              
BODY_TYPE  => '*HTML',                                              
BODY       => '<h3>This is an HTML mail. Please find attached the Excel report</h3><br>Sent at:<b> ' CONCAT TIME(CURRENT_TIMESTAMP) CONCAT '</b>',
ATTACHMENT => '/home/MDUCA/WHS_transactions_3.xlsx'
)                                                                   
;

----- Get list of IFS files and send them all as mail attachment
WITH f AS (
SELECT CAST(path_name AS CHAR(80)) fileName
FROM TABLE(qsys2.ifs_object_statistics(
START_PATH_NAME => '/home/MDUCA/Excel',
SUBTREE_DIRECTORIES => 'NO',
OBJECT_TYPE_LIST => '*ALLSTMF'
))
WHERE path_name LIKE '%.xlsx%'
ORDER BY CREATE_TIMESTAMP DESC
LIMIT 10
-- alternative syntax: FETCH FIRST 10 ROWS ONLY
)
, f2 AS (
SELECT LISTAGG(TRIM(fileName), ', ') files
FROM   f
)
SELECT systools.send_email(
TO_EMAIL   => 'mduca@example.com',                           
SUBJECT    => 'Test mail 4',                              
BODY_TYPE  => '*HTML',                                              
BODY       => '<h3>Please find attached the Excel reports</h3><br>Sent at:<b> ' CONCAT TIME(CURRENT_TIMESTAMP) CONCAT '</b>',
ATTACHMENT => files
)
FROM   f2
;