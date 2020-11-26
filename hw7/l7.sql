1. ��������� ������ ������������� users, ������� ����������� ���� �� ���� ����� orders � �������� ��������.
	��������� ������� ��� ���� VK, �� ����� ������� ��� ��. 
	��������� ��� � ������� �������������, ������� ��������� ������ 15 ���������.

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

2.�������� ������ ������� products � �������� catalogs, ������� ������������� ������.
	O�������� ��� � ������� �� ������� users � ����� �������� � ������� �� ������� profiles

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

3.(�� �������) ����� ������� ������� ������ flights (id, from, to) � ������� ������� cities (label, name). ���� from, to � label �������� ���������� �������� �������, ���� name � �������. �������� ������ ������ flights � �������� ���������� �������.
	� ���� ������� � ������� flights ������� fromm � too (�� ���� ������� �� ���� ����� ����������� � ������������������ �������)

SELECT fr.*, ft.flight_to
FROM  (SELECT f.id, c.name AS flight_from FROM flights AS f JOIN cities AS c ON f.fromm=c.label) fr
   JOIN 
      (SELECT f.id, c.name AS flight_to FROM flights AS f JOIN cities AS c ON f.too=c.label) ft 
         ON fr.id = ft.id 
ORDER BY 1;
+----+------------------+----------------+
| id | flight_from      | flight_to      |
+----+------------------+----------------+
|  1 | ������           | ����           |
|  2 | ��������         | ������         |
|  3 | �������          | ������         |
|  4 | ����             | �������        |
|  5 | ������           | ������         |
+----+------------------+----------------+
5 rows in set (0.00 sec)


