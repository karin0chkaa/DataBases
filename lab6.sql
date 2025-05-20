--1. Добавить внешние ключи

ALTER TABLE client
    ADD CONSTRAINT pk_client PRIMARY KEY (id_client);
ALTER TABLE hotel
    ADD CONSTRAINT pk_hotel PRIMARY KEY (id_hotel);
ALTER TABLE room_category
    ADD CONSTRAINT pk_room_category PRIMARY KEY (id_room_category);
ALTER TABLE room
    ADD CONSTRAINT pk_room PRIMARY KEY (id_room);
ALTER TABLE room_in_booking
    ADD CONSTRAINT pk_room_in_booking PRIMARY KEY (id_room_in_booking);
ALTER TABLE booking
    ADD CONSTRAINT pk_booking PRIMARY KEY (id_booking);

ALTER TABLE room
    ADD CONSTRAINT fk_hotel
        FOREIGN KEY (id_hotel)
            REFERENCES hotel (id_hotel) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE room
    ADD CONSTRAINT fk_room_category
        FOREIGN KEY (id_room_category)
            REFERENCES room_category (id_room_category) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE booking
    ADD CONSTRAINT fk_client
        FOREIGN KEY (id_client)
            REFERENCES client (id_client) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE room_in_booking
    ADD CONSTRAINT fk_booking
        FOREIGN KEY (id_booking)
            REFERENCES booking (id_booking) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE room_in_booking
    ADD CONSTRAINT fk_room
        FOREIGN KEY (id_room)
            REFERENCES room (id_room) ON DELETE CASCADE ON UPDATE CASCADE;


--2. Выдать информацию о клиентах гостиницы “Космос”, проживающих в номерах
--категории “Люкс” на 1 апреля 2019г.

SELECT client.id_client, client.name, client.phone
FROM client
         JOIN booking ON client.id_client = booking.id_client
         JOIN room_in_booking ON booking.id_booking = room_in_booking.id_booking
         JOIN room ON room_in_booking.id_room = room.id_room
         JOIN hotel ON room.id_hotel = hotel.id_hotel
         JOIN room_category ON room.id_room_category = room_category.id_room_category
WHERE hotel.name = 'Космос'
  AND room_category.name = 'Люкс'
  AND checkin_date <= '2019-04-01'
  and checkout_date > '2019-04-01';


--3.Дать список свободных номеров всех гостиниц на 22 апреля.
SELECT hotel.id_hotel,
       hotel.name,
       hotel.stars,
       room.id_room,
       room.number,
       room.price,
       room_category.name,
       room_category.square
FROM room
         JOIN hotel ON room.id_hotel = hotel.id_hotel
         JOIN room_category ON room.id_room_category = room_category.id_room_category
WHERE room.id_room NOT IN (SELECT id_room_in_booking
                           FROM room_in_booking
                           WHERE checkin_date <= '2019-04-22'
                             AND checkout_date > '2019-04-22');


--4. Дать количество проживающих в гостинице “Космос” на 23 марта по каждой
--категории номеров

SELECT room_category.name                AS category_name,
       COUNT(DISTINCT booking.id_client) AS client_count
FROM room_in_booking
         JOIN
     booking ON room_in_booking.id_booking = booking.id_booking
         JOIN
     room ON room_in_booking.id_room = room.id_room
         JOIN
     hotel ON room.id_hotel = hotel.id_hotel
         JOIN
     room_category ON room.id_room_category = room_category.id_room_category
WHERE hotel.name = 'Космос'
  AND room_in_booking.checkin_date <= '2019-03-23'
  AND room_in_booking.checkout_date > '2019-03-23'
GROUP BY room_category.name
ORDER BY client_count DESC;

