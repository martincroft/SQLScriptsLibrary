-- DBA_Permissions.sql  #SQL


  
-----------------------------------------------------------------  
-- Object:   sp_DBA_DBPermissions  
-- Written By:  
-- Date Written:   
-- Purpose:   Returns permissions for all databases   
-- Template:  1.0   
-- Usage:     
--    sp_DBA_DBPermissions  
-- Calls:   N/A  
-----------------------------------------------------------------  
-- Modified By  Modified Date  Description					Version 
-- MAC			16/11/2010	   Modified to use table var	2.0
-----------------------------------------------------------------  
-- {developer}  {date}    {description} {Version}  
-----------------------------------------------------------------  

DECLARE  @SecurityDetails TABLE
(ServerName sysname,DatabaseName sysname,member_principal_name sysname,principal_type_desc sysname,role_name sysname)

 INSERT INTO @SecurityDetails
	   
EXEC sp_MSForEachDB  N'USE [?]; 
			
	   
	   SELECT @@ServerName,
	   DB_name(),
	   rm.member_principal_name, 
	   rm.principal_type_desc, 
	   rm.role_name
FROM    sys.database_principals p
right outer JOIN (
				  select role_principal_id, 
				  dp.type_desc as principal_type_desc, 
				  member_principal_id,user_name(member_principal_id) as member_principal_name,
				  user_name(role_principal_id) as role_name

				  from sys.database_role_members rm
				  INNER JOIN sys.database_principals dp
					ON    rm.member_principal_id = dp.principal_id
				 
				   ) rm
ON   rm.role_principal_id = p.principal_id

Where principal_type_desc in (''Sql_User'',''WINDOWS_USER'',''WINDOWS_GROUP'')'

SELECT * FROM @SecurityDetails

GO


