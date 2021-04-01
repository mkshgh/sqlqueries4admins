declare @dbname varchar(max),@pass varchar(max),@user_name varchar(50);
declare @queryUser varchar(max), @query_userDB varchar(max)
SET @user_name = 'newUser';
SET @pass = 'enterst#rongpa$$w04D';
SET @dbname = 'CGPAY';

-- here the query needs to be one liner 
SET  @query_userDB = 'USE ['+@dbname+'];Select DB_NAME()'
EXEC sp_sqlexec @query_userDB
-- if it goes to new line the query has no idea what happened above
Select DB_NAME()
print @query_userDB

USE [CGPAY];

-- Create a login for the user
exec sp_addlogin @user_name, @pass;

-- Give access rights to the users
ALTER ROLE [db_accessadmin] ADD MEMBER [@user_name];
ALTER ROLE [db_ddladmin] ADD MEMBER [@user_name];
ALTER ROLE [db_datareader] ADD MEMBER [@user_name];
ALTER ROLE [db_datawriter] ADD MEMBER [@user_name];

-- Give this access only to the users added to the msdb only
IF DB_NAME() = 'msdb'
	BEGIN
    ALTER ROLE [DatabaseMailUserRole] ADD MEMBER [@user_name];
    ALTER ROLE [SQLAgentUserRole] ADD MEMBER [@user_name];
	print 'DB_Altered';
	END
ELSE 
	print 'nodb';

-- Get the user Roles from user
USE [CGPay]

SELECT DB_NAME() as dbname,  m.name AS member_principal_name, r.name role_principal_name
FROM sys.database_role_members rm 
JOIN sys.database_principals r 
    ON rm.role_principal_id = r.principal_id
JOIN sys.database_principals m 
    ON rm.member_principal_id = m.principal_id
where m.name = 'prabins'

-- Get the user and their roles from a specific DB
declare @dbname varchar(max),@pass varchar(max),@user_name varchar(50);
DECLARE @excluded_users VARCHAR(max) = '''guest'',''dbo'',''dc_admin'',''dc_operator'',''dc_operator'',''dc_operator'',''dc_proxy'',''dc_proxy'',''MS_DataCollectorInternalUser'',''PolicyAdministratorRole'',''ServerGroupAdministratorRole'',''SQLAgentOperatorRole'',''SQLAgentReaderRole'',''UtilityIMRWriter'',''INFORMATION_SCHEMA'',''sys'',''##MS_PolicyEventProcessingLogin##'',''##MS_PolicyTsqlExecutionLogin##'''
DECLARE @get_user_db_policy_Query VARCHAR(max)

SET @dbname = 'msdb'

SET @get_user_db_policy_Query = 'USE ['+@dbname+'];
SELECT DB_NAME() as dbname,  m.name AS member_principal_name, r.name role_principal_name
FROM sys.database_role_members rm 
JOIN sys.database_principals r 
    ON rm.role_principal_id = r.principal_id
JOIN sys.database_principals m 
    ON rm.member_principal_id = m.principal_id
where m.name NOT IN ('+@excluded_users+')
ORDER BY member_principal_name'

EXEC(@get_user_db_policy_Query)


-- Search for all the dbs in the server
-- Get the list of users and their roles in all the DBs except the excluded ones

declare @dbname varchar(max),@user varchar(50),@queryUser varchar(max)
DECLARE @excluded_users VARCHAR(max) = '''guest'',''dbo'',''dc_admin'',''dc_operator'',''dc_operator'',''dc_operator'',''dc_proxy'',''dc_proxy'',''MS_DataCollectorInternalUser'',''PolicyAdministratorRole'',''ServerGroupAdministratorRole'',''SQLAgentOperatorRole'',''SQLAgentReaderRole'',''UtilityIMRWriter'',''INFORMATION_SCHEMA'',''sys'',''##MS_PolicyEventProcessingLogin##'',''##MS_PolicyTsqlExecutionLogin##'''
DECLARE @get_user_db_policy_Query VARCHAR(max)

IF OBJECT_ID ('tempdb..#temp') is not null
BEGIN
    drop table #temp
END

select name into #temp from master.sys.sysdatabases;

