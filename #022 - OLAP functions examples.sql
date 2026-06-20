--- Add line number
SELECT ROW_NUMBER() OVER(), whscode, trnprog 
FROM 	mduca1.whstra00f
;
---- RANK + DENSE_RANK 
WITH a AS (
SELECT ordcust, SUM(ordinvoiced ) AS invoiced
FROM	mduca1.ordhd00f
WHERE  	annul = ' '
GROUP BY ordcust
)
SELECT
ROW_NUMBER() OVER() line,
ordcust, invoiced,
RANK() OVER(ORDER BY invoiced DESC) rank,
DENSE_RANK() OVER(ORDER BY invoiced DESC) dense
FROM	a
;
---- Quartiles with NTILE
WITH a AS (
SELECT ordcust, SUM(ordinvoiced ) AS invoiced
FROM	mduca1.ordhd00f
WHERE  	annul = ' '
GROUP BY ordcust
)
SELECT
ordcust, invoiced,
NTILE(4) OVER(ORDER BY invoiced DESC) AS quartile
FROM	a
;
---- Days between two item transactions
SELECT 
    itemcode, 
    trndate,
    LAG(trndate, 1) OVER(PARTITION BY itemcode ORDER BY trndate) AS previous_trn_date,
    trndate - LAG(trndate, 1) OVER(PARTITION BY itemcode ORDER BY trndate) AS elapsed_days
FROM mduca1.whstra00f
;
-- Running total per item
WITH A AS (
SELECT  whscode, itemcode, trndate, trnsign, 
CASE WHEN TRNSIGN = '-' THEN QUANTITY*(-1)
	ELSE QUANTITY END QTY
FROM	mduca1.whstra00f
ORDER BY whscode, itemcode, trndate
)
SELECT whscode, itemcode, trndate, QTY,
sum(QTY) over(PARTITION BY whscode, itemcode ORDER BY trndate) AS running_tot
FROM 	a
ORDER BY whscode, itemcode, trndate
;
--- Running total per warehouse
WITH A AS (
SELECT  whscode, itemcode, trndate, trnsign, 
CASE WHEN TRNSIGN = '-' THEN QUANTITY*(-1)
	ELSE QUANTITY END qty
FROM	mduca1.whstra00f 
WHERE   whscode = 'W01'
ORDER BY whscode, itemcode, trndate
)
SELECT whscode, itemcode, trndate, qty,
sum(QTY) over(ORDER BY trndate ROWS UNBOUNDED PRECEDING ) AS running_tot
FROM 	a
ORDER BY whscode, itemcode, trndate
;
-- Group totals with ROLLUP
WITH A AS (
SELECT  whscode, itemcode, trndate, trnsign, 
CASE WHEN TRNSIGN = '-' THEN QUANTITY*(-1)
	ELSE QUANTITY END QTY
FROM	mduca1.whstra00f
ORDER BY whscode, itemcode, trndate
)
SELECT COALESCE(whscode, 'Gross total'), COALESCE(itemcode, 'Whs total') AS item,
SUM(qty) AS total
FROM 	a
GROUP BY ROLLUP(whscode, itemcode)
;
--- All groups totals with CUBE
WITH A AS (
SELECT  whscode, itemcode, trndate, trnsign, 
CASE WHEN TRNSIGN = '-' THEN QUANTITY*(-1)
	ELSE QUANTITY END QTY
FROM	mduca1.whstra00f
ORDER BY whscode, itemcode, trndate
)
SELECT 
CASE WHEN whscode IS NULL AND itemcode IS NULL THEN 'Gross total'
	 WHEN whscode IS NULL AND itemcode IS NOT NULL THEN 'Item total'
	 ELSE whscode END AS warehouse,
CASE WHEN itemcode IS NULL AND whscode IS NULL THEN 'Gross total'
	 WHEN itemcode IS NULL AND whscode IS NOT NULL THEN 'Warehouse total'
	 ELSE itemcode END AS item,
SUM(qty) running_tot
FROM 	a
GROUP BY CUBE(whscode, itemcode) 
ORDER BY whscode, itemcode
;
