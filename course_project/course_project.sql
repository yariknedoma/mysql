-- -------------------------------------------------------------------------------------------
-- Составить общее текстовое описание БД и решаемых ею задач; минимальное количество таблиц - 10;

/*  
 В качестве курсовой работы, я решил попробовать построить часть функционала базы данных geekbrains.
 
 Моя БД состоит из 10 таблиц:
 	1. users - таблица пользователей
 	2. courses - таблица предметов
 	3. groups_courses - таблица груп студентов, периодически формирующихся для предметов
 	4. groups_users - таблица студентов, принадлежащих к группам 
 					  (один студент может состоять во многих группах)
 	5. homeworks - таблица для домашних заданий студентов
 	6. tests - таблица тестов, доступных для студентов
 	7. questions - таблица вопросов к тестам
 	8. answers - таблица ответов на вопросы для тестов
 	9. attempts - попытки прохождения тестов, совершенные студентами
 	10. attempts_questions - вопросы на тестах и ответы студентов на них
 
 В таблице не добавлен такой функционал, как сообщения, посты итд., 
 так как это все было рассмотрено на уроках.
 */


-- -------------------------------------------------------------------------------------------
-- скрипты создания структуры БД (с первичными ключами, индексами, внешними ключами);

-- пользователи
CREATE TABLE users (
user_id SERIAL PRIMARY KEY,
first_name VARCHAR(25) NOT NULL,
last_name VARCHAR(25) NOT NULL,
email VARCHAR(50) UNIQUE NOT NULL,
phone VARCHAR(20) UNIQUE NOT NULL);

-- предметы
CREATE TABLE courses (
course_id SERIAL PRIMARY KEY,
course_name VARCHAR(100) NOT NULL,
lessons_amount TINYINT UNSIGNED,
max_members TINYINT UNSIGNED);

-- группы для курсов
DROP TABLE IF EXISTS groups_courses;
CREATE TABLE groups_courses (
group_id SERIAL PRIMARY KEY,
course_id BIGINT UNSIGNED NOT NULL,
date_begins DATE,
date_ends DATE,
FOREIGN KEY (course_id) REFERENCES courses(course_id));

-- студенты в группе
DROP TABLE IF EXISTS groups_users;
CREATE TABLE groups_users (
id SERIAL PRIMARY KEY,
user_id BIGINT UNSIGNED NOT NULL,
group_id BIGINT UNSIGNED NOT NULL,
added_to_group DATE DEFAULT (CURRENT_DATE),
FOREIGN KEY (user_id) REFERENCES users(user_id),
FOREIGN KEY (group_id) REFERENCES groups_courses(group_id));

-- домашние работы
DROP TABLE IF EXISTS homeworks;
CREATE TABLE homeworks (
homework_id SERIAL PRIMARY KEY,
user_id BIGINT UNSIGNED NOT NULL,
group_id BIGINT UNSIGNED NOT NULL,
homework_link VARCHAR(255) NOT NULL,
lesson_number INT UNSIGNED NOT NULL,
grade TINYINT UNSIGNED,
created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY (user_id) REFERENCES users(user_id),
FOREIGN KEY (group_id) REFERENCES groups_courses(group_id));

-- тесты
DROP TABLE IF EXISTS tests;
CREATE TABLE tests (
test_id SERIAL PRIMARY KEY,
course_id BIGINT UNSIGNED,
test_name VARCHAR(50) NOT NULL,
questions_amount TINYINT UNSIGNED NOT NULL,
cor_ans_to_pass TINYINT UNSIGNED NOT NULL,
created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY (course_id) REFERENCES courses(course_id));

-- вопросы для тестов
DROP TABLE IF EXISTS questions;
CREATE TABLE questions (
question_id SERIAL PRIMARY KEY,
test_id BIGINT UNSIGNED NOT NULL,
question_name VARCHAR(50) NOT NULL,
created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY (test_id) REFERENCES tests(test_id));

-- ответы на вопросы
DROP TABLE IF EXISTS answers;
CREATE TABLE answers (
answer_id SERIAL PRIMARY KEY,
question_id BIGINT UNSIGNED NOT NULL,
answer_name VARCHAR(50) NOT NULL,
is_correct ENUM('0', '1'),
FOREIGN KEY (question_id) REFERENCES questions(question_id));

