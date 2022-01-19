-- sp_DBA_Expensive_Queries_Summary.sql  #SQL


USE [master]
go

/****** Object:  StoredProcedure [dbo].[sp_DBA_Expensive_Queries]    Script Date: 11/21/2011 12:45:55 ******/
SET ANSI_NULLS ON
go

SET QUOTED_IDENTIFIER ON
go

/****** Object:  StoredProcedure [dbo].[sp_DBA_Expensive_Queries]    Script Date: 11/21/2011 12:46:16 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_DBA_Expensive_Queries_Summary]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_DBA_Expensive_Queries_Summary]
go

        
          
CREATE procedure [dbo].[sp_DBA_Expensive_Queries_Summary]          
  
          
          
-------------------------------------------------------------------            
---- Object:   sp_DBA_Expensive_Queries_Summary            
---- Written By:  Ian Hall          
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
          

Select top 50
sum(qs.total_worker_time) as total_cpu_time, 
sum(qs.execution_count) as total_execution_count,
max(qs.last_execution_time) last_execution_time, 
count(*) as  '#_statements',
DB_NAME(qt.dbid) DB, OBJECT_NAME (qt.objectid), qs.sql_handle ,
qt.[text], plan_handle
from sys.dm_exec_query_stats as qs
cross apply sys.dm_exec_sql_text (qs.sql_handle) as qt
cross apply sys.dm_exec_query_plan (qs.plan_handle) as qp
group by qt.dbid,qt.objectid, qs.sql_handle,qt.[text],plan_handle
order by max(qs.total_worker_time)  desc

          
go
exec sp_ms_marksystemobject sp_DBA_Expensive_Queries_Summary
GO

GRANT EXEC on sp_DBA_Expensive_Queries_Summary to [PUBLIC]




