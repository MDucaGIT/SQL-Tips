**free
// ---------------------------------------------------------------
// Get info from call stack - 3
// ---------------------------------------------------------------
ctl-opt decedit('0,') datedit(*dmy.)
 dftactgrp(*no) actgrp(*caller)
 option(*srcstmt : *nodebugio : *noexpdds)
 fixnbr(*zoned : *inputpacked)
 bnddir('SQLTIPS')
 ;
// *ENTRY PLIST
dcl-pi SQT10103 ;
end-pi;

dcl-pr getCallerPgm char(10);
end-pr;

dcl-pr isCalledFrom ind;
   dcl-parm   *n  char(10) const;
end-pr;


dcl-s msg        char(50);
dcl-s called     ind;
dcl-s caller     char(10);

Exec SQL
  SET OPTION COMMIT = *NONE,
             CLOSQLCSR=*ENDMOD,
             DLYPRP=*YES
  ;

 clear caller;
 clear called;
 clear caller;

 caller = getCallerPgm();
 msg = '> SQT10103 was called from: ' + caller;
 dsply msg;

 called = isCalledFrom('SQT02001');
 msg = '> SQT02001 &C in call stack.';
 if called;
    msg = %scanrpl('&C': 'appears': msg);
 else;
    msg = %scanrpl('&C': 'does not appear': msg);
 endif;
 dsply msg;

 called = isCalledFrom('SQT10101');
  msg = '> SQT10101 &C in call stack.';
 if called;
    msg = %scanrpl('&C': 'appears': msg);
 else;
    msg = %scanrpl('&C': 'does not appear': msg);
 endif;
 dsply msg;

*inLR=*on;
return; 