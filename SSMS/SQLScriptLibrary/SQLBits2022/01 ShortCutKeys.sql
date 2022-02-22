/* My most useful short cut (at the moment) */
USE [AdventureWorks2019]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [HumanResources].[vEmployeeDepartment] 
AS 
SELECT 
    e.[BusinessEntityID] 
    ,p.[Title] 
    ,p.[FirstName] 
    ,p.[MiddleName] 
    ,p.[LastName] 
    ,p.[Suffix] 
    ,e.[JobTitle]
    ,d.[Name] AS [Department] 
    ,d.[GroupName] 
    ,edh.[StartDate] 
FROM [HumanResources].[Employee] e
	INNER JOIN [Person].[Person] p
	ON p.[BusinessEntityID] = e.[BusinessEntityID]
    INNER JOIN [HumanResources].[EmployeeDepartmentHistory] edh 
    ON e.[BusinessEntityID] = edh.[BusinessEntityID] 
    INNER JOIN [HumanResources].[Department] d 
    ON edh.[DepartmentID] = d.[DepartmentID] 
WHERE edh.EndDate IS NULL
GO


/* Which might end up replaced by this..... */
USE StackOverflow2010
GO

SELECT TOP (1000) [Id]
      ,[AcceptedAnswerId]
      ,[AnswerCount]
      ,[Body]
      ,[ClosedDate]
      ,[CommentCount]
      ,[CommunityOwnedDate]
      ,[CreationDate]
      ,[FavoriteCount]
      ,[LastActivityDate]
      ,[LastEditDate]
      ,[LastEditorDisplayName]
      ,[LastEditorUserId]
      ,[OwnerUserId]
      ,[ParentId]
      ,[PostTypeId]
      ,[Score] --
      ,[Tags]
      ,[Title]
      ,[ViewCount]
  FROM [StackOverflow2010].[dbo].[Posts]

