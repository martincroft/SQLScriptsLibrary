-- sp_DBA_tools.sql  #SQL
USE [master]
go

IF EXISTS ( SELECT * FROM sysobjects where id = OBJECT_ID(N'sp_DBA_tools') and type = 'p')
DROP PROCEDURE sp_DBA_tools
Go



USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_DBAtools]    Script Date: 10/21/2010 15:51:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[sp_DBA_tools] 
AS  
EXECUTE AS login = 'sa'  
-----------------------------------------------------------------  
-- Object:   sp_DBA_tools  
-- Written By:  Martin Croft  
-- Date Written:   
-- Purpose:   Return   
-- Template:  1.0   
-- Usage:     
--    sp_DBAtools  
-- Calls:   N/A  
-----------------------------------------------------------------  
-- Modified By  Modified Date  Description  Version  
-----------------------------------------------------------------  
-- {developer}  {date}    {description} {Version}  
-----------------------------------------------------------------  


SELECT 
	tab.name
	,MAX('Master') AS Location
	,MAX(CASE 
		WHEN ex.name ='Version' THEN  CAST(ex.value AS sql_variant) 
		ELSE '' 
	END		
		)AS [version]
	, MAX(CASE 
		WHEN ex.name ='RunID' THEN  CAST(ex.value AS sql_variant) 
		ELSE '' 
	END	)AS [RunID]	
	, MAX(CASE 
		WHEN ex.name ='Description' THEN  CAST(ex.value AS sql_variant) 
		ELSE '' 
	END		
		)AS [Description]
	, MAX(CASE 
		WHEN ex.name ='Parameters' THEN  CAST(ex.value AS sql_variant) 
		ELSE '' 
	END		
		)AS [Parameters]


FROM
	Master.sys.objects tab
LEFT JOIN
	Master.sys.extended_properties ex on ex.major_id=tab.object_id	AND ex.minor_id=0 AND ex.class=1
WHERE
	tab.name like '%[_]DBA[_]%'
GROUP BY 
	  tab.name

GO
EXEC sys.sp_addextendedproperty @name=N'Version', @value=N'1.0' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'sp_DBA_tools'
GO

GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'List DBA support procedures' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'sp_DBA_tools'
GO
GRANT EXEC on sp_DBA_tools to [PUBLIC]
GO




