1. Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.
	Подправил задание под базу VK, но смысл остался тот же. 
	Отобразил имя и фамилию пользователей, которые отправили больше 15 сообщений.

SELECT first_name, last_name
FROM users 
WHERE id IN (SELECT from_user_id FROM messages GROUP BY 1 HAVING count(*) > 15);
+------------+------------+
| first_name | last_name  |
+------------+------------+
| Emil       | White      |
| Breanne    | Sawayn     |
| Judah      | Durgan     |
| Torrance   | Gusikowski |
| Yesenia    | Hermiston  |
+------------+------------+
5 rows in set (0.00 sec)

2.Выведите список товаров products и разделов catalogs, который соответствует товару.
	Oбъединил имя и фамилию из таблицы users с датой рождения и страной из таблицы profiles

SELECT u.first_name, u.last_name, p.birthday, p.country 
FROM users AS u JOIN profiles AS p 
ON u.id=p.user_id
LIMIT 10;
+------------+-------------+------------+---------------------------+
| first_name | last_name   | birthday   | country                   |
+------------+-------------+------------+---------------------------+
| Chelsey    | Breitenberg | 2017-12-03 | Slovenia                  |
| Bonita     | Wyman       | 2018-09-20 | Slovenia                  |
| Durward    | Huels       | 2011-04-19 | Swaziland                 |
| Kory       | Schmeler    | 1997-05-24 | Greece                    |
| Christop   | Rowe        | 2019-01-19 | Saint Barthelemy          |
| Shanie     | Denesik     | 2004-06-26 | Swaziland                 |
| Beryl      | Frami       | 2017-07-23 | Saint Pierre and Miquelon |
| Annabell   | Lehner      | 2013-10-09 | Fiji                      |
| Shaniya    | Borer       | 1992-01-04 | Rwanda                    |
| Orie       | Auer        | 1985-06-04 | Panama                    |
+------------+-------------+------------+---------------------------+
10 rows in set (0.00 sec)

3.(по желанию) Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name). Поля from, to и label содержат английские названия городов, поле name — русское. Выведите список рейсов flights с русскими названиями городов.
	у меня столбцы в таблице flights названы fromm и too (не было времени на того чтобы разобраться с зарезервированными именами)

SELECT fr.*, ft.flight_to
FROM  (SELECT f.id, c.name AS flight_from FROM flights AS f JOIN cities AS c ON f.fromm=c.label) fr
   JOIN 
      (SELECT f.id, c.name AS flight_to FROM flights AS f JOIN cities AS c ON f.too=c.label) ft 
         ON fr.id = ft.id 
ORDER BY 1;
+----+------------------+----------------+
| id | flight_from      | flight_to      |
+----+------------------+----------------+
|  1 | Москва           | Омск           |
|  2 | Новгород         | Казань         |
|  3 | Иркутск          | Москва         |
|  4 | Омск             | Иркутск        |
|  5 | Москва           | Казань         |
+----+------------------+----------------+
5 rows in set (0.00 sec)


