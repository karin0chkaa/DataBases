--1. Добавить внешние ключи
ALTER TABLE subject
    ADD CONSTRAINT pf_subject PRIMARY KEY (id_subject);
ALTER TABLE "group"
    ADD CONSTRAINT pk_group PRIMARY KEY (id_group);
ALTER TABLE teacher
    ADD CONSTRAINT pk_teacher PRIMARY KEY (id_teacher);
ALTER TABLE mark
    ADD CONSTRAINT pk_mark PRIMARY KEY (id_mark);
ALTER TABLE student
    ADD CONSTRAINT pk_student PRIMARY KEY (id_student);
ALTER TABLE lesson
    ADD CONSTRAINT pk_booking PRIMARY KEY (id_lesson);

ALTER TABLE mark
    ADD CONSTRAINT fk_lesson
        FOREIGN KEY (id_lesson)
            REFERENCES lesson (id_lesson) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE mark
    ALTER COLUMN id_student TYPE INT USING id_student::INTEGER;

ALTER TABLE mark
    ADD CONSTRAINT fk_student
        FOREIGN KEY (id_student)
            REFERENCES student (id_student) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE lesson
    ADD CONSTRAINT fk_teacher
        FOREIGN KEY (id_teacher)
            REFERENCES teacher (id_teacher) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE lesson
    ADD CONSTRAINT fk_subject
        FOREIGN KEY (id_subject)
            REFERENCES subject (id_subject) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE lesson
    ADD CONSTRAINT fk_group
        FOREIGN KEY (id_group)
            REFERENCES "group" (id_group) ON DELETE CASCADE ON UPDATE CASCADE;


-- 2. Выдать оценки студентов по информатике если они обучаются данному
-- предмету. Оформить выдачу данных с использованием view.

CREATE INDEX idx_subject_name ON subject (name);
CREATE INDEX idx_mark_id_student ON mark (id_student);
CREATE INDEX idx_mark_id_lesson ON mark (id_lesson);
CREATE INDEX idx_lesson_id_subject ON lesson (id_subject);
CREATE INDEX idx_lesson_id_group ON lesson (id_group);
CREATE INDEX idx_group_id ON "group" (id_group);
CREATE INDEX idx_student_id ON student (id_student);

CREATE VIEW informatics_grades AS
SELECT student.id_student,
       student.name,
       "group".name AS group_name,
       subject.name AS subject_name,
       lesson.date  AS lesson_date,
       mark.mark
FROM student
         JOIN mark ON student.id_student = mark.id_student
         JOIN lesson ON mark.id_lesson = lesson.id_lesson
         JOIN subject ON lesson.id_subject = subject.id_subject
         JOIN "group" ON lesson.id_group = "group".id_group
WHERE subject.name = 'Информатика';

SELECT *
FROM informatics_grades;

DROP VIEW informatics_grades;

--3. Дать информацию о должниках с указанием фамилии студента и названия
--предмета. Должниками считаются студенты, не имеющие оценки по предмету,
--который ведется в группе. Оформить в виде процедуры, на входе
--идентификатор группы.

CREATE OR REPLACE FUNCTION get_debtors_by_group_func(group_id INT)
    RETURNS TABLE
            (
                student_name TEXT,
                subject_name TEXT
            )
AS
$$
BEGIN
    RETURN QUERY
    SELECT student.name::TEXT, subject.name::TEXT
    FROM student
             JOIN "group" ON student.id_group = "group".id_group
             JOIN lesson ON "group".id_group = lesson.id_group
             JOIN subject ON lesson.id_subject = subject.id_subject
             LEFT JOIN mark ON student.id_student = mark.id_student AND lesson.id_lesson = mark.id_lesson
    WHERE "group".id_group = group_id
      AND mark.id_mark IS NULL
    GROUP BY student.id_student, student.name, subject.id_subject, subject.name;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_debtors_by_group_func(2);

DROP FUNCTION get_debtors_by_group_func(integer);

--4. Дать среднюю оценку студентов по каждому предмету для тех предметов, по
-- которым занимается не менее 35 студентов.
SELECT subject.id_subject,
       subject.name,
       COUNT(DISTINCT student.id_student) AS student_count,
       AVG(mark.mark::numeric)            AS average_mark
FROM subject
         JOIN lesson ON subject.id_subject = lesson.id_subject
         JOIN mark ON lesson.id_lesson = mark.id_lesson
         JOIN student ON mark.id_student = student.id_student
GROUP BY subject.id_subject, subject.name
HAVING COUNT(DISTINCT student.id_student) >= 35
ORDER BY average_mark DESC;


--5. Дать оценки студентов специальности ВМ по всем проводимым предметам с
-- указанием группы, фамилии, предмета, даты. При отсутствии оценки заполнить
-- значениями NULL поля оценки.
SELECT "group".name, student.name, subject.name, lesson.date, mark.mark
FROM "group"
         JOIN student ON "group".id_group = student.id_group
         JOIN lesson ON "group".id_group = lesson.id_group

         JOIN subject ON lesson.id_subject = subject.id_subject
         LEFT JOIN mark ON lesson.id_lesson = mark.id_lesson AND student.id_student = mark.id_student
WHERE "group".name = 'ВМ'
ORDER BY "group".name, student.name, subject.name, lesson.date;


--6. Всем студентам специальности ПС, получившим оценки меньшие 5 по предмету
-- БД до 12.05, повысить эти оценки на 1 балл.
UPDATE mark
SET mark = mark::INTEGER + 1
WHERE id_mark IN (SELECT mark.id_mark
                  FROM mark
                           JOIN student ON mark.id_student = student.id_student
                           JOIN "group" ON student.id_group = "group".id_group
                           JOIN lesson ON mark.id_lesson = lesson.id_lesson
                           JOIN subject ON lesson.id_subject = subject.id_subject
                  WHERE "group".name = 'ПС'
                    AND subject.name = 'БД'
                    AND lesson.date < '2019-05-12'
                    AND mark.mark::integer < 5);


SELECT "group".name, student.name, subject.name, lesson.date, mark.mark
FROM mark
         JOIN student ON mark.id_student = student.id_student
         JOIN "group" ON student.id_group = "group".id_group
         JOIN lesson ON mark.id_lesson = lesson.id_lesson
         JOIN subject ON lesson.id_subject = subject.id_subject
WHERE "group".name = 'ПС'
  AND subject.name = 'БД'
  AND lesson.date < '2019-05-12'
  AND mark.mark::integer >= 5;


--7. Добавить необходимые индексы.
ALTER TABLE mark
    ALTER COLUMN mark TYPE INTEGER USING mark::INTEGER;

CREATE INDEX idx_student_id_group ON student (id_group);
CREATE INDEX idx_lesson_id_group_date ON lesson (id_group, date);

CREATE INDEX idx_mark_id_lesson_id_student ON mark (id_lesson, id_student);
CREATE INDEX idx_subject_id_name ON subject (id_subject, name);

CREATE INDEX idx_group_name ON "group" (name);
CREATE INDEX idx_mark_id_student_id_lesson ON mark (id_student, id_lesson);

CREATE INDEX IF NOT EXISTS idx_subject_name ON subject (name);
CREATE INDEX idx_lesson_date ON lesson (date);
CREATE INDEX idx_lesson_id_subject_date ON lesson (id_subject, date);
CREATE INDEX idx_mark_mark ON mark (mark);