-- попытки студентов
DROP TABLE IF EXISTS test_attempts;
CREATE TABLE test_attempts (
attempt_id SERIAL PRIMARY KEY,
user_id BIGINT UNSIGNED NOT NULL,
test_id BIGINT UNSIGNED NOT NULL,
correct_answers TINYINT UNSIGNED,
date_attempt DATETIME DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY (user_id) REFERENCES users(user_id),
FOREIGN KEY (test_id) REFERENCES tests(test_id));

-- вопросы и ответы на тесты
DROP TABLE IF EXISTS attempts_questions;
CREATE TABLE attempts_questions (
id SERIAL PRIMARY KEY,
attempt_id BIGINT UNSIGNED NOT NULL,
question_id BIGINT UNSIGNED NOT NULL,
answer_id BIGINT UNSIGNED NOT NULL,
FOREIGN KEY (attempt_id) REFERENCES test_attempts(attempt_id),
FOREIGN KEY (question_id) REFERENCES questions(question_id),
FOREIGN KEY (answer_id) REFERENCES answers(answer_id));


-- -------------------------------------------------------------------------------------------
-- скрипты наполнения БД данными;

-- 100 пользователей из таблицы vk
INSERT INTO users (first_name, last_name, email, phone)
SELECT first_name, last_name, email, phone FROM vk.users;

-- 10 предметов
INSERT INTO courses (course_name, lessons_amount, max_members)
VALUES   ('Основы языка Python', 8, 50),
	   ('Linux. Рабочая станция', 8, 50),
	   ('Базы данных', 8, 50),
	   ('Библиотеки Python для Data Science: Numpy, Matplotlib, Scikit-learn', 10, 50),
	   ('Библиотеки Python для Data Science: продолжение', 4, 50),
	   ('Методы сбора и обработки данных из сети Интернет', 8, 50),
	   ('Введение в математический анализ', 11, 50),
	   ('Теория вероятностей и математическая статистика', 8, 50),
	   ('Линейная алгебра', 5, 50),
	   ('Алгоритмы анализа данных', 8, 50);
	   
-- 8 учебных групп
INSERT INTO groups_courses (course_id, date_begins, date_ends)
VALUES (1, '2020-12-12', '2021-02-01'),
       (1, '2021-01-15', '2021-03-15'),
       (2, '2020-10-11', '2020-11-11'),
       (3, '2020-11-05', '2021-01-10'),
       (4, '2021-02-20', '2021-04-01'),
       (5, '2021-04-08', '2021-05-15'),
       (6, '2020-09-25', '2020-12-05'),
       (7, '2020-08-13', '2021-11-02');
      
-- процедура по добавлению студентов в группы 
-- (с условием, что один студент может быть записан в одну и ту же группу только раз)
DELIMITER //

DROP PROCEDURE IF EXISTS adding_to_groups_users // 
CREATE PROCEDURE adding_to_groups_users(amount INT)
BEGIN
  DECLARE i INT DEFAULT 0;
  DECLARE u_id INT;
  DECLARE g_id INT;
  WHILE amount > i DO
    SET u_id = CEIL(RAND()*100);
    SET g_id = CEIL(RAND()*8);
    IF NOT EXISTS(SELECT user_id, group_id 
    			  FROM groups_users 
    			  WHERE user_id = u_id AND group_id = g_id)
    THEN 
      INSERT INTO groups_users (user_id, group_id)
      VALUES (u_id, g_id);
      SET i = i + 1;
    END IF;
  END WHILE;
END // 

DELIMITER ;

-- добавление 200 студентов
mysql> CALL adding_to_groups_users(200);
Query OK, 1 row affected (0.11 sec)

mysql> SELECT * 
    -> FROM groups_users 
    -> ORDER BY id DESC 
    -> LIMIT 5;
+-----+---------+----------+----------------+
| id  | user_id | group_id | added_to_group |
+-----+---------+----------+----------------+
| 200 |      24 |        7 | 2020-12-13     |
| 199 |      99 |        5 | 2020-12-13     |
| 198 |      24 |        2 | 2020-12-13     |
| 197 |      39 |        6 | 2020-12-13     |
| 196 |      90 |        4 | 2020-12-13     |
+-----+---------+----------+----------------+
5 rows in set (0.00 sec)


