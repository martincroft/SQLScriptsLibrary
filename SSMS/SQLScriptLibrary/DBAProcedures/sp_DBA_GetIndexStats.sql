-- sp_DBA_GetIndexStats.sql  #SQL
use [master]
go

IF exists ( Select * from sys.sysobjects where id = OBJECT_ID(N'sp_DBA_GetIndexStats') and type = 'p')
Drop procedure sp_DBA_GetIndexStats
Go


CREATE Procedure  [dbo].[sp_DBA_GetIndexStats]      
(      
	@tableName nvarchar(100) = NULL,   
	@IndexType VARCHAR(50)   = NULL   --0 All 1 Nonclustered 2 clustered 3 Heap
)      
as       
      
-----------------------------------------------------------------        
-- Object:     sp_DBA_GetIndexStats      
-- Written By:         
-- Date Written:  19/10/2010       
-- Usage:           
-- sp_DBA_GetIndexStats 
-- sp_DBA_GetIndexStats @tableName ='tbl_Scheme'
-- sp_DBA_GetIndexStats @IndexType ='CLUSTERED'
-----------------------------------------------------------------        
-- {developer}  {date}    {description} {Version}        
-----------------------------------------------------------------        
      
SELECT      
	db_name() AS DatabaseName, 
	o.name,      
	indexname=i.name,    
	i.type_desc, 
	i.index_id,      
	user_seeks,   
	user_scans,
	user_lookups,
	reads=user_seeks + user_scans + user_lookups,         
	writes =  user_updates,         
	rows = (SELECT SUM(p.rows) FROM sys.partitions p WHERE p.index_id = s.index_id AND s.object_id = p.object_id),      
	8 * (a.used_pages) AS 'Indexsize(KB)',  
	CASE      
		WHEN s.user_updates < 1 THEN 100      
		ELSE 1.00 * (s.user_seeks + s.user_scans + s.user_lookups) / s.user_updates      
	END AS reads_per_write,      
	'DROP INDEX ' + QUOTENAME(i.name)+' ON ' + QUOTENAME(c.name) + '.' + QUOTENAME(OBJECT_NAME(s.object_id)) as 'drop statement'      
FROM 
	sys.dm_db_index_usage_stats s        
INNER JOIN       
	sys.indexes i ON i.index_id = s.index_id AND s.object_id = i.object_id         
INNER JOIN       
	sys.objects o on s.object_id = o.object_id      
INNER JOIN       
	sys.schemas c on o.schema_id = c.schema_id  
INNER JOIN    
	 sys.partitions AS p ON p.OBJECT_ID = i.OBJECT_ID AND p.index_id = i.index_id  
INNER JOIN   
	 sys.allocation_units AS a ON a.container_id = p.partition_id  
  
WHERE       
		(OBJECTPROPERTY(s.object_id,'IsUserTable') = 1  or OBJECTPROPERTY(s.object_id,'IsView') = 1)
	 AND       
		s.database_id = DB_ID() 
	 AND       
		i.name IS NOT NULL
	AND      
		i.is_unique_constraint = 0 
	AND       
		o.name =COALESCE(@tablename,o.name)     
	AND
		i.type_desc = COALESCE(@IndexType, i.type_desc)
				
						
    
ORDER BY O.name desc      
      

 
GO

EXEC sp_MS_marksystemobject sp_DBA_GetIndexStats

GO

EXEC sys.sp_addextendedproperty @name=N'Version', @value=N'1.1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'sp_DBA_GetIndexStats'
GO

GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Get Index stats, Table,Name, reads, Writes' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'sp_DBA_GetIndexStats'
GO

EXEC sys.sp_addextendedproperty @name=N'Parameters', @value=N'@Calls=25, @IndexType =0 All , 1=Nonclustered, 2 =Clustered 3=Heap' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'sp_DBA_GetIndexStats'
GO

GRANT EXEC on sp_DBA_GetIndexStats to [PUBLIC]

