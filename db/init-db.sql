CREATE DATABASE testdb;
CREATE TABLE table1 (
column1 integer,
column2 integer);

INSERT INTO table1 (column1)
SELECT a.column1 FROM generate_series(1, 1000000) AS a (column1);