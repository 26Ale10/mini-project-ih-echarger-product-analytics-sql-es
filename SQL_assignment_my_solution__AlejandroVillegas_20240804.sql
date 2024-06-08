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


-- Question 9: Top 3 users with more chargers being used




-- LEVEL 4

-- Question 10: Number of users that have used only AC chargers, DC chargers or both

-- Question 11: Monthly average number of users per charger

-- Question 12: Top 3 users per charger (for each charger, number of sessions)




-- LEVEL 5

-- Question 13: Top 3 users with longest sessions per month (consider the month of start_time)
    
-- Question 14. Average time between sessions for each charger for each month (consider the month of start_time)
