-- DBA_IndexStats.sql  #SQL
-- Updated to deal with read only secondary 

WITH CTE_Indexes
AS
(
      
SELECT      
	@@Servername AS ServerName,
	
	db_name() AS DatabaseName, 
	o.name AS TableName,      
	i.name AS IndexName,
	readActivity= SUM(CASE WHEN COALESCE(user_seeks + user_scans + user_lookups,0) > 0 THEN 1 ELSE 0 END),         
	NoreadActivity= SUM(CASE WHEN COALESCE(user_seeks + user_scans + user_lookups,0) = 0 THEN 1 ELSE 0 END),         
	writeActivity =  SUM(CASE WHEN COALESCE(user_updates,0) > 0 THEN 1 ELSE 0 END),
	TotalIndexes = COUNT(*)
FROM 
	sys.indexes i        
INNER JOIN       
	sys.dm_db_index_usage_stats s ON i.index_id = s.index_id AND s.object_id = i.object_id         
INNER JOIN       
	sys.objects o on i.object_id = o.object_id      
LEFT JOIN       
	sys.schemas c on o.schema_id = c.schema_id  
LEFT JOIN    
	 sys.partitions AS p ON p.OBJECT_ID = i.OBJECT_ID AND p.index_id = i.index_id  
LEFT JOIN   
	 sys.allocation_units AS a ON a.container_id = p.partition_id  
  
WHERE       
		(OBJECTPROPERTY(i.object_id,'IsUserTable') = 1  or OBJECTPROPERTY(i.object_id,'IsView') = 1)
	 AND       
		i.name IS NOT NULL
	AND      
		i.is_unique_constraint = 0 
	

	AND s.database_id=DB_ID()
GROUP BY 
	o.name ,i.name 
)


SELECT 
	ServerName, DatabaseName, TableName,  SUM(readActivity) AS readActivity, SUM(NoreadActivity) AS NoreadActivity, SUM(writeActivity) AS writeActivity, SUM(TotalIndexes) AS TotalIndexes
FROM 
	CTE_Indexes
GROUP BY 
	ServerName, DatabaseName, TableName
ORDER BY SUM(TotalIndexes) desc