
-- Dev server Issue getting messages suggesting space issues 
EXEC sp_DBA_DBSpaceCalc

-- You've had a recommended index to add to a table ,haven't you already got on simulair by the name 
EXEC sp_DBA_GetIndexColumns

--Where are my indexing pain points
EXEC sp_DBA_GetIndexStats

-- Job such a such has not run
EXEC sp_DBA_JobSchedule

-- I'm dbo on the database but can't access it
EXEC sp_DBA_List_dbroles

--Anything changed after the release last night?
EXEC sp_DBA_MissingIndexes


