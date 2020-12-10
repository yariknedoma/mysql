
1. Проанализировать какие запросы могут выполняться наиболее
часто в процессе работы приложения и добавить необходимые индексы.

CREATE INDEX users_last_name_idx ON users(last_name);
CREATE INDEX profiles_birthday_idx ON profiles(birthday);

2. Задание на оконные функции
Построить запрос, который будет выводить следующие столбцы:
имя группы;
среднее количество пользователей в группах;
самый молодой пользователь в группе;
самый старший пользователь в группе;
общее количество пользователей в группе;
всего пользователей в системе;
отношение в процентах (общее количество пользователей в группе / всего пользователей в системе) * 100.
        
SELECT 
DISTINCT communities.id, 
communities.name,
ROUND(
  (COUNT(*) OVER())/(SELECT COUNT(*) FROM communities),2) average,
MIN(profiles.birthday) OVER w AS youngest,
MAX(profiles.birthday) OVER w AS oldest,
COUNT(*) OVER w followers,
(SELECT COUNT(*) FROM users) total_users,
ROUND(
  (COUNT(*) OVER w)/(SELECT COUNT(*) FROM users)*100, 2) 'followers_%'
FROM (communities
      JOIN communities_users
      ON communities.id = communities_users.community_id
       JOIN profiles
       ON communities_users.user_id = profiles.user_id)
        JOIN users
        ON profiles.user_id = users.id
         WINDOW w AS (PARTITION BY communities.id);
        