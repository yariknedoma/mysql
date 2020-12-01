к каждому заданию добавил сначала старый и затем новый запросы.

3. Определить кто больше поставил лайков (всего) - мужчины или женщины?

SELECT 
       (SELECT gender 
        FROM profiles 
        WHERE profiles.user_id = likes.user_id) AS sex, 
        COUNT(user_id) AS total_likes
FROM likes 
GROUP BY sex;

SELECT p.gender, 
       COUNT(*) likes
FROM profiles p
  JOIN likes l
    ON l.user_id = p.user_id
GROUP BY 1;

4. Подсчитать общее количество лайков десяти самым молодым пользователям (сколько лайков получили 10 самых молодых пользователей).

SELECT COUNT(*) AS total_likes
FROM likes 
WHERE target_type_id = 2 
      AND target_id IN (SELECT * FROM 
                                    (SELECT user_id 
                                     FROM profiles 
                                     ORDER BY birthday DESC
                                     LIMIT 10) 
                                               temp_tab);
                        
SELECT COUNT(*) likes 
FROM likes l
  JOIN (SELECT * 
        FROM profiles 
        ORDER BY birthday DESC
        LIMIT 10) p
    ON l.target_id = p.user_id AND l.target_type_id = 2;
    
    
5. Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети

(критерии активности необходимо определить самостоятельно).

SELECT user_id, 
       COUNT(*) AS total_likes, 
       (SELECT COUNT(*) 
          FROM posts 
          WHERE posts.user_id = likes.user_id) AS total_posts,
        COUNT(*)+(SELECT COUNT(*) 
                   FROM posts 
                   WHERE posts.user_id = likes.user_id) likes_and_posts
FROM likes 
GROUP BY user_id 
ORDER BY 4 
LIMIT 10;
                   
SELECT l.user_id, l.total_likes + p.total_posts likes_and_posts
FROM (SELECT user_id, COUNT(*) total_likes
      FROM likes
      GROUP BY 1) l
  JOIN (SELECT user_id, COUNT(*) total_posts
        FROM posts
        GROUP BY 1) p
    ON l.user_id = p.user_id
ORDER BY 2 
LIMIT 10;