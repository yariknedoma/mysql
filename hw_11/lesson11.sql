1. Практическое задание по теме “Оптимизация запросов”
Создайте таблицу logs типа Archive. Пусть при каждом создании записи в таблицах users, catalogs и products в таблицу logs помещается время и дата создания записи, название таблицы, идентификатор первичного ключа и содержимое поля name.

CREATE TABLE logs (
	created_at DATETIME NOT NULL,
	table_name VARCHAR(50) NOT NULL,
	id INT UNSIGNED NOT NULL,
	value VARCHAR(50) NOT NULL
) ENGINE = ARCHIVE //


CREATE TRIGGER logs_users AFTER INSERT ON users
FOR EACH ROW
BEGIN
	INSERT INTO logs (created_at, table_name, id, value)
	VALUES (NOW(), 'users', NEW.id, NEW.name);
END //


CREATE TRIGGER logs_catalogs AFTER INSERT ON catalogs
FOR EACH ROW
BEGIN
	INSERT INTO logs (created_at, table_name, id, value)
	VALUES (NOW(), 'catalogs', NEW.id, NEW.name);
END //


CREATE TRIGGER logs_products AFTER INSERT ON products
FOR EACH ROW
BEGIN
	INSERT INTO logs (created_at, table_name, id, value)
	VALUES (NOW(), 'products', NEW.id, NEW.name);
END //


2. (по желанию) Создайте SQL-запрос, который помещает в таблицу users миллион записей.

CREATE TABLE hw10_t2 (
    id INT UNSIGNED NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP) //
    
CREATE PROCEDURE insert_users(amount INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    WHILE i < amount DO
        SET i = i + 1;
        INSERT INTO hw10_t2 (id)
        VALUES (i);
    END WHILE;
END//


mysql> CALL insert_users(10)//
Query OK, 1 row affected (0.08 sec)

mysql> select * from hw10_t2//
+----+---------------------+
| id | created_at          |
+----+---------------------+
|  1 | 2020-12-10 18:42:15 |
|  2 | 2020-12-10 18:42:15 |
|  3 | 2020-12-10 18:42:15 |
|  4 | 2020-12-10 18:42:15 |
|  5 | 2020-12-10 18:42:15 |
|  6 | 2020-12-10 18:42:15 |
|  7 | 2020-12-10 18:42:15 |
|  8 | 2020-12-10 18:42:15 |
|  9 | 2020-12-10 18:42:15 |
| 10 | 2020-12-10 18:42:15 |
+----+---------------------+
10 rows in set (0.00 sec)

