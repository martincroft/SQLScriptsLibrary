-- DBA_Deadlocks.sql  #SQL
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
 
