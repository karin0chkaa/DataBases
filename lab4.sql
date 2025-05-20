--1. INSERT
--a. Вставка данных в phone без указания списка полей
INSERT INTO phone VALUES (1, '89870000000', '2025-01-01', 1),
                         (2, '89870000001', '2025-01-02', 2),
                         (3, '89870000002', '2025-01-03', 3),
                         (4, '89870000003', '2025-01-04', 4),
                         (5, '89870000004', '2025-01-05', 5);

--b.
-- Вставка данных в operator с указанием списка полей
INSERT INTO operator (id_operator, email, company_name) VALUES (1, 'operator1@gmail.com', 'Tele2'),
                                                                         (2, 'operator2@gmail.com', 'MTS'),
                                                                         (3, 'operator3@gmail.com', 'Beeline'),
                                                                         (4, 'operator4@gmail.com', 'Megafon'),
                                                                         (5, 'operator5@gmail.com', 'Yota');


-- Вставка данных в service_type с указанием списка полей
INSERT INTO service_type (id_service_type, name, description, cost, id_operator) VALUES (1, 'Internet', 'High-speed fiber connection', 49.99,1),
                                                                                        (2, 'Mobile Plan', 'Unlimited calls and 10GB data', 39.99, 2),
                                                                                        (3, 'Premium Plan', 'Unlimited calls and 50GB data', 159.99, 3),
                                                                                        (4, 'Basic TV', '50 channels', 29.99, 4),
                                                                                        (5, 'Full Package', 'All services included', 199.99, 5);

-- Вставка данных в client с указанием списка полей
INSERT INTO client (id_client, first_name, last_name, email, address, id_phone) VALUES (1, 'Ivan', 'Ivanov', 'ivanovivan@gmail.com', 'Petrova 1a', 1),
                                                                                       (2, 'Petr', 'Petrov', 'petrpetrov@gmail.com', 'Lenina 5b', 2),
                                                                                       (3, 'Fedor', 'Sidorov', 'fedorsidorov@gmail.com', 'Pushkina 10', 3),
                                                                                       (4, 'Anna', 'Smirnova', 'annasmirnova@gmail.com', 'Gorkogo 20', 4),
                                                                                       (5, 'Elena', 'Fedorova', 'elenafedorova@gmail.com', 'Sovetskaya 30', 5);

-- Вставка данных в payment с указанием списка полей
INSERT INTO payment (id_payment, payment_date, id_client, id_service_type) VALUES (1, '2025-03-14 12:00:00', 1, 1),
                                                                                  (2, '2025-03-15 14:30:00', 2, 2),
                                                                                  (3, '2025-03-16 16:45:00', 3, 3),
                                                                                  (4, '2025-03-17 18:00:00', 4, 4),
                                                                                  (5, '2025-03-18 19:15:00', 5, 5);


--c. Вставка данных с чтением значения из другой таблицы
INSERT INTO payment(id_payment, payment_date, id_client, id_service_type)
    SELECT 6, '2025-03-19 10:00:00', id_client, id_service_type
    FROM client, service_type
    WHERE client.id_client = 2 AND service_type.id_service_type = 2;

--3.2.DELETE
--a. Всех записей
TRUNCATE TABLE phone CASCADE;
TRUNCATE TABLE operator CASCADE;
TRUNCATE TABLE client CASCADE;
TRUNCATE TABLE service_type CASCADE;
TRUNCATE TABLE payment CASCADE;

--b. По условию DELETE FROM table_name WHERE condition;
DELETE FROM phone WHERE id_phone = 1;
DELETE FROM operator WHERE id_operator = 1;
DELETE FROM service_type WHERE id_service_type = 1;
DELETE FROM client WHERE id_client = 1;
DELETE FROM payment WHERE id_payment = 1;

--3.3.UPDATE
--a. Всех записей
UPDATE phone SET number = '87771178849' WHERE id_phone >= 1;

--b. По условию обновляя один атрибут
-- UPDATE table_name SET column1 = value1, column2 = value2, ... WHERE condition;

UPDATE phone SET number = '89991234567' WHERE id_phone = 1;
UPDATE operator SET email = 'new_emailoperator1@mail.ru' WHERE  id_operator = 1;
UPDATE client SET last_name = 'Sidorov' WHERE id_client = 1;
UPDATE service_type SET cost = '99.99' WHERE id_service_type = 1;
UPDATE payment SET payment_date = '2025-03-15' WHERE id_payment = 1;

