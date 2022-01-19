-- sp_DBA_TableInfo.sql  #SQL
USE [master]
GO

IF EXISTS (
		SELECT *
		FROM sys.sysobjects
		WHERE id = OBJECT_ID(N'sp_DBA_TableInfo')
			AND type = 'p'
		)
	DROP PROCEDURE sp_DBA_TableInfo
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].sp_DBA_TableInfo (
	@TableName SYSNAME = NULL
	,@SchemeName SYSNAME = NULL
	,@Sort TINYINT = 1
	,@IncludeExcluded BIT = NULL
	,@CountOnly BIT = NULL
	)
AS
-----------------------------------------------------------------  
-- Object:   sp_DBA_TableInfo  
-- Written By: Martin Croft 
-- Date Written:   
-- Purpose:   Return table information
-- Usage:     
-- sp_DBA_TableInfo  @TableName='dbCodelookup'
-- Calls:   N/A  
-----------------------------------------------------------------  

SELECT TABLE_SCHEMA +'.'+TABLE_NAME AS tableName, TABLE_TYPE FROM INFORMATION_SCHEMA.TABLES
ORDER BY TABLE_TYPE,TABLE_SCHEMA +'.'+TABLE_NAME 




GO

EXEC sp_MS_marksystemobject 'sp_DBA_TableInfo'
GO

EXEC sys.sp_addextendedproperty @name = N'Version'
	,@value = N'1.0'
	,@level0type = N'SCHEMA'
	,@level0name = N'dbo'
	,@level1type = N'PROCEDURE'
	,@level1name = N'sp_DBA_TableInfo'
GO

EXEC sys.sp_addextendedproperty @name = N'Description'
	,@value = N'Get missing index information'
	,@level0type = N'SCHEMA'
	,@level0name = N'dbo'
	,@level1type = N'PROCEDURE'
	,@level1name = N'sp_DBA_TableInfo'
GO

EXEC sys.sp_addextendedproperty @name = N'Parameters'
	,@value = N'@ObjectName=NULL,@SchemeName=dbo,@Sort =1'
	,@level0type = N'SCHEMA'
	,@level0name = N'dbo'
	,@level1type = N'PROCEDURE'
	,@level1name = N'sp_DBA_TableInfo'
GO

GRANT EXEC
	ON sp_DBA_TableInfo
	TO [PUBLIC]
