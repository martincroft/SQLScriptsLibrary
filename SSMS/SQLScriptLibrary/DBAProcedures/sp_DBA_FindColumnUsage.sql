-- sp_DBA_FindColumnUsage.sql  #SQL
USE [master]
GO


IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[sp_DBA_FindColumnUsage]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_DBA_FindColumnUsage]
GO

-----------------------------------------------------------------
-- Object:			sp_DBA_FindColumnUsage
-- Written By:		Martin Croft
-- Date Written:	Nov 2011
-- Purpose:			Search SQL code , views, procedures 
-- Example:			sp_DBA_FindColumnUsage @vcTableName ='CCD_Customer',@vcColumnName='SURNAME'
--					sp_DBA_FindColumnUsage @vcTableName ='[Person].[Person]',@vcColumnName='Lastname'
-----------------------------------------------------------------
-- Modified By		Modified Date		Description
-----------------------------------------------------------------
-- {developer}		{date}			{description}
-----------------------------------------------------------------

CREATE PROCEDURE [dbo].[sp_DBA_FindColumnUsage]    
 @vcTableName varchar(100),    
 @vcColumnName varchar(100)     
AS    
/************************************************************************************************    
DESCRIPTION: Creates prinatable report of all stored procedures, views, triggers    
  and user-defined functions that reference  the    
  table/column passed into the proc.    
     
PARAMETERS:    
  @vcTableName - table containing searched column    
  @vcColumnName - column being searched for    
REMARKS:    
  To print the output of this report in Query Analyzer/Management      
  Studio select the execute mode to be file and you will    
  be prompted for a file name to save as. Alternately    
  you can select the execute mode to be text, run the query, set    
  the focus on the results pane and then select File/Save from    
  the menu.    
    
  This procedure must be installed in the database where it will    
  be run due to it's use of database system tables.    
    
USAGE:     
       
  sp_DBA_FindColumnUsage 'jct_contract_element_card_sigs', 'contract_element_id'    
     
AUTHOR: Karen Gayda    
    
DATE: 07/19/2007    
    
MODIFICATION HISTORY:    
WHO  DATE  DESCRIPTION    
---  ---------- -------------------------------------------    
*************************************************************************************************/    
SET NOCOUNT ON    
    
    
    
PRINT ''    
PRINT 'REPORT FOR DEPENDENCIES FOR TABLE/COLUMN:'    
PRINT '-----------------------------------------'    
PRINT  @vcTableName + '.' +@vcColumnName    
    
    
PRINT ''    
PRINT ''    
PRINT 'STORED PROCEDURES:'    
PRINT ''    
    
SELECT DISTINCT  SUBSTRING(o.NAME,1,60) AS [Procedure Name]    
  FROM sysobjects o    
  INNER JOIN syscomments c    
   ON o.ID = c.ID    
  WHERE  o.XTYPE = 'P'    
   AND c.Text LIKE '%' + @vcColumnName + '%' + @vcTableName + '%'      
       
       
 ORDER BY  [Procedure Name]    
PRINT CAST(@@ROWCOUNT as Varchar(5)) + ' dependent stored procedures for column "' + @vcTableName + '.' +@vcColumnName +  '".'    
    
    
    
PRINT''    
PRINT''    
PRINT 'VIEWS:'    
PRINT''    
SELECT DISTINCT  SUBSTRING(o.NAME,1,60) AS [View Name]    
  FROM sysobjects o    
  INNER JOIN syscomments c    
   ON o.ID = c.ID    
  WHERE  o.XTYPE = 'V'    
   AND c.Text LIKE '%' + @vcColumnName + '%' + @vcTableName + '%'      
       
       
 ORDER BY  [View Name]    
PRINT CAST(@@ROWCOUNT as Varchar(5)) + ' dependent views for column "' + @vcTableName + '.' +@vcColumnName +  '".'    
    
    
PRINT ''    
PRINT ''    
PRINT 'FUNCTIONS:'    
PRINT ''    
    
SELECT DISTINCT  SUBSTRING(o.NAME,1,60) AS [Function Name],     
  CASE WHEN o.XTYPE = 'FN' THEN 'Scalar'    
   WHEN o.XTYPE = 'IF' THEN 'Inline'    
   WHEN o.XTYPE = 'TF' THEN 'Table'    
   ELSE '?'    
  END     
  as [Function Type]    
  FROM sysobjects o    
  INNER JOIN syscomments c    
   ON o.ID = c.ID    
  WHERE  o.XTYPE IN ('FN','IF','TF')    
   AND c.Text LIKE '%' + @vcColumnName + '%' + @vcTableName + '%'      
       
       
 ORDER BY  [Function Name]    
PRINT CAST(@@ROWCOUNT as Varchar(5)) + ' dependent functions for column "' + @vcTableName + '.' +@vcColumnName +  '".'    
    
PRINT''    
PRINT''    
PRINT 'TRIGGERS:'    
PRINT''    
    
SELECT DISTINCT  SUBSTRING(o.NAME,1,60) AS [Trigger Name]    
  FROM sysobjects o    
  INNER JOIN syscomments c    
   ON o.ID = c.ID    
  WHERE  o.XTYPE = 'TR'    
   AND c.Text LIKE '%' + @vcColumnName + '%' + @vcTableName + '%'      
       
       
 ORDER BY  [Trigger Name]    
PRINT CAST(@@ROWCOUNT as Varchar(5)) + ' dependent triggers for column "' + @vcTableName + '.' +@vcColumnName +  '".'  

GO


EXEC sp_MS_marksystemobject sp_DBA_FindColumnUsage

GO

EXEC sys.sp_addextendedproperty @name=N'Version', @value=N'1.0' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'sp_DBA_FindColumnUsage'
GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Get deatils of where table / column exists in proc/views/functions' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'sp_DBA_FindColumnUsage'
GO

EXEC sys.sp_addextendedproperty @name=N'Parameters', @value=N'@vcTableName =[enter table],@vcColumnName=[ColumnName]' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'sp_DBA_FindColumnUsage'
	GO
	EXEC sp_ms_marksystemobject sp_DBA_FindColumnUsage
	
	GO
	
	GRANT EXEC on sp_DBA_FindColumnUsage to [PUBLIC]