--c. По условию обновляя несколько атрибутов
-- UPDATE table_name SET column1 = value1, column2 = value2, ... WHERE condition;
UPDATE phone SET number = '89991110001', activated_on = '2025-03-01' WHERE id_phone = 2;
UPDATE operator SET email = 'newEmailOperator@gmail.com', company_name = 'Beeline' WHERE id_operator = '1';
UPDATE client SET first_name = 'Petr', last_name = 'Sokolov', email = 'petr_sokolov@fmail.com' WHERE id_client = 1;
UPDATE service_type SET name = 'Calls abroad', description = 'Making calls while roaming', cost = '149.89' WHERE id_service_type = 1;
UPDATE payment SET payment_date = '2025-03-15', id_service_type = 1 WHERE id_payment = 2;


--3.4.SELECT
--a. С набором извлекаемых атрибутов (SELECT atr1, atr2 FROM...)
SELECT id_phone, number FROM phone;
SELECT id_operator, email, company_name FROM operator;
SELECT id_client, first_name, last_name, email FROM client;
SELECT id_service_type, name, cost FROM service_type;
SELECT id_payment, payment_date FROM payment;

--b. Со всеми атрибутами (SELECT * FROM...)
SELECT * FROM phone;
SELECT * FROM operator;
SELECT * FROM client;
SELECT * FROM service_type;
SELECT * FROM payment;

--c. С условием по атрибуту (SELECT * FROM ... WHERE atr1 = value)
SELECT * FROM phone WHERE id_phone = 1;
SELECT * FROM operator WHERE company_name = 'Beeline';
SELECT * FROM client WHERE first_name = 'Petr';
SELECT * FROM service_type WHERE cost > 100;
SELECT * FROM payment WHERE id_client = 1;

-- 3.5. SELECT ORDER BY + TOP (LIMIT)
-- a. С сортировкой по возрастанию ASC + ограничение вывода количества записей
SELECT * FROM phone ORDER BY number ASC LIMIT 5;
SELECT * FROM operator ORDER BY company_name ASC LIMIT 3;
SELECT * FROM client ORDER BY first_name ASC LIMIT 3;
SELECT * FROM service_type ORDER BY cost ASC LIMIT 5;
SELECT * FROM payment ORDER BY payment_date ASC LIMIT 5;

-- b. С сортировкой по убыванию DESC
SELECT * FROM phone ORDER BY number DESC;
SELECT * FROM operator ORDER BY company_name DESC;
SELECT * FROM client ORDER BY first_name DESC;
SELECT * FROM service_type ORDER BY cost DESC;
SELECT * FROM payment ORDER BY payment_date DESC;

-- c. С сортировкой по двум атрибутам + ограничение вывода количества записей
SELECT * FROM phone ORDER BY number ASC, activated_on DESC LIMIT 5;
SELECT * FROM operator ORDER BY company_name ASC, email DESC LIMIT 3;
SELECT * FROM client ORDER BY first_name ASC, last_name ASC LIMIT 3;
SELECT * FROM service_type ORDER BY cost DESC, name ASC LIMIT 10;
SELECT * FROM payment ORDER BY payment_date ASC, id_client DESC LIMIT 10;

-- d. С сортировкой по первому атрибуту, из списка извлекаемых
SELECT * FROM phone ORDER BY 1 ASC ;


-- 3.6. Работа с датами
-- Необходимо, чтобы одна из таблиц содержала атрибут с типом DATETIME. Например,
-- таблица авторов может содержать дату рождения автора.

-- a. WHERE по дате
SELECT * FROM payment WHERE payment_date = '2025-03-15 00:00:00';

-- b. WHERE дата в диапазоне
SELECT * FROM payment WHERE payment_date BETWEEN '2025-03-01 00:00:00' AND '2025-03-31 23:59:59';

-- c. Извлечь из таблицы не всю дату, а только год. Например, год рождения автора.
-- Для этого используется функция YEAR ( https://docs.microsoft.com/en-us/sql/t-
-- sql/functions/year-transact-sql?view=sql-server-2017 )
SELECT EXTRACT(YEAR FROM  payment_date) AS payment_year FROM payment;


--3.7. Функции агрегации
--a. Посчитать количество записей в таблице
SELECT COUNT(*) FROM payment;
SELECT COUNT(*) FROM phone;

--b. Посчитать количество уникальных записей в таблице
SELECT COUNT(DISTINCT id_client) FROM payment;
SELECT COUNT(DISTINCT number) FROM phone;

