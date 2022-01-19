-- sp_DBA_search_code.sql  #SQL
USE [master]
GO


IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[sp_DBA_search_code]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_DBA_search_code]
GO

-----------------------------------------------------------------
-- Object:			sp_DBA_search_code
-- Written By:		Martin Croft
-- Date Written:	Nov 2011
-- Purpose:			Search SQL code , views, procedures 
-- Example:			sp_DBA_search_code @SearchStr ='cust'
-----------------------------------------------------------------
-- Modified By		Modified Date		Description
-----------------------------------------------------------------
-- {developer}		{date}			{description}
-----------------------------------------------------------------
  

  
CREATE PROC [dbo].[sp_DBA_search_code]      
(      
@SearchStr  VARCHAR(100)    
)      
AS      
    
BEGIN      
      
 SELECT DISTINCT USER_NAME(o.uid) + '.' + OBJECT_NAME(c.id) AS 'Object name',      
  CASE       
    WHEN OBJECTPROPERTY(c.id, 'IsReplProc') = 1       
    THEN 'Replication stored procedure'      
    WHEN OBJECTPROPERTY(c.id, 'IsExtendedProc') = 1       
    THEN 'Extended stored procedure'          
   WHEN OBJECTPROPERTY(c.id, 'IsProcedure') = 1       
    THEN 'Stored Procedure'       
   WHEN OBJECTPROPERTY(c.id, 'IsTrigger') = 1       
    THEN 'Trigger'       
   WHEN OBJECTPROPERTY(c.id, 'IsTableFunction') = 1       
    THEN 'Table-valued function'       
   WHEN OBJECTPROPERTY(c.id, 'IsScalarFunction') = 1       
    THEN 'Scalar-valued function'      
    WHEN OBJECTPROPERTY(c.id, 'IsInlineFunction') = 1       
    THEN 'Inline function'       
  END AS 'Object type',      
  'EXEC sp_helptext ''' + USER_NAME(o.uid) + '.' + OBJECT_NAME(c.id) + '''' AS 'Run this command to see the object text'      
 FROM syscomments c      
  INNER JOIN      
  sysobjects o      
  ON c.id = o.id      
 WHERE c.text LIKE '%' + @SearchStr + '%' AND      
  encrypted = 0    AND      
  (      
  OBJECTPROPERTY(c.id, 'IsReplProc') = 1  OR      
  OBJECTPROPERTY(c.id, 'IsExtendedProc') = 1 OR      
  OBJECTPROPERTY(c.id, 'IsProcedure') = 1  OR      
  OBJECTPROPERTY(c.id, 'IsTrigger') = 1  OR      
  OBJECTPROPERTY(c.id, 'IsTableFunction') = 1 OR      
  OBJECTPROPERTY(c.id, 'IsScalarFunction') = 1 OR      
  OBJECTPROPERTY(c.id, 'IsInlineFunction') = 1       
  )      
      
 ORDER BY 'Object type', 'Object name'      
      
END  


GO




EXEC sp_MS_marksystemobject [sp_DBA_search_code]

GO

EXEC sys.sp_addextendedproperty @name=N'Version', @value=N'1.0' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'sp_DBA_search_code'
GO

GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Search Views / Stored Procedures' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'sp_DBA_search_code'
GO

EXEC sys.sp_addextendedproperty @name=N'Parameters', @value=N'@SearchStr= [string to search]' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'sp_DBA_search_code'
      


    
