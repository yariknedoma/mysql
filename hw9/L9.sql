Практическое задание по теме “Транзакции, переменные, представления”

1. В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. 
Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.

START TRANSACTION;
INSERT INTO sample.users  
SELECT * FROM shop.users WHERE id = 1;
COMMIT;

2. Создайте представление, которое выводит название name товарной позиции из таблицы products 
и соответствующее название каталога name из таблицы catalogs.

CREATE VIEW t2 AS SELECT p.name product_name, c.name catalog_name 
                  FROM products p 
                  LEFT JOIN catalogs c 
                  ON p.catalog_id = c.id;
                 
4. Пусть имеется любая таблица с календарным полем created_at. 
Создайте запрос, который удаляет устаревшие записи из таблицы, 
оставляя только 5 самых свежих записей.

DELETE 
FROM table1
WHERE id NOT IN (SELECT id 
				 FROM (SELECT id 
				       FROM table1 
				       ORDER BY created_at DESC 
				       LIMIT 5) tmp);


Практическое задание по теме “Хранимые процедуры и функции, триггеры"

1. Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток. 
С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", 
с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", 
с 18:00 до 00:00 — "Добрый вечер", 
с 00:00 до 6:00 — "Доброй ночи".


CREATE FUNCTION hello () 
RETURNS VARCHAR(255) DETERMINISTIC 
BEGIN 
	IF (DATE_FORMAT(NOW(), '%H') BETWEEN 6 AND 11) THEN 
	  RETURN CONCAT('Доброе утро'); 
	ELSEIF (DATE_FORMAT(NOW(), '%H') BETWEEN 12 AND 17) THEN 
	  RETURN CONCAT('Добрый день'); 
	ELSEIF (DATE_FORMAT(NOW(), '%H') BETWEEN 18 AND 23) THEN 
	  RETURN CONCAT('Добрый вечер'); 
	ELSE 
	  RETURN ('Доброй ночи'); 
	END IF; 
END//

2. В таблице products есть два текстовых поля: name с названием товара и description с его описанием. 
Допустимо присутствие обоих полей или одно из них. 
Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема. 
Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены. 
При попытке присвоить полям NULL-значение необходимо отменить операцию.

CREATE TRIGGER products_name_description_ins BEFORE INSERT ON products
FOR EACH ROW
BEGIN
	IF(ISNULL(NEW.name) AND ISNULL(NEW.description)) 
	THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'INSERT cancelled';
	END IF;
END

CREATE TRIGGER products_name_description_upd BEFORE UPDATE ON products
FOR EACH ROW
BEGIN
	IF(ISNULL(NEW.name) AND ISNULL(NEW.description)) 
	THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'UPDATE cancelled';
	END IF;
END



