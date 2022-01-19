-- sp_DBA_JobSchedules.sql  #SQL

USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_DBA_DBPermissions]    Script Date: 10/21/2010 16:04:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_DBA_JobSchedule]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_DBA_JobSchedule]
GO


CREATE PROCEDURE sp_DBA_JobSchedule

AS
-----------------------------------------------------------------
-- Object:			[sp_DBA_JobSchedule]
-- Written By:		Martin Croft
-- Date Written:	
-- Purpose:			Lists Job Schedules, when jobs run and jobs enabled, runtimes 
-- source http://www.sqlservercentral.com/scripts/SQL+Server+2005/87998/
-- Sekhar Mynam , 2012/02/23
-- Usage:			[sp_DBA_JobSchedule] 
-----------------------------------------------------------------
-- Modified By		Modified Date		Description		Version
-----------------------------------------------------------------
-----------------------------------------------------------------


DECLARE @x INT, @y INT, @z INT
DECLARE @counter SMALLINT
DECLARE @days VARCHAR(100), @day VARCHAR(10)
DECLARE @Jname sysname, @freq_interval INT, @JID VARCHAR(50)
SET NOCOUNT ON

CREATE TABLE #temp (JID VARCHAR(50), Jname sysname, 
Jdays VARCHAR(100))

--–This cursor runs throough all the jobs that have a weekly frequency running on different days
DECLARE C CURSOR FOR SELECT sjs.job_id AS Job_id, ss.name AS Name, ss.freq_interval
FROM msdb.dbo.sysjobschedules sjs JOIN msdb..sysschedules ss ON sjs.schedule_id = ss.schedule_id
WHERE freq_type = 8

OPEN C
FETCH NEXT FROM c INTO @JID, @Jname, @freq_interval
WHILE @@FETCH_STATUS = 0
BEGIN
SET @counter = 0
SET @x = 64
SET @y = @freq_interval
SET @z = @y
SET @days = ''
SET @day = ''

WHILE @y <> 0
BEGIN
SELECT @y = @y - @x
SELECT @counter = @counter + 1
IF @y < 0 
BEGIN
SET @y = @z
GOTO START
END


SELECT @day = CASE @x
WHEN 1 THEN 'Sunday'
WHEN 2 THEN 'Monday'
WHEN 4 THEN 'Tuesday'
WHEN 8 THEN 'Wednesday'
WHEN 16 THEN 'Thursday'
WHEN 32 THEN 'Friday'
WHEN 64 THEN 'Saturday'
END

SELECT @days = @day + ',' + @days
START:
SELECT @x = CASE @counter
WHEN 1 THEN 32
WHEN 2 THEN 16
WHEN 3 THEN 8
WHEN 4 THEN 4
WHEN 5 THEN 2
WHEN 6 THEN 1
END

SET @z = @y
IF @y = 0 BREAK
END

INSERT INTO #temp SELECT @jid, @jname, LEFT(@days, LEN(@days)-1)
FETCH NEXT FROM c INTO @jid, @Jname, @freq_interval

END
CLOSE c
DEALLOCATE c

--–Final query to extract complete information by joining sysjobs, sysschedules and #Temp table

SELECT b.name Job_Name, 
CASE b.enabled 
WHEN 1 THEN 'Enabled'
ELSE 'Disabled'
END AS JobEnabled, ss.name Schedule_Name, 

CASE ss.enabled 
WHEN 1 THEN 'Enabled'
ELSE 'Disabled'
END AS ScheduleEnabled,

CASE freq_type 
WHEN 1 THEN 'Once'
WHEN 4 THEN 'Daily'
WHEN 8 THEN 'Weekly'
WHEN 16 THEN 'Monthly' + CAST(freq_interval AS CHAR(2)) + 'th Day'
WHEN 32 THEN 'Monthly Relative'
WHEN 64 THEN 'Execute When SQL Server Agent Starts'
END AS [Job Frequency],

