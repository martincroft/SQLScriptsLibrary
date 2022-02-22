--================================
/* Help the servers broken !!*/
--================================













--================================
/* List the DBA tools */
--================================


exec sp_DBA_tools













--================================
/* Whats running on the server */
--================================

exec sp_DBA_WhoIsActive


--================================
/* Find blocking  details*/
--================================


exec sp_DBA_BlockingInfo



--================================
/* Whats up with my code (simple version as we always know its it depends)*/
--================================

exec sp_DBA_GetProcedureStats uspDemoProcedure

exec sp_DBA_ProcedureExecutionPlan uspDemoProcedure


