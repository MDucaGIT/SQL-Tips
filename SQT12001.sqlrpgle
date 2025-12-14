**free
// ---------------------------------------------------------------
// Service Program: SQT12001
// Get Warehouse inventory
//
//
// ---------------------------------------------------------------
 ctl-opt decedit('0,') datedit(*dmy.)
  nomain
  option(*srcstmt : *nodebugio : *noexpdds)
  fixnbr(*zoned : *inputpacked);

dcl-s  balance      zoned(13:2);
dcl-ds dsWHSTRA     extname('WHSTRA00F') end-ds;
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
// getItemsWhs - Retrieve all items in warehouse
//               with current stock on hand
//
//  INPUT parameters:
// - pWhsIN      VARCHAR(3)    Warehouse code
//
//  OUTPUT parameters:
//   TABLE
// - pItmType    CHAR(1)      Item type
// - pItmCode    CHAR(40)     Item Code
// - pItmDesc    CHAR(80)     Item Description
// - pWhs        CHAR(3)      Warehouse code
// - pUM         CHAR(2)      Unit of measure
// - pBalance    NUMERIC(13, 2)      Current balance (stock on hand)
//
//*******************************************************************
dcl-proc  getItemsWhs   export;
  dcl-pi getItemsWhs   ;
    // input parms
    dcl-parm   pWhsIN      varchar(3) const;
    // Output table columns
    dcl-parm   pItmType    like(ItemType) ;
    dcl-parm   pItmCode    like(ItemCode) ;
    dcl-parm   pItmDesc    char(80);
    dcl-parm   pWhs        like(WhsCode);
    dcl-parm   pUM         like(UM);
    dcl-parm   pBalance    zoned(13: 2);
    // null indicators - Define one for each input parameter and
    //  for each column of output table
    dcl-parm   n_pWhsIN    int(5) const ;
    dcl-parm   n_pItmType  int(5)       ;
    dcl-parm   n_pItmCode  int(5)       ;
    dcl-parm   n_pItmDesc  int(5)       ;
    dcl-parm   n_pWhs      int(5)       ;
    dcl-parm   n_pUM       int(5)       ;
    dcl-parm   n_pBalance  int(5)       ;
    // SQL fixed parameters
    dcl-parm   state       char(5) ;
    dcl-parm   function    varchar(517) const;
    dcl-parm   specific    varchar(128) const;
    dcl-parm   errorMsg    varchar(1000) ;
    dcl-parm   callType    int(10) const;
  end-pi;

dcl-c CALL_OPEN        -1;
dcl-c CALL_FETCH        0;
dcl-c CALL_CLOSE        1;
dcl-c PARM_NULL        -1;
dcl-c PARM_NOTNULL      0;
dcl-c EOF             100;

monitor;
// Check for input parameters
if n_pWhsIN=PARM_NULL;
  state = '38999';
  errorMsg = 'Warehouse code not specified' ;
return;
endif;

// Manage operations
select;
when CallType = CALL_OPEN;
  exsr doOpen;
when CallType = CALL_FETCH;
  exsr doFetch;
when CallType = CALL_CLOSE;
  exsr doClose;
endsl;

on-error;
    state = '38998';
    return ;
endmon;

return ;
//-----------------------------------------------------------------------
// Declare and Open cursor
//-----------------------------------------------------------------------
begsr doOpen;

    Exec SQL
    DECLARE c1 CURSOR FOR
    WITH itemswhs AS (
      SELECT DISTINCT t.ITEMTYPE, t.ITEMCODE,
            t.WHSCODE, t.UM
      FROM  WhsTra00f t
      WHERE t.Annul = ' '
    )
    SELECT  t.ITEMTYPE, t.ITEMCODE, i.ITEMDESC,
            t.WHSCODE, t.UM, getItemBalance(
              t.ITEMTYPE, t.ITEMCODE, t.WHSCODE
            )
    FROM itemswhs t
    LEFT JOIN ItemMs00f i ON (t.ItemType, t.ItemCode)=(i.ItemType, i.ItemCode)
    WHERE   t.WhsCode = (
            CASE WHEN :pWhsIN = '***' THEN t.WhsCode
                 ELSE :pWhsIN END
      )
    ;
    Exec SQL
    OPEN c1
    ;

endsr;
//-----------------------------------------------------------------------
// Fetch one row
//-----------------------------------------------------------------------
begsr doFetch;

    Exec SQL
    FETCH c1
    INTO    :pItmType :n_pItmType,
            :pItmCode :n_pItmCode,
            :pItmDesc :n_pItmDesc,
            :pWhs :n_pWhs,
            :pUM :n_pUM,
            :pBalance
    ;
    select;
    // End of file
    when SQLCODE = EOF;
        state = '02000';
        return;
    // Other errors detected
    when SQLCODE <> 0;
        state = '38998';
        errorMsg = 'Error in reading data';
        return;
    endsl;

endsr;
//-----------------------------------------------------------------------
// Close cursor
//-----------------------------------------------------------------------
begsr doClose;

  Exec SQL
  CLOSE  c1
  ;

endsr;

end-proc;
