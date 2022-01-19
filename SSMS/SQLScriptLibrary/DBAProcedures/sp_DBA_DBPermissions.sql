-- sp_DBA_DBPermissions.sql  #SQL


USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_DBA_DBPermissions]    Script Date: 10/21/2010 16:04:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_DBA_DBPermissions]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_DBA_DBPermissions]
GO



CREATE   PROCEDURE [dbo].[sp_DBA_DBPermissions] 

AS  
  
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
(ServerName sysname,DatabaseName sysname,member_principal_name sysname,principal_type_desc sysname,role_name sysname,TimeStampDate DATETIME)

 INSERT INTO @SecurityDetails
	   
EXEC sp_MSForEachDB  N'USE [?]; 
			
	   
	   SELECT @@ServerName,
	   DB_name(),
	   rm.member_principal_name, 
	   rm.principal_type_desc, 
	   rm.role_name,
	   Getdate()
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


EXEC sp_MS_marksystemobject sp_DBA_DBPermissions

GO

EXEC sys.sp_addextendedproperty @name=N'Version', @value=N'2.0' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'sp_DBA_DBPermissions'
GO

GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Get database permission information' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'sp_DBA_DBPermissions'
GO

EXEC sys.sp_addextendedproperty @name=N'Parameters', @value=N'N/A' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'sp_DBA_DBPermissions'
GO

EXEC sys.sp_addextendedproperty @name=N'RunID', 
		@value=N'1' , 
		@level0type=N'SCHEMA',
		@level0name=N'dbo', 
		@level1type=N'PROCEDURE',
		@level1name=N'sp_DBA_DBPermissions'

EXEC sp_MS_marksystemobject    sp_DBA_DBPermissions

GO

GRANT EXEC on sp_DBA_DBPermissions to [PUBLIC]
