-- 006_Security_Audit.sql  #SQL
--Security
/*
01 The SQL Server is placed in the DMZ external facing servers 
02 Internet accessible from Server 
03 Segregate production from test servers 
04 Dedicated SQL Server 
05 Ad Hoc Distributed Queries
06 CLR enabled
07 cross db ownership chaining
08 Database Mail XPs
09 Ole Automation Procedures
10 Test data is obfuscated 
11 remote access
12 remote admin connections
13 Scan for startup proc
14 Monitor addition of start-up procedures
15 SQL Mail XPs
16 is_trustworthy_on
17 Xp_cmdshell enabled
18-28 XP Public permissions 
29 SQL Server service accounts Are not members of the local administrators group
30 SQL Server service accounts Are not members of the Domain administrators group
31 Service Account has Sysamin
32 SQL Server service accounts use a domain based service accounts
33 SQL Server service accounts use a domain based service accounts
34 SQL Server SQL Server browser Service
35 The SQL Server Active Directory Helper  Service
36 The VSS Writer allows service
37 Anti-Virus Software
38 SQL Server ports (1433,1434)
39 SQL Server install file permissions
40 SQL Server service packs / hot fixes and patches
41 Is Guest user disabled 
42 Example databases 
43 SQL Proxy SQL Proxy exists
44 SQL Server proxy account permissions 
45 SQL Server Error log
46 Database Encryption
47-49 Linked servers 
50 Windows Authentication should be used over mixed mode 
51 Authentication settings sa account is disabled 
52 Authentication settings sa account is renamed 
53 Authentication settings CHECK_POLICY should be set for each mixed mode account 
54 Are any passwords set to expire
55 Users must change password at next login
56 Sysadmin Only required privileged users are Sysadmin 
57 Sysadmin anonymous accounts have Sysadmin access
58 No AD users / groups exist outside the privileged ‘SQL Administrators’ AD group
59 BUILTIN\Administrators Exists 
60 Backups are on a secure network share
61 Privileged users and service accounts backup permissions
62 No backup / restore routines are in place for Dev/Test
63 db_backupoperator Access
64 Replication Running under different accounts
65 Replication Agent permissions
66 Merge Agent and Distribution Agent accounts
67 Pull subscriptions
68 Replication connections
69 Auditing Authorised Schema additions
70 Auditing Schema changes
71 BUILTIN\Administrators is SA 
72 Failed login trace running
73 SQL Logins without enforce password policy set
74 have any passwords had failed log in 
75 Password Expired
76 have passwords been reset in last month
77 Orphaned User
78 C2 Auditing 
79 Windows Firewall Setting 
*/

/* Version History V1.1

	V1.0 - Initial version
	V1.1 - Corrected issue with SQLAGENT Service account not 
*/


USE MASTER
GO

SET NOCOUNT ON

--------------------
--Create Temp Table
IF EXISTS (SELECT  * FROM tempdb.dbo.sysobjects o WHERE o.xtype IN ('U')  AND o.id = OBJECT_ID(N'tempdb..#SecurityCheck'))
	DROP TABLE #SecurityCheck;

CREATE TABLE #SecurityCheck (MODULE NVARCHAR(500),
                             RESULT NVARCHAR(500),
                             DETAILS NVARCHAR(500),
                             FURTHER_INFO XML
                           
                            )

				

--==============================================================================================
--01 The SQL Server is placed in the DMZ and firewalled off to reduce the risk of remote attacks
--==============================================================================================                           

INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'01 The SQL Server is placed in the DMZ external facing servers '  AS Module,
		'Check that the SQL server is placed in the DMZ and firewalled off to reduce the risk of remote attacks' As Details,
		 'MANUAL REVIEW' AS Result, 
		 CAST('--Check that the SQL server is The SQL Server is placed in the DMZ and firewalled off to reduce the risk of remote attacks.
		 For all external facing servers. 
		  ' AS XML) AS FURTHER_INFO


--==============================================================================================
--02 Internet accessible from Server
--==============================================================================================                           

INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'02 Internet accessible from Server '  AS Module,
		'Check that the SQL server is not able to access the internet' As Details,
		 'MANUAL REVIEW' AS Result, 
		 CAST('--Access to the internet could allow unauthorised users to compromise SQL server, download malicious tools or potentially extract data
		  ' AS XML) AS FURTHER_INFO

--==============================================================================================
--03 Segregate production from test servers
--==============================================================================================                           

INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'03 Segregate production from test servers '  AS Module,
		'Check that the production servers are segregated from test server' As Details,
		 'MANUAL REVIEW' AS Result, 
		 CAST('-- Production servers and development server should following best practices be on
-- Segregated parts of the network, so if development which usually can be a less secure environment
--is compromised , it should not allow access to the production environment 
		  ' AS XML) AS FURTHER_INFO



--==============================================================================================
--04 Dedicated Server
--==============================================================================================                           

INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'04 Dedicated SQL Server '  AS Module,
		'Check that the SQL Server only has one function' As Details,
		 'MANUAL REVIEW' AS Result, 
		 CAST('--Review Add / Remove programmes and items in the start / programs folder to ensure
--that no application / programmes are installed that shouldnt be. Only SQL server should be installed on SQL Servers
		  ' AS XML) AS FURTHER_INFO


--==============================================================================================
--05 Ad Hoc Distributed Queries
--==============================================================================================                           

INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)

SELECT 
	'05 Ad Hoc Distributed Queries' AS MODULE, 
	'Ad Hoc Distributed Queries should be disabled' AS Details,
	CASE WHEN VALUE = 0 THEN 'PASS' ELSE 'FAIL' END AS RESULT,
	 CAST('--If enabled disable after investigation of why it is enabled ( ONCE WE HAVE approved change) 
--sp_configure ''Ad Hoc Distributed Queries'',1 GO RECONFIGURE

SELECT 
	@@Servername AS srvName,
	Name,
	Value,
	value_in_use,
	description
	FROM 
		sys.configurations
WHERE 
	name = ''Ad Hoc Distributed Queries''


' AS XML) AS FURTHER_INFO
FROM 
	sys.configurations
WHERE 
	name = 'Ad Hoc Distributed Queries'

--==============================================================================================
--06 CLR enabled 
--==============================================================================================

 
INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)		
SELECT 
	'06 CLR enabled' AS Issue,
	'CLR being enabled can be a security risk if it is not required it should be switched off', 
		CASE WHEN VALUE = 0 THEN 'PASS' ELSE 'FAIL' END AS RESULT,
	CAST(' --Review 
	SELECT 
		@@Servername AS srvName,
		Name,
		Value,
		value_in_use,
		description
	FROM 
		sys.configurations 
	WHERE 
		name =''clr enabled'''AS XML) AS FURTHER_INFO
FROM 
	sys.configurations
WHERE 
	name = 'clr enabled'	


--==============================================================================================
--07 Cross Database ownership 
--==============================================================================================
GO


INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)		
SELECT 
	'07 cross db ownership chaining' AS Issue,
	'cross db ownership chaining can open up security holes ', 
	CASE WHEN VALUE = 0 THEN 'PASS' ELSE 'FAIL' END AS RESULT,
	CAST(' --Cross-database ownership chaining opens up several serious security holes and, except for specific circumstances, should be avoided
--It can allow users who should have no access to particular database gaining access through permissions in another database
	SELECT 
		@@Servername AS srvName,
		Name,
		Value,
		value_in_use,
		description
	FROM 
		sys.configurations 
	WHERE 
		name =''cross db ownership chaining''
		
	SELECT 
		@@Servername AS srvName,
		[name] AS [Database], 
		[is_db_chaining_on] 
	FROM [sys].databases 
	ORDER BY [name];
		
		'AS XML)
FROM 
	sys.configurations
WHERE 
	name ='cross db ownership chaining' 

--==============================================================================================
--08 Database Mail XPs
--==============================================================================================
INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)

SELECT 
	'08 Database Mail XPs' AS MODULE, 
	'Is Database Mail XPs disabled' AS Details,
	CASE WHEN VALUE = 0 THEN 'PASS' ELSE 'FAIL' END AS RESULT,
	 CAST('-- Check the following queries for further information 
SELECT 
		@@Servername AS srvName,
		Name,
		Value,
		value_in_use,
		description
	 FROM 
	sys.configurations 
WHERE 
	name = ''Database Mail XPs''
	 
--Review if the SQL server can email externally, database query / fileattachment 
--as this can be a major security risk if compromised 

	EXEC msdb.dbo.sp_send_dbmail
    @recipients = ''external test account'',
    @body = ''This is a test message to validate external message cant be sent'',
	@query =''SELECT GETDATE()'',
	@attach_query_result_as_file=1,
    @subject = ''Test security message'' ;
	 ' AS XML) AS FURTHER_INFO
FROM 
	sys.configurations 
WHERE 
	name = 'Database Mail XPs'


--==============================================================================================
--09 Ole Automation Procedures
--==============================================================================================
INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)

SELECT 
	'09 Ole Automation Procedures' AS MODULE, 
	'Is Ole Automation Procedures disabled' AS Details,
	CASE WHEN VALUE = 0 THEN 'PASS' ELSE 'FAIL' END AS RESULT,
	 CAST(' --the OLE automation stored procedures include: – sp_OACreate – sp_OADestroy – sp_OAGetErrorInfo – sp_OAGetProperty 
-– sp_OAMethod – sp_OAStop – sp_OASetProperty OLE Automation stored procedures can be used to reconfigure the security
-- of other services including IIS (Internet Information Server).
-- so unless there is an explicit reason these should not be enabled 
	 
	 SELECT *
	 FROM 
	sys.configurations 
WHERE 
	name = ''Ole Automation Procedures''
	 ' AS XML) AS FURTHER_INFO
FROM 
	sys.configurations 
WHERE 
	name = 'Ole Automation Procedures'


--==============================================================================================
--10 Test data is obfuscated
--==============================================================================================                           

INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'10 Test data is obfuscated '  AS Module,
		'Check that production data in test /development is obfuscated' As Details,
		 'MANUAL REVIEW' AS Result, 
		 CAST('--Any Data that is copied from production to development or test should be obfuscated
--If backup / restores are created without any additional steps then this will not be the case
		  ' AS XML) AS FURTHER_INFO


--==============================================================================================
--11 remote access
--==============================================================================================
INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)

SELECT 
	'11 remote access' AS MODULE, 
	'Is remote access disabled' AS Details,
	CASE WHEN VALUE = 0 THEN 'PASS' ELSE 'WARNING' END AS RESULT,
	 CAST(' --Microsoft see remote access as a security risk but it is dependent on individual systems
--as to if the server requirement needs to be locked down against access to the server
--this should be reviewed on a server by server basis
	 
	 SELECT *
	 FROM 
	sys.configurations 
WHERE 
	name = ''remote access''
	 ' AS XML) AS FURTHER_INFO
FROM 
	sys.configurations 
WHERE 
	name = 'remote access'


--==============================================================================================
--12 remote admin connections
--==============================================================================================
INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)

SELECT 
	'12 remote admin connections' AS MODULE, 
	'Is remote admin connections' AS Details,
	CASE WHEN VALUE = 0 THEN 'PASS' ELSE 'WARNING' END AS RESULT,
	 CAST(' --Remote admin connections , this should be based on a server by server basis
--Microsoft best practices highlight as a security risk but could compromise
--server recoverability if this is disabled  
	 
	 SELECT *
	 FROM 
	sys.configurations 
WHERE scan
	name = ''remote admin connections''
	 ' AS XML) AS FURTHER_INFO
FROM 
	sys.configurations 
WHERE 
	name = 'remote admin connections'


--==============================================================================================
--13 Scan for startup proc
--==============================================================================================

 
INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
SELECT 
	'13 Scan for startup proc' AS Issue, 
	'Start up procedures can be a security issue as they execute when the SQL Server starts' AS Details,
	CASE WHEN VALUE =1 THEN 'FAIL' ELSE 'PASS' END AS Result, 
	CAST('--Review the start up procedures that are running 
SELECT 
	name,create_date,modify_date
FROM 
	master.sys.procedures
WHERE
		is_auto_executed = 1
	
	' AS XML) AS FURTHER_INFO
FROM 
	master.sys.configurations WHERE name ='scan for startup procs'



--==============================================================================================
--14 Scan for startup proc
--==============================================================================================                           

INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'14 Monitor addition of start-up procedures'  AS Module,
		'Check to monitor addition of start-up procedures are in place' As Details,
		 'MANUAL REVIEW' AS Result, 
		 CAST('--Are there any checks in place to capture startup procedures being added to the system
--Notifications should be configured to ensure any new / amendments to existing start up procedures
--Are audited
		  ' AS XML) AS FURTHER_INFO

--==============================================================================================
--15 SQL Mail XPs
--==============================================================================================

--IF @@Version > 2008 R2 SQL Mail is defunct and if 64 bit


DECLARE @Enabled TINYINT

--if 64bit server sqlmail doesnt work 
SELECT @Enabled =
		CASE 
			WHEN CAST(SERVERPROPERTY('Edition')AS VARCHAR(40)) Like '%64-bit%' THEN 0 ELSE 1 
		END

--If  greater than SQL 2008 R2 SQL Mail is defunct 
SELECT @Enabled=@Enabled+CASE WHEN SUBSTRING(CONVERT(varchar(128), SERVERPROPERTY('ProductVersion')),1,
				CHARINDEX('.',CONVERT(varchar(128), SERVERPROPERTY('ProductVersion')),1)-1 ) > 10
				THEN 0 ELSE 1 
				END

IF @Enabled = 2 -- SQL Mail could be enabled
BEGIN

	INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'15 SQL Mail XPs' AS MODULE, 
		'Is SQL Mail XPs disabled' AS Details,
		CASE WHEN VALUE = 0 THEN 'PASS' ELSE 'FAIL' END AS RESULT,
		 CAST(' --SQL Mail can only be used on SQL2008 R2 systems and earlier 32bit systems
SELECT 
	*
FROM 
	sys.configurations 
WHERE 
	name = ''Database Mail XPs''
	 
	--Review if the SQL server can email externally, database query / fileattachment 
	--as this can be a major security risk if compromised 

		EXEC msdb.dbo.sp_send_dbmail
		@recipients = ''external test account'',
		@body = ''This is a test message to validate external message cant be sent'',
		@query =''SELECT GETDATE()'',
		@attach_query_result_as_file=1,
		@subject = ''Test security message'' ;
		 ' AS XML) AS FURTHER_INFO
	FROM 
		sys.configurations 
	WHERE 
		name = 'SQL Mail XPs'
END
ELSE
BEGIN
	INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'15 SQL Mail XPs' AS MODULE, 
		'Is SQL Mail XPs disabled' AS Details,
		 'PASS'  AS RESULT,
		 CAST(' --SQL Mail can only be used on SQL2008 R2 systems and earlier 32bit systems
SELECT 
	*
FROM 
	sys.configurations 
WHERE 
	name = ''Database Mail XPs''
	 
	--Review if the SQL server can email externally, database query / fileattachment 
	--as this can be a major security risk if compromised 

		EXEC msdb.dbo.sp_send_dbmail
		@recipients = ''external test account'',
		@body = ''This is a test message to validate external message cant be sent'',
		@query =''SELECT GETDATE()'',
		@attach_query_result_as_file=1,
		@subject = ''Test security message'' ;
		 ' AS XML) AS FURTHER_INFO
END

--==============================================================================================
--16 TRUSTWORTHY
--==============================================================================================

DECLARE @is_trustworthy_on INT
SELECT @is_trustworthy_on =count(*)
FROM sys.databases 
WHERE is_trustworthy_on=1 AND Name not in ('Master','MSDB')

INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
SELECT 
	'16 is_trustworthy_on' AS MODULE, 
	'Is is_trustworthy_on on' AS Details,
	CASE WHEN @is_trustworthy_on = 0 THEN 'PASS' ELSE 'FAIL' END AS RESULT,
	 CAST('--TRUSTWORTHY can allow users access to database that they have not got
--explicit permissions to if they are dbo / db_owner of other databases
--MSDB should not have trustworthy set either as this can compromise a server 
--and allow unauthorised code to be executed http://jongurgul.com/blog/tag/trustworthy/  
	 
	 
SELECT name,is_trustworthy_on FROM sys.databases 
WHERE is_trustworthy_on=1
	 ' AS XML) AS FURTHER_INFO


--==============================================================================================
--17 Xp_cmdshell enabled
--==============================================================================================
 
INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)	
	
SELECT 
	'17 Xp_cmdshell enabled' AS Issue ,
	'xp_cmdshell being enabled is a security risk that someone with access to SQL can access other servers' AS Details,
	CASE WHEN VALUE =1 THEN 'FAIL' ELSE 'PASS' END as Result,
	CAST('--Xp_cmdshell can allow SQL access to the operating system and is a known vulnerability for hackers 
sELECT
		*
FROM 
	sys.configurations 
WHERE 
	name =''xp_cmdshell'' 
	
	' AS XML) as FURTHER_INFO
FROM 
	sys.configurations 
WHERE 
	name ='xp_cmdshell' 

--==============================================================================================
--18-28 XP Public permissions 
--==============================================================================================

GO
DECLARE @XPEnabled  INT =0

SELECT
   @XPEnabled =COUNT(*)
FROM    
   sys.database_permissions
WHERE
   OBJECT_NAME(major_ID) IN ('xp_availablemedia','xp_cmdshell',
                             'xp_deletemail','xp_dirtree',
                             'xp_dropwebtask','xp_enumerrorlogs',
                             'xp_enumgroups','xp_findnextmsg',
                             'xp_fixeddrives','xp_getnetname',
                             'xp_logevent','xp_loginconfig',
                             'xp_makewebtask','xp_regread',
                             'xp_readerrorlog','xp_readmail',
                             'xp_runwebtask','xp_sendmail',
                             'xp_servicecontrol','xp_sprintf',
                             'xp_sscanf','xp_startmail',
                             'xp_stopmail','xp_grantlogin',
                             'xp_revokelogin','xp_logininfo',
                             'xp_subdirs','xp_regaddmultistring',
                             'xp_regdeletekey','xp_regdeletevalue',
                             'xp_regenumkeys','xp_regenumvalues',
                             'xp_regremovemultistring','xp_regwrite')
   AND USER_NAME(grantee_principal_id) LIKE 'PUBLIC'



INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)		
SELECT 
	'18-28 XP Public permissions ' AS Issue,
	'Public permissions should not be granted to XPs', 
	CASE WHEN @XPEnabled=0 THEN 'PASS' ELSE 'FAIL' END as Result,
CAST('-- Run the following query for additional information 
SELECT
   OBJECT_NAME(major_id)           AS [Extended Stored Procedure],
   USER_NAME(grantee_principal_id) AS [User]
FROM    
   sys.database_permissions
WHERE
   OBJECT_NAME(major_ID) IN (''xp_availablemedia'',''xp_cmdshell'',
                             ''xp_deletemail'',''xp_dirtree'',
                             ''xp_dropwebtask'',''xp_enumerrorlogs'',
                             ''xp_enumgroups'',''xp_findnextmsg'',
                             ''xp_fixeddrives'',''xp_getnetname'',
                             ''xp_logevent'',''xp_loginconfig'',
                             ''xp_makewebtask'',''xp_regread'',
                             ''xp_readerrorlog'',''xp_readmail'',
                             ''xp_runwebtask'',''xp_sendmail'',
                             ''xp_servicecontrol'',''xp_sprintf'',
                             ''xp_sscanf'',''xp_startmail'',
                             ''xp_stopmail'',''xp_grantlogin'',
                             ''xp_revokelogin'',''xp_logininfo'',
                             ''xp_subdirs'',''xp_regaddmultistring'',
                             ''xp_regdeletekey'',''xp_regdeletevalue'',
                             ''xp_regenumkeys'',''xp_regenumvalues'',
                             ''xp_regremovemultistring'',''xp_regwrite'')
   AND USER_NAME(grantee_principal_id) LIKE ''PUBLIC''
ORDER BY 1;
		   
''' AS XML)


--==============================================================================================
--29 SQL Server service accounts- Local Admins
--==============================================================================================                           

INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'29 SQL Server service accounts are not members of the local administrators group'  AS Module,
		'Service accounts do not need to be local administrators' As Details,
		 'MANUAL REVIEW' AS Result, 
		 CAST('--Review the Local Administrator group to check that the SQL service / Agent Account
--are not in this group. If they are need to be reviewed access the account needs and 
--permissions changed accordingly 
		  ' AS XML) AS FURTHER_INFO


--==============================================================================================
--30 SQL Server service accounts - Domain Admins
--==============================================================================================                           

INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'30 SQL Server service accounts are not members of the Domain administrators group'  AS Module,
		'Service accounts do not need to be domain administrators' As Details,
		 'MANUAL REVIEW' AS Result, 
		 CAST('--Review the Domain Administrator group to check that the SQL service / Agent Account
--are not in this group. If they are need to be reviewed access the account needs and 
--permissions changed accordingly 
		  ' AS XML) AS FURTHER_INFO

--==============================================================================================
--31 SQL Server service accounts - Service account have minimum permissions required
--=============================================================================================                           

GO

DECLARE @ServiceAccountSyadmin INT =0

DECLARE 
	 @ServiceAccount VARCHAR(100)  
	,@RegistryKey NVARCHAR(1000)
	,@StartupState INT
	,@ServerInstance VARCHAR(32)
	,@AgentAccount VARCHAR(100)  

SELECT  @ServerInstance=CAST(SERVERPROPERTY('InstanceName') AS VARCHAR(32))

IF @ServerInstance IS NULL
SELECT @RegistryKey = 'SYSTEM\CurrentControlSet\Services\MSSQLSERVER'
ELSE
SELECT @RegistryKey = 'SYSTEM\CurrentControlSet\Services\MSSQL$' + @ServerInstance


EXECUTE master.dbo.xp_instance_regread  
		 N'HKEY_LOCAL_MACHINE'
		,@RegistryKey
		,N'ObjectName'
		,@ServiceAccount OUTPUT

DECLARE
	 @ConfigItem VARCHAR(30)
	,@ActualSetting VARCHAR(30)
SELECT 	
	 @ConfigItem = 'SQL Service Account Startup'


IF @ServerInstance IS NULL
SELECT @RegistryKey = 'SYSTEM\CurrentControlSet\Services\MSSQLSERVER'
ELSE
SELECT @RegistryKey = 'SYSTEM\CurrentControlSet\Services\MSSQL$' + @ServerInstance

EXECUTE master..xp_instance_regread 
	 N'HKEY_LOCAL_MACHINE'
	,@RegistryKey
	,N'Start'
	,@StartupState OUTPUT


SELECT 
	@ActualSetting = 	CASE @StartupState
					WHEN 2 THEN 'Automatic'
					WHEN 3 THEN 'Manual'
					WHEN 4 THEN 'Disabled'
				END

IF @ServerInstance IS NULL
SELECT @RegistryKey = 'SYSTEM\CurrentControlSet\Services\SQLSERVERAGENT'
ELSE
SELECT @RegistryKey = 'SYSTEM\CurrentControlSet\Services\SQLAGENT$' + @ServerInstance

EXECUTE master..xp_instance_regread 
	 N'HKEY_LOCAL_MACHINE'
	,@RegistryKey
	,N'Start'
	,@StartupState OUTPUT

EXECUTE master.dbo.xp_instance_regread  
		 N'HKEY_LOCAL_MACHINE'
		,@RegistryKey
		,N'ObjectName'
		,@AgentAccount OUTPUT

SELECT 
	@ServiceAccountSyadmin= COUNT(*) 
FROM 
		sys.server_role_members rm
	JOIN
		sys.server_principals lgn  ON rm.member_principal_id = lgn.principal_id  
   WHERE 
			lgn.name IN (@AgentAccount,@ServiceAccount)
 
 INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)		
SELECT 
	'31 Service Account has Sysamin' AS Issue,
	'SQL Accounts should be least privilege permissions and should not have Sysadmin', 
	CASE WHEN @ServiceAccountSyadmin=0 THEN 'PASS' ELSE 'FAIL' END as Result,
	CAST(' --Review the following query for additional information 

  SELECT 
		''ServerRole'' = SUSER_NAME(rm.role_principal_id),
		 ''MemberName'' = lgn.name
		  ,type_desc
   FROM 
		sys.server_role_members rm
	JOIN
		sys.server_principals lgn  ON rm.member_principal_id = lgn.principal_id  
  'AS XML)

--==============================================================================================
--32 SQL Server service accounts - 
--SQL Service accounts should use a domain based service accounts and not use The Local System and Network Service accounts  

--=============================================================================================                           

INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'32 SQL Server service accounts use a domain based service accounts'  AS Module,
		'SQL Service accounts should use a domain based service accounts ' As Details,
		 'MANUAL REVIEW' AS Result, 
		 CAST('--Review the Service account permissions on the server. 
--SQL Service accounts should use a domain based service accounts and not use the Local System
-- and Network Service accounts  

		  ' AS XML) AS FURTHER_INFO

--==============================================================================================
--33 SQL Server service accounts - Service account have minimum permissions required
--=============================================================================================                           

INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'33 SQL Agent and SQL Server service account should be different accounts'  AS Module,
		'Service accounts should not be run under the same account' As Details,
		 'MANUAL REVIEW' AS Result, 
		 CAST('--Review the Service account permissions on the server. 
--to ensure the accounts used are not the same 

GO

DECLARE @ServiceAccountSyadmin INT =0

DECLARE 
	 @ServiceAccount VARCHAR(100)  
	,@RegistryKey NVARCHAR(1000)
	,@StartupState INT
	,@ServerInstance VARCHAR(32)
	,@AgentAccount VARCHAR(100)  

SELECT  @ServerInstance=CAST(SERVERPROPERTY(''InstanceName'') AS VARCHAR(32))

IF @ServerInstance IS NULL
SELECT @RegistryKey = ''SYSTEM\CurrentControlSet\Services\MSSQLSERVER''
ELSE
SELECT @RegistryKey = ''SYSTEM\CurrentControlSet\Services\MSSQL$'' + @ServerInstance


EXECUTE master.dbo.xp_instance_regread  
		 N''HKEY_LOCAL_MACHINE''
		,@RegistryKey
		,N''ObjectName''
		,@ServiceAccount OUTPUT

DECLARE
	 @ConfigItem VARCHAR(30)
	,@ActualSetting VARCHAR(30)
SELECT 	
	 @ConfigItem = ''SQL Service Account Startup''


IF @ServerInstance IS NULL
SELECT @RegistryKey = ''SYSTEM\CurrentControlSet\Services\MSSQLSERVER''
ELSE
SELECT @RegistryKey = ''SYSTEM\CurrentControlSet\Services\MSSQL$'' + @ServerInstance

EXECUTE master..xp_instance_regread 
	 N''HKEY_LOCAL_MACHINE''
	,@RegistryKey
	,N''Start''
	,@StartupState OUTPUT


SELECT 
	@ActualSetting = 	CASE @StartupState
					WHEN 2 THEN ''Automatic''
					WHEN 3 THEN ''Manual''
					WHEN 4 THEN ''Disabled''
				END

IF @ServerInstance IS NULL
SELECT @RegistryKey = ''SYSTEM\CurrentControlSet\Services\SQLSERVERAGENT''
ELSE
SELECT @RegistryKey = ''SYSTEM\CurrentControlSet\Services\SQLAGENT$'' + @ServerInstance

EXECUTE master..xp_instance_regread 
	 N''HKEY_LOCAL_MACHINE''
	,@RegistryKey
	,N''Start''
	,@StartupState OUTPUT

EXECUTE master.dbo.xp_instance_regread  
		 N''HKEY_LOCAL_MACHINE''
		,@RegistryKey
		,N''ObjectName''
		,@AgentAccount OUTPUT

SELECT 
		 @@SERVERNAME AS ServerName
		 ,''ServerRole'' = SUSER_NAME(rm.role_principal_id)
		 ,''MemberName'' = lgn.name
		 ,type_desc
		 ,create_date
		 ,modify_date
		 ,default_database_name
		 ,default_language_name
FROM 
		sys.server_role_members rm
	JOIN
		sys.server_principals lgn  ON rm.member_principal_id = lgn.principal_id  
   WHERE 
		 lgn.name IN (@AgentAccount,@ServiceAccount)


SELECT 
	@AgentAccount AS AgentAccount,
	@ServiceAccount AS ServiceAccount




		  ' AS XML) AS FURTHER_INFO

--==============================================================================================
--34 SQL Server SQL Server browser Service
--=============================================================================================                           

INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'34 SQL Server SQL Server browser Service'  AS Module,
		'SQL Server SQL Server browser Service Usage' As Details,
		 'MANUAL REVIEW' AS Result, 
		 CAST('-- If named instance are not in use and dynamic TC/IP port assignment is in
-- place this is disabled
			   
		  ' AS XML) AS FURTHER_INFO

--==============================================================================================
--35 The SQL Server Active Directory Helper 
--=============================================================================================                           

INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'35 The SQL Server Active Directory Helper  Service'  AS Module,
		'The SQL Server Active Directory Helper  Usage' As Details,
		 'MANUAL REVIEW' AS Result, 
		 CAST('-- If SQL server is not domain joined, or the ability to find SQL instances via 
-- Active Directory is not required, it is this service should be disabled.
			   
		  ' AS XML) AS FURTHER_INFO

--==============================================================================================
--36 The VSS Writer allows service
--=============================================================================================                           

INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'36 The VSS Writer allows service'  AS Module,
		'The VSS Writer allows service Usage' As Details,
		 'MANUAL REVIEW' AS Result, 
		 CAST('-- If volume shadow copy is not in use this this service should be disabled 
		  ' AS XML) AS FURTHER_INFO

--==============================================================================================
--37 Anti-Virus
--=============================================================================================                           

INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'37 Anti-Virus Software'  AS Module,
		'Anti-Virus is installed on the SQL Server' As Details,
		 'MANUAL REVIEW' AS Result, 
		 CAST('-- Anti-Virus software is installed and configured to run on
-- the SQL Server
		  ' AS XML) AS FURTHER_INFO

--==============================================================================================
--38 SQL Server ports (1433,1434)
--=============================================================================================                           

INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'38 SQL Server ports (1433,1434)'  AS Module,
		'Any secure SQL servers default ports should be changed' As Details,
		 'MANUAL REVIEW' AS Result, 
		 CAST('-- If the SQL Server in question is a highly secure system changing the default port
-- should be considered 
		  ' AS XML) AS FURTHER_INFO


--=============================================================================================                           
--39 SQL Server install file permissions
--=============================================================================================                           

INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'39 SQL Server install file permissions'  AS Module,
		'Are permissions locked down to relevant accounts' As Details,
		 'MANUAL REVIEW' AS Result, 
		 CAST('-- Review permissions on the SQL install folders to ensure that they are
-- not open and locked down the minimum permission required
		  ' AS XML) AS FURTHER_INFO

--=============================================================================================                           
--40 SQL Server service packs / hot fixes and patches
--=============================================================================================                           

INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'40 SQL Server service packs / hot fixes and patches'  AS Module,
		'Check server versions and service packs' As Details,
		 'MANUAL REVIEW' AS Result, 
		 CAST('-- Run the following code and review if SP/ CU updates are available 
SELECT  @@VERSION AS [SQL Server and OS Version Info];

 -- http://sqlserverbuilds.blogspot.co.uk/

 -- http://sqlserverupdates.com/
		  ' AS XML) AS FURTHER_INFO


--==============================================================================================
--41 Is Guest user disabled - ok to be enabled in master, tempdb and msdb
--==============================================================================================

GO
IF (SELECT OBJECT_ID('Tempdb.dbo.##Guest')) IS NOT NULL  DROP TABLE ##Guest
CREATE TABLE ##Guest 
  (          
	    Name		 VARCHAR(255),
	    grantee_name VARCHAR(255),
	    Permission	VARCHAR(255)
   )   

EXEC master.dbo.sp_msForEachDB ' USE [?] INSERT INTO ##Guest
SELECT DB_NAME(),prins.name AS grantee_name, perms.permission_name
FROM   sys.database_permissions AS perms
JOIN   sys.database_principals AS prins
ON     perms.grantee_principal_id = prins.principal_id
WHERE  prins.name = ''guest'' AND perms.permission_name = ''CONNECT'';'

 
 
 
DECLARE @GuestAccounts INT =0

SELECT  @GuestAccounts=COUNT(*) FROM ##Guest
WHERE Name Not in ('MSDB','tempdb','master')

  
 
INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)		
SELECT 
	'41 Is Guest user disabled ' AS Issue,
	'SQL Accounts should be least privilege permissions and should not have Sysadmin', 
	CASE WHEN @GuestAccounts=0 THEN 'PASS' ELSE 'FAIL' END as Result,
	CAST('--The guest user cannot be dropped but it can be disabled by revoking the CONNECT permission
-- however you should not revoke guest permissions against MSDB, Master and TempDB
-- The guest user could be required for the distribution 
-- database see https://msdn.microsoft.com/en-us/library/ms151868.aspx for more information
		SELECT * FROM ##Guest
	  ' AS XML)

--==============================================================================================
--42 Example databases
--==============================================================================================

INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
SELECT 
	'42 Example databases ' AS MODULE, 
	'Are example databases Installed ' AS Details,
	CASE WHEN count(*) =0 THEN 'PASS' ELSE 'FAIL' END AS RESULT,
CAST('--System database should not be on production servers
		SELECT name FROM Master.dbo.sysdatabases 
WHERE NAME like ''Adventure%'' or Name like ''North%''
	 ' AS XML) AS FURTHER_INFO		
FROM Master.dbo.sysdatabases 
WHERE NAME like 'Adventure%' or Name like 'North%'


--==============================================================================================
--43 SQL Proxy -SQL Proxy
--==============================================================================================
INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'43 SQL Proxy SQL Proxy exists'  AS Module,
		'Check if Proxy accounts are being used ' As Details,
		 'MANUAL REVIEW' AS Result, 
		 CAST('--Proxy accounts offer a security option for running the SQL Server Agent 
-- Sometimes SQL Server Agent could need elevated permissions to run some of the tasks it need to run
-- rather than give local admin access, you can use a proxy account to limit the permission necessary    

SELECT 
	* 
FROM 
	[sys].[credentials]

SELECT 
	* 
FROM 
	MSDB.dbo.sysproxies 
 
		  ' AS XML) AS FURTHER_INFO
--==============================================================================================
--44 SQL Server proxy account has minimum privileges needed  
--==============================================================================================
INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'44 SQL Server proxy account permissions '  AS Module,
		'Check that any proxy account have specific permissions ' As Details,
		 'MANUAL REVIEW' AS Result, 
		 CAST('--If proxy accounts are configured review the permissions that the account have
--run the following query to find the jobs and jobsteps that are using a proxy. review what these jobs are doing
--checking permissions on folders and permissions the proxy account has 			   
SELECT 
	j.Name As JobName,
	s.step_name As StepName,
	j.enabled As JobEnabled,
	p.name AS ProxyName 
FROM 
	MSDB.dbo.sysjobs j JOIN MSDB.dbo.sysjobsteps S on J.job_id=s.job_id
JOIN  
	MSDB.dbo.sysproxies p ON p.proxy_id =s.proxy_id
WHERE 
	s.proxy_id IS NOT NULL

SELECT 
	* 
FROM 
	[sys].[credentials]

SELECT 
	* 
FROM 
	MSDB.dbo.sysproxies 		
' AS XML) AS FURTHER_INFO




--==============================================================================================
--45 SQL Error Logs are collated into a central location
--==============================================================================================
INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'45 SQL Server Error log'  AS Module,
		'Review if SQL error logs are available in central location' As Details,
		 'MANUAL REVIEW' AS Result, 
		 CAST('--Check if there is anything in place to collate SQL error logs / Operating systems into a central repository  
--If the server is being monitored by Spotlight or other monitoring tools then it possible logs are captured in realtime
--this allows if a server is compromised there is a potential audit trail 
' AS XML) AS FURTHER_INFO
--==============================================================================================
--46 Database Encryption
--==============================================================================================
INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'46 Database Encryption'  AS Module,
		'Should Database be encrypted if so are they?' As Details,
		 'MANUAL REVIEW' AS Result, 
		 CAST('--Is there a requirement to encrypt the database, this will need to be evaluated  
--Additionally  if TDE Transparent database encryption is a requirement, this is an enterprise feature
--check the server version 

SELECT @@VERSION  

--Also check if TDE is enabled 

SELECT 
CASE WHEN encryption_state  =   0 THEN ''No database encryption key present, no encryption''
	WHEN encryption_state	= 	1 THEN ''Unencrypted''
	WHEN encryption_state	=   2 THEN ''Encryption in progress''
	WHEN encryption_state	=   3 THEN ''Encrypted''
	WHEN encryption_state	=   4 THEN ''Key change in progress''
	WHEN encryption_state	=   5 THEN ''Decryption in progress''
	WHEN encryption_state	=   6 THEN ''Protection change in progress (The certificate or asymmetric key that is encrypting the database encryption key is being changed.)''
END,
* FROM sys.dm_database_encryption_keys
		  ' AS XML) AS FURTHER_INFO

--==============================================================================================
--47 Linked Servers -permissions locked down to minimal required permissions
--48 Linked Servers -windows authentication permissions 
--49 Linked Servers  -Are ad hoc queries through linked servers disabled 
--==============================================================================================
GO
DECLARE @no_linkedservers INT =0

SELECT @no_linkedservers=COUNT(*) from sys.servers
WHERE is_linked <> 0 

INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)		
SELECT 
	'47-49 Linked servers ' AS Issue,
	'Linked servers can be a security risk these should be investigated further', 
	CASE WHEN @no_linkedservers=0 THEN 'PASS' ELSE 'WARNING' END as Result,
	CAST('--The following query lists all the linked servers this should be reviewed
		   
		SELECT 
			 name, 
			 product, 
			 provider, 
			 data_source,   
			 is_linked, 
			 is_remote_login_enabled, 
			 is_rpc_out_enabled, 
			 is_data_access_enabled, 
			 is_system, 
			 is_publisher, 
			 is_subscriber, 
			 is_distributor, 
			 is_nonsql_subscriber, 
			 is_remote_proc_transaction_promotion_enabled, 
			 modify_date
		FROM  
			sys.servers

	SELECT * FROM Sys.configurations
	  where name =''Ad Hoc Distributed Queries''
	  ' AS XML)
--==============================================================================================
--50 Authentication settings Windows Authentication should be used over mixed mode
--==============================================================================================

INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'50 Windows Authentication should be used over mixed mode '  AS Module,
		'Best practice guidelines for Authentication Settings' As Details,
		 'MANUAL REVIEW' AS Result, 
		 CAST('--Best practices is that Windows Authentication is used over mixed mode
--this can however not be optional as many applications required mixed mode. 
--this should be flagged up as a warning  

SELECT 
	CASE SERVERPROPERTY(''IsIntegratedSecurityOnly'')   
		WHEN 1 THEN ''Windows Authentication''   
		WHEN 0 THEN ''Windows and SQL Server Authentication''  
	END as [Authentication Mode]
' AS XML) AS FURTHER_INFO

--==============================================================================================
--51 Authentication settings sa account is disabled
--==============================================================================================

INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'51 Authentication settings sa account is disabled '  AS Module,
		'Best practices are the SA is disabled' As Details,
		 'MANUAL REVIEW' AS Result, 
		 CAST('--If authentication mode is Windows and SQL Server Authentication best security
--practices are that the sa account is disabled 

SELECT 
	CASE SERVERPROPERTY(''IsIntegratedSecurityOnly'')   
		WHEN 1 THEN ''Windows Authentication''   
		WHEN 0 THEN ''Windows and SQL Server Authentication''  
	END as [Authentication Mode

--Check if SA account exists. If so recommendation this is renamed 
SELECT * FROM sys.server_principals where is_disabled =1
		  ' AS XML) AS FURTHER_INFO

--==============================================================================================
--52 Authentication settings sa account is renamed
--==============================================================================================

INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'52 Authentication settings sa account is renamed '  AS Module,
		'Best practices are SA account is renamed to remove a known vunrebility  ' As Details,
		 'MANUAL REVIEW' AS Result, 
		 CAST('--If authentication mode is Windows and SQL Server Authentication best security
--practices are that the sa account is renamed 

SELECT 
	CASE SERVERPROPERTY(''IsIntegratedSecurityOnly'')   
		WHEN 1 THEN ''Windows Authentication''   
		WHEN 0 THEN ''Windows and SQL Server Authentication''  
	END as [Authentication Mode

--Check if SA account exists. If so recommendation this is renamed 
SELECT * FROM sys.server_principals where name =''sa''
		  ' AS XML) AS FURTHER_INFO

--==============================================================================================
--53 Authentication settings CHECK_POLICY should be set for each mixed 
--==============================================================================================

INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
SELECT 
		'53 Authentication settings CHECK_POLICY should be set for each mixed mode account '  AS Module,
		'CHECK_POLICY should be set for SQL logins following best practice ' As Details,
		CASE WHEN SUM(CAST(is_policy_checked AS INT)) > 0 THEN 'FAIL' ELSE 'PASS' END AS Result,
		 CAST('--Review the following scripts 
--Allows SQL Server to use Windows password policy mechanisms. 
--SQL Server can use Windows password policy mechanisms.
--the password history is initialized and maintained so when changes occur they can be reviewed

SELECT 
	Name,
	is_policy_checked,
	*
FROM 
	master.sys.sql_logins
WHERE
	type_desc =''SQL_LOGIN''
AND
	is_policy_checked=0
		  ' AS XML) AS FURTHER_INFO
FROM master.sys.sql_logins



--==============================================================================================
--54 Authentication settings Enforce password expiration is not ticked
--==============================================================================================
DECLARE @SettoExpire INT 

SELECT 
	@SettoExpire=COUNT(*)
FROM 
	master.sys.sql_logins
WHERE 
	is_expiration_checked =1

 
INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
SELECT
	'54 Are any passwords set to expire' AS Issue, 
	'There can be issues with account expiring unknown to the users' AS details,
	CASE WHEN @SettoExpire > 0 THEN 'FAIL' ELSE 'PASS' END AS Result,
		 CAST('--The following code will show any accounts that are due to expire and when
		 SELECT
				name,type_desc,
				create_date,
				modify_date,
				is_expiration_checked,
				LOGINPROPERTY(Name,''DaysUntilExpiration'') DaysUntilExpiration
		FROM 
				master.sys.sql_logins
		WHERE 
				is_expiration_checked =1
		 
		 ' AS XML) AS FURTHER_INFO

--==============================================================================================
--55 Authentication settings -Users must change password at next login  is not ticked
--==============================================================================================
INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'55 Users must change password at next login'  AS Module,
		'Password set to be changed should not exist for SQL logins ' As Details,
CASE WHEN SUM(CAST(LOGINPROPERTY(Name,'IsMustChange') AS INT)) > 0 THEN 'FAIL' ELSE 'PASS' END AS Result,
		 CAST('--Passwords should not be set to change at next login for SQL accounts 
			   -- 
SELECT 
		name,type_desc,
		create_date,
		modify_date,
		LOGINPROPERTY(Name,''IsMustChange'') IsMustChange
FROM 
		master.sys.sql_logins
	WHERE 
		LOGINPROPERTY(Name,''IsMustChange'') !=0
		  ' AS XML) AS FURTHER_INFO
FROM 
		master.sys.sql_logins

			
--==============================================================================================
--56 Sysadmin  settings -Only required privileged  users are Sysadmin 
--==============================================================================================
INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'56 Sysadmin Only required privileged users are Sysadmin '  AS Module,
		'Sysadmin should be locked down to the minimum number of users ' As Details,
		 'MANUAL REVIEW' AS Result, 
		 CAST('--Review the output of the following query 
--ascertain the users / groups that should have sysadmin access and highlight
--any of the values returned that shouldnt have sysadmin access 
 
 SELECT 
		 @@SERVERNAME AS ServerName
		 ,''ServerRole'' = SUSER_NAME(rm.role_principal_id)
		 ,''MemberName'' = lgn.name
		 ,type_desc
		 ,create_date
		 ,modify_date
		 ,default_database_name
		 ,default_language_name
  FROM 
		sys.server_role_members rm
	LEFT JOIN
		sys.server_principals lgn  ON rm.member_principal_id = lgn.principal_id  
  ORDER BY 			
		lgn.type_desc
		  ' AS XML) AS FURTHER_INFO
--==============================================================================================
--57 Sysadmin anonymous accounts have Sysadmin access
--==============================================================================================
INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
SELECT 
		'57 Sysadmin anonymous accounts have Sysadmin access'  AS Module,
		'Anonymous accounts should not have sysadmin access' As Details,
		 'MANUAL REVIEW' AS Result, 
		 CAST('--Admin acounts should be trackable back to individuals
--Accounts such as ReportUser which many people use should not have sysadmin access 
 SELECT 
		 @@SERVERNAME AS ServerName
		 ,''ServerRole'' = SUSER_NAME(rm.role_principal_id)
		 ,''MemberName'' = lgn.name
		 ,type_desc
		 ,create_date
		 ,modify_date
		 ,default_database_name
		 ,default_language_name
  FROM 
		sys.server_role_members rm
	LEFT JOIN
		sys.server_principals lgn  ON rm.member_principal_id = lgn.principal_id  
  ORDER BY 			
		lgn.type_desc
		  ' AS XML) AS FURTHER_INFO
		
--==============================================================================================
--58 No AD users / groups exist outside the privileged ‘SQL Administrators’ AD group
--==============================================================================================
INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'58 No AD users / groups exist outside the privileged ‘SQL Administrators’ AD group'  AS Module,
		'An AD group should be configured for Sysadmin users  ' As Details,
		 'MANUAL REVIEW' AS Result, 
		 CAST('--Review any users / groups that have sysadmin out side the an authorised
--sysadmin group such as "SQL Administrators" for example 
 SELECT 
		 @@SERVERNAME AS ServerName
		 ,''ServerRole'' = SUSER_NAME(rm.role_principal_id)
		 ,''MemberName'' = lgn.name
		 ,type_desc
		 ,create_date
		 ,modify_date
		 ,default_database_name
		 ,default_language_name
  FROM 
		sys.server_role_members rm
	LEFT JOIN
		sys.server_principals lgn  ON rm.member_principal_id = lgn.principal_id  
  ORDER BY 			
		lgn.type_desc
		  ' AS XML) AS FURTHER_INFO

--==============================================================================================
--59 BUILTIN\Administrators does not exist
--==============================================================================================

	DECLARE @BulkAdmin INT

	SELECT @BulkAdmin =count(*) 
	FROM master.dbo.syslogins 
	WHERE [NAME] = 'BUILTIN\Administrators' 

	INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'59 BUILTIN\Administrators Exists '  AS Module,
		'BUILTIN\Administrators Existing can be a security riska and should be removed' As Details,
		CASE WHEN  @BulkAdmin=1 THEN 'FAIL' ELSE 'PASS' END AS Result, 
		 CAST('--The 01 BUILTIN\Administrators account was installed by default in Legacy versions
--of SQL server. If it still exists this should be looked into being removed
--Consideration should be taken before removing to ensure genuine sysadmin accounts are not removed
		  ' AS XML) AS FURTHER_INFO
--==============================================================================================
--60 Backups are on a secure network share
--==============================================================================================
INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'60 Backups are on a secure network share'  AS Module,
		'Backup locations should not be on local drives / should offer redundancy' As Details,
		 'MANUAL REVIEW' AS Result, 
		 CAST('--Check location of backup files, these should not be on local disks but on  
--a secure network share
--run the following loactions to get backup locations 

			   SELECT DISTINCT 
	database_name,
	REVERSE(SUBSTRING(REVERSE(physical_device_name),CHARINDEX(''\'',REVERSE(physical_device_name))+1, LEN(physical_device_name)))
FROM 
		[msdb].[dbo].[backupset] a
JOIN 
		[msdb].[dbo].[backupmediafamily] b ON a.media_set_id=b.media_set_id

SELECT  
	database_name
	,REVERSE(SUBSTRING(REVERSE(physical_device_name),CHARINDEX(''\'',REVERSE(physical_device_name))+1, LEN(physical_device_name)))
	,MAX(backup_start_date) As LastBackupDate
FROM 
		[msdb].[dbo].[backupset] a
JOIN 
		[msdb].[dbo].[backupmediafamily] b ON a.media_set_id=b.media_set_id
WHERE backup_start_date [ Enter Greater than and a date to check against ]
GROUP BY
	database_name
	,REVERSE(SUBSTRING(REVERSE(physical_device_name),CHARINDEX(''\'',REVERSE(physical_device_name))+1, LEN(physical_device_name)))
ORDER BY database_name	
		 ,REVERSE(SUBSTRING(REVERSE(physical_device_name),CHARINDEX(''\'',REVERSE(physical_device_name))+1, LEN(physical_device_name)))

		  ' AS XML) AS FURTHER_INFO
GO
--==============================================================================================
--61 Privileged users  and service accounts only have access
--==============================================================================================
INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'61 Privileged users and service accounts backup permissions'  AS Module,
		'Only Privileged users and service accounts  should have access to backup shares' As Details,
		 'MANUAL REVIEW' AS Result, 
		 CAST('--Check permissions on locations of backup files, 
--These should be privileged users only 
--run the following loactions to get backup locations 

SELECT DISTINCT 
	database_name,
	REVERSE(SUBSTRING(REVERSE(physical_device_name),CHARINDEX(''\'',REVERSE(physical_device_name))+1, LEN(physical_device_name)))
FROM 
	[msdb].[dbo].[backupset] a
JOIN 
	[msdb].[dbo].[backupmediafamily] b ON a.media_set_id=b.media_set_id 
		  ' AS XML) AS FURTHER_INFO

GO
--==============================================================================================
--62 No backup / restore routines are in place to put production data into development / test environments
--==============================================================================================
INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'62 No backup / restore routines are in place for Dev/Test'  AS Module,
		'Production Data should not be restored to test without being de-productionised ' As Details,
		 'MANUAL REVIEW' AS Result, 
		 CAST('--Check that restores are not taking place from production to test environment 
--This could involve speaking with development teams to ascertain if production data is used in test
--and the process for this
		  ' AS XML) AS FURTHER_INFO
GO
--==============================================================================================
--63 db_backupoperator Access
--==============================================================================================
INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'63 db_backupoperator Access'  AS Module,
		'Review who has access to backup databases' As Details,
		 'MANUAL REVIEW' AS Result, 
		 CAST('--Review users that have access to db_backupoperator group 
--to ensure it matches what is expected

SELECT ROL.name AS RoleName
      ,MEM.name AS MemberName
      ,MEM.type_desc AS MemberType
      ,MEM.default_schema_name AS DefaultSchema
      ,SP.name AS ServerLogin
FROM sys.database_role_members AS DRM
     INNER JOIN sys.database_principals AS ROL
         ON DRM.role_principal_id = ROL.principal_id
     INNER JOIN sys.database_principals AS MEM
         ON DRM.member_principal_id = MEM.principal_id
     INNER JOIN sys.server_principals AS SP
         ON MEM.[sid] = SP.[sid]
ORDER BY RoleName
        ,MemberName;
		  ' AS XML) AS FURTHER_INFO
GO
--==============================================================================================
--64 Replication Running under different accounts
--==============================================================================================
INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'64 Replication running under different accounts'  AS Module,
		' ' As Details,
		 'MANUAL REVIEW' AS Result, 
		 CAST('-- Review following link for replication permissions
--Review accounts that are running replication 
-- This can be achieved through Replication / Launch Replication monitor
-- Drill down into publication and select properties 
-- Select agent properties 
-- 
		  ' AS XML) AS FURTHER_INFO
GO
--==============================================================================================
--65 Replication Agent permissions Are using the minimum permissions required 
--==============================================================================================
INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'65 Replication Agent permissions'  AS Module,
		' ' As Details,
		 'MANUAL REVIEW' AS Result, 
		 CAST('-- Review following link for replication permissions
--Review accounts that are running replication and snapshot folder
-- This can be achieved through Replication Launch Replication monitor
-- Switch to distribution view
-- Drill down into publication and select properties 
-- Select agent properties
-- Check snapshop folders and permission on the folders
-- https://msdn.microsoft.com/en-us/library/ms151868.aspx

		  ' AS XML) AS FURTHER_INFO
GO
--==============================================================================================
--66 Merge Agent and Distribution Agent accounts
--==============================================================================================
INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'66 Merge Agent and Distribution Agent accounts'  AS Module,
		'Merge Agent and Distribution Agent accounts are in the publication access list' As Details,
		 'MANUAL REVIEW' AS Result, 
		 CAST('--Ensure all Merge Agent and Distribution Agent accounts are in the publication access list (PAL).
-- https://msdn.microsoft.com/en-GB/library/ms151153.aspx
-- EXECUTE the following stored procedure on the publisher sp_help_publication_access  @publication =  ''Publication Name''
--check users who have access 

		  ' AS XML) AS FURTHER_INFO
GO
--==============================================================================================
--67 Pull subscriptions
--==============================================================================================
INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'67 Pull subscriptions'  AS Module,
		'If you use pull subscriptions, use a network share rather than a local path for the snapshot folder.' As Details,
		 'MANUAL REVIEW' AS Result, 
		 CAST('-- Check if using pull subscriptions 
--If you use pull subscriptions, use a network share rather than a local path for the snapshot folder. 

SELECT 
	name ,
	mda.publisher_db,
	mda.subscriber_db,
	(CASE  
		WHEN mda.subscription_type =  ''0'' THEN ''Push'' 
		WHEN mda.subscription_type =  ''1'' THEN ''Pull'' 
		WHEN mda.subscription_type =  ''2'' THEN ''Anonymous''
		ELSE CAST(mda.subscription_type AS VARCHAR)
	END) [ReplicationType] 
FROM distribution.dbo.MSdistribution_agents mda
-- 
		  ' AS XML) AS FURTHER_INFO

GO
--==============================================================================================
--68 Replication connections
--==============================================================================================
INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'68 Replication connections'  AS Module,
		'Is is recommended that Server connections are encrypted for a secure environment' As Details,
		 'MANUAL REVIEW' AS Result, 
		 CAST('--Encrypt the connections between computers in a replication topology using an industry standard method, 
--such as Virtual Private Networks (VPN), Secure Sockets Layer (SSL), or IP Security (IPSEC). 
-- 
To check if the configured  to accept encrypted connections
In SQL Server Configuration Manager, expand SQL Server Network Configuration, right-click Protocols for server instance, and then select Properties.
In the Protocols for instance name Properties dialog box, on the Certificate tab, a certificate should have been selected in the box.
		  ' AS XML) AS FURTHER_INFO
GO
--==============================================================================================
--69 Auditing Authorised Schema additions
--==============================================================================================
INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'69 Auditing Authorised Schema additions'  AS Module,
		'Is any auditing of changes made to production changes' As Details,
		 'MANUAL REVIEW' AS Result, 
		 CAST('--Are productions changes, captured   
		  ' AS XML) AS FURTHER_INFO
GO

--==============================================================================================
--70 Auditing Schema changes covered by release / change control
--==============================================================================================
INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'70 Auditing Schema changes'  AS Module,
		'Review Auditing options for schema changes / Change control' As Details,
		 'MANUAL REVIEW' AS Result, 
		 CAST('--Validate if there are scheduled releases and if releases occur out of these time 
-- review database for objects being added
-- Check if any DDL Triggers are enabled 

SELECT * FROM sys.triggers WHERE parent_class_desc = ''DATABASE'' 
		  ' AS XML) AS FURTHER_INFO

GO
--==============================================================================================
--71 Bulk Admin Account is SA
--==============================================================================================

	DECLARE @BulkAdminSA INT =0

  SELECT 
		@BulkAdminSA= count(*)
   FROM 
		sys.server_role_members rm
	JOIN
		sys.server_principals lgn  ON rm.member_principal_id = lgn.principal_id  
   WHERE 
			rm.role_principal_id >=3 AND rm.role_principal_id <=10  
		AND 
			lgn.name ='BUILTIN\Administrators'
 
 
	INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'71 BUILTIN\Administrators is SA '  AS Module,
		'The BUILTIN\Administrators should not if it exists have Sysadmin privileges' As Details,
		CASE WHEN  @BulkAdminSA=1 THEN 'FAIL' ELSE 'PASS' END AS Result, 
		 CAST('--Running the following query allows you to see the Sysadmin users
SELECT 
	ServerRole = SUSER_NAME(rm.role_principal_id),
		MemberName = lgn.name
FROM 
	sys.server_role_members rm
JOIN
	sys.server_principals lgn  ON rm.member_principal_id = lgn.principal_id  
 ' AS XML) AS FURTHER_INFO

	

GO
--==============================================================================================
--72 Login Trace
--==============================================================================================

 
INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)

SELECT 
	'72 Failed login trace running' AS MODULE, 
	'SQL has a default black box trace which is running by default' AS Details,
	CASE WHEN VALUE = 1 THEN 'PASS' ELSE 'FAIL' END AS RESULT,
	 CAST('--If not enabled enable ( ONCE WE HAVE change approved) sp_configure ''default trace enabled'',1 GO RECONFIGURE' AS XML) AS FURTHER_INFO
FROM 
	sys.configurations 
WHERE 
	name = 'default trace enabled'



GO
--==============================================================================================
--73 SQL Logins without enforce password policy set
--
--==============================================================================================

DECLARE @EnforcePassword INT

SELECT 
	@EnforcePassword =COUNT(*)
FROM 
	master.sys.sql_logins
WHERE 
	type_desc='SQL_LOGIN'
AND
	is_policy_checked=0
	

INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)	
SELECT 
	'73 SQL Logins without enforce password policy set' AS Issue,
	'SQL best practices are policy checked is set on SQL login account' AS Details,
	CASE WHEN @EnforcePassword =0 THEN 'PASS' ELSE 'FAIL' END as esult,
	CAST('-- Run the following code
-- to list any accounts that have had a BadPasswordCount
SELECT 
	name,
	create_date,
	modify_date,
	is_policy_checked
FROM 
	master.sys.sql_logins
WHERE 
	type_desc=''SQL_LOGIN''
AND
		is_policy_checked=0
					' AS XML) AS FURTHER_INFO

GO
--==============================================================================================
--74 have any passwords had failed log in 
--Need to check enforce password policy 
--==============================================================================================
DECLARE @BadPasswordCount INT =0

SELECT @BadPasswordCount=CAST(LOGINPROPERTY(Name,'BadPasswordCount') as INT)
FROM 
	master.sys.sql_logins

WHERE LOGINPROPERTY(Name,'BadPasswordCount') <>0

INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)	
SELECT 
	'74 have any passwords had failed log in ' AS Issue,
	'Attempted logins should be review to frequency and last attempted time this
	is only for accounts with check enforce password policy =ON' AS Details,
	CASE WHEN @BadPasswordCount =0 THEN 'PASS' ELSE 'FAIL' END as Result,
	CAST('--Run the following code
		  -- to list any accounts that have had a BadPasswordCount
				SELECT 
					name,type_desc,
					create_date,
					modify_date,
					LOGINPROPERTY(Name,''BadPasswordCount'') BadPasswordCount,
					LOGINPROPERTY(Name,''BadPasswordTime'') BadPasswordTime
				FROM 
					master.sys.sql_logins
				WHERE 
					LOGINPROPERTY(Name,''BadPasswordCount'') !=0
					' AS XML) AS FURTHER_INFO


GO
--==============================================================================================
--75 Password Expired 
--==============================================================================================

DECLARE @ExpiredLogins INT =0

SELECT 
	@ExpiredLogins = COUNT(*)
FROM 
	master.sys.sql_logins
WHERE 
	LOGINPROPERTY(Name,'IsExpired') =1
	
INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)		
SELECT 	
		'75 Password Expired' AS Issue,
		'Accounts that are expired should be removed if not required' AS details,
		CASE WHEN @ExpiredLogins=0 THEN 'PASS' ELSE 'FAIL' END AS Result,
		CAST('--Review following code
SELECT 
	name,type_desc,
	create_date,
	modify_date,
	LOGINPROPERTY(Name,''IsExpired'') PasswordExpired
FROM 
	master.sys.sql_logins
WHERE 
	LOGINPROPERTY(Name,''IsExpired'') =1' AS XML) AS FURTHER_INFO


GO 
--==============================================================================================
--76 have passwords been reset in last month
--==============================================================================================

DECLARE @PasswordReset INT =0

SELECT @PasswordReset =COUNT(*)
FROM 
	master.sys.sql_logins
WHERE 
	LOGINPROPERTY(Name,'PasswordLastSetTime')  > DATEADD(month,-1,GETDATE())

INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)		
SELECT 
	'76 have passwords been reset in last month' AS Issue,
	'Passwords that have been reset should be reviewed that this is not an issue ', 
	CASE WHEN @PasswordReset=0 THEN 'PASS' ELSE 'WARNING' END as Result,
	CAST('--Review the list of accounts returned with the following query
	SELECT 
		name,
		create_date,
		modify_date,
		LOGINPROPERTY(Name,''PasswordLastSetTime'')  AS PasswordLastSetTime
	FROM 
		master.sys.sql_logins
	WHERE 
		LOGINPROPERTY(Name,''PasswordLastSetTime'')  BETWEEN  DATEADD(month,-1,GETDATE()) AND GETDATE()		
		'AS XML)
	
GO
--==============================================================================================
--77 Any orphaned users across the databases
--==============================================================================================


DECLARE @orphanedUsers INT =0

IF (SELECT OBJECT_ID('Tempdb.dbo.##Logins')) IS NOT NULL  DROP TABLE ##Logins
CREATE TABLE ##Logins
  (          
	    Name		 VARCHAR(255),
	    USID		 VARCHAR(255),
	    DBName		VARCHAR(255)
	    
   )   

DECLARE @Database TABLE ( ID INT IDENTITY(1,1), DBname Sysname)
DECLARE @DbName Sysname

INSERT INTO @Database (Dbname)
SELECT Name FROM sys.databases WHERE state_desc ='ONLINE'
WHILE (SELECT COUNT(*) FROM @Database) > 0 
	BEGIN
		SELECT TOP (1) @DbName=[DBName] FROM @Database
		EXEC ('USE ['+ @DbName+ '] INSERT ##Logins(Name,USID) EXEC sp_change_users_login ''report''')
		EXEC ('USE ['+ @DbName+ '] UPDATE ##Logins SET DbName =db_name() WHERE DBName IS NULL')
	
		DELETE FROM @Database WHERE DBname =@DbName
	END 

SELECT @orphanedUsers=count(*) FROM ##Logins

INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)			
SELECT 
	'77 Orphaned User' AS Issue,
	'Security best practices are orphaned used should be removed from the server these should be investigated further', 
	CASE WHEN @orphanedUsers=0 THEN 'PASS' ELSE 'FAIL' END as Result,
	CAST('--The following query lists all the logins with orphaned users to be reviewed
		   
SELECT 
		*
FROM  
	##Logins
	  ' AS XML)
	  
GO	
--==============================================================================================
--78 C2 Auditing not enabled
--==============================================================================================

GO
DECLARE @C2Auditing  INT =0

SELECT @C2Auditing = CAST(VALUE AS INT) FROM sys.configurations WHERE name ='c2 audit mode'

INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)		
SELECT 
	'78 C2 Auditing ' AS Issue,
	'C2 Auditing gives a higher level of security, it is not appropriate for all systems ', 
	CASE WHEN @C2Auditing=0 THEN 'Auditing OFF' ELSE 'Auditing ON' END as Result,
	CAST('--More details
--This feature will be removed in a future version of Microsoft SQL Server. 
--Avoid using this feature in new development work, and plan to modify applications 
--that currently use this feature. The C2 security standard has been superseded by Common Criteria Certification
-- https://msdn.microsoft.com/en-us/library/ms187634.aspx		   
	  ' AS XML)

--==============================================================================================
--79 Windows Firewall not enabled
--==============================================================================================


INSERT INTO #SecurityCheck (MODULE,Details,RESULT,Further_info)
	SELECT 
		'79 Windows Firewall is not enabled'  AS Module,
		'Firewalls should be used on SQL servers' As Details,
		 'MANUAL REVIEW' AS Result, 
		 CAST('--type Firewall from run box on server and check windows firewall is active
-- or a 3rd party firewall is in use.
			   
		  ' AS XML) AS FURTHER_INFO

SELECT * FROM #SecurityCheck
ORDER BY 1  


GO
