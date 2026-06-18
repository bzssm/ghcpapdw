-- ZavaBankDB Database Creation Script
-- Zava Bank Legacy Banking Application
-- Generated: 2026-05-14

USE [master];
GO

-- Create database if it doesn't exist
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'ZavaBankDB')
BEGIN
    CREATE DATABASE [ZavaBankDB]
    COLLATE SQL_Latin1_General_CP1_CI_AS;
END
GO

ALTER DATABASE [ZavaBankDB] SET RECOVERY SIMPLE;
GO

-- Create application login
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = N'zavaapp')
BEGIN
    CREATE LOGIN [zavaapp] WITH PASSWORD = N'ZavaBank2024!', DEFAULT_DATABASE = [ZavaBankDB];
END
GO

USE [ZavaBankDB];
GO

-- Create application user
IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = N'zavaapp')
BEGIN
    CREATE USER [zavaapp] FOR LOGIN [zavaapp];
END
GO

ALTER ROLE [db_owner] ADD MEMBER [zavaapp];
GO

PRINT 'Database ZavaBankDB created successfully.';
GO
