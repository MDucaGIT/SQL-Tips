**free
// ---------------------------------------------------------------
// Get info from call stack - 1
// ---------------------------------------------------------------
ctl-opt decedit('0,') datedit(*dmy.)
 dftactgrp(*no) actgrp(*caller)
 option(*srcstmt : *nodebugio : *noexpdds)
 fixnbr(*zoned : *inputpacked);
// *ENTRY PLIST
dcl-pi SQT10101 ;
end-pi;
// prototype for SQT10102
dcl-pr SQT10102 extpgm('SQT10102');
end-pr;


Exec SQL
  SET OPTION COMMIT = *NONE,
             CLOSQLCSR=*ENDMOD,
             DLYPRP=*YES
  ;

 SQT10102();


*inLR=*on;
return; 