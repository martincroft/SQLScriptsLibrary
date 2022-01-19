-- sp_DBA_Deadlocks.sql  #SQL
USE [master]
go

/****** Object:  StoredProcedure [dbo].[sp_DBA_Expensive_Queries]    Script Date: 11/21/2011 12:45:55 ******/
SET ANSI_NULLS ON
go

SET QUOTED_IDENTIFIER ON
go

/****** Object:  StoredProcedure [dbo].[sp_DBA_Expensive_Queries]    Script Date: 11/21/2011 12:46:16 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_DBA_Deadlocks]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_DBA_Deadlocks]
go

  
CREATE PROCEDURE sp_DBA_Deadlocks  
AS   
-----------------------------------------------------------------    
-- Object:   sp_DBA_Deadlocks    
-- Written By:   
-- Date Written: 15-July-2011   
-- Purpose:   Returns deadlock details .    
-- Template:  1.0     
-- Usage:       
--    sp_DBA_MIssingIndxes    
-- Calls:   N/A    
-----------------------------------------------------------------    
-- Modified By  Modified Date  Description  Version    
-- Added Meta data and added to source control
-----------------------------------------------------------------    
-- {developer}  {date}    {description} {Version}    
-----------------------------------------------------------------    
SELECT  CAST(XEventData.XEvent.value('(data/value)[1]', 'varchar(max)')  
                          
            AS XML) AS DeadlockGraph  
FROM  
(SELECT CAST(target_data AS XML) AS TargetData  
FROM sys.dm_xe_session_targets st  
JOIN sys.dm_xe_sessions s ON s.address = st.event_session_address  
WHERE name = 'system_health') AS DATA  
CROSS APPLY TargetData.nodes ('//RingBufferTarget/event') AS XEventData (XEvent)  
WHERE XEventData.XEvent.value('@name', 'varchar(4000)') = 'xml_deadlock_report'  
  
 GO
 
 
 
GO

EXEC sp_MS_marksystemobject sp_DBA_Deadlocks

GO

GRANT EXEC on sp_MS_marksystemobject to [PUBLIC]

GO
