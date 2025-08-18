**free
// ---------------------------------------------------------------
// Write IFS file with SQL & RPG
// ---------------------------------------------------------------
// *ENTRY PLIST
dcl-pi SQT03001 ;
end-pi;

dcl-s  line       char(48);
dcl-s  $exit      ind;
dcl-s  pathFile   char(200);
dcl-c  EOF        100;

Exec SQL
  SET OPTION COMMIT = *NONE,
             CLOSQLCSR=*ENDMOD,
             DLYPRP=*YES
  ;

pathFile = '/home/MDUCA/Employee.txt';

// Write empty file. If existing, it will be deleted first
Exec SQL
CALL qsys2.ifs_write(
PATH_NAME => TRIM(:pathFile),
LINE => '',
OVERWRITE => 'REPLACE',
FILE_CCSID => 1208,
END_OF_LINE => 'NONE'
)
;

Exec SQL
   DECLARE c1 CURSOR FOR
   SELECT DIGITS(emid) CONCAT
          emsur        CONCAT
          emfir        CONCAT
          emdep
    FROM  Employee
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
      // Write line to IFS file
      Exec SQL
      CALL qsys2.ifs_write(
      PATH_NAME => TRIM(:pathFile),
      LINE => :line,
      OVERWRITE => 'APPEND',
      FILE_CCSID => 1208,
      END_OF_LINE => 'CRLF'
      )
      ;
    other;
      $exit = *on;
  endsl;

enddo;

Exec SQL
  CLOSE c1;

*inLR=*on;
return;