CASE freq_type 
WHEN 32 THEN CASE freq_relative_interval
WHEN 1 THEN 'First'
WHEN 2 THEN 'Second'
WHEN 4 THEN 'Third'
WHEN 8 THEN 'Fourth'
WHEN 16 THEN 'Last'
END
ELSE ''
END AS [Monthly Frequency],

CASE freq_type
WHEN 16 THEN CAST(freq_interval AS CHAR(2)) + 'th Day of Month'
WHEN 32 THEN CASE freq_interval 
WHEN 1 THEN 'Sunday'
WHEN 2 THEN 'Monday'
WHEN 3 THEN 'Tuesday'
WHEN 4 THEN 'Wednesday'
WHEN 5 THEN 'Thursday'
WHEN 6 THEN 'Friday'
WHEN 7 THEN 'Saturday'
WHEN 8 THEN 'Day'
WHEN 9 THEN 'Weekday'
WHEN 10 THEN 'Weekend day'
END
WHEN 8 THEN c.Jdays
ELSE ''
END AS [Runs ON],
CASE freq_subday_type
WHEN 1 THEN 'At the specified Time'
WHEN 2 THEN 'Seconds'
WHEN 4 THEN 'Minutes'
WHEN 8 THEN 'Hours'
END AS [INTERVAL TYPE], CASE freq_subday_type 
WHEN 1 THEN 0
ELSE freq_subday_interval 
END AS [TIME INTERVAL],
CASE freq_type 
WHEN 8 THEN CAST(freq_recurrence_factor AS CHAR(2)) + ' Week'
WHEN 16 THEN CAST(freq_recurrence_factor AS CHAR(2)) + ' Month'
WHEN 32 THEN CAST(freq_recurrence_factor AS CHAR(2)) + ' Month'
ELSE ''
END AS [Occurs EVERY],

LEFT(active_start_date,4) + '-' + SUBSTRING(CAST(active_start_date AS CHAR),5,2) 
+ '-' + RIGHT(active_start_date,2) [BEGIN DATE-Executing Job], 

LEFT(REPLICATE('0', 6-LEN(active_start_time)) + CAST(active_start_time AS CHAR(6)),2) + ':' +
SUBSTRING(REPLICATE('0', 6-LEN(active_start_time)) + CAST(active_start_time AS CHAR(6)),3,2) + ':' +
SUBSTRING(REPLICATE('0', 6-LEN(active_start_time)) + CAST(active_start_time AS CHAR(6)),5,2)
[Executing AT],

LEFT(active_end_date,4) + '-' + SUBSTRING(CAST(active_end_date AS CHAR),5,2) 
+ '-' + RIGHT(active_end_date,2) [END DATE-Executing Job],

LEFT(REPLICATE('0', 6-LEN(active_end_time)) + CAST(active_end_time AS CHAR(6)),2) + ':' +
SUBSTRING(REPLICATE('0', 6-LEN(active_end_time)) + CAST(active_end_time AS CHAR(6)),3,2) + ':' +
SUBSTRING(REPLICATE('0', 6-LEN(active_end_time)) + CAST(active_end_time AS CHAR(6)),5,2)
[END TIME-Executing Job],

b.date_created [Job Created], ss.date_created [Schedule Created] 
FROM msdb..sysjobschedules a 
JOIN msdb..sysschedules ss ON a.schedule_id = ss.schedule_id
RIGHT OUTER JOIN msdb..sysjobs b ON a.job_id = b.job_id
LEFT OUTER JOIN #temp c ON ss.name = c.jname AND a.job_id = c.Jid
--where b.name like '%backup%'
ORDER BY 1

DROP TABLE #Temp


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



EXEC sp_MS_marksystemobject sp_DBA_JobSchedule

GO

EXEC sys.sp_addextendedproperty @name=N'Version', @value=N'10.0' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'sp_DBA_JobSchedule'
GO

GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Get Job schedule information' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'sp_DBA_JobSchedule'
GO
GO   
GRANT EXEC on sp_DBA_JobSchedule to [PUBLIC]
