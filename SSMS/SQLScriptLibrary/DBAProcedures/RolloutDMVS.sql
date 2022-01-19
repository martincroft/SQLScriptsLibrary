-- RolloutDMVS.sql  #SQL
-- Run in SQL CMD mode
-- Connect to any server and the following procedures will be installed - Script lists the installed procedures at the end
GO

:setvar location "C:\SQLScriptsLibrary\SSMS\SQLScriptLibrary\DBAProcedures"




USE Master
GO
:r $(location)\sp_DBA_BlockingInfo.sql


GO
:r $(location)\sp_DBA_GetIndexColumns.sql


GO
:r $(location)\sp_DBA_search_code.sql

GO

:r $(location)\sp_DBA_Duplicate_Indexes.sql
GO



:r $(location)\sp_DBA_tools.sql
GO


:r $(location)\sp_DBA_WhoIsActive.sql


GO
:r $(location)\sp_DBA_DBPermissions.sql

GO

:r $(location)\sp_DBA_DBSpaceCalc_2005_2008.sql

GO

:r $(location)\sp_DBA_Deadlocks.sql

GO

:r $(location)\sp_DBA_Expensive_Queries.sql

GO

:r $(location)\sp_DBA_Expensive_Queries_Summary.sql

GO

:r $(location)\sp_DBA_fields.sql

GO

:r $(location)\sp_DBA_FindColumnUsage.sql

GO

:r $(location)\sp_DBA_FK_Missing_Indexes.sql

GO
:r $(location)\sp_DBA_GetIndexStats.sql

GO
:r $(location)\sp_DBA_GetProcedureStats.sql

GO
:r $(location)\sp_DBA_List_dbroles.sql

GO
:r $(location)\sp_DBA_MissingIndexes.sql

GO
:r $(location)\sp_DBA_ProcedureExecutionPlan.sql
GO
:r $(location)\sp_DBA_Jobschedules.sql

EXEC sp_DBA_tools