-- проверка на то, чтобы один студент не был записан в одну группу несколько раз

mysql> SELECT user_id, group_id
    -> FROM groups_users
    -> GROUP BY user_id, group_id HAVING COUNT(*)>1;
Empty set (0.00 sec)

-- данные для дз со ссылками из таблицы vk.media (для курсов, которые уже начались)

INSERT INTO homeworks (user_id, group_id, homework_link, lesson_number, grade)
SELECT gu.user_id, gu.group_id, vm.filename, 1, NULL
FROM groups_users gu JOIN vk.media vm
					 ON gu.id = vm.id
					   JOIN groups_courses gc 
					   USING (group_id)
WHERE gc.date_begins < NOW();

-- 3 теста по разным предметам

INSERT INTO tests (course_id, test_name, questions_amount, cor_ans_to_pass)
VALUES (2, 'Linux. Начальный уровень', 5, 4),
	   (1, 'Тест по Python. Начальный уровень', 5, 4),
	   (3, 'База данных MySql', 5, 3);
	  
-- 10 вопросов для каждого теста

INSERT INTO questions (test_id, question_name)
(SELECT 1, CONCAT(LEFT(body, 20), '?')
FROM vk.messages
LIMIT 10)
UNION
(SELECT 2, CONCAT(LEFT(body, 20), '?')
FROM vk.messages
WHERE id > 10
LIMIT 10)
UNION
(SELECT 3, CONCAT(LEFT(body, 20), '?')
FROM vk.messages
WHERE id > 20
LIMIT 10)
;

mysql> SELECT * 
	   FROM questions 
	   LIMIT 11;
+-------------+---------+-----------------------+---------------------+
| question_id | test_id | question_name         | created_at          |
+-------------+---------+-----------------------+---------------------+
|          78 |       1 | Voluptates libero ha? | 2020-12-13 11:43:49 |
|          79 |       1 | Et et minus voluptat? | 2020-12-13 11:43:49 |
|          80 |       1 | Accusantium sed est ? | 2020-12-13 11:43:49 |
|          81 |       1 | Nemo temporibus dolo? | 2020-12-13 11:43:49 |
|          82 |       1 | Ut distinctio eius p? | 2020-12-13 11:43:49 |
|          83 |       1 | Facere et dolor magn? | 2020-12-13 11:43:49 |
|          84 |       1 | Sequi laborum aspern? | 2020-12-13 11:43:49 |
|          85 |       1 | Ullam animi voluptas? | 2020-12-13 11:43:49 |
|          86 |       1 | Reiciendis ea asperi? | 2020-12-13 11:43:49 |
|          87 |       1 | Qui ullam debitis su? | 2020-12-13 11:43:49 |
|          88 |       2 | Quia cum in consequa? | 2020-12-13 11:43:49 |
+-------------+---------+-----------------------+---------------------+
11 rows in set (0.00 sec)

/* id начинается с 78 из-за того, что менял данные несколько раз, 
   а TRUNCATE нельзя выполнить из-за внешних ключей. 
   Удалять и ставить их снова, к сожалению, не очень хочется! */

-- по 2 варианта ответа на каждый вопрос

INSERT INTO answers (question_id, answer_name, is_correct)
 (SELECT question_id, LEFT(body, 5), '0' 
  FROM questions q 
    JOIN vk.messages vm 
    ON q.question_id = vm.id)
UNION 
 (SELECT question_id, LEFT(body, 5), '1' 
  FROM questions q 
    JOIN vk.messages vm 
    ON q.question_id + 100 = vm.id);

mysql> SELECT * 
	   FROM answers 
	   ORDER BY question_id 
	   LIMIT 10;
+-----------+-------------+-------------+------------+
| answer_id | question_id | answer_name | is_correct |
+-----------+-------------+-------------+------------+
|         1 |          78 | Labor       | 0          |
|        31 |          78 | Quia        | 1          |
|         2 |          79 | Ab au       | 0          |
|        32 |          79 | Omnis       | 1          |
|         3 |          80 | Minus       | 0          |
|        33 |          80 | Sit f       | 1          |
|         4 |          81 | Excep       | 0          |
|        34 |          81 | Volup       | 1          |
|         5 |          82 | Ut la       | 0          |
|        35 |          82 | Autem       | 1          |
+-----------+-------------+-------------+------------+
10 rows in set (0.00 sec)