--c. Вывести уникальные значения столбца
SELECT DISTINCT company_name FROM operator;
SELECT DISTINCT number FROM phone;

--d. Найти максимальное значение столбца
SELECT MAX(cost) FROM service_type;
SELECT MAX(payment_date) FROM payment;

-- e. Найти минимальное значение столбца
SELECT MIN(cost) FROM service_type;
SELECT MIN(payment_date) FROM payment;

-- f. Написать запрос COUNT() + GROUP BY
SELECT id_operator, COUNT(*) AS operator_count FROM operator GROUP BY id_operator;
SELECT id_client, COUNT(*) AS client_count FROM client GROUP BY id_client;
SELECT id_phone, COUNT(number) AS number_count FROM phone GROUP BY id_phone;


-- 3.8. SELECT GROUP BY + HAVING
-- a. Написать 3 разных запроса с использованием GROUP BY + HAVING. Для
-- каждого запроса написать комментарий с пояснением, какую информацию
-- извлекает запрос. Запрос должен быть осмысленным, т.е. находить информацию,
-- которую можно использовать.

SELECT id_service_type, COUNT(id_service_type) AS service_type_count FROM service_type GROUP BY id_service_type HAVING cost > 50;
--Запрос группирует услуги по типу услеги id_service_type, подсчитывает количество каждой из них и выводит только те услуги, стоимость которых больше 50.

SELECT id_operator, AVG(cost) AS avg_cost FROM service_type GROUP BY id_operator HAVING AVG(cost) > 50;
--Запрос группирует данные по операторам и находит среднюю стоимость услуг предлагаемых каждым опертором. Отбираются те операторсы, у которых средняя стоимость услуги больще 50.

SELECT id_client, COUNT(id_payment) AS payment_count FROM payment WHERE payment_date > '2025-03-01' GROUP BY id_client HAVING COUNT(id_payment) > 0;
--Запрос группирует клиентов и выводит тех, кто заплатил за услугу после 1.03.2025.


-- 3.9. SELECT JOIN
-- a. LEFT JOIN двух таблиц и WHERE по одному из атрибутов
SELECT client.id_client, client.first_name, client.last_name, client.email, phone.number FROM client
LEFT JOIN phone ON client.id_phone = phone.id_phone
WHERE client.last_name LIKE 'S%';

-- b. RIGHT JOIN. Получить такую же выборку, как и в 3.9 a
SELECT client.id_client, client.first_name, client.last_name, client.email, phone.number FROM phone
RIGHT JOIN client ON phone.id_phone = client.id_phone
WHERE client.last_name LIKE 'S%';

-- c. LEFT JOIN трех таблиц + WHERE по атрибуту из каждой таблицы
SELECT client.id_client, client.first_name, client.last_name, client.email, phone.number, operator.company_name FROM client
LEFT JOIN phone ON client.id_phone = phone.id_phone
LEFT JOIN operator ON phone.id_operator = operator.id_operator
WHERE client.last_name LIKE 'S%' AND phone.number LIKE '898%' AND operator.company_name = 'Beeline';

-- d. INNER JOIN двух таблиц
SELECT client.id_client, client.first_name, client.last_name, client.email, payment.payment_date FROM client
INNER JOIN payment ON client.id_client = payment.id_client;

-- 3.10. Подзапросы
-- a. Написать запрос с условием WHERE IN (подзапрос)
SELECT first_name, last_name FROM client WHERE id_client IN (SELECT id_client FROM payment WHERE payment_date > '2025-03-01');

-- b. Написать запрос SELECT atr1, atr2, (подзапрос) FROM ...
SELECT id_client, first_name, (SELECT COUNT(*) AS payment_count FROM payment WHERE payment.id_client = client.id_client) FROM client;
--извлекает id и имя клиента, а также количество платежей этого клиента

-- c. Написать запрос вида SELECT * FROM (подзапрос)
SELECT * FROM (SELECT id_service_type, name, cost FROM service_type WHERE cost > 100) AS expensive_service_type;
--Выбирает все услуги, стоимость которых превышает 100

-- d. Написать запрос вида SELECT * FROM table JOIN (подзапрос) ON …
SELECT * FROM client
JOIN (SELECT id_client, payment_date FROM payment WHERE payment_date > '2025-03-01') AS resent_payments
ON client.id_client = resent_payments.id_client;
--Объединение клиентов с их последними платежами, совершенными после 1 марта 2025 года