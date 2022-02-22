-- DBA_BlockingChain.sql  #SQL
USE [master]
GO

SET ANSI_NULLS ON
GO

-----------------------------------------------------------------  
-- Object:   DBA_BlockingChain.sql  
-- Written By:  Martin Croft
-- Date Written:   
-- Purpose:   Shows lead blocking
-- Usage:     DBA_BlockingChain
-----------------------------------------------------------------  
-- Modified By  Modified Date  Description					Version 
-----------------------------------------------------------------  
-- {developer}  {date}    {description} {Version}  
-----------------------------------------------------------------  


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


