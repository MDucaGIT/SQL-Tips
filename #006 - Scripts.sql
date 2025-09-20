-------- Call REST API to get 25 products 
WITH a (rsp) AS (
VALUES(qsys2.http_get(
'https://dummyjson.com/products/search?q=phone&limit=25',
'{
"header": "accept,text/plain",
"header": "Content-Type, application/json",
"sslTolerate" : "true"
}
'
))
)
SELECT id, brand, title, category, price, stock
FROM a,
JSON_TABLE
(
rsp,
'lax $.products[*]'
COLUMNS
(
ID         dec(5)    PATH '$.id',
brand      char(25)  PATH '$.brand',
title      char(40)  PATH '$.title',
category   char(40)  PATH '$.category',
price      dec(12,2) PATH '$.price',
stock      dec(5)    PATH '$.stock'
)
) AS j
;

------ Improved version with HTTP Status code
WITH a (rspmsg, rsphdr) AS (
SELECT * FROM TABLE (qsys2.http_get_verbose(
'https://dummyjson.com/products/search?q=phone&limit=25',
'{
"header": "accept,text/plain",
"header": "Content-Type, application/json",
"sslTolerate" : "true"
}
'
))
)
, hdr AS (
SELECT status
FROM a,
JSON_TABLE
(
rsphdr,
'lax $'
COLUMNS
(
status    char(5)   PATH '$.HTTP_STATUS_CODE'
))
)
, msg AS (
SELECT id, brand, title, category, price, stock
FROM a,
JSON_TABLE
(
rspmsg,
'lax $.products[*]'
COLUMNS
(
ID        dec(5)    PATH '$.id',
brand     char(25)  PATH '$.brand',
title     char(40)  PATH '$.title',
category  char(40)  PATH '$.category',
price     dec(12,2) PATH '$.price',
stock     dec(5)    PATH '$.stock'
)
) AS j
)
SELECT *
FROM    hdr
LEFT JOIN    msg ON 1=1
;