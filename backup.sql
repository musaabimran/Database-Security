USE [master];
GO

CREATE DATABASE [SQLTestDB];
GO

USE [SQLTestDB];
GO
CREATE TABLE SQLTest (
	ID INT NOT NULL PRIMARY KEY,
	c1 VARCHAR(100) NOT NULL,
	dt1 DATETIME NOT NULL DEFAULT GETDATE()
);
GO

USE [SQLTestDB]
GO

INSERT INTO SQLTest (ID, c1) VALUES (1, 'test1');
INSERT INTO SQLTest (ID, c1) VALUES (2, 'test2');
INSERT INTO SQLTest (ID, c1) VALUES (3, 'test3');
INSERT INTO SQLTest (ID, c1) VALUES (4, 'test4');
INSERT INTO SQLTest (ID, c1) VALUES (5, 'test5');
GO

SELECT * FROM SQLTest;
GO

-- Alternatively, you can run the following Transact-SQL command to back up your database. The path may be different on your computer
USE [master];
GO
BACKUP DATABASE [SQLTestDB]
TO DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\SQLTestDB.bak' 
WITH NOFORMAT, NOINIT,
NAME = N'SQLTestDB-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, STATS = 10;
GO

-- Alternatively, you can run the following Transact-SQL script to restore your database. The path may be different on your computer
USE [master];
GO
RESTORE DATABASE [SQLTestDB] 
FROM DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\SQLTestDB.bak' WITH  FILE = 1, NOUNLOAD, STATS = 5;
GO


-- Run the following Transact-SQL command to remove the database you created, along with its backup history in the msdb database:
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'SQLTestDB'
GO

USE [master];
GO
DROP DATABASE [SQLTestDB];
GO