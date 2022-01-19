use [master]
go

IF exists ( Select * from sys.sysobjects where id = OBJECT_ID(N'sp_DBA_GetIndexColumns') and type = 'p')
Drop procedure sp_DBA_GetIndexColumns
Go


CREATE Procedure  [dbo].[sp_DBA_GetIndexColumns]      
(      
	
	@tableName sysname = NULL,
	@SchemaName sysname =NULL

)      
AS    
      
-----------------------------------------------------------------        
-- Object:     sp_DBA_GetIndexColumns      
-- Written By:         
-- Date Written:  19/10/2010       
-- Usage:           
-- sp_DBA_GetIndexColumns 
-- sp_DBA_GetIndexColumns @tableName ='tbl_Scheme'
-- sp_DBA_GetIndexColumns @tableName ='tbl_Scheme' @SchemaName ='sales'
-----------------------------------------------------------------        
-- {developer}  {date}    {description} {Version}        
-----------------------------------------------------------------        
--https://www.ptr.co.uk/blog/sql-server-display-indexes-their-columns-included-columns

--If no scheme provided going to assume dbo
IF @SchemaName IS NULL SET @SchemaName='dbo'

DECLARE @TempTable AS TABLE (SchemaName VARCHAR(100), 
							 ObjectID INT, 
							 TableName VARCHAR(100), 
							 IndexID INT, 
							 IndexName VARCHAR(MAX), 
							 ColumnID INT, 
							 column_index_id INT, 
							 ColumnNames  VARCHAR(500), 
							 IncludeColumns  VARCHAR(MAX), 
							 NumberOfColumns INT, 
							 IndexType  VARCHAR(20),
							 LastColRecord INT);

WITH CTE_Indexes (SchemaName, ObjectID, TableName, IndexID, IndexName, ColumnID, column_index_id, ColumnNames, IncludeColumns, NumberOfColumns, IndexType)
AS
(
SELECT s.name, t.object_id, t.name, i.index_id, i.name, c.column_id, ic.index_column_id,
		CASE ic.is_included_column WHEN 0 THEN CAST(c.name AS VARCHAR(5000)) ELSE '' END, 
		CASE ic.is_included_column WHEN 1 THEN CAST(c.name AS VARCHAR(5000)) ELSE '' END, 1, i.type_desc
	FROM  sys.schemas AS s
		JOIN sys.tables AS t ON s.schema_id = t.schema_id
			JOIN sys.indexes AS i ON i.object_id = t.object_id
				JOIN sys.index_columns AS ic ON ic.index_id = i.index_id AND ic.object_id = i.object_id
					JOIN sys.columns AS c ON c.column_id = ic.column_id AND c.object_id = ic.object_id
						AND ic.index_column_id = 1
UNION ALL
SELECT s.name, t.object_id, t.name, i.index_id, i.name, c.column_id, ic.index_column_id,
		CASE ic.is_included_column WHEN 0 THEN CAST(cte.ColumnNames + ', ' + c.name AS VARCHAR(5000))  ELSE cte.ColumnNames END, 
		CASE  
			WHEN ic.is_included_column = 1 AND cte.IncludeColumns != '' THEN CAST(cte.IncludeColumns + ', ' + c.name AS VARCHAR(5000))
			WHEN ic.is_included_column =1 AND cte.IncludeColumns = '' THEN CAST(c.name AS VARCHAR(5000)) 
			ELSE '' 
		END,
		cte.NumberOfColumns + 1, i.type_desc
	FROM  sys.schemas AS s
		JOIN sys.tables AS t ON s.schema_id = t.schema_id
			JOIN sys.indexes AS i ON i.object_id = t.object_id
				JOIN sys.index_columns AS ic ON ic.index_id = i.index_id AND ic.object_id = i.object_id
					JOIN sys.columns AS c ON c.column_id = ic.column_id AND c.object_id = ic.object_id 
					JOIN CTE_Indexes cte ON cte.Column_index_ID + 1 = ic.index_column_id  
					--JOIN CTE_Indexes cte ON cte.ColumnID + 1 = ic.index_column_id  
							AND cte.IndexID = i.index_id AND cte.ObjectID = ic.object_id

)
INSERT INTO  @TempTable 
SELECT *, RANK() OVER (PARTITION BY ObjectID, IndexID ORDER BY NumberOfColumns DESC) AS LastRecord FROM CTE_Indexes AS cte;

SELECT SchemaName, TableName, IndexName, ColumnNames, IncludeColumns, IndexType FROM @TempTable
WHERE LastColRecord = 1
AND TableName = COALESCE(@TableName,TableName)
ORDER BY objectid, TableName, ColumnNames, IndexName





GO

EXEC sp_MS_marksystemobject sp_DBA_GetIndexColumns

GO

EXEC sys.sp_addextendedproperty @name=N'Version', @value=N'1.2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'sp_DBA_GetIndexColumns'
GO

GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Get Index columns with include columns' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'sp_DBA_GetIndexColumns'
GO

EXEC sys.sp_addextendedproperty @name=N'Parameters', @value=N'@tablename=[Table], @SchemaName =[Schema]' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'sp_DBA_GetIndexColumns'
GO

GRANT EXEC on sp_DBA_GetIndexColumns to [PUBLIC]
