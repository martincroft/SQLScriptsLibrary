-- sp_DBA_MissingIndexes.sql  #SQL
use [master]
go



IF exists ( Select * from sys.sysobjects where id = OBJECT_ID(N'sp_DBA_MissingIndexes') and type = 'p')
Drop procedure sp_DBA_MissingIndexes
GO

/****** Object:  StoredProcedure [dbo].[sp_DBA_MissingIndexes]    Script Date: 10/21/2010 16:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[sp_DBA_MissingIndexes]
(
 @TableName sysname = NULL,
 @SchemeName sysname =null,
 @Sort Tinyint =1,
 @IncludeExcluded BIT = NULL,
 @CountOnly BIT = NULL
 )

AS  
-----------------------------------------------------------------  
-- Object:   sp_DBA_MissingIndexes  
-- Written By:  
-- Date Written:   
-- Purpose:   Return missing index information
-- Usage:     
--    sp_DBA_MissingIndexes  @TableName='dbCodelookup'
-- Calls:   N/A  
-----------------------------------------------------------------  

SELECT
  migs.avg_total_user_cost * (migs.avg_user_impact / 100.0) * (migs.user_seeks + migs.user_scans) AS improvement_measure,
  mid.statement AS TableName, 
  so.name,
  mid.object_id,
  	 replace(replace('CREATE NONCLUSTERED INDEX Ixn_' + object_name(mid.object_id) +'_' 
			  +  case 
					when mid.equality_columns is not null 
					and mid.inequality_columns is not null 
					then replace(mid.equality_columns,', ','_') + '_' + replace(mid.inequality_columns,', ','_')
					when mid.equality_columns is not null 
					and mid.inequality_columns is null 
					then replace(mid.equality_columns,', ','_')
					when mid.inequality_columns is not null 
					then replace(mid.inequality_columns,', ','_')
				  end
			 +         case 
			when mid.included_columns is not null 
			then '_I'
			else ''
			end
		   + ' on ' 
		   + ss.name COLLATE DATABASE_DEFAULT + '.'
			+ object_name(mid.object_id) + ' (' + 
			case 
					when mid.equality_columns is not null 
					and mid.inequality_columns is not null 
					then mid.equality_columns + ',' + mid.inequality_columns
					when mid.equality_columns is not null 
					and mid.inequality_columns is null 
					then mid.equality_columns
					when mid.inequality_columns is not null 
					then mid.inequality_columns
			end
			+ ')' + char(10)
			+ 
			case 
			when mid.included_columns is not null 
			then 'Include (' + mid.included_columns + ')'
			else ''
			end,'[',''),']','') as CreateIndexStmt,
			 equality_columns AS equality_columns,
			 inequality_columns AS inequality_columns,
			 included_columns AS included_columns,
			migs.unique_compiles,
			migs.user_seeks, 
			migs.user_scans,
			migs.avg_total_user_cost, 
			migs.avg_user_impact,
			migs.last_user_seek, 
			migs.last_user_scan,
			migs.system_seeks, 
			migs.system_scans,
			migs.avg_total_system_cost, 
			migs.avg_system_impact,
			migs.last_system_seek, 
			migs.last_system_scan,
			(CONVERT(Numeric(19,6), migs.user_seeks)+CONVERT(Numeric(19,6), migs.unique_compiles))*CONVERT(Numeric(19,6), migs.avg_total_user_cost)*CONVERT(Numeric(19,6), migs.avg_user_impact/100.0) AS Score
FROM sys.dm_db_missing_index_groups mig
INNER JOIN sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle
INNER JOIN SYS.DM_DB_MISSING_INDEX_DETAILS mid ON mig.index_handle = mid.index_handle
LEFT JOIN sys.objects so on so.object_id=mid.object_id
LEFT JOIN sys.schemas ss ON ss.schema_id=so.schema_id
WHERE migs.avg_total_user_cost * (migs.avg_user_impact / 100.0) * (migs.user_seeks + migs.user_scans) > 10
AND so.name = COALESCE(@TableName,so.name) AND mid.database_id = db_id()
ORDER BY migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans) DESC


GO
	
EXEC sp_MS_marksystemobject 'sp_DBA_MissingIndexes'

GO

EXEC sys.sp_addextendedproperty @name=N'Version', @value=N'1.0' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'sp_DBA_MissingIndexes'
GO

GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Get missing index information' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'sp_DBA_MissingIndexes'
GO

EXEC sys.sp_addextendedproperty @name=N'Parameters', @value=N'@ObjectName=NULL,@SchemeName=dbo,@Sort =1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'sp_DBA_MissingIndexes'
GO

GRANT EXEC on sp_DBA_MissingIndexes to [PUBLIC]