WHILE EXISTS(Select Top 1 name  from #temp)
BEGIN
    SET @dbname = (Select Top 1 name  from #temp);
	SET @get_user_db_policy_Query = 'USE ['+@dbname+'];
	SELECT DB_NAME() as dbname,  m.name AS member_principal_name, r.name role_principal_name
	FROM sys.database_role_members rm 
	JOIN sys.database_principals r 
		ON rm.role_principal_id = r.principal_id
	JOIN sys.database_principals m 
		ON rm.member_principal_id = m.principal_id
	where m.name NOT IN ('+@excluded_users+')
	ORDER BY member_principal_name'

	EXEC(@get_user_db_policy_Query)
    Delete from #temp WHere name = @dbname
END

-- Search for all the dbs in the server
-- Get the list of users and their roles in all the DBs except the excluded ones
-- Create a query to delete all the existing users and login, add new login and associate the users to the given DB with the roles extracted.
-- Search for all the dbs in the server
-- Get the list of users and their roles in all the DBs except the excluded ones
-- Create a query to delete all the existing users and login, add new login and associate the users to the given DB with the roles extracted.
-- Search for all the dbs in the server
-- Get the list of users and their roles in all the DBs except the excluded ones
-- Create a query to delete all the existing users and login, add new login and associate the users to the given DB with the roles extracted.

declare @dbname varchar(max),@user varchar(50),@queryUser varchar(max)
DECLARE @excluded_users VARCHAR(max) = '''guest'',''dbo'',''dc_admin'',''dc_operator'',''dc_operator'',''dc_operator'',''dc_proxy'',''dc_proxy'',''MS_DataCollectorInternalUser'',''PolicyAdministratorRole'',''ServerGroupAdministratorRole'',''SQLAgentOperatorRole'',''SQLAgentReaderRole'',''UtilityIMRWriter'',''INFORMATION_SCHEMA'',''sys'',''##MS_PolicyEventProcessingLogin##'',''##MS_PolicyTsqlExecutionLogin##'''
DECLARE @get_user_db_policy_Query VARCHAR(max)
declare @is_preset_Query VARCHAR(max)
DECLARE @delete_existing_user_Query VARCHAR(max)
SET @user = 'prabinr'
IF OBJECT_ID ('tempdb..#temp') is not null
BEGIN
    drop table #temp
END
 
IF OBJECT_ID ('tempdb..#HoldTB') is not null
BEGIN
    drop table #HoldTB
END

Create table #HoldTB
(
    DBUserCreation varchar(max)
)

select name into #temp from master.sys.sysdatabases;

WHILE EXISTS(Select Top 1 name  from #temp)
BEGIN
	SET @dbname = (Select Top 1 name  from #temp);
	SET @get_user_db_policy_Query = 'USE ['+@dbname+'];
	SELECT ''ALTER ROLE [''+r.name+''] ADD MEMBER [''+m.name+'']'' AS ''DBUserCreation''
	FROM sys.database_role_members rm
	JOIN sys.database_principals r
		ON rm.role_principal_id = r.principal_id
	JOIN sys.database_principals m 
		ON rm.member_principal_id = m.principal_id
	where m.name NOT IN ('+@excluded_users+')
	ORDER BY m.name';
	
	SET @delete_existing_user_Query = 'USE ['+@dbname+'];
		SELECT ''DROP USER IF EXISTS "'+@user+'" ' + CHAR(13) + 'GO' + CHAR(13) + 'CREATE USER ['+@user+'] FOR LOGIN ['+@user+'] WITH DEFAULT_SCHEMA=[dbo]' + CHAR(13)+ 'GO''
		FROM sys.sysusers
		where m.name NOT IN ('+@excluded_users+')
		ORDER BY m.name';

	
	INSERT INTO #HoldTB VALUES ('USE ['+@dbname+']')
	INSERT INTO #HoldTB VALUES (@delete_existing_user_Query)
	-- INSERT INTO #HoldTB VALUES ('DROP USER IF EXISTS "'+@user+'" ')
	-- INSERT INTO #HoldTB VALUES ('GO')
	-- INSERT INTO #HoldTB VALUES ('CREATE USER ['+@user+'] FOR LOGIN ['+@user+'] WITH DEFAULT_SCHEMA=[dbo]')
	-- INSERT INTO #HoldTB VALUES ('GO')
	INSERT INTO #HoldTB EXEC(@get_user_db_policy_Query)
	INSERT INTO #HoldTB VALUES ('GO')
    Delete from #temp WHere name = @dbname
	
END
select * from #HoldTB
drop table #HoldTB
drop table #temp
ALTER ROLE [db_accessadmin] ADD MEMBER [@user_name];