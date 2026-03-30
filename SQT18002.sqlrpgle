**free
// ---------------------------------------------------------------
// Test SQL error trapping
// ---------------------------------------------------------------
ctl-opt decedit('0,') datedit(*dmy.)
 dftactgrp(*no) actgrp(*caller)
 option(*srcstmt : *nodebugio : *noexpdds)
 fixnbr(*zoned : *inputpacked);
// *ENTRY PLIST
dcl-pi SQT18002 ;
end-pi;

dcl-s i          int(10);
dcl-s prog       zoned(9);
dcl-ds dsWHSTRA  extname('WHSTRA00F') end-ds;

Exec SQL
  SET OPTION COMMIT = *CHG,
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
 clear dsWHSTRA;
 trnProg = prog;
 whsCode = 'W01';
 trnDate = %date();
 trnCode = 'TR+';
 trnSign = '+';
 itemType = '1';
 itemCode = 'ITEM-AAAA-00001';
 UM = 'GR';
 quantity = 50000;

Exec SQL
 INSERT INTO WhsTra00F
 (trnProg, whsCode, trnDate, trnCode,
 trnSign, itemType, itemCode, UM, quantity
 )
 VALUES
 (:trnProg, :whsCode, :trnDate, :trnCode,
 :trnSign, :itemType, :itemCode, :UM, :quantity
 )
 ;

on-error;
   rolbk;
endmon;

commit;
*inLR=*on;
return;