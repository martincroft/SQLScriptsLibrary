-- sp_DBA_ProcedureExecutionPlan.sql  #SQL

USE [Master]
GO

/****** Object:  StoredProcedure [dbo].[sp_DBA_GetConnectionInfo]    Script Date: 09/03/2010 11:04:29 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[sp_DBA_ProcedureExecutionPlan]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_DBA_ProcedureExecutionPlan]
GO



CREATE PROCEDURE sp_DBA_ProcedureExecutionPlan 
(
@ProcName NVARCHAR(150)
)
AS

-----------------------------------------------------------------
-- Object:			sp_DBA_ProcedureExecutionPlan
-- Written By:		
-- Date Written:	
-- Purpose:			Returns Execution plan for procedure from cache
-- Usage:			
--					sp_DBA_ProcedureExecutionPlan 'schSearchDoc'
-- Calls:			N/A
-----------------------------------------------------------------
-- Modified By		Modified Date		Description		Version
-----------------------------------------------------------------
-- {developer}		{date}				{description}	{Version}


SELECT 
	UseCounts, 
	Cacheobjtype, 
	Objtype, 
	TEXT, query_plan ,OBJECT_NAME(sys.dm_exec_sql_text.objectid)
FROM sys.dm_exec_cached_plans  
CROSS APPLY 
      sys.dm_exec_sql_text(plan_handle) 
CROSS APPLY 
      sys.dm_exec_query_plan(plan_handle)
WHERE OBJECT_NAME(sys.dm_exec_sql_text.objectid)= @ProcName

GO

EXEC sp_ms_marksystemobject sp_DBA_ProcedureExecutionPlan
