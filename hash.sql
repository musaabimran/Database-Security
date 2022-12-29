-- create database
CREATE DATABASE hashing_passowrds

use hashing_passowrds

-- creating table
CREATE TABLE dbo.[User]
(
    UserID INT IDENTITY(1,1) NOT NULL,
    LoginName NVARCHAR(40) NOT NULL,
    PasswordHash BINARY(64) NOT NULL,
    FirstName NVARCHAR(40) NULL,
    LastName NVARCHAR(40) NULL,
    CONSTRAINT [PK_User_UserID] PRIMARY KEY CLUSTERED (UserID ASC)
)

/*
We developed this stored procedure in the simplest way to illustrate this example, 
but in reality these kind of procedures contain more complicated code)
*/

CREATE PROCEDURE dbo.uspAddUser
    @pLogin NVARCHAR(50), 
    @pPassword NVARCHAR(50), 
    @pFirstName NVARCHAR(40) = NULL, 
    @pLastName NVARCHAR(40) = NULL,
    @responseMessage NVARCHAR(250) OUTPUT
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRY

        INSERT INTO dbo.[User] (LoginName, PasswordHash, FirstName, LastName)
        VALUES(@pLogin, HASHBYTES('SHA2_256', @pPassword), @pFirstName, @pLastName)

        SET @responseMessage='Success'

    END TRY
    BEGIN CATCH
        SET @responseMessage=ERROR_MESSAGE() 
    END CATCH

END

/*
As we can see, the stored procedure takes the password as an input parameter and inserts it into the database in an encrypted form 
HASHBYTES('SHA2_256', @pPassword). We can run the stored procedure as follows
*/

DECLARE @responseMessage NVARCHAR(250)

EXEC dbo.uspAddUser
          @pLogin = N'Admin',
          @pPassword = N'123',
          @pFirstName = N'Admin',
          @pLastName = N'Administrator',
          @responseMessage=@responseMessage OUTPUT

SELECT *
FROM [dbo].[User]

/*
There is also a way to make a stronger hash, even if the user chooses a weak password. 
It is a hash generated from the combination of a password and randomly generated text. 
This randomly generated text is called a salt in cryptography. 
In this case the attacker should spend incomparably more time, because he/she should also consider the salt for cracking.
Salt should be unique for each user, otherwise if two different users have the same password, their password 
hashes also will be the same and if their salts are the same, it means that the hashed password string for these users
will be the same, which is risky because after cracking one of the passwords the attacker will know the other password too.  
By using different salts for each user, we can avoid these kinds of situations.
*/


ALTER TABLE dbo.[User] ADD Salt UNIQUEIDENTIFIER 
GO

ALTER PROCEDURE dbo.uspAddUser
    @pLogin NVARCHAR(50), 
    @pPassword NVARCHAR(50),
    @pFirstName NVARCHAR(40) = NULL, 
    @pLastName NVARCHAR(40) = NULL,
    @responseMessage NVARCHAR(250) OUTPUT
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @salt UNIQUEIDENTIFIER=NEWID()
    BEGIN TRY

        INSERT INTO dbo.[User] (LoginName, PasswordHash, Salt, FirstName, LastName)
        VALUES(@pLogin, HASHBYTES('SHA2_512', @pPassword+CAST(@salt AS NVARCHAR(36))), @salt, @pFirstName, @pLastName)

       SET @responseMessage='Success'

    END TRY
    BEGIN CATCH
        SET @responseMessage=ERROR_MESSAGE() 
    END CATCH

END
	

-- Then we truncate the table and run the procedure again:

TRUNCATE TABLE [dbo].[User]

DECLARE @responseMessage NVARCHAR(250)

EXEC dbo.uspAddUser
          @pLogin = N'Admin',
          @pPassword = N'123',
          @pFirstName = N'Admin',
          @pLastName = N'Administrator',
          @responseMessage=@responseMessage OUTPUT

SELECT UserID, LoginName, PasswordHash, Salt, FirstName, LastName
FROM [dbo].[User]
	
