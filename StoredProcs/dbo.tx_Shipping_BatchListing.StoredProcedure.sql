USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_Shipping_BatchListing]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 07/12/10
-- Description:	Returns rows of invoices and items that are in the specified batch 
-- Returns:		Wcss.QueryRow.ShippingInvoiceShipmentRow - ShippingItemRow - ShippingTicketRow - with purchase email
-- exec [dbo].[tx_Shipping_BatchListing] 10033, @sortMethod='FirstNameLastName',@filterMethod='all',@StartRowIndex=0,@PageSize=10000
-- exec [dbo].[tx_Shipping_BatchListing] 10028, @sortMethod='FirstNameLastName',@filterMethod='notyetprintedonly',@StartRowIndex=0,@PageSize=10000
-- =============================================

CREATE	PROC [dbo].[tx_Shipping_BatchListing](

	@batchId		INT,
	@sortMethod		VARCHAR(50),
	@StartRowIndex  INT,
	@PageSize       INT

)
AS

SET NOCOUNT ON

SET DEADLOCK_PRIORITY LOW 

BEGIN

	--FILTER INVOICES
	CREATE TABLE #tmpAllBatchInvoice(
	
		Id					INT, 
		UniqueId			VARCHAR(100), 
		dtInvoiceDate		DATETIME, 
		PurchaseEmail		VARCHAR(300), 
		InvoiceShipmentId	INT
	)
	
	INSERT #tmpAllBatchInvoice(Id, UniqueId, dtInvoiceDate, PurchaseEmail, InvoiceShipmentId)
	SELECT	DISTINCT i.[Id], i.[UniqueId], i.[dtInvoiceDate], i.[PurchaseEmail], invs.[Id] AS InvoiceShipmentId			
	FROM	[ShipmentBatch_InvoiceShipment] sbis, 
			[InvoiceShipment] invs, 
			[Invoice] i 
	WHERE	sbis.[tShipmentBatchId] = @batchId 
			AND sbis.[tInvoiceShipmentId] = invs.[Id] 
			AND invs.[tInvoiceId] = i.[Id] 
			AND invs.[vcContext] = 'ticket' 
			AND i.[InvoiceStatus] <> 'NotPaid'

	-- Create a temp table TO store the select results
    CREATE TABLE #PageIndexForInvoices (
    
        IndexId				INT IDENTITY (1, 1) NOT NULL,
        InvoiceId			INT,
		UniqueId			VARCHAR(20),
		InvoiceDate			DATETIME,
		InvoiceShipmentId	INT,
		LastNameFirst		VARCHAR(500),
		FirstNameLastName	VARCHAR(500),
		PurchaseEmail		VARCHAR(256)
	)

	--get showdates that are greater than yesterday
	INSERT INTO #PageIndexForInvoices ( [InvoiceId], [UniqueId], [InvoiceDate], [InvoiceShipmentId], [LastNameFirst], [FirstNameLastName], [PurchaseEmail] )
	SELECT [InvoiceId], [UniqueId], [InvoiceDate], [InvoiceShipmentId], [LastNameFirst], [FirstNameLastName], [PurchaseEmail] 
	FROM
			(				
				--WHITTLE DOWN THE INVOICE LIST TO JUST THOSE ON THE CURRENT PAGE
				SELECT	DISTINCT (t.[Id]) AS InvoiceId, t.[UniqueId], t.[dtInvoiceDate] AS InvoiceDate, t.[InvoiceShipmentId],  
					(invs.[LastName] + ' ' + invs.[FirstName]) AS LastNameFirst,  
					(invs.[FirstName] + ' ' + invs.[LastName]) AS FirstNameLastName,  
					t.[PurchaseEmail], 
					ROW_NUMBER() OVER (ORDER BY 
						(CASE WHEN @sortMethod = 'lastnamefirst' THEN (invs.[LastName] + ' ' + invs.[FirstName]) END), 
						(CASE WHEN @sortMethod = 'firstnamelastname' THEN (invs.[FirstName] + ' ' + invs.[LastName]) END), 
						(CASE WHEN @sortMethod = 'purchaseemail' THEN t.[PurchaseEmail] END),
						(CASE WHEN @sortMethod <> 'lastnamefirst' AND @sortMethod <> 'firstnamelastname' AND @sortMethod <> 'purchaseemail' THEN invs.[dtShipped] END)
					) AS RowNum
				FROM	[#tmpAllBatchInvoice] t, [InvoiceShipment] invs
				WHERE	t.[InvoiceShipmentId] = invs.[Id]
			) Invoices
	WHERE	Invoices.RowNum BETWEEN @StartRowIndex AND (@StartRowIndex + @PageSize -1)
	ORDER BY RowNum

	--RETURN LIST OF INVOICESHIPMENTS
	SELECT	invs.[Id], t.[UniqueId], t.[InvoiceDate], invs.[tInvoiceId], invs.[ReferenceNumber], ISNULL(invs.[TShipItemId],0) as tShipItemId, 
			invs.[bLabelPrinted], t.[PurchaseEmail], ISNULL(invs.[CompanyName],'') as CompanyName, invs.[FirstName], invs.[LastName], 
			invs.[Address1], ISNULL(invs.[Address2],'') as Address2, invs.[City], invs.[StateProvince], invs.[PostalCode], 
			invs.[Country], invs.[Phone], invs.[dtShipped], ISNULL(invs.[bRTS],0) as bRTS, 
			ISNULL(invs.[TrackingInformation],'') as TrackingInformation, 
			invs.[PackingList], ISNULL(invs.[PackingAdditional],'') as PackingAdditional, invs.[mShippingActual],
			(ISNULL(ibs.[blFirstName],'') + ' ' + ISNULL(ibs.[blLastName],'')) AS BillingName
	FROM	[#PageIndexForInvoices] t, 
			[InvoiceShipment] invs
			LEFT OUTER JOIN [InvoiceBillShip] ibs 
				ON ibs.[tInvoiceId] = invs.[tInvoiceId]
	WHERE	invs.[Id] = t.[InvoiceShipmentId]
	ORDER BY 
		CASE WHEN @sortMethod = 'lastnamefirst' THEN t.[LastNameFirst] END,
		CASE WHEN @sortMethod = 'firstnamelastname' THEN t.[FirstNameLastName] END,
		CASE WHEN @sortMethod = 'purchaseemail' THEN t.[PurchaseEmail] END,
		CASE WHEN @sortMethod <> 'lastnamefirst' AND @sortMethod <> 'firstnamelastname' AND @sortMethod <> 'purchaseemail' THEN invs.[dtShipped] END

	--RETURN LIST OF MATCHING ITEMS
	CREATE TABLE #tmpItems(
		
		Id				INT, 
		tInvoiceId		INT, 
		tShipItemId		INT, 
		tShowTicketId	INT, 
		iQuantity		INT, 
		PurchaseName	VARCHAR(300), 
		ShippingMethod	VARCHAR(300), 
		dtShipped		DATETIME, 
		TicketNumbers	VARCHAR(2000)
	)
	
	INSERT #tmpItems(Id, tInvoiceId, tShipItemId, tShowTicketId, iQuantity, 
		PurchaseName, ShippingMethod, dtShipped, TicketNumbers)
	SELECT	ii.[Id], ii.[tInvoiceId], ii.[tShipItemId], ii.[tShowTicketId], ii.[iQuantity], ii.[PurchaseName], 
			ii.[ShippingMethod], ii.[dtShipped], ISNULL(ev.[vcValue],'') AS TicketNumbers
	FROM	[#PageIndexForInvoices] t, 
			[InvoiceItem] ii 
			LEFT OUTER JOIN [EntityValue] ev 
				ON ev.[vcTableRelation] = 'InvoiceItem' AND 
					ev.[vcValueContext] = 'TicketNumbers' AND 
					ev.[tParentId] = ii.[Id], 
			[ShipmentBatch_InvoiceShipment] sbis, 
			[InvoiceShipmentItem] isi, 
			[InvoiceShipment] invs
	WHERE	sbis.[tShipmentBatchId] = @batchId 
			AND sbis.[tInvoiceShipmentId] = isi.[tInvoiceShipmentId] 
			AND isi.[tInvoiceItemId] = ii.[Id] 
			AND isi.[tInvoiceShipmentId] = invs.[Id] 
			AND ii.[PurchaseAction] = 'Purchased' 
			AND t.[InvoiceId] = ii.[tInvoiceId] 			
	ORDER BY ii.[tInvoiceId] ASC, ii.[tShowTicketId] ASC

	SELECT DISTINCT * FROM [#tmpItems]

	--RETURN DISTINCT LIST OF SHOWTICKETS
	CREATE TABLE #tmpDistinctTicketList(tShowTicketId INT)
	
	INSERT #tmpDistinctTicketList(tShowTicketId)
	SELECT	DISTINCT (t.[tShowTicketId]) AS tShowTicketId
	FROM	[#tmpItems] t

	--UPDATE AGGREGATES FOR DISTINCT SHOWTICKET LIST
	CREATE TABLE #tmpTicketAggs(tShowTicketId INT, OrderQty INT, ItemQty INT)
	
	INSERT #tmpTicketAggs(tShowTicketId, OrderQty, ItemQty)
	SELECT	p.[tShowTicketId], COUNT(DISTINCT(p.Id)) AS OrderQty, SUM(p.[iQuantity]) AS ItemQty
	FROM	[#tmpDistinctTicketList] t 
			LEFT OUTER JOIN [#tmpItems] p 
				ON p.[tShowTicketId] = t.[tShowTicketId]
	GROUP BY p.[tShowTicketId]

	--RETURN DISTINCT SHOWTICKET LIST
	SELECT	st.[Id], st.[dtDateOfShow] AS 'DateOfShow', SUBSTRING(s.[Name], 22, LEN(s.[Name])) AS 'ShowName',
			st.[CriteriaText], st.[SalesDescription], 
			st.[mPrice], st.[mServiceCharge], ISNULL(st.[bAllowShipping],0) AS 'bAllowShipping', a.[Name] AS 'AgeName',
			ag.[OrderQty], ag.[ItemQty]
	FROM	[#tmpDistinctTicketList] t
			LEFT OUTER JOIN [#tmpTicketAggs] ag 
				ON t.[tShowTicketId] = ag.[tShowTicketId], 
			[ShowTicket] st 
			LEFT OUTER JOIN [Age] a 
				ON st.[tAgeId] = a.[Id], [Show] s
	WHERE	st.[Id] = t.[tShowTicketId] 
			AND st.[tShowId] = s.[Id]
	ORDER BY st.[dtDateOfShow]

	--CLEANUP
	DROP TABLE	[#tmpDistinctTicketList]

	DROP TABLE	[#tmpItems]

	DROP TABLE	[#tmpAllBatchInvoice]

	DROP TABLE	[#PageIndexForInvoices]

END
GO
