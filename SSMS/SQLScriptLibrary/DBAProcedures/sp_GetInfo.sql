USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_GetInfo]    Script Date: 15/02/2022 09:31:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

DROP PROC IF EXISTS sp_GetInfo
GO
CREATE PROCEDURE [dbo].[sp_GetInfo]
 (
	@TableName VARCHAR(50)
 )
AS
-----------------------------------------------------------------------------        
-- Object:     sp_GetInfo      
-- Written By: M Croft        
-- Date Written: 09/2/22      
-- Usage: Gets details of SQL object, use in conjenction with shortcut key then can highlight table object to get useful info          
-- sp_GetInfo TableName
-- sp_GetInfo ColumnName
-----------------------------------------------------------------------------        
-- {developer}  {date}    	  {description} 							       
-- MC 			15/03/22	  Added ability to use schema (if tablename unique)				
-----------------------------------------------------------------------------       

SET NOCOUNT ON

DECLARE @isTable BIT =0,
		@isColumn BIT =0,
		@ColumnName VARCHAR(50),
		@SchemaName sysname



    BEGIN
        --If table name is unique can use schema else will need to use DBO 
        IF (SELECT COUNT(*) FROM sys.objects so 
        JOIN sys.schemas ss ON so.schema_id=ss.schema_id
        WHERE type_desc='USER_TABLE' AND so.Name=@TableName) =1
        BEGIN
            SELECT @SchemaName=ss.Name  FROM sys.objects so 
            JOIN sys.schemas ss ON so.schema_id=ss.schema_id
            WHERE type_desc='USER_TABLE' AND so.Name=@TableName
        END
            ELSE SET @SchemaName='dbo'
            SELECT @TableName=@TableName
    END



-- If our table has brackets and no spaces lets remove the brackets so can highlight [tablename] and tablename
IF CHARINDEX('[',@TableName,0) != 0 AND CHARINDEX(' ',@TableName,0) =0  
SET @TableName= REPLACE(REPLACE(@TableName,'[',''),']','')

--add for clarity in code if were dealing with table or column
SET @ColumnName=@TableName

--Lets check if the objects a table
IF EXISTS(SELECT * FROM sys.tables WHERE name =@TableName)
SET @isTable=1

--Let check if the objects a column
IF EXISTS(SELECT * FROM sys.columns WHERE name =@ColumnName)
SET @isColumn=1


DROP TABLE IF EXISTS #MetricResults
CREATE TABLE #MetricResults
(
	ID INT IDENTITY (1,1),
	Metric VARCHAR(100),
	DatabaseName VARCHAR(100),
	TableName VARCHAR(50),
	Value VARCHAR(500),

)


