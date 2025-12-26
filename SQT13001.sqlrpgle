**free
// ---------------------------------------------------------------
// Print warehouse transactions report
// ---------------------------------------------------------------
 ctl-opt decedit('0,') datedit(*dmy.)
  option(*srcstmt : *nodebugio : *noexpdds)
  fixnbr(*zoned : *inputpacked);
// ---------------------------------------------------------------
dcl-f  SQT13001P printer oflind(*in88);
// *ENTRY PLIST
dcl-pi SQT13001 ;
   pWhs          char(3) options(*nopass);
end-pi;

// Program status data structure
dcl-ds PSDS psds qualified;
  thisPgm         *PROC;
end-ds;

dcl-s  $exit      ind;
dcl-s  dateISO    date;
dcl-s  whs        like(pWhs);
dcl-s  overflow   ind based(pIn88);
dcl-s  pIn88      pointer inz(%addr(*in(88)));
dcl-c  EOF        100;
// ---------------------------------------------------------------

Exec SQL
  SET OPTION COMMIT = *NONE,
             CLOSQLCSR=*ENDMOD,
             DLYPRP=*YES
  ;

 vline1 = *all'-';
 vline2 = *all'-';
 vtoday = %dec(%date(): *EUR);
 vpgm   = PSDS.thisPgm;
 if not %passed(pWhs);
    whs = '***';
 else;
    whs = pWhs;
 endif;

 Exec SQL
   DECLARE c1 CURSOR FOR
   SELECT TrnProg, WhsCode, TrnDate,
    ItemType, ItemCode, UM,
    CASE WHEN TrnSign = '-' THEN Quantity * (-1)
         ELSE Quantity END
    FROM WhsTra00f
   WHERE Annul = ' '
     AND WhsCode = (CASE WHEN :whs = '***' THEN WhsCode
         ELSE :whs END)
   ORDER BY TrnProg
   ;
 Exec SQL
   OPEN c1;

$exit = *off;
overflow = *on;
dou $exit;
  Exec SQL
  FETCH c1 INTO :vprogr, :vwhs, :dateISO,
                :vType, :vItem, :vUM,
                :vQty
  ;
  select;
    when SQLCODE = EOF;
      $exit = *on;
    when SQLCODE >= 0;
      vDate = %dec(dateISO: *EUR);
      if overflow;
         write HEADER;
         overflow = *off;
      endif;
      write LINE;
    other;
      $exit = *on;
  endsl;

enddo;

Exec SQL
  CLOSE c1;

*inLR=*on;
return;