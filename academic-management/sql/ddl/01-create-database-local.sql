-- 01. Create user
CREATE USER sga_admin WITH PASSWORD '*************';
-- 02. Create database (with ENCODING= 'UTF8', TEMPLATE=Template 0, OWNER: sga_admin)
CREATE DATABASE academic_management_database WITH ENCODING='UTF8' LC_COLLATE='es_CO.UTF-8' LC_CTYPE='es_CO.UTF-8' TEMPLATE=template0 OWNER = sga_admin;
-- 03. Grant privileges
GRANT ALL PRIVILEGES ON DATABASE academic_management_database TO sga_admin;
-- 04. Create Schema
CREATE SCHEMA IF NOT EXISTS academic AUTHORIZATION sga_admin;
-- 05. Comment on database
COMMENT ON DATABASE academic_management_database IS 'Database for the academic management system.';
-- 06. Comment of schema
COMMENT ON SCHEMA academic IS 'Main scheme for the academic management system';