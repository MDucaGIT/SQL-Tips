--- Books table
SELECT *
FROM JSON_TABLE(
GET_CLOB_FROM_FILE('/home/MDUCA/SQL_Tips/#5-BooksAndMagazines.json'),
'lax $.Books[*]'
COLUMNS(
"ID"		CHAR(6)  PATH '$.BookID',
"Title"		CHAR(30) PATH '$.Title',
"Genre"		CHAR(30) PATH '$.Genre',
"PublicationYear"  INTEGER PATH '$.PublicationYear',
"ISBN"		CHAR(20)  PATH '$.ISBN'
)
)
;
--- Books and authors (max.2)
SELECT *
FROM JSON_TABLE(
GET_CLOB_FROM_FILE('/home/MDUCA/SQL_Tips/#5-BooksAndMagazines.json'),
'lax $.Books[*]'
COLUMNS(
"ID"		CHAR(6)  PATH '$.BookID',
"Title"		CHAR(30) PATH '$.Title',
"Genre"		CHAR(30) PATH '$.Genre',
"PublicationYear"  INTEGER PATH '$.PublicationYear',
"ISBN"		CHAR(20)  PATH '$.ISBN',
"Author1"	CHAR(30)  PATH 'lax $.Authors[0]',
"Author2"	CHAR(30)  PATH 'lax $.Authors[1]'
)
)
;
---- BookID + Authors (undefined number)
SELECT *
FROM JSON_TABLE(
GET_CLOB_FROM_FILE('/home/MDUCA/SQL_Tips/#5-BooksAndMagazines.json'),
'lax $.Books[*]'
COLUMNS(
"ID"		CHAR(6)  PATH '$.BookID',
NESTED PATH '$.Authors[*]'
COLUMNS(
"Author"	CHAR(30) PATH '$'
)
)
)
;