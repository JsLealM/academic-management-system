-- 01. Create rol
CREATE ROLE sga_admin;
-- 01.1 Create user
CREATE USER rds_user_test WITH PASSWORD '*************';
-- 02. Create database (with ENCODING= 'UTF8', TEMPLATE=Template 0)
CREATE DATABASE academic_management_database WITH ENCODING='UTF8' LC_COLLATE='es_CO.UTF-8' LC_CTYPE='es_CO.UTF-8' TEMPLATE=template0;
-- 03. Grant privileges to role
GRANT ALL PRIVILEGES ON DATABASE academic_management_database TO sga_admin;
-- 03.2 Grant privileges to user
GRANT sga_admin TO rds_user_test;
-- 04. Create Schema
CREATE SCHEMA IF NOT EXISTS academic;
-- 04.2 Grant privileges on schema
ALTER SCHEMA academic OWNER TO sga_admin;
-- 05. Comment on database
COMMENT ON DATABASE academic_management_database IS 'Database for the academic management system, using the Springboot framework.';
-- 06. Comment of schema
COMMENT ON SCHEMA academic IS 'Main scheme for the academic management system.';