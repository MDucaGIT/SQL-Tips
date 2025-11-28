**free
// ---------------------------------------------------------------
// Service Program: SQT11001
// Get Item Balance
// ---------------------------------------------------------------
 ctl-opt decedit('0,') datedit(*dmy.)
  nomain
  option(*srcstmt : *nodebugio : *noexpdds)
  fixnbr(*zoned : *inputpacked);

dcl-s balance      zoned(13:2);

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
// getItemBalance - Get item balance to date
//
// INPUT parameters:
// - pType      Item type  VARCHAR(1)
// - pItem      Item code  VARCHAR(40)
// - pWhs       Warehouse code  VARCHAR(3)
// - pDate      Balance date DATE
//
/// OUTPUT parameters:
// - balance    Balance to date   ZONED(13:2)
//
//*******************************************************************
 dcl-proc  getItemBalance   export;
    dcl-pi getItemBalance   zoned(13:2);
       dcl-parm pType     varchar(1)  const;
       dcl-parm pItem     varchar(40) const;
       dcl-parm pWhs      varchar(3)  const;
       dcl-parm pDate     date const;
    end-pi;

 monitor;
 balance = 0;
 Exec SQL
 SELECT COALESCE(
  SUM(CASE WHEN TrnSign = '-' THEN Quantity * (-1)
           ELSE Quantity END)
  , 0)
 INTO   :balance
 FROM   WhsTra00f
 WHERE Annul = ' '
   AND ItemType = :pType
   AND ItemCode = :pItem
   AND WhsCode  = (
    CASE WHEN :pWhs = '***' THEN WhsCode
    ELSE :pWhs END)
   AND TrnDate <= :pDate
 ;
 on-error;
 endmon;
 return balance;

 end-proc;
//*******************************************************************
// getItemBalance2 - Get item balance to date
//                   Date parameter not passed
// INPUT parameters:
// - pType      Item type  VARCHAR(1)
// - pItem      Item code  VARCHAR(40)
// - pWhs       Warehouse code  VARCHAR(3)
//
/// OUTPUT parameters:
// - balance    Balance to date   ZONED(13:2)
//
//*******************************************************************
 dcl-proc  getItemBalance2  export;
    dcl-pi getItemBalance2  zoned(13:2);
       dcl-parm pType     varchar(1)  const;
       dcl-parm pItem     varchar(40) const;
       dcl-parm pWhs      varchar(3)  const;
    end-pi;

dcl-s today      date;
monitor;
today = %date();
balance = getItemBalance(pType: pItem: pWhs: today);

on-error;
endmon;
return balance;

end-proc;