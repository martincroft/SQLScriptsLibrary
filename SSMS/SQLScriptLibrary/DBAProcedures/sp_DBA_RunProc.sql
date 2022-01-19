IF EXISTS ( SELECT * FROM sysobjects where id = OBJECT_ID(N'sp_DBA_RunProc') and type = 'p')
DROP PROCEDURE sp_DBA_RunProc
Go


CREATE PROC sp_DBA_RunProc
(
	@RunID INT

)
AS

SET NOCOUNT ON

IF @RunID=-1 
BEGIN
	PRINT '============================='
	PRINT 'sp_DBA_DBPermissions'
	PRINT '============================='
	PRINT 'Syntax sp_DBA_DBPermissions'
	PRINT 'Syntax No paramaters'
	PRINT 'Description Returns permissions for all databases on server'
	PRINT '' 
	PRINT '============================='
	PRINT 'Example '
	PRINT 'EXEC sp_DBA_DBPermissions'
	PRINT '============================='
END

IF @RunID=1 EXEC sp_DBA_DBPermissions



IF @RunID=-2
BEGIN
	PRINT '============================='
	PRINT 'sp_DBA_DBSpaceCalc'
	PRINT '============================='
	PRINT 'Syntax sp_DBA_DBSpaceCalc'
	PRINT 'Syntax No paramaters'
	PRINT 'Description '
	PRINT 'Returns database data size by database'
	PRINT 'Returns database log size by database'
	PRINT 'Returns toatl database log size that can be freed up'
	PRINT '' 
	PRINT '============================='
	PRINT 'Example '
	PRINT 'EXEC sp_DBA_DBSpaceCalc'
	PRINT '============================='
END

IF @RunID=2 EXEC sp_DBA_DBSpaceCalc



IF @RunID=-5
BEGIN
	PRINT '============================='
	PRINT 'sp_DBA_Expensive_Queries'
	PRINT '============================='
	PRINT 'Syntax sp_DBA_Expensive_Queries'
	PRINT 'Syntax paramaters CPU I/O Read Writes'
	PRINT 'Description '
	PRINT 'Returns expensive queries'
	PRINT 'based on type, I/O CPU, Read, Writes '
	PRINT 'Returns data from current database'
	PRINT '' 
	PRINT '============================='
	PRINT 'Example '
	PRINT 'sp_DBA_Expensive_Queries ''CPU'''
	PRINT 'sp_DBA_Expensive_Queries ''I/O'''
	PRINT 'sp_DBA_Expensive_Queries ''Read'''
	PRINT 'sp_DBA_Expensive_Queries ''Writes'''
	PRINT '============================='
END
IF @RunID=5 EXEC sp_DBA_Expensive_Queries



IF @RunID=-7
BEGIN
	PRINT '============================='
	PRINT 'sp_DBA_fields'
	PRINT '============================='
	PRINT 'Syntax sp_DBA_fields'
	PRINT 'Syntax paramaters column to search for, will find %search%'
	PRINT 'Description '
	PRINT 'Returns all columns, source tablename and'
	PRINT 'Datatype, length and scale'
	PRINT 'in current database'
	PRINT '' 
	PRINT '============================='
	PRINT 'Example '
	PRINT 'sp_DBA_fields ''Customer'''
	PRINT '============================='
END

IF @RunID=7 EXEC sp_DBA_fields



IF @RunID=-8
BEGIN
	PRINT '============================='
	PRINT 'sp_DBA_FindColumnUsage'
	PRINT '============================='
	PRINT 'Syntax sp_DBA_FindColumnUsage'
	PRINT 'Syntax paramaters table to search for, column'
	PRINT 'Description '
	PRINT 'Returns all columns, source tablename and source column'
	PRINT 'with any associated procedures/views/ functions '
	PRINT 'in current database'
	PRINT '' 
	PRINT '============================='
	PRINT 'Example '
	PRINT 'sp_DBA_FindColumnUsage ''Customer_table'', ''customer_id'''
	PRINT '============================='
END
IF @RunID=8 EXEC sp_DBA_FindColumnUsage



IF @RunID=9 EXEC sp_DBA_FK_Missing_Indexes
IF @RunID=10 EXEC sp_DBA_GetIndexColumns
IF @RunID=11 EXEC sp_DBA_GetIndexStats
IF @RunID=12 EXEC sp_DBA_GetProcedureStats
IF @RunID=13 EXEC sp_DBA_JobSchedule
IF @RunID=14 EXEC sp_DBA_List_dbroles
IF @RunID=15 EXEC sp_DBA_MissingIndexes
IF @RunID=16 EXEC sp_DBA_ProcedureExecutionPlan
IF @RunID=17 EXEC sp_DBA_search_code
IF @RunID=18 EXEC sp_DBA_Duplicate_Indexes

GO

EXEC sp_ms_marksystemobject 'sp_DBA_RunProc'

GO

GRANT EXEC on sp_DBA_RunProc to [PUBLIC]

GO
