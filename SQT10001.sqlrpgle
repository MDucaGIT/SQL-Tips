**free
// ---------------------------------------------------------------
// Service Program: SQT10001
// Get info from call stack
// ---------------------------------------------------------------
 ctl-opt decedit('0,') datedit(*dmy.)
  nomain
  option(*srcstmt : *nodebugio : *noexpdds)
  fixnbr(*zoned : *inputpacked);


// Program status data structure
dcl-ds PSDS psds qualified;
  thisPgm         *PROC;
end-ds;

Exec SQL
  SET OPTION
      COMMIT = *NONE,
      CLOSQLCSR = *ENDACTGRP,
      DLYPRP = *YES
  ;

//*******************************************************************
// isCalledFrom - Check if given program is in call stack
//
// INPUT parameters:
// - pPgm      Program to check   CHAR(10)
//
/// OUTPUT parameters:
// - pCalled   '1'=program appears in call stack  IND
//
//*******************************************************************
 dcl-proc  isCalledFrom   export;
    dcl-pi isCalledFrom   ind;
       dcl-parm pPgm      char(10);
    end-pi;

 dcl-s pCalled      ind;

 monitor;
 pCalled = *off;
 Exec SQL
 SELECT '1'
 INTO   :pCalled
 FROM TABLE (QSYS2.STACK_INFO('*')) s
 WHERE program_library_name NOT LIKE 'Q%'
   AND program_name = :pPgm
 LIMIT 1
;
 on-error;
 endmon;
 return pCalled;

 end-proc;
//*******************************************************************
// getCallerPgm - Get caller program name
//
// INPUT parameters:
// -     none
//
// OUTPUT parameters:
// - pCaller    caller program   CHAR(10)
//
//*******************************************************************
dcl-proc  getCallerPgm   export;
   dcl-pi getCallerPgm   char(10);
   end-pi;

dcl-s pCaller      char(10);

monitor;
clear pCaller;
Exec SQL
WITH a AS (
SELECT
 min(ordinal_position) pos, program_name, program_library_name
FROM TABLE(STACK_INFO(
JOB_NAME => '*'
))
WHERE  program_library_name NOT LIKE 'QSYS%'
  AND  program_name <> :psds.thispgm
GROUP BY program_name, program_library_name
)
SELECT program_name
  INTO :pCaller
FROM   a
ORDER BY pos DESC
OFFSET 1 ROWS
FETCH FIRST 1 ROWS ONLY
;
on-error;
endmon;
return pCaller;

end-proc;
 