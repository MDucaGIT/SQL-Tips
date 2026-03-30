**free
// ---------------------------------------------------------------
// Test SQL error trapping
// ---------------------------------------------------------------
ctl-opt decedit('0,') datedit(*dmy.)
 dftactgrp(*no) actgrp(*caller)
 option(*srcstmt : *nodebugio : *noexpdds)
 fixnbr(*zoned : *inputpacked);
// *ENTRY PLIST
dcl-pi SQT18001 ;
end-pi;

dcl-s i int(10);
dcl-s prog     zoned(9);

Exec SQL
  SET OPTION COMMIT = *CHG ,
             CLOSQLCSR=*ENDMOD,
             DLYPRP=*YES
  ;
  monitor;
 Exec SQL
 SELECT COALESCE(MAX(trnProg) + 1, 1801)
 INTO   :prog
 FROM   WhsTra00f
 WHERE  trnProg BETWEEN 1800 AND 1900
 ;
 Exec SQL
 INSERT INTO WhsTra00F
 (TrnProg, WhsCode, TrnDate, TrnCode, TrnSign, ItemType, ItemCode,
 UM, Quantity
 )
 VALUES (:prog, 'W01', CURRENT_DATE,
 'TR+', '+', '1', 'ITEM-AAAA-00001', 'KG', 50000.00)
 ;

on-error;
   rolbk;
endmon;

commit;
*inLR=*on;
return;