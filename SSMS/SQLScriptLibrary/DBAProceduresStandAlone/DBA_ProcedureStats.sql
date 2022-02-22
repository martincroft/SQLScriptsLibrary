-- DBA_ProcedureStats.sql  #SQL
  
SELECT 
	 p.name AS [SP Name] ,  
	 SS.NAME,
	 qs.total_logical_reads AS [TotalLogicalReads] ,   
	 CASE WHEN qs.total_logical_reads  > 0 THEN	 qs.total_logical_reads / qs.execution_count ELSE 0
		  END	 AS [AvgLogicalReads] ,  
	 qs.execution_count ,   
	 CASE WHEN qs.total_elapsed_time > 0  THEN total_elapsed_time /1000 ELSE 0 END AS total_elapsed_timeMS,
	 
	 CASE WHEN qs.execution_count > 0  THEN (total_elapsed_time /1000)/qs.execution_count ELSE 0 END AS [avg_elapsed_timeMS] , 
	 	 CASE WHEN qs.execution_count > 0  THEN (total_elapsed_time /1000/1000)/qs.execution_count ELSE 0 END AS [avg_elapsed_timeSec] ,  
	 qs.cached_time,  
	 db_name() AS DbName, 
	 @@ServerName AS ServerName  
	 ,qs.plan_handle
FROM   
	sys.procedures AS p   
INNER JOIN   
	sys.dm_exec_procedure_stats AS qs ON p.[object_id] = qs.[object_id]  AND db_id() = database_id
LEFT JOIN 
	SYS.schemas SS ON SS.schema_id = p.schema_id

WHERE p.name  LIKE '%msp_despatch_update_load_pallets%'
ORDER BY  8 desc
	 -- CASE WHEN qs.execution_count > 0  THEN (total_elapsed_time /1000/1000)/qs.execution_count ELSE 0 END  DESC

	-- DBCC FREEPROCCACHE
--
--sp_recompile [returnsModule.transfer_wave_id_by_reference_or_customer_id_get]


/*

EXEC sp_whoisactive

DBCC FREEPROCCACHE (0x050011003776EB4FC0162FF1C101000001000000000000000000000000000000000000000000000000000000)

returns_record_stock_data_dump_generate_outstanding

SELECT * FROM sys.dm_exec_query_plan(0x05000600888EA41E809A16B21900000001000000000000000000000000000000000000000000000000000000) 

*/


