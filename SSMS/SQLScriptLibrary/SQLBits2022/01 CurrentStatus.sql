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





