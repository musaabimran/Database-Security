-- DEMO PART --
-- ENCRYPTING DATABASE WITH AES 256 --


-- Creating database
CREATE DATABASE Customerdata1;

-- use database
Go 
USE Customerdata1;
GO
   


-- creating table
 CREATE TABLE Customerdata1.dbo.CustomerInfo
(
CustID  INT PRIMARY KEY, 
CustName     VARCHAR(30) NOT NULL, 
BankACCNumber VARCHAR(10) NOT NULL
);
GO


-- inserting values in database
Insert into Customerdata1.dbo.CustomerInfo (CustID,CustName,BankACCNumber)
            Select 1,'Abdullah',11111111 UNION ALL
            Select 2, 'Aisha',22222222 UNION ALL
            Select 3, 'Minahil',33333333 UNION ALL
            Select 4,'Ahmed',44444444 UNION ALL
            Select 5, 'Aosaf',55555555



-- We use CREATE MASTER KEY statement for creating a database master key:
USE Customerdata1;
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'X5j13$#eCM1cG@Kdc';

-- ENCRYPTION
-- We can use sys.symmetric_keys catalog view to verify the existence of this database master key in SQL Server encryption:
SELECT name KeyName, 
    symmetric_key_id KeyID, 
    key_length KeyLength, 
    algorithm_desc KeyAlgorithm
FROM sys.symmetric_keys;


-- Execute the following query for creating a certificate:

USE Customerdata1;
GO
CREATE CERTIFICATE Certificate_test WITH SUBJECT = 'Protect my data';
GO


-- We can verify the certificate using the catalog view sys.certificates:

SELECT name CertName, 
    certificate_id CertID, 
    pvt_key_encryption_type_desc EncryptType, 
    issuer_name Issuer
FROM sys.certificates;

/*
We use CREATE SYMMETRIC KEY statement for it using the following parameters:

1- ALGORITHM: AES_256
2- ENCRYPTION BY CERTIFICATE: It should be the same certificate name that we specified earlier using CREATE CERTIFICATE statement
*/

CREATE SYMMETRIC KEY SymKey_test WITH ALGORITHM = AES_256 ENCRYPTION BY CERTIFICATE Certificate_test;



-- Once we have created this symmetric key, check the existing keys using catalog view for column level SQL Server Encryption as checked earlier
SELECT name KeyName, 
    symmetric_key_id KeyID, 
    key_length KeyLength, 
    algorithm_desc KeyAlgorithm
FROM sys.symmetric_keys;



ALTER TABLE Customerdata1.dbo.CustomerInfo
ADD BankACCNumber_encrypt varbinary(MAX)



-- In a query window, open the symmetric key and decrypt using the certificate. 
-- We need to use the same symmetric key and certificate name that we created earlier
OPEN SYMMETRIC KEY SymKey_test
        DECRYPTION BY CERTIFICATE Certificate_test;


UPDATE Customerdata1.dbo.CustomerInfo
        SET BankACCNumber_encrypt = EncryptByKey (Key_GUID('SymKey_test'), BankACCNumber)system.byte
        FROM Customerdata1.dbo.CustomerInfo;
        GO

-- Close the symmetric key using the CLOSE SYMMETRIC KEY statement. 
-- If we do not close the key, it remains open until the session is terminated
CLOSE SYMMETRIC KEY SymKey_test;
            GO

-- Let’s remove the old column as well
ALTER TABLE Customerdata1.dbo.CustomerInfo DROP COLUMN BankACCNumber;
GO



-- printing all of the data
SELECT * 
FROM Customerdata1.dbo.CustomerInfo;



-- DECRYPTION
-- In a query window, open the symmetric key and decrypt using the certificate. We need to use the same symmetric key 
-- and certificate name that we created earlier

OPEN SYMMETRIC KEY SymKey_test
        DECRYPTION BY CERTIFICATE Certificate_test;


--Use the SELECT statement and decrypt encrypted data using the DecryptByKey() function
SELECT CustID, CustName,BankACCNumber_encrypt AS 'Encrypted data',
            CONVERT(varchar, DecryptByKey(BankACCNumber_encrypt)) AS 'Decrypted Bank account number'
            FROM Customerdata1.dbo.CustomerInfo;



-- Permissions required for decrypting data
-- A user with the read permission cannot decrypt data using the symmetric key. 
-- Let’s simulate the issue. For this, we will create a user and provide db_datareader permissions on Customerdata1 database:

USE [master]
GO
CREATE LOGIN [SQLShack] WITH PASSWORD=N'sqlshack', DEFAULT_DATABASE=[CustomerData1], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
USE [CustomerData1]
GO
CREATE USER [SQLShack] FOR LOGIN [SQLShack]
GO
USE [CustomerData1]
GO
ALTER ROLE [db_datareader] ADD MEMBER [SQLShack]
GO

-- Now connect to SSMS using SQLShack user and execute the query to select the record with decrypting BankACCNumber_encrypt column:

OPEN SYMMETRIC KEY SymKey_test
DECRYPTION BY CERTIFICATE Certificate_test;
    
SELECT CustID, CustName,BankACCNumber_encrypt AS 'Encrypted data',
CONVERT(varchar, DecryptByKey(BankACCNumber_encrypt)) AS 'Decrypted Bank account number'
FROM Customerdata1.dbo.CustomerInfo;

-- We can provide permissions to the Symmetric key and Certificate:

-- Symmetric key permission: GRANT VIEW DEFINITION
-- Certificate permission: GRANT VIEW DEFINITION and GRANT CONTROL permissions
-- Execute these scripts with from a user account with admin privileges:

GRANT VIEW DEFINITION ON SYMMETRIC KEY::SymKey_test TO SQLShack; 
GO
GRANT VIEW DEFINITION ON Certificate::[Certificate_test] TO SQLShack;
GO
GRANT CONTROL ON Certificate::[Certificate_test] TO SQLShack;