-- 10 попыток студентов

INSERT INTO test_attempts (user_id, test_id)
VALUES (10, 2),
	   (20, 3),
	   (30, 1),
	   (35, 1),
	   (27, 2),
	   (84, 3),
	   (29, 1),
	   (32, 3),
	   (19, 1),
	   (74, 2);

-- вопросы и ответы на тесты

-- процедура по добавлению 5 вопросов к тесту по введеному id
DELIMITER //

DROP PROCEDURE IF EXISTS adding_to_attempts_questions // 
CREATE PROCEDURE adding_to_attempts_questions(u_id INT)
BEGIN
  DECLARE i INT DEFAULT 0;
  WHILE i < 1 DO 
    DROP TEMPORARY TABLE IF EXISTS tmp;
    CREATE TEMPORARY TABLE tmp AS
    SELECT ta.attempt_id, q.question_id, a.answer_id 
    FROM test_attempts ta 
       JOIN questions q 
       ON ta.test_id = q.test_id 
         JOIN answers a 
         ON q.question_id = a.question_id  
    WHERE user_id = u_id 
    ORDER BY rand() 
    LIMIT 5;
    IF (SELECT COUNT(DISTINCT question_id) FROM tmp) = 5 
    THEN 
      INSERT INTO attempts_questions (attempt_id, question_id, answer_id)
      SELECT * FROM tmp;
      SET i = i + 1;
    END IF;
  END WHILE;
END // 

DELIMITER ;

-- добавление

mysql> CALL adding_to_attempts_questions(10);
Query OK, 5 rows affected (0.00 sec)

mysql> CALL adding_to_attempts_questions(20);
Query OK, 5 rows affected (0.01 sec)

mysql> CALL adding_to_attempts_questions(30);
Query OK, 5 rows affected (0.01 sec)

mysql> CALL adding_to_attempts_questions(35);
Query OK, 5 rows affected (0.01 sec)

mysql> CALL adding_to_attempts_questions(27);
Query OK, 5 rows affected (0.01 sec)

...

mysql> SELECT attempt_id, question_id, answer_id 
	   FROM attempts_questions 
	   LIMIT 15;
+------------+-------------+-----------+
| attempt_id | question_id | answer_id |
+------------+-------------+-----------+
|          1 |          97 |        20 |
|          1 |          95 |        18 |
|          1 |          90 |        13 |
|          1 |          96 |        49 |
|          1 |          93 |        16 |
|          2 |         106 |        29 |
|          2 |         104 |        57 |
|          2 |         105 |        58 |
|          2 |         100 |        53 |
|          2 |         101 |        54 |
|          3 |          87 |        40 |
|          3 |          80 |        33 |
|          3 |          78 |        31 |
|          3 |          86 |        39 |
|          3 |          83 |        36 |
+------------+-------------+-----------+
15 rows in set (0.00 sec)

