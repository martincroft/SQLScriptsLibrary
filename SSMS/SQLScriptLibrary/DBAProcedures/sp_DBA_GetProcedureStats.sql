-- sp_DBA_GetProcedureStats.sql  #SQL


USE [master]
GO

/****** Object:  StoredProcedure [dbo].[pr_InsertErrorLog]    Script Date: 09/08/2010 15:36:58 ******/
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[sp_DBA_GetProcedureStats]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].sp_DBA_GetProcedureStats
GO


CREATE  PROCEDURE sp_DBA_GetProcedureStats  
(
	@ProcName sysname = NULL ,
	@Rows INT = 50 -- number of rows to be returned
)
AS  
  
-----------------------------------------------------------------  
-- Object:   sp_DBA_GetProcedureStats  
-- Written By:  Martin Croft  
-- Date Written:   
-- Purpose:   Return   
--     sp_DBA_GetProcedureStats  
-- Calls:   N/A  
-----------------------------------------------------------------  
-- Modified By  Modified Date  Description  Version 
--26/09 MAC added schemaname  1.2
-----------------------------------------------------------------  
-- {developer}  {date}    {description} {Version}  
-----------------------------------------------------------------  
  
  
-- Top Cached SPs By Total Logical Reads .  
-- Logical reads relate to memory pressure  
BEGIN TRY
  
SELECT TOP ( @Rows )   
	 SCHEMA_NAME(p.schema_id) AS SchemaName,
	 p.name AS [SP Name] ,  
	 qs.total_logical_reads AS [TotalLogicalReads] ,   
	 CASE WHEN qs.total_logical_reads  > 0 THEN	 qs.total_logical_reads / qs.execution_count ELSE 0
		  END	 AS [AvgLogicalReads] ,  
	 qs.execution_count ,   
	 CASE WHEN qs.total_elapsed_time > 0  THEN total_elapsed_time /1000 ELSE 0 END AS total_elapsed_timeMS ,  
	 CASE WHEN qs.execution_count > 0  THEN (total_elapsed_time /1000)/qs.execution_count ELSE 0 END AS [avg_elapsed_timeMS] ,  
	 qs.cached_time,  
	 db_name() AS DbName, 
	 @@ServerName AS ServerName   
FROM   
	sys.procedures AS p   
INNER JOIN   
	sys.dm_exec_procedure_stats AS qs ON p.[object_id] = qs.[object_id]  AND db_id() = database_id
WHERE
	p.name =COALESCE(@ProcName,p.name)
ORDER BY   
	 qs.total_logical_reads DESC ;  

 END TRY
 BEGIN CATCH

 PRINT ERROR_MESSAGE() 

 END CATCH

GO

EXEC sp_MS_marksystemobject sp_DBA_GetProcedureStats 
GO

EXEC sp_addextendedproperty @name=N'Version', @value=N'1.2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'sp_DBA_GetProcedureStats'
GO
EXEC sp_addextendedproperty @name=N'Description', @value=N'Get procedures stats' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'sp_DBA_GetProcedureStats'
GO
EXEC sp_addextendedproperty @name=N'Parameters', @value=N'@ProcName=''sp_Wht'' ,@Rows=50' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'sp_DBA_GetProcedureStats'
GO

GRANT EXEC on sp_DBA_GetProcedureStats to [PUBLIC]

