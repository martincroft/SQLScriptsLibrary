-- sp_DBA_DBSpaceCalc_2005_2008.sql  #SQL


USE [master]
GO

/****** Object:  StoredProcedure [dbo].[sp_DBA_DBSpaceCalc]    Script Date: 11/16/2010 16:03:48 ******/
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[sp_DBA_DBSpaceCalc]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_DBA_DBSpaceCalc]
GO

USE [master]
GO

/****** Object:  StoredProcedure [dbo].[sp_DBA_DBSpaceCalc]    Script Date: 11/16/2010 16:03:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE  PROCEDURE [dbo].[sp_DBA_DBSpaceCalc] 
AS  
  
-----------------------------------------------------------------  
-- Object:   sp_DBA_DBSpaceCalc  
-- Written By:  Martin Croft  
-- Date Written:   
-- Purpose:   Returns space information   
-- Template:  1.0   
-- Usage:     
--    sp_DBA_DBSpaceCalc  
-- Calls:   N/A  
-----------------------------------------------------------------  
-- Modified By  Modified Date  Description  Version  
-----------------------------------------------------------------  
-- {developer}  {date}    {description} {Version}  
-- Added 2 decimal placing rounding 
-----------------------------------------------------------------  


CREATE TABLE #LogFiles
(
 DBName VARCHAR(100)
,LogSize DECIMAL(12,6)
,LogSpaceuse DECIMAL(12,6)
,LogSpaceFree DECIMAL(12,6) DEFAULT (0)
)

INSERT INTO #LogFiles
EXEC ('DBCC sqlperf(logspace)')

UPDATE #logfiles
SET LogSpaceFree =(LogSize /100) * LogSpaceuse


CREATE TABLE #FileStats 

(
	ID INT IDENTITY(1,1)
	,FileID INT
	,FileGroup INT
	,TotalExtents INT
	,UsedExtents INT
	,Name sysname
	,FileName VARCHAR(200)
	,DBNAME sysname NULL
	,Updated INT DEFAULT (0)
	,srvName VARCHAR(30)
)



CREATE TABLE #Databases
(
	 ID INT IDENTITY(1,1)
	,DBID INT
	,Name VARCHAR(200)
)

 --Get all database that are online and not snapshots
INSERT INTO #Databases (DBID,Name)
SELECT 
	database_id,
	Name 
FROM 
	master.sys.databases
WHERE 
		state_desc='ONLINE' 
	AND 
		source_database_id IS NULL


DECLARE @MaxID INT, @Loop INT

DECLARE @ExecStr VARCHAR(200), @Name VARCHAR(100),@Rowcount INT

SELECT @MaxID =MAX(ID) FROM #Databases
SET @Loop=1

WHILE @Loop <= @MaxID 
BEGIN
	SELECT @Name = Name from #databases where ID =@loop
	SELECT @ExecStr='USE ['+@Name+']; DBCC showfilestats' 

--Insert file stats into temp table for each DB

	INSERT INTO #FileStats 
	(	FileID
		,FileGroup
		,TotalExtents
		,UsedExtents
		,Name
		,FileName
	)
	
	EXEC (@ExecStr)
	SET @rowcount =@@rowcount 
	

	--SELECT @Loop , (@loop+@rowcount)

	UPDATE #FileStats
	SET DBNAME = @Name
		,Updated =1
		,srvName =@@servername
	WHERE 
		updated =0

	SET @loop=@loop+1
END


--Database Sizes 

SELECT 
	 @@servername AS SrvName
	,DBName
	,fileid
	,DATABASEPROPERTYEX( DBName, 'RECOVERY' ) AS Model
	,ROUND(cast(((TotalExtents * 64 *1.0 )/1024) as decimal(10,2)),-2) TotalSizeMg
	,cast((UsedExtents * 64 *1.0) /1024 as decimal (10,2)) UsedSizeMg
	,cast(ROUND(((TotalExtents * 64 *1.0 )/1024 )-((UsedExtents * 64 *1.0) /1024 ),2,-2)as decimal(10,2)) FreeMg
FROM 
	#filestats
ORDER BY 
	DBNAME,fileid
	---ROUND(((TotalExtents * 64 *1.0 )/1024 )-((UsedExtents * 64 *1.0) /1024 ),2,-2)  DESC

 --Data than can be reclaimed back
SELECT 
	SrvName
	,ROUND(CAST(SUM(ROUND(((TotalExtents * 64 *1.0 )/1024 )-((UsedExtents * 64 *1.0) /1024 ),2,-2))AS VARCHAR(50)),-2) [FreeMg - Data Size that can be claimed back]
FROM 
	#filestats
GROUP BY
	SrvName



 --Data than can be reclaimed back
SELECT 
	SrvName
	,SUM(cast((UsedExtents * 64 *1.0) /1024 as decimal (10,2))) [TotalUsedSizeMg]
FROM 
	#filestats
GROUP BY
	SrvName



 
--Dabtabase log sizes
SELECT
	 DBName
	,ROUND(CAST(LogSize AS VARCHAR(50)),-2) [LogSize Mg]
	,ROUND(CAST(LogSpaceuse AS VARCHAR(50)),-2)[LogSpaceused %]
	,ROUND(CAST((LogSize-LogSpaceFree) AS VARCHAR(50)),-2)[LogSpaceFree Mg]
FROM 
	#logfiles
ORDER BY 
	LogSpaceFree DESC




--Log space that can be reclaimed  

SELECT 
	ROUND(CAST(SUM(LogSize-LogSpaceFree)AS VARCHAR(MAX)),2) [Log Space that can be reclaimed] 
FROM 
	#logfiles

 
   

GO

EXEC sp_addextendedproperty @name=N'Description', @value=N'Get Database and log sizing information' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'sp_DBA_DBSpaceCalc'
GO

EXEC sp_addextendedproperty @name=N'Version', @value=N'1.0' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'sp_DBA_DBSpaceCalc'
GO

EXEC sp_MS_marksystemobject sp_DBA_DBSpaceCalc
GO

GRANT EXEC on sp_DBA_DBSpaceCalc to [PUBLIC]
