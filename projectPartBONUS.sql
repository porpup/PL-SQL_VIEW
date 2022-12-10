SPOOL /tmp/oracle/projectPartBONUS_spool.txt

SELECT
    to_char (sysdate, 'DD Month YYYY Year Day HH:MI:SS AM')
FROM
    dual;

/* Question 1: (use script 7Clearwater) 
Create a view containing item description, item_id, price, 
color, inventory_id, size of all the inventory of 
clearwater database. 
Can we UPDATE, INSERT directly TO the view? 
If NOT, can you provide a solution? */
CONNECT des02/des02

CREATE OR REPLACE VIEW inv_view AS
SELECT
    ITEM_DESC,
    ITEM.ITEM_ID,
    INV_PRICE,
    COLOR,
    INV_ID,
    INV_SIZE
FROM
    ITEM,
    INVENTORY
WHERE
    ITEM.ITEM_ID = INVENTORY.ITEM_ID;

GRANT SELECT, INSERT, UPDATE ON inv_view TO scott;

CREATE OR REPLACE TRIGGER instead_update_inv_view
INSTEAD OF UPDATE ON inv_view
FOR EACH ROW
BEGIN
    UPDATE ITEM
    SET ITEM_DESC = :NEW.ITEM_DESC
    WHERE ITEM_ID = :NEW.ITEM_ID;

    UPDATE INVENTORY
    SET INV_PRICE = :NEW.INV_PRICE,
        COLOR = :NEW.COLOR,
        INV_SIZE = :NEW.INV_SIZE
    WHERE INV_ID = :NEW.INV_ID;
END;
/

CREATE SEQUENCE inv_sequence START WITH 33;

GRANT SELECT ON inv_sequence TO scott;

CREATE SEQUENCE item_sequence START WITH 8;

GRANT SELECT ON item_sequence TO scott;

CREATE OR REPLACE TRIGGER instead_insert_inv_view
INSTEAD OF INSERT ON inv_view
FOR EACH ROW
BEGIN
    INSERT INTO ITEM (
                        ITEM_ID,
                        ITEM_DESC
    ) VALUES (
            item_sequence.CURRVAL,
            :NEW.ITEM_DESC
    );

    INSERT INTO INVENTORY (
                            INV_PRICE,
                            COLOR,
                            INV_ID,
                            INV_SIZE,
                            ITEM_ID
    ) VALUES (
            :NEW.INV_PRICE,
            :NEW.COLOR,
            inv_sequence.CURRVAL,
            :NEW.INV_SIZE,
            item_sequence.CURRVAL
    );
END;
/

CONNECT scott/tiger

UPDATE des02.inv_view
SET INV_PRICE = 499
WHERE ITEM_ID = 2;

INSERT INTO des02.inv_view
VALUES (
            'Shorts',
            des02.item_sequence.NEXTVAL,
            59,
            'Red',
            des02.inv_sequence.NEXTVAL,
            'S'
);

SET LINESIZE 200;

SELECT * FROM des02.inv_view;





/* Question 2: (use script 7Northwoods)
Create a view containing course name, credit, student name, 
c_sec_id, SEC NUM, grade of all course section taken by a student. 
Can we UPDATE, INSERT directly TO the view? 
If NOT, can you provide a solution? */
CONNECT des03/des03

CREATE OR REPLACE VIEW course_view AS
SELECT
    COURSE.COURSE_ID,
    COURSE_NAME,
    CREDITS,
    STUDENT.S_ID,
    S_LAST,
    COURSE_SECTION.C_SEC_ID,
    SEC_NUM,
    GRADE
FROM
    COURSE,
    COURSE_SECTION,
    STUDENT,
    ENROLLMENT
WHERE
    COURSE.COURSE_ID = COURSE_SECTION.COURSE_ID AND
    STUDENT.S_ID = ENROLLMENT.S_ID AND
    COURSE_SECTION.C_SEC_ID = ENROLLMENT.C_SEC_ID;

GRANT SELECT, INSERT, UPDATE ON course_view TO scott;

CREATE OR REPLACE TRIGGER instead_update_course_view
INSTEAD OF UPDATE ON course_view
FOR EACH ROW
BEGIN
    UPDATE COURSE
    SET COURSE_NAME = :NEW.COURSE_NAME,
        CREDITS = :NEW.CREDITS
    WHERE COURSE_ID = :NEW.COURSE_ID;

    UPDATE STUDENT
    SET S_LAST = :NEW.S_LAST
    WHERE S_ID = :NEW.S_ID;
    
    UPDATE COURSE_SECTION
    SET SEC_NUM = :NEW.SEC_NUM
    WHERE C_SEC_ID = :NEW.C_SEC_ID;
    
    UPDATE ENROLLMENT
    SET GRADE = :NEW.GRADE
    WHERE C_SEC_ID = :NEW.C_SEC_ID; 
END;
/

CREATE SEQUENCE course_seq START WITH 6;

GRANT SELECT ON course_seq TO scott;

CREATE SEQUENCE student_seq START WITH 7;

GRANT SELECT ON student_seq TO scott;

CREATE SEQUENCE course_section_seq START WITH 14;

GRANT SELECT ON course_section_seq TO scott;

CREATE SEQUENCE term_id_seq START WITH 7;

CREATE OR REPLACE TRIGGER instead_insert_course_view
INSTEAD OF INSERT ON course_view
FOR EACH ROW
BEGIN
    INSERT INTO COURSE (
                        COURSE_ID,
                        COURSE_NAME,
                        CREDITS
    ) VALUES (
            course_seq.CURRVAL,
            :NEW.COURSE_NAME,
            :NEW.CREDITS
    );

    INSERT INTO STUDENT (
                        S_ID,
                        S_LAST
    ) VALUES (
            student_seq.CURRVAL,
            :NEW.S_LAST
    );
    
    INSERT INTO TERM (
                        TERM_ID
    ) VALUES (
                term_id_seq.NEXTVAL
    );

    INSERT INTO COURSE_SECTION (
                                C_SEC_ID,
                                SEC_NUM,
                                COURSE_ID,
                                TERM_ID,
                                MAX_ENRL
    ) VALUES (
            course_section_seq.CURRVAL,
            :NEW.SEC_NUM,
            course_seq.CURRVAL,
            term_id_seq.CURRVAL,
            35
    );

    INSERT INTO ENROLLMENT (
                            S_ID,
                            C_SEC_ID,
                            GRADE
    ) VALUES (
            student_seq.CURRVAL,
            course_section_seq.CURRVAL,
            :NEW.GRADE
    );
END;
/

CONNECT scott/tiger

UPDATE des03.course_view
SET GRADE = 'A'
WHERE C_SEC_ID = 12;

UPDATE des03.course_view
SET S_LAST = 'Baraka'
WHERE S_ID = 3;

INSERT INTO des03.course_view
VALUES (    
        des03.course_seq.NEXTVAL,
        'Database',
        3,
        des03.student_seq.NEXTVAL,
        'Jackson',
        des03.course_section_seq.NEXTVAL,
        1,
        'A'
);

SET LINESIZE 200;

SELECT * FROM des03.course_view;


SPOOL OFF;