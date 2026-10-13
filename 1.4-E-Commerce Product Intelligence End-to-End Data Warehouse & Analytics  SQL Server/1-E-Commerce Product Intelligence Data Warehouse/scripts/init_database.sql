/*
=============================================================
Create Database and Schemas
=============================================================
Author  : Mohamed Abdullah Ali
Project : E-Commerce Product Intelligence Data Warehouse

Script Purpose:
    Creates the 'EcommerceDW' database (dropping it first if it exists) and
    the three Medallion schemas: 'bronze', 'silver' and 'gold'.

WARNING:
    Running this script DROPS the entire 'EcommerceDW' database if it exists.
    All data is permanently deleted. Make sure you have backups first.
=============================================================
*/

USE master;
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'EcommerceDW')
BEGIN
    ALTER DATABASE EcommerceDW SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE EcommerceDW;
END;
GO

CREATE DATABASE EcommerceDW;
GO

USE EcommerceDW;
GO

CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
