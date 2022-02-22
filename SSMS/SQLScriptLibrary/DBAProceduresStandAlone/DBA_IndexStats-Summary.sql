-- DBA_IndexStats-Summary.sql  #SQL

--IF (SELECT OBJECT_ID('Staging.DatabaseIndexStats')) IS NOT NULL DROP TABLE Staging.DatabaseIndexStats
--CREATE TABLE Staging.DatabaseIndexStats
--(
--	 ServerName VARCHAR(50)
--	,DatabaseName VARCHAR(1000)
--	,ReportDate DATE
--	,user_seeks BIGINT
--	,user_scans BIGINT
--	,user_lookups BIGINT
--	,reads BIGINT
--	,writes BIGINT
--	,ServerStartDate DATETIME

--)


--select distinct servername  from [max].Staging.DatabaseIndexStats


--SELECT distinct server_name AS ServerName  FROM [Max].[ODS].[V200_Server_Details]


IF (SELECT OBJECT_ID('Tempdb..#DatabaseAccess')) IS NOT NULL DROP TABLE #DatabaseAccess
CREATE TABLE #DatabaseAccess
(
	 ServerName VARCHAR(100)
	,DatabaseName VARCHAR(100)
	,ReportDate DATETIME
	,user_seeks BIGINT
	,user_scans BIGINT
	,user_lookups BIGINT
	,reads BIGINT
	,writes BIGINT
	,ServerStartDate DATETIME

)

 
EXEC sp_MSFOREACHDB 'USE [?]

IF db_name() NOT IN (''TempDB'',''model'',''msdb'',''DBATools'',''master'')

INSERT INTO #DatabaseAccess
(
	 ServerName
	,DatabaseName
	,ReportDate
	,user_seeks
	,user_scans
	,user_lookups
	,reads
	,writes
	,ServerStartDate

)


SELECT      
	@@ServerName AS ServerName,
	db_name() AS DatabaseName,
	CAST(GETDATE() as DATETIME) as ReportDate,
	COALESCE(SUM(user_seeks),0) AS user_seeks,   
	COALESCE(SUM(user_scans),0) AS user_scans,
	COALESCE(SUM(user_lookups),0) AS user_scans,
	reads=COALESCE(SUM(user_seeks + user_scans + user_lookups),0),         
	writes = COALESCE(SUM(user_updates),0), 
	ServerStartDate = (select login_time from master.dbo.sysprocesses where spid =1)
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
		(OBJECTPROPERTY(s.object_id,''IsUserTable'') = 1  or OBJECTPROPERTY(s.object_id,''IsView'') = 1)
	 AND       
		i.name IS NOT NULL

	AND s.database_id = DB_ID() 
'	

SELECT * FROM #DatabaseAccess