--5. Дать список последних проживавших клиентов по всем комнатам гостиницы
--“Космос”, выехавшим в апреле с указанием даты выезда.
-- нужны именно последние проживающие - можно через подзапрос.
-- SELECT client.name, client.phone, room.id_room, room.number, room_category.name, room_in_booking.checkout_date
-- FROM room_in_booking
--          JOIN booking ON room_in_booking.id_booking = booking.id_booking
--          JOIN client ON booking.id_client = client.id_client
--          JOIN room ON room_in_booking.id_room = room.id_room
--          JOIN hotel ON room.id_hotel = hotel.id_hotel
--          JOIN room_category ON room.id_room_category = room_category.id_room_category
-- WHERE hotel.name = 'Космос'
--   AND EXTRACT(MONTH FROM room_in_booking.checkout_date) = 4;

ALTER TABLE room_in_booking
    ALTER COLUMN checkout_date TYPE DATE USING checkout_date::DATE;

SELECT client.name,
       client.phone,
       room.id_room,
       room.number,
       room_category.name AS category_name,
       room_in_booking.checkout_date
FROM (SELECT id_room, MAX(checkout_date) AS last_checkout_date
      FROM room_in_booking
      WHERE EXTRACT(MONTH FROM checkout_date) = 4
      GROUP BY id_room) AS last_checkouts
         JOIN room_in_booking
              ON last_checkouts.id_room = room_in_booking.id_room
                  AND last_checkouts.last_checkout_date = room_in_booking.checkout_date
         JOIN booking ON room_in_booking.id_booking = booking.id_booking
         JOIN client ON booking.id_client = client.id_client
         JOIN room ON room_in_booking.id_room = room.id_room
         JOIN hotel ON room.id_hotel = hotel.id_hotel
         JOIN room_category ON room.id_room_category = room_category.id_room_category
WHERE hotel.name = 'Космос';

--6. Продлить на 2 дня дату проживания в гостинице “Космос” всем клиентам
--комнат категории “Бизнес”, которые заселились 10 мая.
UPDATE room_in_booking
SET checkout_date = (checkout_date::date + INTERVAL '2 days')::text
FROM room
         JOIN hotel ON room.id_hotel = hotel.id_hotel
         JOIN room_category ON room.id_room_category = room_category.id_room_category
WHERE room_in_booking.id_room_in_booking = room.id_room
  AND hotel.name = 'Космос'
  AND room_category.name = 'Бизнес'
  AND room_in_booking.checkin_date = '2019-05-10';


--7. Найти все "пересекающиеся" варианты проживания. Правильное состояние: не
-- может быть забронирован один номер на одну дату несколько раз, т.к. нельзя
-- заселиться нескольким клиентам в один номер. Записи в таблице
-- room_in_booking с id_room_in_booking = 5 и 2154 являются примером
-- неправильного состояния, которые необходимо найти. Результирующий кортеж
-- выборки должен содержать информацию о двух конфликтующих номерах.
SELECT r1.id_room_in_booking AS first_booking_id,
       r2.id_room_in_booking AS second_booking_id,
       r1.id_room,
       room.number           AS room_number,
       hotel.name            AS hotel_name,
       r1.checkin_date       AS first_checkin,
       r1.checkout_date      AS first_checkout,
       r2.checkin_date       AS second_checkin,
       r2.checkout_date      AS second_checkout
FROM room_in_booking r1
         JOIN room_in_booking r2 ON r1.id_room = r2.id_room
         JOIN room ON r1.id_room = room.id_room
         JOIN hotel ON room.id_hotel = hotel.id_hotel
WHERE r1.id_room_in_booking < r2.id_room_in_booking
  AND (r1.checkin_date::date < r2.checkin_date::date AND r1.checkout_date::date > r2.checkout_date::date);
-- объяснить что делает условие - r1.id_room_in_booking < r2.id_room_in_booking
-- С фильтрацией разобраться чекин чекаут


SELECT r1.id_room_in_booking AS first_booking_id,
       r2.id_room_in_booking AS second_booking_id,
       r1.id_room,
       room.number           AS room_number,
       hotel.name            AS hotel_name,
       r1.checkin_date       AS first_checkin,
       r1.checkout_date      AS first_checkout,
       r2.checkin_date       AS second_checkin,
       r2.checkout_date      AS second_checkout
