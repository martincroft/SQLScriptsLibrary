-- DBA_BlockingChain.sql  #SQL
USE [master]
GO

SET ANSI_NULLS ON
GO

-----------------------------------------------------------------  
-- Object:   sp_DBA_BlockingInfo.sql  
-- Written By:  Martin Croft
-- Date Written:   
-- Purpose:   Shows lead blocking
-- Usage:     sp_DBA_BlockingInfo
-----------------------------------------------------------------  
-- Modified By  Modified Date  Description					Version 
-----------------------------------------------------------------  
-- {developer}  {date}    {description} {Version}  
-----------------------------------------------------------------  
IF EXISTS (
		SELECT *
		FROM sys.sysobjects
		WHERE id = OBJECT_ID(N'sp_DBA_BlockingInfo')
			AND type = 'p'
		)
	DROP PROCEDURE sp_DBA_BlockingInfo
GO
CREATE PROCEDURE sp_DBA_BlockingInfo
AS

IF (SELECT OBJECT_ID('TempDB.dbo.#T')) IS NOT NULL DROP TABLE #T
CREATE TABLE #T (spid INT, Blocked INT, BATCH VARCHAR(MAX))

INSERT INTO #T (Spid,blocked,Batch)
SELECT  spid ,
        blocked ,
        REPLACE(REPLACE(T.text, CHAR(10), ' '), CHAR(13), ' ') AS BATCH

FROM    sys.sysprocesses R
        CROSS APPLY sys.dm_exec_sql_text(R.sql_handle) T;

WITH    BLOCKERS ( SPID, BLOCKED, LEVEL, BATCH )
          AS ( SELECT   spid ,
                        blocked ,
                        CAST (REPLICATE('0', 4 - LEN(CAST (spid AS VARCHAR)))
                        + CAST (spid AS VARCHAR) AS VARCHAR(1000)) AS LEVEL ,
                        BATCH
               FROM     #T R
               WHERE    ( blocked = 0
                          OR blocked = spid
                        )
                        AND EXISTS ( SELECT *
                                     FROM   #T R2
                                     WHERE  R2.blocked = R.spid
                                            AND R2.blocked <> R2.spid )
               UNION ALL
               SELECT   R.spid ,
                        R.blocked ,
                        CAST (BLOCKERS.LEVEL
                        + RIGHT(CAST (( 1000 + R.spid ) AS VARCHAR(100)), 4) AS VARCHAR(1000)) AS LEVEL ,
                        R.BATCH
               FROM     #T AS R
                        INNER JOIN BLOCKERS ON R.blocked = BLOCKERS.SPID
               WHERE    R.blocked > 0
                        AND R.blocked <> R.spid
             )
    SELECT  N'    ' + REPLICATE(N'|         ', LEN(LEVEL) / 4 - 1)
            + CASE WHEN ( LEN(LEVEL) / 4 - 1 ) = 0 THEN 'HEAD -  '
                   ELSE '|------  '
              END + CAST (SPID AS NVARCHAR(10)) + N' ' + BATCH AS BLOCKING_TREE
    FROM    BLOCKERS
    ORDER BY LEVEL ASC;

GO


EXEC sp_MS_marksystemobject 'sp_DBA_BlockingInfo'
GO

EXEC sys.sp_addextendedproperty @name = N'Version'
	,@value = N'1.0'
	,@level0type = N'SCHEMA'
	,@level0name = N'dbo'
	,@level1type = N'PROCEDURE'
	,@level1name = N'sp_DBA_BlockingInfo'
GO

EXEC sys.sp_addextendedproperty @name = N'Description'
	,@value = N'Get blocking info / lead blocking spid'
	,@level0type = N'SCHEMA'
	,@level0name = N'dbo'
	,@level1type = N'PROCEDURE'
	,@level1name = N'sp_DBA_BlockingInfo'
GO

EXEC sys.sp_addextendedproperty @name = N'Parameters'
	,@value = N'N/A'
	,@level0type = N'SCHEMA'
	,@level0name = N'dbo'
	,@level1type = N'PROCEDURE'
	,@level1name = N'sp_DBA_BlockingInfo'
GO

GRANT EXEC
	ON sp_DBA_BlockingInfo
	TO [PUBLIC]