-- -------------------------------------------------------------------------------------------
-- скрипты характерных выборок (включающие группировки, JOIN'ы, вложенные таблицы);

-- 1. Запрос выводит имя и фамилию пользователя, название теста, 
--    название предмета, к которому относится тест, количество правильных ответов,
--    количество правильных ответов для сдачи теста и результат.

SELECT ta.attempt_id, CONCAT(u.first_name, ' ', u.last_name) name, t.test_name, c.course_name,
SUM(a.is_correct)-5 correct_answers, 
t.cor_ans_to_pass, IF(SUM(a.is_correct)-5>=t.cor_ans_to_pass, 'passed', 'failed') 'result'
FROM test_attempts ta JOIN users u
                      USING (user_id)
					    JOIN tests t
                        USING (test_id)
                          JOIN courses c 
                          USING (course_id)
                            JOIN attempts_questions aq 
                            USING (attempt_id)
                              JOIN answers a 
                              USING (answer_id)
GROUP BY attempt_id
ORDER BY result DESC;

/* 
 SUM(a.is_correct) почему-то считало 0 за 1, а 1 за 2, 
 поэтому для получения верного значения в таблице используется  SUM(a.is_correct)-5
 */

+------------+---------------------+---------------------------------------------------------+--------------------------------------+-----------------+-----------------+--------+
| attempt_id | name                | test_name                                               | course_name                          | correct_answers | cor_ans_to_pass | result |
+------------+---------------------+---------------------------------------------------------+--------------------------------------+-----------------+-----------------+--------+
|          3 | Ramona Ziemann      | Linux. Начальный уровень                                | Linux. Рабочая станция               |               5 |               4 | passed |
|          2 | Elroy Lemke         | База данных MySql                                       | Базы данных                          |               4 |               3 | passed |
|          8 | Brice Gaylord       | База данных MySql                                       | Базы данных                          |               3 |               3 | passed |
|          4 | Alf Zboncak         | Linux. Начальный уровень                                | Linux. Рабочая станция               |               2 |               4 | failed |
|          7 | Gabrielle Marquardt | Linux. Начальный уровень                                | Linux. Рабочая станция               |               2 |               4 | failed |
|          9 | Jada Kiehn          | Linux. Начальный уровень                                | Linux. Рабочая станция               |               1 |               4 | failed |
|          1 | Orie Auer           | Тест по Python. Начальный уровень                       | Основы языка Python                  |               1 |               4 | failed |
|          5 | Royce Lubowitz      | Тест по Python. Начальный уровень                       | Основы языка Python                  |               1 |               4 | failed |
|         10 | Jolie Hilll         | Тест по Python. Начальный уровень                       | Основы языка Python                  |               0 |               4 | failed |
|          6 | Nigel Connelly      | База данных MySql                                       | Базы данных                          |               1 |               3 | failed |
+------------+---------------------+---------------------------------------------------------+--------------------------------------+-----------------+-----------------+--------+
10 rows in set (0.03 sec)

-- 2. Запрос выводит название предмета, количество, созданных по нему, групп и общее количество когда-либо записанных на предмет студентов.

SELECT c.course_name, COUNT(DISTINCT gc.group_id) total_groups, COUNT(gc.group_id) total_students
FROM courses c LEFT JOIN groups_courses gc
               USING (course_id)
                 LEFT JOIN groups_users gu
                 USING (group_id)
GROUP BY c.course_name 
ORDER BY total_students DESC;
+--------------------------------------------------------------------------------------------+--------------+----------------+
| course_name                                                                                | total_groups | total_students |
+--------------------------------------------------------------------------------------------+--------------+----------------+
| Основы языка Python                                                                        |            2 |             52 |
| Базы данных                                                                                |            1 |             29 |
| Библиотеки Python для Data Science: продолжение                                            |            1 |             28 |
| Библиотеки Python для Data Science: Numpy, Matplotlib, Scikit-learn                        |            1 |             26 |
| Введение в математический анализ                                                           |            1 |             22 |
| Методы сбора и обработки данных из сети Интернет                                           |            1 |             22 |
| Linux. Рабочая станция                                                                     |            1 |             21 |
| Алгоритмы анализа данных                                                                   |            0 |              0 |
| Линейная алгебра                                                                           |            0 |              0 |
| Теория вероятностей и математическая статистика                                            |            0 |              0 |
+--------------------------------------------------------------------------------------------+--------------+----------------+
10 rows in set (0.00 sec)


-- -------------------------------------------------------------------------------------------
-- представления (минимум 2);

-- 1. Представление users_courses_tests, состоящее из id и имени каждого пользователя, показывает количество групп, в которых они состоят,
--  и количество написанных ими тестов. Отсортировано в порядке убывания по сумме групп и тестов.

CREATE VIEW users_courses_tests AS
SELECT u.user_id, CONCAT(u.first_name, ' ', u.last_name) name, 
                  COUNT(DISTINCT gu.group_id) total_groups, 
                  COUNT(DISTINCT ta.attempt_id) total_tests
FROM users u LEFT JOIN groups_users gu 
             USING (user_id)
               LEFT JOIN test_attempts ta
               USING (user_id)
GROUP BY 1
ORDER BY total_groups+total_tests DESC;


mysql> SELECT * FROM users_courses_tests LIMIT 10;
+---------+-----------------+--------------+-------------+
| user_id | name            | total_groups | total_tests |
+---------+-----------------+--------------+-------------+
|      83 | Danny Cummerata |            5 |           0 |
|      27 | Royce Lubowitz  |            4 |           1 |
|      91 | Cody Erdman     |            4 |           0 |
|      84 | Nigel Connelly  |            3 |           1 |
|      81 | Lavonne Will    |            4 |           0 |
|      62 | Yazmin Bergnaum |            4 |           0 |
|      50 | Bennie Feil     |            4 |           0 |
|      48 | Judah Durgan    |            4 |           0 |
|      32 | Brice Gaylord   |            3 |           1 |
|      20 | Elroy Lemke     |            3 |           1 |
+---------+-----------------+--------------+-------------+
10 rows in set (0.00 sec)

-- 2. Представление active_groups, включает в себя все активные группы. 
--    Показывает id группы, название предмета, количество учеников в группе, дату начала курса и количество дней до конца.
--    Отсортировано в порядке убывания количества оставшихся дней.

CREATE VIEW active_groups AS
SELECT gc.group_id, c.course_name, COUNT(gu.user_id) total_students, gc.date_begins, DATEDIFF(gc.date_ends, NOW()) days_to_the_end
FROM groups_courses gc JOIN courses c 
					   USING (course_id)
					     LEFT JOIN groups_users gu 
					     USING (group_id)
WHERE gc.date_begins < NOW() AND gc.date_ends > NOW()
GROUP BY gc.group_id
ORDER BY days_to_the_end;


mysql> SELECT * FROM active_groups;
+----------+---------------------------------------------------------------+----------------+-------------+-----------------+
| group_id | course_name                                                   | total_students | date_begins | days_to_the_end |
+----------+---------------------------------------------------------------+----------------+-------------+-----------------+
|        4 | Базы данных                                                   |             29 | 2020-11-05  |              28 |
|        1 | Основы языка Python                                           |             29 | 2020-12-12  |              50 |
|        8 | Введение в математический анализ                              |             22 | 2020-08-13  |             324 |
+----------+---------------------------------------------------------------+----------------+-------------+-----------------+
3 rows in set (0.00 sec)


-- -------------------------------------------------------------------------------------------
-- хранимые процедуры / триггеры;
-- пара процедур есть выше в части о добавлении пользователей


-- Триггер, который не дает написать тест, если студент не окончил курс

-- для этого задания добавим новую группу, которая будет уже завершена на сегодняшний день;
-- добавим одного пользователя в эту группу;
-- и добавим тест для этого предмета.

INSERT INTO groups_courses (course_id, date_begins, date_ends) VALUES (9, '2020-05-05', '2020-10-10');

INSERT INTO groups_users (user_id, group_id) VALUES (15, 9);

INSERT INTO tests (course_id, test_name, questions_amount, cor_ans_to_pass) VALUES (9, 'Линейная алгебра. Основы', 5, 4);

DELIMITER //

DROP TRIGGER IF EXISTS course_check_before_ins // 
CREATE TRIGGER course_check_before_ins BEFORE INSERT ON test_attempts
FOR EACH ROW
BEGIN
  IF NOT EXISTS(
    (SELECT test_id 
     FROM groups_users gu 
       JOIN groups_courses gc 
       USING (group_id)
         JOIN tests
         USING (course_id)
     WHERE user_id = NEW.user_id AND date_ends < NOW() AND test_id = NEW.test_id))
  THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Student hasnt finished the course. INSERT has been cancelled.';
  END IF;
END //

DELIMITER ;

-- проверка работы триггера
-- попробуем добавить попытку прохождения теста пользователю, не закончившему курс по линейной алгебре.

mysql> INSERT INTO test_attempts (user_id, test_id) VALUES (10, 4);
ERROR 1644 (45000): Student hasnt finished the course. INSERT has been cancelled.

-- добавим попытку прохождения теста пользователю, закончившему курс по линейной алгебре.

mysql> INSERT INTO test_attempts (user_id, test_id) VALUES (15, 4);
Query OK, 1 row affected (0.01 sec)


-- -------------------------------------------------------------------------------------------
	
