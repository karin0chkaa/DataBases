--1. Добавить внешние ключи

ALTER TABLE company
    ADD CONSTRAINT fk_company PRIMARY KEY (id_company);
ALTER TABLE dealer
    ADD CONSTRAINT fk_dealer PRIMARY KEY (id_dealer);
ALTER TABLE pharmacy
    ADD CONSTRAINT fk_pharmacy PRIMARY KEY (id_pharmacy);
ALTER TABLE medicine
    ADD CONSTRAINT fk_medicine PRIMARY KEY (id_medicine);
ALTER TABLE "order"
    ADD CONSTRAINT fk_order PRIMARY KEY (id_order);
ALTER TABLE production
    ADD CONSTRAINT fk_production PRIMARY KEY (id_production);

--dealer
ALTER TABLE dealer
    ADD CONSTRAINT fk_company
        FOREIGN KEY (id_company)
            REFERENCES company (id_company)
            ON DELETE CASCADE ON UPDATE CASCADE;

--production
ALTER TABLE production
    ADD CONSTRAINT fk_company
        FOREIGN KEY (id_company)
            REFERENCES company (id_company)
            ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE production
    ADD CONSTRAINT fk_medicine
        FOREIGN KEY (id_medicine)
            REFERENCES medicine (id_medicine)
            ON DELETE CASCADE ON UPDATE CASCADE;

--order
ALTER TABLE "order"
    ADD CONSTRAINT fk_production
        FOREIGN KEY (id_production)
            REFERENCES production (id_production)
            ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "order"
    ADD CONSTRAINT fk_dealer
        FOREIGN KEY (id_dealer)
            REFERENCES dealer (id_dealer)
            ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "order"
    ALTER COLUMN id_pharmacy TYPE INT USING id_pharmacy::INTEGER;

ALTER TABLE "order"
    ADD CONSTRAINT fk_pharmacy
        FOREIGN KEY (id_pharmacy)
            REFERENCES pharmacy (id_pharmacy)
            ON DELETE CASCADE ON UPDATE CASCADE;


--2. Выдать информацию по всем заказам лекарствам “Кордерон” компании “Аргус”
--с указанием названий аптек, дат, объема заказов.

SELECT pharmacy.name AS pharmasy_name, "order".date AS order_date, "order".quantity AS order_quantity
FROM "order"
         JOIN production ON "order".id_production = production.id_production
         JOIN company ON production.id_company = company.id_company
         JOIN medicine ON production.id_medicine = medicine.id_medicine
         JOIN pharmacy ON "order".id_pharmacy = pharmacy.id_pharmacy
WHERE medicine.name = 'Кордерон'
  AND company.name = 'Аргус';


--3. Дать список лекарств компании “Фарма”, на которые не были сделаны заказы
--до 25 января.

SELECT medicine.name AS medicine_name
FROM medicine
         JOIN production ON medicine.id_medicine = production.id_medicine
         JOIN company ON production.id_company = company.id_company
WHERE company.name = 'Фарма'
  AND NOT EXISTS (SELECT 1
                  FROM "order"
                  WHERE "order".id_production = production.id_production
                    AND "order".date < '2019-01-25');


--4. Дать минимальный и максимальный баллы лекарств каждой фирмы, которая
--оформила не менее 120 заказов.

SELECT company.name AS company_name, MAX(production.rating) AS max_rating, MIN(production.rating) AS min_rating
FROM company
         JOIN production ON company.id_company = production.id_company
WHERE company.id_company IN (SELECT production.id_company
                             FROM "order"
                                      JOIN production ON "order".id_production = production.id_production
                             GROUP BY production.id_company
                             HAVING count("order".id_order) >= 120)
GROUP BY company.name;


--5. Дать списки сделавших заказы аптек по всем дилерам компании “AstraZeneca”.
--Если у дилера нет заказов, в названии аптеки проставить NULL.

SELECT pharmacy.name AS pharmacy_name, dealer.name AS dealer_name
FROM dealer
         JOIN company ON dealer.id_company = company.id_company
         LEFT JOIN "order" ON dealer.id_dealer = "order".id_dealer
         LEFT JOIN pharmacy ON "order".id_pharmacy = pharmacy.id_pharmacy
WHERE company.name = 'AstraZeneca';


-- 6. Уменьшить на 20% стоимость всех лекарств, если она превышает 3000, а
-- длительность лечения не более 7 дней.

ALTER TABLE production
    ALTER COLUMN price TYPE NUMERIC USING REPLACE(price, ',', '.')::NUMERIC;

UPDATE production
SET price = price * 0.8
WHERE price > 3000
  AND id_medicine IN (SELECT id_medicine FROM medicine WHERE cure_duration <= 7);


-- 7. Добавить необходимые индексы.
CREATE INDEX idx_company_name ON company (name);

CREATE INDEX idx_dealer_company ON dealer (id_company);
CREATE INDEX idx_dealer_name ON dealer (name);

CREATE INDEX idx_medicine_name ON medicine (name);
CREATE INDEX idx_medicine_cure_duration ON medicine (cure_duration);

CREATE INDEX idx_production_company ON production (id_company);
CREATE INDEX idx_production_medicine ON production (id_medicine);
CREATE INDEX idx_production_price ON production (price);
CREATE INDEX idx_production_rating ON production (rating);

CREATE INDEX idx_pharmacy_name ON pharmacy (name);
CREATE INDEX idx_pharmacy_rating ON pharmacy (rating);

CREATE INDEX idx_order_production ON "order" (id_production);
CREATE INDEX idx_order_dealer ON "order" (id_dealer);
CREATE INDEX idx_order_pharmacy ON "order" (id_pharmacy);
CREATE INDEX idx_order_date ON "order" (date);
CREATE INDEX idx_order_quantity ON "order" (quantity);