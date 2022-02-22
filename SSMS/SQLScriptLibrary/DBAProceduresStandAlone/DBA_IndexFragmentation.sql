-- DBA_IndexFragmentation.sql  #SQL
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE
	@Objectname nvarchar(50) =NULL,
	@Mode nvarchar(20)= NULL

-----------------------------------------------------------------  
-- Object:    sp_DBA_IndexFragmentation
-- Written By:
-- Date Written: 03/12/2010  
-- Purpose:   Return  / 
-- Usage:      sp_DBA_IndexFragmentation  @Objectname='[Person].[Address]', @Mode='LIMITED'
-----------------------------------------------------------------  
-- Modified By  Modified Date  Description  Version  
-----------------------------------------------------------------  
-- {developer}  {date}    {description} {Version}  
-----------------------------------------------------------------  
  
  
-- SP calculates the fragmentation of Indexes on a given table
  
  
Declare @Objectid int 
  
Set @Objectid = (Select Object_id(@ObjectName))  
   

  
SELECT                       
   Object_name(i.object_id)     AS  TableName,                      
   db_name()     AS  Database_name,                        
   i.Object_id     AS  ObjectID,                 
   so.id as IndexID    ,                
   si.name      AS  IndexName,                        
   i.index_id        AS  IndexNOId,                         
   Index_depth     AS  Lvl,                         
   page_count     AS  page_count,                                          
   avg_fragmentation_in_percent AS  ScanDensity,                         
                 
   GETDATE()     As  ReportDate     
                     
   FROM                       
    sys.dm_db_index_physical_stats (db_id(),@ObjectID,Null,NULL,ISNULL(@mode,'LIMITED'))   i                      
  JOIN                      
    sys.indexes si ON si.object_id=i.object_id AND si.index_id=i.index_id                
  JOIN                 
   sysobjects so ON i.object_id = so.id                    
   WHERE                      
  Index_level=0 --leaf level data                       
    AND                      
  i.index_id <> 0 -- Ignore heaps                      
    AND                      
  i.alloc_unit_type_desc='IN_ROW_DATA'                          
  
  AND page_count > 500 and avg_fragmentation_in_percent > 30

  ORDER BY  avg_fragmentation_in_percent desc




  