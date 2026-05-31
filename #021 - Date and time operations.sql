-- IBMi SQL Tips #21 - examples


-- date numeric (8, 0) YYYYMMDD to DDMMYYYY
VALUES
VARCHAR_FORMAT(
 DATE(TIMESTAMP_FORMAT(CHAR(:dateNum), 'YYYYMMDD')), 
 'DDMMYYYY'
) 
;    
-- date numeric (8, 0) DDMMYYYY to YYYYMMDD  
VALUES
VARCHAR_FORMAT(
 DATE(TIMESTAMP_FORMAT(RIGHT('0' CONCAT VARCHAR(:dateNum), 8), 
 'DDMMYYYY')), 
 'YYYYMMDD'
) 
--- miscellaneous examples
;  
VALUES CURRENT_DATE + 1 MONTHS + 15 DAYS
;
VALUES DATE('2026-05-30') - 3 YEARS
;
VALUES DATE('2024-02-29') - 1 YEARS
;
VALUES FIRST_DAY('2024-02-03')
;
VALUES QUARTER('2026-01-24')
;
VALUES MONTHNAME('2026-09-24')
;
VALUES WEEK('2026-01-04')
;
VALUES WEEK_ISO('2026-01-04')
;
-- dates and days difference
VALUES DATE('2026-05-31') - DATE('2025-01-01');
VALUES DAYS(DATE('2026-05-31')) - DAYS(DATE('2025-01-01')); 

--- first day of quarter
VALUES DATE(CHAR(YEAR(:pdata) CONCAT '-01-01')) + 
((QUARTER(:pdata) - 1) * 3 ) MONTHS
;
--- last day of quarter
VALUES DATE(CHAR(YEAR(:pdata) CONCAT '-01-01')) + 
(QUARTER(:pdata) * 3 ) MONTHS - 1 DAYS
;
---- time difference in hours, min, sec
VALUES VARCHAR_FORMAT(
 TIMESTAMP('2000-01-01-00.00.00') + (TIME(:time2) - TIME(:time1)), 
 'HH24:MI:SS'
)
;

---- time difference between system log messages
WITH a AS(
SELECT message_id, message_timestamp msg_time
FROM   TABLE(qsys2.history_log_info(
START_TIME => CURRENT_TIME - 200 MINUTES
))
WHERE  message_id = 'CPF2234'
)
, b AS (
SELECT message_id, msg_time, LEAD(msg_time, 1) OVER(ORDER BY msg_time) msg_time2
FROM   a
ORDER BY msg_time
)
SELECT b.*, 
VARCHAR_FORMAT(
 TIMESTAMP('2000-01-01-00.00.00') + (TIME(msg_time2) - TIME(msg_time)), 
 'HH24:MI:SS'
) difference
FROM   b
WHERE msg_time2 IS NOT NULL
;
--- Get the current time of a specific city 
SELECT 
    x.time_zone          AS TIME_ZONE,
    x.local_date         AS LOCAL_DATE,
    x.local_time         AS LOCAL_TIME,
    x.is_daylight_saving AS IS_DST_ACTIVE
FROM JSON_TABLE(
    QSYS2.HTTP_GET(
        'https://timeapi.io/api/v1/time/current/zone?timeZone=' || CAST(:areaCity AS VARCHAR(100)), 
        ''),
    '$'
    COLUMNS(
        time_zone          VARCHAR(50)  PATH '$.timezone',
        local_date	       DATE         PATH '$.date',
        local_time         TIME         PATH '$.time',
        is_daylight_saving VARCHAR(5)   PATH '$.dst_active'
    )
) AS x
; 