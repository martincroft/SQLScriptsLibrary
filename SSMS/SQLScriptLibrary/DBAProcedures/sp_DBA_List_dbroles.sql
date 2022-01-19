-- sp_DBA_List_dbroles.sql  #SQL
USE [master]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_DBA_List_dbroles]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_DBA_List_dbroles]
GO


CREATE   PROCEDURE [dbo].[sp_DBA_List_dbroles] 
-----------------------------------------------------------------  
-- Object:   [sp_DBA_List_dbroles]  
-- Written By:  Martin Croft
-- source Mangal Pardeshi microsoft forum
-- Date Written:   
-- Purpose:   Returns roles for all users in all databases   
-- Usage:    EXEC [sp_DBA_List_dbroles]  @datareader=1,@datawriter=1
--			 EXEC [sp_DBA_List_dbroles] @dbo=1
-----------------------------------------------------------------  
-- Modified By  Modified Date  Description					Version 
-----------------------------------------------------------------  
-- {developer}  {date}    {description} {Version}  
-----------------------------------------------------------------  

(@database   NVARCHAR(128)=NULL,
 @user       VARCHAR(20)=NULL,
 @dbo        CHAR(1)=NULL,
 @access     CHAR(1)=NULL,
 @security   CHAR(1)=NULL,
 @ddl        CHAR(1)=NULL,
 @datareader CHAR(1)=NULL,
 @datawriter CHAR(1)=NULL,
 @denyread   CHAR(1)=NULL,
 @denywrite  CHAR(1)=NULL)
AS
    DECLARE @dbname VARCHAR(200)
    DECLARE @mSql1 VARCHAR(8000)

    CREATE TABLE #DBROLES
      (
         DBName            SYSNAME NOT NULL,
         UserName          SYSNAME NOT NULL,
         db_owner          VARCHAR(3) NOT NULL,
         db_accessadmin    VARCHAR(3) NOT NULL,
         db_securityadmin  VARCHAR(3) NOT NULL,
         db_ddladmin       VARCHAR(3) NOT NULL,
         db_datareader     VARCHAR(3) NOT NULL,
         db_datawriter     VARCHAR(3) NOT NULL,
         db_denydatareader VARCHAR(3) NOT NULL,
         db_denydatawriter VARCHAR(3) NOT NULL
       
      )

    DECLARE DBName_Cursor CURSOR FOR
      SELECT [name]
      FROM   master.sys.databases
      WHERE  name NOT IN ( 'mssecurity', 'tempdb' ) AND state_desc ='ONLINE'
      ORDER  BY name

    OPEN DBName_Cursor

    FETCH NEXT FROM DBName_Cursor INTO @dbname

    WHILE @@FETCH_STATUS = 0
      BEGIN
          SET @mSQL1 = ' Insert into #DBROLES ( DBName, UserName, db_owner, db_accessadmin,

db_securityadmin, db_ddladmin, db_datareader, db_datawriter,

db_denydatareader, db_denydatawriter )

SELECT ' + '''[' + @dbName + ']''' + ' as DBName ,UserName, ' + Char(13) + '

Max(CASE RoleName WHEN ''db_owner'' THEN ''Yes'' ELSE ''No'' END) AS db_owner,

Max(CASE RoleName WHEN ''db_accessadmin '' THEN ''Yes'' ELSE ''No'' END) AS db_accessadmin ,

Max(CASE RoleName WHEN ''db_securityadmin'' THEN ''Yes'' ELSE ''No'' END) AS db_securityadmin,

Max(CASE RoleName WHEN ''db_ddladmin'' THEN ''Yes'' ELSE ''No'' END) AS db_ddladmin,

Max(CASE RoleName WHEN ''db_datareader'' THEN ''Yes'' ELSE ''No'' END) AS db_datareader,

Max(CASE RoleName WHEN ''db_datawriter'' THEN ''Yes'' ELSE ''No'' END) AS db_datawriter,

Max(CASE RoleName WHEN ''db_denydatareader'' THEN ''Yes'' ELSE ''No'' END) AS db_denydatareader,

Max(CASE RoleName WHEN ''db_denydatawriter'' THEN ''Yes'' ELSE ''No'' END) AS db_denydatawriter

from (

select b.name as USERName, c.name as RoleName

from [' + @dbName + '].dbo.sysmembers a ' + Char(13) + ' join [' + @dbName + '].dbo.sysusers b ' + Char(13) + ' on a.memberuid = b.uid join [' + @dbName + '].dbo.sysusers c

on a.groupuid = c.uid )s

Group by USERName

order by UserName'

          --Print @mSql1
          EXECUTE (@mSql1)

          FETCH NEXT FROM DBName_Cursor INTO @dbname
      END

    CLOSE DBName_Cursor

    DEALLOCATE DBName_Cursor

    SELECT *
    FROM   #DBRoles
    WHERE  ( ( @database IS NULL )
              OR ( DBName LIKE '%' + @database + '%' ) )
           AND ( ( @user IS NULL )
                  OR ( UserName LIKE '%' + @user + '%' ) )
           AND ( ( @dbo IS NULL )
                  OR ( db_owner = 'Yes' ) )
           AND ( ( @access IS NULL )
                  OR ( db_accessadmin = 'Yes' ) )
           AND ( ( @security IS NULL )
                  OR ( db_securityadmin = 'Yes' ) )
           AND ( ( @ddl IS NULL )
                  OR ( db_ddladmin = 'Yes' ) )
           AND ( ( @datareader IS NULL )
                  OR ( db_datareader = 'Yes' ) )
           AND ( ( @datawriter IS NULL )
                  OR ( db_datawriter = 'Yes' ) )
           AND ( ( @denyread IS NULL )
                  OR ( db_denydatareader = 'Yes' ) )
           AND ( ( @denywrite IS NULL )
                  OR ( db_denydatawriter = 'Yes' ) ) 

GO

EXEC sp_MS_marksystemobject sp_DBA_List_dbroles

GO

EXEC sys.sp_addextendedproperty @name=N'Version', @value=N'2.0' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'sp_DBA_List_dbroles'
GO

GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Returns roles for all users in all databases' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'sp_DBA_List_dbroles'
GO

EXEC sys.sp_addextendedproperty @name=N'Parameters', @value=N'@database, @user,@dbo,@access,@security,@ddl,@datareader,@datawriter,@denyread,@denywrite (set to 1 to display if exists)  ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'sp_DBA_List_dbroles'


GRANT EXEC ON sp_DBA_List_dbroles to [Public]
