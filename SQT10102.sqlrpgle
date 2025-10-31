**free
// ---------------------------------------------------------------
// Get info from call stack - 2
// ---------------------------------------------------------------
ctl-opt decedit('0,') datedit(*dmy.)
 dftactgrp(*no) actgrp(*caller)
 option(*srcstmt : *nodebugio : *noexpdds)
 fixnbr(*zoned : *inputpacked);
// *ENTRY PLIST
dcl-pi SQT10102 ;
end-pi;

// prototype for SQT10103
dcl-pr SQT10103 extpgm('SQT10103');
end-pr;

Exec SQL
  SET OPTION COMMIT = *NONE,
             CLOSQLCSR=*ENDMOD,
             DLYPRP=*YES
  ;

 SQT10103();


*inLR=*on;
return; 