FROM room_in_booking r1
         JOIN
     room_in_booking r2
     ON r1.id_room = r2.id_room
         JOIN
     room ON r1.id_room = room.id_room
         JOIN
     hotel ON room.id_hotel = hotel.id_hotel
WHERE r1.id_room_in_booking < r2.id_room_in_booking
  AND (
    (r1.checkin_date <= r2.checkin_date AND r1.checkout_date >= r2.checkout_date)
        OR
    (r2.checkin_date <= r1.checkin_date AND r2.checkout_date >= r1.checkout_date)
        OR
    (r1.checkin_date < r2.checkin_date AND r1.checkout_date > r2.checkin_date)
        OR
    (r1.checkin_date < r2.checkout_date AND r1.checkout_date > r2.checkout_date)
    );

--8. Создать бронирование в транзакции.
BEGIN;

DO
$$
    DECLARE
        v_id_client     INT  := 1; -- ID клиента
        v_id_room       INT  := 101; -- ID номера
        v_checkin_date  DATE := '2019-01-15'; -- Дата заезда
        v_checkout_date DATE := '2019-01-20'; -- Дата выезда
        v_booking_id    INT; -- Переменная для хранения ID нового бронирования
    BEGIN
        --Проверка доступности номера
        IF EXISTS (SELECT 1
                   FROM room_in_booking rib
                   WHERE rib.id_room = v_id_room
                     AND (
                       (v_checkin_date >= rib.checkin_date AND v_checkin_date < rib.checkout_date) OR
                       (v_checkout_date > rib.checkin_date AND v_checkout_date <= rib.checkout_date) OR
                       (v_checkin_date <= rib.checkin_date AND v_checkout_date >= rib.checkout_date)
                       )) THEN
            RAISE EXCEPTION 'Номер с ID % уже забронирован на указанные даты.', v_id_room;
        END IF;

        --Создание записи о бронировании
        INSERT INTO booking (id_client, booking_date)
        VALUES (v_id_client, CURRENT_DATE)
        RETURNING id_booking INTO v_booking_id;

        --Создание записи о бронировании номера
        INSERT INTO room_in_booking (id_booking, id_room, checkin_date, checkout_date)
        VALUES (v_booking_id, v_id_room, v_checkin_date, v_checkout_date);

    EXCEPTION
        WHEN OTHERS THEN
            -- В случае ошибки выводим сообщение и откатываемся на уровне сессии
            RAISE NOTICE 'Ошибка при создании бронирования: %', SQLERRM;
    END
$$;

-- Если блок DO выполнился успешно, фиксируем транзакцию
COMMIT;

--9. Добавить необходимые индексы для всех таблиц.
CREATE INDEX idx_hotel_id ON hotel (id_hotel);
CREATE INDEX idx_hotel_name ON hotel (name);

CREATE INDEX idx_room_category_id ON room_category (id_room_category);
CREATE INDEX idx_room_category_name ON room_category (name);

CREATE INDEX idx_room_id ON room (id_room);
CREATE INDEX idx_room_hotel ON room (id_hotel);
CREATE INDEX idx_room_category ON room (id_room_category);
CREATE INDEX idx_room_number ON room (number);

CREATE INDEX idx_room_on_booking_id ON room_in_booking (id_room_in_booking);
CREATE INDEX idx_room_in_booking_room ON room_in_booking (id_room);
CREATE INDEX idx_room_in_booking_booking ON room_in_booking (id_booking);
CREATE INDEX idx_room_in_booking_dates ON room_in_booking (checkin_date, checkout_date);

CREATE INDEX idx_booking_id ON booking (id_booking);
CREATE INDEX idx_booking_client ON booking (id_client);
CREATE INDEX idx_booking_date ON booking (booking_date);

CREATE INDEX idx_client_id ON client (id_client);
CREATE INDEX idx_client_phone ON client (phone);
CREATE INDEX idx_client_name ON client (name);

CREATE INDEX idx_room_in_booking_checkin ON room_in_booking (checkin_date);
CREATE INDEX idx_room_in_booking_checkout ON room_in_booking (checkout_date);

