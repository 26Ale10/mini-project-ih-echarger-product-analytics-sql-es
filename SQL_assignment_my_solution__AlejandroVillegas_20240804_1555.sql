-- LEVEL 1

-- Question 1: Number of users with sessions
-- Solution 1:
SELECT COUNT(DISTINCT user_id) AS Total_User
FROM sessions;


-- Question 2: Number of chargers used by user with id 1
-- Solution 2:

SELECT COUNT(*) 
FROM sessions
WHERE user_id = 1
;


-- LEVEL 2

-- Question 3: Number of sessions per charger type (AC/DC):
-- Solution 3:

SELECT T1.type as Type,
        COUNT(T2.ID)        
FROM chargers AS T1
JOIN sessions as T2
    ON
    T1.id = T2.charger_id
GROUP BY Type   
;

-- Question 4: Chargers being used by more than one user
-- Solution 4:
WITH T1 AS (
SELECT charger_id, COUNT(DISTINCT user_id) AS Total_users
FROM sessions
GROUP BY charger_id
HAVING COUNT(DISTINCT user_id > 1)
ORDER BY Total_users DESC)
SELECT T1.*,T2.label FROM T1
JOIN chargers AS T2 ON T1.charger_id = T2.id
;
-- Question 5: Average session time per charger
-- Solution 5: en horas
WITH T1 AS (
SELECT charger_id, round(avg((strftime('%s',end_time) - strftime('%s',start_time))/3600),2) as Avg_sesion_time 
FROM sessions
GROUP BY charger_id)
SELECT T2.label AS Charger, T1.Avg_sesion_time FROM T1
JOIN chargers AS T2 ON T2.id = T1.charger_id
;


-- LEVEL 3

-- Question 6: Full username of users that have used more than one charger in one day (NOTE: for date only consider start_time)
-- Solution 6:

SELECT * FROM users 
WHERE id IN 
(SELECT user_id FROM sessions
GROUP BY user_id, date(start_time)
HAVING COUNT(DISTINCT charger_id) > 1);

-- Question 7: Top 3 chargers with longer sessions
-- Solution 7:

WITH T1 AS (
SELECT charger_id, ((strftime('%s',end_time) - strftime('%s',start_time))/3600) as Sesion_time, rank() over(ORDER BY ((strftime('%s',end_time) - strftime('%s',start_time))/3600) DESC) AS ranking
FROM sessions
GROUP BY charger_id)
SELECT T2.label AS Charger, Sesion_time FROM T1
JOIN chargers AS T2 ON T2.id = T1.charger_id and Ranking < 4
;


-- Question 8: Average number of users per charger (per charger in general, not per charger_id specifically)
-- Solution 8:


SELECT type AS Type_Charger, (COUNT(DISTINCT user_id)) as conteo FROM sessions AS T1
JOIN chargers AS T2 ON T1.charger_id = T2.id

GROUP BY Type_Charger;


-- Question 9: Top 3 users with more chargers being used
WITH ranking_users AS (
SELECT user_id ,COUNT(DISTINCT charger_id) AS Total_chargers_used,rank() over(ORDER BY COUNT(DISTINCT charger_id) DESC) AS Ranking 
FROM sessions
GROUP BY user_id) SELECT Ranking, name as Name, surname as Surname FROM ranking_users
JOIN users AS T1 ON ranking_users.user_id = T1.id
WHERE Ranking < 4
;

-- LEVEL 4

-- Question 10: Number of users that have used only AC chargers, DC chargers or both
-- Solution 10:

SELECT name,surname, CASE WHEN USE_AC > 0 AND USE_DC > 0 THEN 'USE_BOTH'
                    WHEN USE_AC > 0 AND USE_DC = 0 THEN 'JUST_AC'
                    WHEN USE_AC = 0 AND USE_DC > 0 THEN 'JUST_DC' END AS USE FROM users AS U
JOIN
(WITH conteo AS (SELECT T1.*, 
CASE WHEN type LIKE 'AC' THEN 1 ELSE 0 END AS AC, 
CASE WHEN type LIKE 'DC' THEN 1 ELSE 0 END AS DC
FROM sessions AS T1
JOIN chargers AS T2 ON T1.charger_id = T2.id
ORDER BY user_id)
SELECT user_id, SUM(AC) AS USE_AC, SUM(DC) AS USE_DC
FROM conteo
GROUP BY user_id) AS T ON U.id = T.user_id;


-- Question 11: Monthly average number of users per charger
--Solution 11:
SELECT charger_id, COUNT(DISTINCT user_id) total_users FROM sessions

GROUP BY charger_id, strftime('%m',start_time);

-- Question 12: Top 3 users per charger (for each charger, number of sessions)
-- Solution 12:
WITH Ranking_final as (
WITH conteo_charger AS (
    SELECT charger_id, user_id, COUNT(id) AS sesiones_iniciadas
    FROM sessions
    GROUP BY charger_id, user_id
)

SELECT charger_id, user_id, sesiones_iniciadas, 
       ROW_NUMBER() OVER (PARTITION BY charger_id ORDER BY sesiones_iniciadas DESC) AS Ranking
FROM conteo_charger
ORDER BY charger_id,Ranking) SELECT * FROM Ranking_final
WHERE Ranking < 4
;

-- LEVEL 5

-- Question 13: Top 3 users with longest sessions per month (consider the month of start_time)
-- Solution 13: 

WITH T1 AS (SELECT user_id, strftime('%m',start_time) as month, round((strftime('%s',end_time) - strftime('%s',start_time))/3600) AS TIME FROM sessions), 
T2 AS( SELECT *, RANK() OVER(ORDER BY TIME DESC) as Ranking FROM T1
) SELECT * FROM T2
WHERE Ranking < 4;

-- Question 14. Average time between sessions for each charger for each month (consider the month of start_time)
-- Solution:

WITH T1 AS 
(
SELECT id,charger_id, strftime('%m',start_time) as month, round(((strftime('%s',end_time) - strftime('%s',start_time))/3600),2) as Sesion_time -- en minutos
FROM sessions
GROUP BY id, charger_id,month)
SELECT charger_id, month, round(avg(Sesion_time)) as Avg_sesion_time 
FROM T1
GROUP BY charger_id, month
;

