-- DBA_IndexStats.sql  #SQL
-- Updated to deal with read only secondary 
      
SELECT      
	@@Servername AS ServerName,
	DATABASEPROPERTYEX(DB_NAME(), 'Updateability') AS Updateability,
	db_name() AS DatabaseName, 
	c.name,
	o.name,      
	indexname=i.name,    
	i.type_desc, 
	i.index_id,      
	COALESCE(user_seeks,0) AS user_seeks ,  
	COALESCE(user_scans,0) AS user_scans,
	COALESCE(user_lookups,0) AS user_lookups,
	reads=COALESCE(user_seeks + user_scans + user_lookups,0),         
	writes =  COALESCE(user_updates,0),          
	rows = (SELECT SUM(p.rows) FROM sys.partitions p WHERE p.index_id = s.index_id AND s.object_id = p.object_id),      
	8 * (a.used_pages) AS 'Indexsize(KB)',  
	CASE      
		WHEN s.user_updates < 1 THEN 100      
		ELSE 1.00 * (s.user_seeks + s.user_scans + s.user_lookups) / s.user_updates      
	END AS reads_per_write,      
	'DROP INDEX ' + QUOTENAME(i.name)+' ON ' + QUOTENAME(c.name) + '.' + QUOTENAME(OBJECT_NAME(i.object_id)) as 'drop statement'      
FROM 
	sys.indexes i        
LEFT JOIN       
	sys.dm_db_index_usage_stats s ON i.index_id = s.index_id AND s.object_id = i.object_id         
LEFT JOIN       
	sys.objects o on i.object_id = o.object_id      
LEFT JOIN       
	sys.schemas c on o.schema_id = c.schema_id  
LEFT JOIN    
	 sys.partitions AS p ON p.OBJECT_ID = i.OBJECT_ID AND p.index_id = i.index_id  
LEFT JOIN   
	 sys.allocation_units AS a ON a.container_id = p.partition_id  
  
WHERE       
		(OBJECTPROPERTY(i.object_id,'IsUserTable') = 1  or OBJECTPROPERTY(i.object_id,'IsView') = 1)
	 --AND       
		--s.database_id = DB_ID() 
	 AND       
		i.name IS NOT NULL
	AND      
		i.is_unique_constraint = 0 

	AND user_seeks + user_scans + user_lookups = 0 AND i.type_desc  <> 'CLUSTERED'
	AND 			o.name IN  ('ms_transfers')
		
	--	OR  i.name IN ('Ixn_ms_returns_record_rr_initial_location_id_I','Ixn_ms_transfers_tr_group_tr_wave_id')
		
		--AND i.name IN (
		--'IX_ms_pallets_pal_despatch_pallet_id'
		--,'ix_ms_pallets_pal_warehouse_pal_open_user_pal_close_user_includes'
		----,'IDX_pal_po_primary_FILTERED'

	--	)

ORDER BY [Indexsize(KB)] desc






