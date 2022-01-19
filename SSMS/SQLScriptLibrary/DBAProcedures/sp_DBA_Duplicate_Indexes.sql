-- sp_DBA_Duplicate_Indexes.sql  #SQL
USE Master 
GO

IF (SELECT object_id('sp_DBA_Duplicate_Indexes'))IS NOT NULL
DROP PROC sp_DBA_Duplicate_Indexes
GO

CREATE PROCEDURE sp_DBA_Duplicate_Indexes AS

-----------------------------------------------------------------    
-- Object:              sp_DBA_Duplicate_Indexes   
-- Written By:            
-- Date Written:		08/10/2014    
-- Purpose:             List all Tables that have a potential duplicate index   
-- Usage:               EXEC sp_DBA_Duplicate_Indexes   
-----------------------------------------------------------------    
-- Modified By          Modified Date           Description    
--  
-----------------------------------------------------------------     

SET NOCOUNT ON
 
;WITH CTEdup (tableName, indexName, KeyCols, IncludeCols )
AS
( 

SELECT '[' + Sch.NAME + '].[' + Tab.[name] + ']' AS TableName
	,Ind.[name] AS IndexName
	,SUBSTRING((
			SELECT ', ' + AC.NAME
			FROM sys.[tables] AS T
			INNER JOIN sys.[indexes] I ON T.[object_id] = I.[object_id]
			INNER JOIN sys.[index_columns] IC ON I.[object_id] = IC.[object_id]
				AND I.[index_id] = IC.[index_id]
			INNER JOIN sys.[all_columns] AC ON T.[object_id] = AC.[object_id]
				AND IC.[column_id] = AC.[column_id]
			WHERE Ind.[object_id] = I.[object_id]
				AND Ind.index_id = I.index_id
				AND IC.is_included_column = 0
			ORDER BY IC.key_ordinal
			FOR XML PATH('')
			), 2, 8000) AS KeyCols
	,SUBSTRING((
			SELECT ', ' + AC.NAME
			FROM sys.[tables] AS T
			INNER JOIN sys.[indexes] I ON T.[object_id] = I.[object_id]
			INNER JOIN sys.[index_columns] IC ON I.[object_id] = IC.[object_id]
				AND I.[index_id] = IC.[index_id]
			INNER JOIN sys.[all_columns] AC ON T.[object_id] = AC.[object_id]
				AND IC.[column_id] = AC.[column_id]
			WHERE Ind.[object_id] = I.[object_id]
				AND Ind.index_id = I.index_id
				AND IC.is_included_column = 1
			ORDER BY IC.key_ordinal
			FOR XML PATH('')
			), 2, 8000) AS IncludeCols
FROM sys.[indexes] Ind
INNER JOIN sys.[tables] AS Tab ON Tab.[object_id] = Ind.[object_id]
INNER JOIN sys.[schemas] AS Sch ON Sch.[schema_id] = Tab.[schema_id]
) 

SELECT db_name() DatabaseName, a.tableName, a.indexName [Original Index], a.KeyCols [Original Key Cols] , c.indexName [Duplicated Index], c.KeyCols [Duplicated Key Cols], c.IncludeCols 
FROM  
CTEdup a
JOIN 
CTEdup c
 
ON  (a.TableName = c.TableName AND LEFT(c.KeyCols,LEN (a.KeyCols)) = a.KeyCols AND a.indexName <> c.indexName  ) 

ORDER BY tableName, [Original Index], [Duplicated Index]

GO 
    
EXEC sp_ms_marksystemobject 'sp_DBA_Duplicate_Indexes'

GO

GRANT EXEC on sp_DBA_Duplicate_Indexes to [PUBLIC]

GO




