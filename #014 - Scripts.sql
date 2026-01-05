------ Create Excel from PF
VALUES systools.generate_spreadsheet(
PATH_NAME => '/home/MDUCA/WHS_transactions_1',
LIBRARY_NAME => 'MDUCA1',
FILE_NAME => 'SQT13001T',
SPREADSHEET_TYPE => 'xlsx',
COLUMN_HEADINGS => 'COLUMN'
)
;
------ Create Excel from SQL statement
VALUES systools.generate_spreadsheet(
PATH_NAME => '/home/MDUCA/WHS_transactions_2',
SPREADSHEET_QUERY => 
 'SELECT trnProg, whsCode, trnDate, itemType, itemCode,
  um, quantity 
  FROM mduca1.WHSTRA00F WHERE annul = '' '' 
  AND whsCode = ''W01''',
SPREADSHEET_TYPE => 'xlsx',
COLUMN_HEADINGS => 'COLUMN'
)
;
------ Create Excel from PF with column labels
VALUES systools.generate_spreadsheet(
PATH_NAME => '/home/MDUCA/WHS_transactions_3',
SPREADSHEET_QUERY => 
 'SELECT trnProg, whsCode, trnDate, itemType, itemCode,
  um, quantity 
  FROM mduca1.WHSTRA00F WHERE annul = '' '' 
  AND whsCode = ''W27''',
SPREADSHEET_TYPE => 'xlsx',
COLUMN_HEADINGS => 'LABEL'
)
;