/*

Open up C:\SQLScriptsLibrary\SSMS\SQLScriptLibrary\Security\01_Security_Audit.sql

browse to https://github.com/martincroft

open up the folder with all the notebooks in
open up the Glenn Berry scripts for SQL 2019


Open solution and close solution explorer

remove everything not needed from quick access

start zoomit
check setting haven't changed 

kill teams

kill slack

close outlook 



*/


-- This was used to create blocking scenario, running multiple procedures at the same time, called from 
--powershell to all concurrent connections
USE AdventureWorks2019
GO
DROP TABLE IF EXISTS CurrentStatus 
GO

CREATE TABLE CurrentStatus (CurrentValue INT)
INSERT INTO CurrentStatus VALUES (0)


select * from CurrentStatus

DROP TABLE IF EXISTS ProceduresToRun
GO
CREATE TABLE ProceduresToRun (name varchar(30))
GO
insert into ProceduresToRun values('uspDemoProcedure')
go 64


