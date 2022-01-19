-- sp_DBA_FK_Missing_Indexes.sql  #SQL
USE master
GO
  
IF (SELECT object_id('sp_DBA_FK_Missing_Indexes'))IS NOT NULL
DROP PROC sp_DBA_FK_Missing_Indexes
GO

CREATE PROCEDURE sp_DBA_FK_Missing_Indexes
AS
-----------------------------------------------------------------    
-- Object:              sp_DBA_FK_Missing_Indexes    
-- Written By:          MAC    
-- Date Written:       04/91/2011    
-- Purpose:             List all Tables that have a FK without any index    
-- Usage:               EXEC sp_DBA_FK_Missing_Indexes   
-----------------------------------------------------------------    
-- Modified By          Modified Date           Description    
-- 1.1 MAC				21/06/2012				Added Database Name
-----------------------------------------------------------------      
SET NOCOUNT ON


IF OBJECT_ID('tempdb..#t1') IS NOT NULL DROP TABLE #t1

IF OBJECT_ID('tempdb..#FKTable') IS NOT NULL DROP TABLE #FKTable


CREATE TABLE #t1
(
do integer default(0), 
index_name varchar(MAX), 
index_descrip varchar(MAX), 
index_keys varchar(MAX), 
table_name varchar(MAX)) 




CREATE TABLE #FKTable
(
fk_name varchar(MAX), 
fk_keys varchar(MAX), 
fk_keyno int,
table_name varchar(MAX)) 

 
EXEC sp_msforeachtable "insert #t1 (index_name, index_descrip, index_keys) exec sp_helpindex '?'; update #t1 set table_name = '?', do = 1 where do = 0"


UPDATE #t1 SET table_name = replace(table_name , '[', '')
UPDATE #t1 set table_name = replace(table_name , ']', '')



INSERT INTO #FKTable
SELECT OBJECT_NAME(constid) AS FKName, COL_NAME(fkeyid, fkey) AS FKColumn, keyno, 
s.name + '.' + OBJECT_NAME(fkeyid) AS TabName
FROM sysforeignkeys k 
JOIN sys.objects c 
ON k.constid = c.object_id
JOIN sys.schemas s
ON c.schema_id = s.schema_id





DECLARE @FKName AS VARCHAR(200), @FKColumn as VARCHAR(100)

DECLARE FKCurusor CURSOR FOR
SELECT OBJECT_NAME(constid) AS FKName, COL_NAME(fkeyid, fkey) AS FKColumn
FROM sysforeignkeys k 
JOIN sysobjects c 
ON k.constid = c.id
WHERE keyno > 1
ORDER BY keyno 



DELETE FROM #FKTable WHERE fk_keyno > 1 

OPEN FKCurusor
FETCH NEXT FROM FKCurusor INTO @FKName,@FKColumn
WHILE (@@FETCH_STATUS = 0)
BEGIN

UPDATE #FKTable SET 
fk_keys = fk_keys + ',' + @FKColumn 
WHERE fk_name = @FKName


FETCH NEXT FROM FKCurusor INTO @FKName,@FKColumn

END 

CLOSE FKCurusor
DEALLOCATE FKCurusor


SELECT 
	db_name() As DatabaseName,
	so.name,
	f1.fk_name,
	f1.fk_keys
FROM 
	sys.objects so
LEFT JOIN
	#FKTable f1 ON so.Name =PARSENAME(F1.table_name,1)
WHERE 
	Type='U' 
AND
	NOT EXISTS 
		(
		SELECT 
			PARSENAME(F1.table_name,1) 
		FROM 
			#FKTable f
		LEFT  JOIN 
			#t1 t	ON f.table_name = t.table_name
		WHERE 
			(f1.fk_name = f.fk_name
		AND 
			fk_keys = SUBSTRING (index_keys, 1 , CASE	WHEN CHARINDEX( ',',index_keys)= 0 THEN LEN(index_keys) ELSE CHARINDEX( ',',index_keys) -1 END)
			)

		)AND
	f1.fk_name IS NOT NULL 
ORDER BY 1 


GO

EXEC Sp_ms_marksystemobject sp_DBA_FK_Missing_Indexes

GO

EXEC sys.Sp_addextendedproperty
  @name      =N'Version',
  @value     =N'1.0',
  @level0type=N'SCHEMA',
  @level0name=N'dbo',
  @level1type=N'PROCEDURE',
  @level1name=N'sp_DBA_FK_Missing_Indexes'

GO

EXEC sys.Sp_addextendedproperty
  @name      =N'Description',
  @value     =N'Get Tables with FK and no Indexes',
  @level0type=N'SCHEMA',
  @level0name=N'dbo',
  @level1type=N'PROCEDURE',
  @level1name=N'sp_DBA_FK_Missing_Indexes'

GO
EXEC sp_ms_marksystemobject sp_DBA_FK_Missing_Indexes

GO


GRANT EXEC on sp_DBA_FK_Missing_Indexes to [PUBLIC]