IF @isTable=1 
BEGIN

		;WITH Cte (DatabaseName,TableName,ColumnName,column_id)
		AS
		( 
		SELECT TOP 100 PERCENT
			db_name() AS DatabaseName, OBJECT_NAME(object_id) AS TableName, COALESCE(Name,'') ColumnName,column_id 
		FROM
			sys.Columns
		WHERE 
			OBJECT_NAME(object_id)  =@TableName
		ORDER BY column_id
		)
		,CTE_Columns
		AS
		(
		SELECT  DatabaseName ,TableName, STUFF(( SELECT ',' +  ColumnName 
		FROM Cte  t1

		ORDER BY column_id
		FOR XML PATH('')
		),1,1,'') AS Value
		FROM Cte t2
		)
		INSERT INTO #MetricResults(Metric,DatabaseName,TableName,Value)
		SELECT distinct 'Columns In Table Order' AS Metric,* FROM CTE_Columns

		;WITH Cte (DatabaseName,TableName,ColumnName,column_id)
		AS
		( 
		SELECT TOP 100 PERCENT
			db_name() AS DatabaseName, OBJECT_NAME(object_id) AS TableName, COALESCE(Name,'') ColumnName,column_id 
		FROM
			sys.Columns
		WHERE 
			OBJECT_NAME(object_id)  =@TableName
		ORDER BY column_id
		)
		,CTE_Columns
		AS
		(
		SELECT  DatabaseName ,TableName, STUFF(( SELECT ',' +  ColumnName 
		FROM Cte  t1

		ORDER BY ColumnName
		FOR XML PATH('')
		),1,1,'') +CHAR(10) AS Value
		FROM Cte t2
		)
		INSERT INTO #MetricResults(Metric,DatabaseName,TableName,Value)
		SELECT distinct 'Columns Alphabetically' AS Metric,* FROM CTE_Columns


		INSERT INTO #MetricResults(Metric,DatabaseName,TableName,Value)
		SELECT 
			'Number of Columns',db_name() AS DatabaseName, OBJECT_NAME(object_id) AS TableName, COUNT(*) AS Value
		FROM
			sys.Columns
		WHERE 
			OBJECT_NAME(object_id)  =@TableName
		GROUP BY 
			 OBJECT_NAME(object_id)


		INSERT INTO #MetricResults(Metric,DatabaseName,TableName,Value)
		SELECT 
			'Number of Indexes',db_name() AS DatabaseName, OBJECT_NAME(object_id) AS TableName, COUNT(*) AS Value
		FROM
			sys.Indexes
		WHERE 
			OBJECT_NAME(object_id)  =@TableName
		GROUP BY 
			 OBJECT_NAME(object_id)



		INSERT INTO #MetricResults(Metric,DatabaseName,TableName,Value)
		SELECT 
			'Row count(*)',db_name() AS DatabaseName, OBJECT_NAME(id) AS TableName,  REPLACE(CONVERT(varchar, CAST(MAX(Rows) AS money), 1),'.00','')  AS Value
		FROM
			sysIndexes
		WHERE 
			OBJECT_NAME(id)  =@TableName
		GROUP BY 
			 OBJECT_NAME(id)

		DECLARE @sqlcmd  SYSNAME
		SET @sqlcmd ='SELECT TOP 10 * FROM ['+@SchemaName+'].'+'['+@TableName+']'
		EXEC(@sqlcmd)


END


IF @isColumn =1
BEGIN
	
	--INSERT INTO #MetricResults(Metric,DatabaseName,TableName,Value)
	SELECT 'Column exists in tables:'As Metric,db_name() AS DatabaseName,@ColumnName AS ColumnName,OBJECT_NAME(sc.object_id) TableName FROM Sys.columns sc
	INNER JOIN sys.objects so ON so.object_id=sc.object_id 
	WHERE type_desc NOT IN ('SYSTEM_TABLE','INTERNAL_TABLE')
	AND sc.name=@ColumnName

END

	--Output results based on the object

	IF @isTable=1 
	BEGIN 
		SELECT DatabaseName,TableName,Metric,Value FROM #MetricResults

		EXEC sp_DBA_GetIndexColumns @TableName

		EXEC sp_DBA_MissingIndexes @TableName


		SELECT 
				 COALESCE(sc.Name,'') ColumnName,
				  CASE 
					WHEN st.Name IN('Char','VARCHAR') THEN st.Name +'('+CAST(sc.max_length AS VARCHAR(4))+')' 
					WHEN st.Name IN('NChar','NVARCHAR') AND sc.Max_length = -1 THEN st.Name +'(MAX)' 
					WHEN st.Name IN('NChar','NVARCHAR') THEN st.Name +'('+CAST(sc.max_length/2 AS VARCHAR(4))+')' 
				 	ELSE st.Name  END  +
				CASE WHEN sc.is_nullable=1 THEN ' null' ELSE ' not null' END AS Name
			FROM
				sys.Columns sc
			INNER JOIN 
				sys.types st on sc.user_type_id=st.user_type_id
			WHERE 
				OBJECT_NAME(sc.object_id)  =@TableName
			ORDER BY sc.column_id
	END
	GO

	EXEC sp_MS_marksystemobject 'sp_GetInfo'