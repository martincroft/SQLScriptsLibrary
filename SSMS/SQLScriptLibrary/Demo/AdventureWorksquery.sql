USE AdventureWorks2019
GO
DROP PROC IF EXISTS uspDemoProcedure
GO

CREATE PROC uspDemoProcedure
AS
SET NOCOUNT ON
BEGIN TRAN

DECLARE @StartTime DATETIME = GETDATE()

DROP TABLE IF EXISTS #Results

CREATE TABLE [dbo].#Results(
	[SalesOrderID] [int] NOT NULL,
	[SalesOrderDetailID] [int] NOT NULL,
	[CarrierTrackingNumber] [nvarchar](25) NULL,
	[OrderQty] [smallint] NOT NULL,
	[ProductID] [int] NOT NULL,
	[SpecialOfferID] [int] NOT NULL,
	[UnitPrice] [money] NOT NULL,
	[UnitPriceDiscount] [money] NOT NULL,
	[LineTotal] [numeric](38, 6) NOT NULL,
	[SalesOrderNumber] [nvarchar](25) NOT NULL,
	[PurchaseOrderNumber] Nvarchar(25) NULL,
	[Name] Nvarchar(50) NOT NULL,
	[ProductNumber] [nvarchar](25) NOT NULL,
	[AccountNumber] Nvarchar(15)  NULL,
	[RevisionNumber] [tinyint] NOT NULL,
	[OrderDate] [datetime] NOT NULL,
	[DueDate] [datetime] NOT NULL,
	[ShipDate] [datetime] NULL,
	[Status] [tinyint] NOT NULL,
	[OnlineOrderFlag] bit NOT NULL,
	[ShipToAddressID] [int] NOT NULL,
	[TotalDue] [money] NOT NULL,
	[Comment] [nvarchar](128) NULL,
	[rowguid] [uniqueidentifier] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
) 

INSERT INTO #Results
SELECT  
	   SOD.[SalesOrderID]
      ,SOD.[SalesOrderDetailID]
      ,SOD.[CarrierTrackingNumber]
      ,SOD.[OrderQty]
      ,SOD.[ProductID]
      ,SOD.[SpecialOfferID]
      ,SOD.[UnitPrice]
      ,SOD.[UnitPriceDiscount]
      ,SOD.[LineTotal]
	  ,SOH.SalesOrderNumber	
	  ,SOH.PurchaseOrderNumber	
	  ,PRD.Name
	  ,PRD.ProductNumber
	  ,SOH.AccountNumber
	 , SOH.[RevisionNumber]
	 , SOH.[OrderDate]
	 , SOH.[DueDate]
	 , SOH.[ShipDate]
	 , SOH.[Status]
	 , SOH.[OnlineOrderFlag]
	 , SOH.[ShipToAddressID]
	 , SOH.[TotalDue], SOH.[Comment], SOh.[rowguid], soh.[ModifiedDate]
  FROM 
	[Sales].[SalesOrderDetailEnlarged] SOD
  INNER JOIN 
    [Sales].[SalesOrderHeaderEnlarged] SOH ON SOD.salesorderid=SOH.salesorderid
  INNER JOIN 
	[Production].Product PRD ON PRD.ProductID=SOD.productID

WHERE SOh.RowGuid = (
						SELECT TOP 1 RowGuid
						FROM 
							[Sales].[SalesOrderHeaderEnlarged]
						WHERE RowGuid IN
						(

						SELECT TOP 1 RowGuid
						FROM 
							[Sales].[SalesOrderHeaderEnlarged]
						WHERE RowGuid IN (
						SELECT TOP 1 
							RowGuid
						FROM 
							[Sales].[SalesOrderHeaderEnlarged]
						ORDER BY NEWID())))
ORDER BY SOh.RowGuid
OPTION (MAXDOP 1, RECOMPILE)


UPDATE  SOH
SET SomeData= CAST(GETDATE() AS VARCHAR(20))
FROM [Sales].[SalesOrderHeaderEnlarged]  SOH (TABLOCK)
WHERE RowGUid IN (SELECT rowguid FROM #Results)

UPDATE CurrentStatus SET CurrentValue=CurrentValue+1

SELECT CAST(DATEDIFF(ms,@StartTime, GETDATE())AS VARCHAR(20))+ ' Ms'

WAITFOR DELAY '00:00:01:00'

COMMIT TRAN


blocking

--sp_DBA_GetIndexColumns 'SalesOrderHeaderEnlarged','sales'

/*
USE [AdventureWorks2019]
GO

CREATE TABLE CurrentStatus (CurrentValue INT)
INSERT INTO CurrentStatus  (1)

GO

DROP INDEX [AK_SalesOrderHeaderEnlarged_rowguid] ON [Sales].[SalesOrderHeaderEnlarged]

GO
*/

/*

CREATE UNIQUE NONCLUSTERED INDEX [AK_SalesOrderHeaderEnlarged_rowguid] ON [Sales].[SalesOrderHeaderEnlarged]
(
	[rowguid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]


 

*/

--ALTER TABLE [Sales].[SalesOrderHeaderEnlarged] ADD [SomeData] VARCHAR(20)



