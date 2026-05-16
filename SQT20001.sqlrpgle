**free
 ctl-opt decedit('0,') datedit(*dmy.)
  dftactgrp(*no) actgrp(*caller)
  option(*srcstmt : *nodebugio : *noexpdds)
  fixnbr(*zoned : *inputpacked);
// ------------------------------------------------------------------
// Prototypes and Overloading Definition
// ------------------------------------------------------------------

// The "Master" procedure: The compiler selects the implementation
// based on the data type of the first parameter.
dcl-pr editDate varchar(30) overload(editDateN: editDateC);

// Prototype for Numeric implementation
dcl-pr editDateN varchar(30);
  p_dateIn   packed(8:0) const;
  p_sep      char(1)     const;
  p_dayLet   char(3)     const options(*nopass);
  p_format   char(5)     const options(*nopass);
end-pr;

// Prototype for Character implementation
dcl-pr editDateC varchar(30);
  p_dateIn   varchar(10) const;
  p_sep      char(1)     const;
  p_dayLet   char(3)     const options(*nopass);
  p_format   char(5)     const options(*nopass);
end-pr;

// Program status data structure
dcl-ds PSDS psds qualified;
  thisPgm         *PROC;
end-ds;

dcl-s resultP  varchar(30);
dcl-s resultZ  varchar(30);
dcl-s resultC  varchar(30);
dcl-s datePacked packed(8);
dcl-s dateZoned packed(8);
dcl-s dateChar   char(10);
// ------------------------------------------------------------------
// Main Program Logic
// ------------------------------------------------------------------

Exec SQL
  SET OPTION COMMIT = *NONE,
             CLOSQLCSR=*ENDMOD,
             DLYPRP=*YES
  ;
datePacked = 10052026;
// Call with Numeric input (Triggers editDateN)
resultP = editDate(datePacked: '-': 'NO': '*DMYY');

dateZoned = 11052026;
// Call with Numeric input (Triggers editDateN)
resultZ = editDate(dateZoned: '-': 'NO': '*DMYY');

// Call with Character input (Triggers editDateC)
dateChar = '15052026';
resultC = editDate('15052026': '/': 'YES': '*DMYY');

dsply ('Packed Call: ' + resultP); 
dsply ('Zoned Call: ' + resultZ); 
dsply ('Char Call: ' + resultC);    
*inLR = *on;
return;

// ------------------------------------------------------------------
// Procedure: editDateN (Numeric Implementation)
// ------------------------------------------------------------------
dcl-proc editDateN;
  dcl-pi *n varchar(30);
    p_dateIn   packed(8:0) const;
    p_sep      char(1)     const;
    p_dayLet   char(3)     const options(*nopass);
    p_format   char(5)     const options(*nopass);
  end-pi;

  dcl-s v_dateIso  date;
  dcl-s v_dateOut  varchar(30);
  dcl-s v_dayLet   char(3) inz('NO');
  dcl-s v_format   char(5) inz('*DMYY');
  dcl-s v_workStr  char(8);
  dcl-s v_dayName  char(10);

  // Handle optional parameters (Default values)
  if %parms >= 3;
    v_dayLet = p_dayLet;
  endif;
  if %parms >= 4;
    v_format = p_format;
  endif;

  // Convert numeric to string with leading zeros (similar to SQL DIGITS)
  v_workStr = %editc(p_dateIn: 'X');

  monitor;
    // Format logic based on the format parameter
    select;
      when v_format = '*DMYY' or v_format = '*MDYY';
        v_dateOut = %subst(v_workStr: 1: 2) + p_sep +
                    %subst(v_workStr: 3: 2) + p_sep +
                    %subst(v_workStr: 5: 4);
      when v_format = '*YYMD';
        v_dateOut = %subst(v_workStr: 7: 2) + p_sep +
                    %subst(v_workStr: 5: 2) + p_sep +
                    %subst(v_workStr: 1: 4);
      other;
        return '*ERROR - Invalid format';
    endsl;

    // If day in letters is requested
    if v_dayLet = 'YES';
      select;
        when v_format = '*DMYY';
          v_dateIso = %date(p_dateIn: *eur);
        when v_format = '*MDYY';
          v_dateIso = %date(p_dateIn: *usa);
        when v_format = '*YYMD';
          v_dateIso = %date(p_dateIn: *iso);
      endsl;

      clear v_dayName;
      Exec SQL
        VALUES DAYNAME(:v_dateIso)
        INTO :v_dayname
        ;
      v_dateOut = %trim(v_dayName) + ' ' + v_dateOut;
    endif;

  on-error;
    return '*ERROR - Invalid date';
  endmon;

  return v_dateOut;
end-proc;

// ------------------------------------------------------------------
// Procedure: editDateC (Character Implementation)
// ------------------------------------------------------------------
dcl-proc editDateC;
  dcl-pi *n varchar(30);
    p_dateIn   varchar(10) const;
    p_sep      char(1)     const;
    p_dayLet   char(3)     const options(*nopass);
    p_format   char(5)     const options(*nopass);
  end-pi;

  dcl-s v_dateNum  packed(8:0);
  dcl-s v_dayLet   char(3) inz('NO');
  dcl-s v_format   char(5) inz('*DMYY');

  // Handle optional parameters (Default values)
  if %parms >= 3;
    v_dayLet = p_dayLet;
  endif;
  if %parms >= 4;
    v_format = p_format;
  endif;

  // Convert character input to numeric and invoke the master procedure
  // which will automatically route the call to editDateN.
  monitor;
    v_dateNum = %dec(p_dateIn: 8: 0);
  on-error;
    return '*ERROR - Non-numeric input';
  endmon;

  return editDate(v_dateNum: p_sep: v_dayLet: v_format);
end-proc;