-- sp_DBA_Expensive_Queries.sql  #SQL
USE [master]
go

/****** Object:  StoredProcedure [dbo].[sp_DBA_Expensive_Queries]    Script Date: 11/21/2011 12:45:55 ******/
SET ANSI_NULLS ON
go

SET QUOTED_IDENTIFIER ON
go

/****** Object:  StoredProcedure [dbo].[sp_DBA_Expensive_Queries]    Script Date: 11/21/2011 12:46:16 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_DBA_Expensive_Queries]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_DBA_Expensive_Queries]
go

        
          
CREATE procedure [dbo].[sp_DBA_Expensive_Queries]          
(@order nvarchar(50) = null ,          
 @Num  nvarchar(50) = 10          
          
)          
          
          
-------------------------------------------------------------------            
---- Object:   sp_DBA_Expensive_Queries            
---- Written By:  Dave Carpenter          
---- Date Written: 15-July-2011           
---- Purpose:   Identify most expensive queries.            
---- Template:  1.0             
---- Usage:               
----    sp_DBA_MIssingIndxes            
---- Calls:   N/A            
-------------------------------------------------------------------            
---- Modified By  Modified Date  Description  Version            
-------------------------------------------------------------------            
---- {developer}  {date}    {description} {Version}            
----  Nov 11 Added Meta data & Added to Sourec control
-------------------------------------------------------------------            
          
          
          
as           
          
DECLARE @SQL nvarchar(4000)         
        
        
          
IF @order is null  or  @order not in('Read','Writes','I/O','CPU')        
          
BEGIN          
          
Print 'Incorrect @order please select Read,Writes, I/O or CPU'          
          
END           
          
IF @order in('Read','Writes','I/O','CPU')        
          
BEGIN          
        
          
IF @order = 'Read'          
Set @order = 'qs.total_logical_reads'         
IF @order ='Writes'          
SET @order = 'qs.total_logical_writes'         
IF @order = 'CPU'          
SET @order = 'qs.total_worker_time'          
IF @order = 'I/O'          
SET @order = 'qs.total_logical_writes'        
        
          
SET @SQL =           
'          
SELECT TOP '+@Num+'
DB_name(),    
 OBJECT_NAME(qt.objectid) As''Object Name'' ,         
 SUBSTRING(qt.TEXT,           
 (qs.statement_start_offset/2)+1,          
 ((CASE qs.statement_end_offset          
  WHEN -1 THEN DATALENGTH(qt.TEXT)          
  ELSE qs.statement_end_offset          
  END - qs.statement_start_offset)/2)+1),          
 qs.execution_count,          
 qs.total_logical_reads, qs.last_logical_reads,          
 qs.total_logical_writes, qs.last_logical_writes,          
 qs.total_worker_time,          
 qs.last_worker_time,          
 qs.total_elapsed_time/1000000 total_elapsed_time_in_S,          
 qs.last_elapsed_time/1000000 last_elapsed_time_in_S,          
 qs.last_execution_time,          
 qp.query_plan          
FROM           
 sys.dm_exec_query_stats qs          
CROSS APPLY           
 sys.dm_exec_sql_text(qs.sql_handle) qt          
CROSS APPLY           
 sys.dm_exec_query_plan(qs.plan_handle) qp          
WHERE           
 qt.dbid = db_id()          
ORDER BY            
 ' +@Order+' DESC'          
          
EXEC (@SQL)          
          
END 
go
exec sp_ms_marksystemobject sp_DBA_Expensive_Queries
GO

GRANT EXEC on sp_DBA_Expensive_Queries to [PUBLIC]




