-- sp_DBA_fields.sql  #SQL

USE [master]
go


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_DBA_fields]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_DBA_fields]
go

-----------------------------------------------------------------
-- Object:			sp_DBA_fields
-- Written By:		Martin Croft
-- Date Written:	Nov 2011
-- Purpose:			Return list of tables were columns exist
-- Example:			sp_DBA_fields @Field ='%Cust%'
-----------------------------------------------------------------
-- Modified By		Modified Date		Description
-----------------------------------------------------------------
-- {developer}		{date}			{description}
-----------------------------------------------------------------
  
CREATE PROCEDURE [dbo].[sp_DBA_fields]    
(    
 @field VARCHAR(100)    
)    
    
AS    
    
SELECT 
	 so.name AS 'Table',    
	 sc.name AS 'Field',    
	 st.name AS 'Type',    
	 sc.length,    
	 sc.prec,    
	 sc.scale,    
	 sc.isnullable    
FROM 
	syscolumns sc    
INNER JOIN 
	sysobjects so ON sc.id = so.id    
INNER JOIN 
	systypes st ON st.xusertype = sc.xusertype    
WHERE 
		so.type = 'U'    
	AND 
		sc.name LIKE '%'+ @field +'%'    
ORDER BY 
	so.name,sc.colorder  




GO

EXEC sp_MS_marksystemobject sp_DBA_fields

GO

EXEC sys.sp_addextendedproperty @name=N'Version', @value=N'10.0' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'sp_DBA_fields'
GO

GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Data dictionary get list of table were columns exists' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'sp_DBA_fields'
GO

EXEC sys.sp_addextendedproperty @name=N'Parameters', @value=N'@field= [enter search string]' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'sp_DBA_fields'
GO 

EXEC sp_ms_marksystemobject sp_DBA_fields

GO

GRANT EXEC on sp_DBA_fields to [PUBLIC]
