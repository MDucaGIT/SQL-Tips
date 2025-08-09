**free
// ---------------------------------------------------------------
// Read IFS file with SQL & RPG
// ---------------------------------------------------------------
// *ENTRY PLIST
dcl-pi SQT02001 ;
end-pi;

dcl-s  line       char(200);
dcl-s  $exit      ind;
dcl-s  path       char(200);
dcl-c  EOF        100;

Exec SQL
  SET OPTION COMMIT = *NONE,
             CLOSQLCSR=*ENDMOD,
             DLYPRP=*YES
  ;

 path = '/home/MDUCA';

 Exec SQL
   DECLARE c1 CURSOR FOR
   WITH a AS (
    SELECT CAST(path_name AS CHAR(200)) filenm
    FROM TABLE(qsys2.ifs_object_statistics(
    START_PATH_NAME => TRIM(:path),
    SUBTREE_DIRECTORIES => 'NO',
    OBJECT_TYPE_LIST => '*ALLSTMF'
    ))
    WHERE UPPER(TRIM(path_name)) LIKE '%.TXT%'
    )
   SELECT r.line
    FROM  a
    JOIN TABLE(qsys2.ifs_read(
    PATH_NAME => TRIM(filenm),
    END_OF_LINE => 'ANY'
    )) r ON 1=1
   ;
 Exec SQL
   OPEN c1;

$exit = *off;
dou $exit;
  Exec SQL
  FETCH c1 INTO :line
  ;
  select;
    when SQLCODE = EOF;
      $exit = *on;
    when SQLCODE >= 0;
      // do something
    other;
      $exit = *on;
  endsl;

enddo;

Exec SQL
  CLOSE c1;

*inLR=*on;

return;
