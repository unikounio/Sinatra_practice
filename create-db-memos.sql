CREATE DATABASE memos with encoding 'UTF8' TEMPLATE template0;

\c memos

CREATE TABLE memos(  
    memo_id int NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    title VARCHAR(255),
    body VARCHAR(1000)
);
