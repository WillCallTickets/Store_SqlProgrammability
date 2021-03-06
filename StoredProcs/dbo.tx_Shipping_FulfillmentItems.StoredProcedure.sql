USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_Shipping_FulfillmentItems]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 07/12/10
-- Description:	Returns rows of invoices that match have the ticket ids in the order. Also returns a list
--	of Shippable Ticket InvoiceItems and a distinct list of the shippable tickets.
-- Returns:		Wcss.QueryRow.ShippingFulfillment
-- exec [dbo].[tx_Shipping_FulfillmentItems] @ticketIdList='12269,12270',@sortMethod='LastNameFirst',@filterMethod='all',@StartRowIndex=0,@PageSize=10000
-- =============================================

CREATE	PROC [dbo].[tx_Shipping_FulfillmentItems](

	@ticketIdList		VARCHAR(1000),
	@sortMethod			VARCHAR(50),
	@filterMethod		VARCHAR(50),
	@willCallMethodText	VARCHAR(50),
	@StartRowIndex		INT,
	@PageSize			INT
	
)
AS

SET NOCOUNT ON

SET DEADLOCK_PRIORITY LOW 

BEGIN

	--SPLIT TICKET IDS INTO A TABLE
	CREATE TABLE #tmpTix(Id INT, TicketId INT)
	
	INSERT	#tmpTix(Id, TicketId)
	SELECT	ti.[Id], ti.[ListItem] AS 'TicketId'
	FROM	fn_ListToTable( @ticketIdList ) ti

	--we need the full list to correctly and fully populate any tix that may have be contained in this order
	--we do not want to limit our return values to just those sale on a particular page
	--first get a list of ALL OF THE invoiceitems that match the selected tickets
	--this will only get shippable items

	--THIS IS A LIST OF ALL THE MATCHING INVOICES - POTENTIAL FOR SPLITTING INTO PAGES
	--note that ship methods are only for initial selection
	--all ship methods in the matching items will be returned
	CREATE TABLE #tmpInvoices(
		
		InvoiceId			INT, 
		LastNameFirst		VARCHAR(500), 
		FirstNameLastName	VARCHAR(500), 
		PurchaseEmail		VARCHAR(500), 
		InvoiceDate			DATETIME
	)
	
	INSERT	#tmpInvoices
	SELECT	DISTINCT(ii.[tInvoiceId]) AS InvoiceId,
			CASE WHEN ibs.[bSameAsBilling] = 0 
				THEN ibs.[LastName] + ' ' + ibs.[FirstName] 
				ELSE ibs.[blLastName] + ' ' + ibs.[blFirstName] 
				END AS LastNameFirst,
			CASE WHEN ibs.[bSameAsBilling] = 0 
				THEN ibs.[FirstName] + ' ' + ibs.[LastName] 
				ELSE ibs.[blFirstName] + ' ' + ibs.[blLastName] 
				END AS FirstNameLastName,
			i.[PurchaseEmail] AS PurchaseEmail, i.[dtInvoiceDate] AS InvoiceDate
	FROM	[InvoiceItem] ii 
			LEFT OUTER JOIN [Invoice] i 
				ON i.[Id] = ii.[tInvoiceId] AND i.[InvoiceStatus]  <> 'NotPaid'
			LEFT OUTER JOIN [InvoiceBillShip] ibs 
				ON ibs.[tInvoiceId] = i.[Id],
			[#tmpTix] tt
    WHERE	ii.[vcContext] = 'ticket' 
			AND ii.[tShowTicketId] IS NOT NULL 
			AND ii.[tShowTicketId] = tt.[TicketId]
			AND ii.[PurchaseAction] = 'Purchased'  
			AND ii.[tShipItemId] IS NOT NULL 
			AND ii.[ShippingMethod] <> @willCallMethodText 
			AND 
			CASE @filterMethod WHEN 'notshippedonly' THEN	
				CASE WHEN ii.[dtShipped] IS NULL THEN 1 ELSE 0 END
			ELSE 1
			END = 1
			
	--THIS IS A DISTINCT LIST OF THE POSSIBLE SHIPPABLE TICKETS IN ALL OF THE INVOICES
	--next, get the list of all the invoiceitems in those invoices that are shippable
	--this becomes a lookup list for the client
	CREATE TABLE #tmpDistinctTicketList(Id INT)
	
	INSERT #tmpDistinctTicketList(Id)
	SELECT	DISTINCT(ii.[tShowTicketId]) AS 'Id'
	FROM	[#tmpInvoices] t, [InvoiceItem] ii
	WHERE	ii.[vcContext] = 'ticket' 
			AND ii.[tInvoiceId] = t.[InvoiceId] 
			AND ii.[tShipItemId] IS NOT NULL 
			AND ii.[tShowTicketId] IS NOT NULL

	-- Create a temp table TO store the select results
    CREATE TABLE #PageIndexForInvoices (
    
        IndexId				INT IDENTITY (1, 1) NOT NULL,
        InvoiceId			INT,
        LastNameFirst		VARCHAR(500),
		FirstNameLastName	VARCHAR(500),
		tTicketShipItemId	INT,
		TicketShipMethod	VARCHAR(256)
    )

	--get showdates that are greater than yesterday
	INSERT INTO #PageIndexForInvoices ( [InvoiceId], [LastNameFirst], [FirstNameLastName], [tTicketShipItemId], [TicketShipMethod] )
	SELECT	[InvoiceId], [LastNameFirst], [FirstNameLastName], [tTicketShipItemId], [TicketShipMethod] 
	FROM	(							
				--WHITTLE DOWN THE INVOICE LIST TO JUST THOSE ON THE CURRENT PAGE
				SELECT	DISTINCT (t.[InvoiceId]) AS InvoiceId, t.[LastNameFirst], t.[FirstNameLastName], 
					ISNULL(ii.[Id],0) AS tTicketShipItemId, ISNULL(ii.[MainActName],'') AS TicketShipMethod, 
					ROW_NUMBER() OVER (ORDER BY 
						(CASE WHEN @sortMethod = 'lastnamefirst' THEN t.[LastNameFirst] END), 
						(CASE WHEN @sortMethod = 'firstnamelastname' THEN t.[FirstNameLastName] END), 
						(CASE WHEN @sortMethod = 'purchaseemail' THEN t.[PurchaseEmail] END),
						(CASE WHEN @sortMethod <> 'lastnamefirst' AND @sortMethod <> 'firstnamelastname' AND @sortMethod <> 'purchaseemail' THEN t.[InvoiceDate] END)
					) AS RowNum
				FROM	[#tmpInvoices] t 
						LEFT OUTER JOIN [InvoiceItem] ii 
							ON	ii.[tInvoiceId] = t.[InvoiceId] 
								AND ii.[vcContext] = 'shippingticket' 
								AND ii.[PurchaseAction] = 'Purchased'
			) Invoices
	WHERE	Invoices.RowNum BETWEEN (@StartRowIndex) AND (@StartRowIndex + @PageSize - 1)
	ORDER BY RowNum

	DROP TABLE [#tmpInvoices]

	--RETURN ORDERED PAGED INVOICES
	SELECT	i.[Id], t.[LastNameFirst], t.[FirstNameLastName], i.[dtInvoiceDate], i.[UniqueId], i.[PurchaseEmail], 
			t.[tTicketShipItemId], t.[TicketShipMethod] 
	FROM	[#PageIndexForInvoices] t, [Invoice] i 
	WHERE	i.[Id] = t.[InvoiceId]
	
	--CREATE A LIST OF JUST THOSE TICKET ITEMS THAT ARE SHIPPABLE AND CONTAINED WITHIN THE PAGED SET OF INVOICES
	--let client filter/hightlight other ship methods - return everything here
	CREATE TABLE #tmpInvoiceItems(
	
		Id				INT, 
		tInvoiceId		INT, 
		iQuantity		INT, 
		tShowTicketId	INT
	)
	
	INSERT	#tmpInvoiceItems (Id, tInvoiceId, iQuantity, tShowTicketId)
	SELECT	ii.[Id], ii.[tInvoiceId], ii.[iQuantity], ii.[tShowTicketId]
	FROM	[#PageIndexForInvoices] t, [InvoiceItem] ii
	WHERE	ii.[vcContext] = 'ticket' 
			AND ii.[tInvoiceId] = t.[InvoiceId] 
			AND ii.[tShipItemId] IS NOT NULL 
			AND ii.[tShipItemId] = t.[tTicketShipItemId] 
			AND ii.[tShowTicketId] IS NOT NULL

	--RETURN THE LIST OF ITEMS			
	CREATE TABLE #tmpItems(
	
		Id				INT, 
		tInvoiceId		INT, 
		tShipItemId		INT, 
		tShowTicketId	INT, 
		iQuantity		INT, 
		PurchaseName	VARCHAR(300), 
		ShippingMethod	VARCHAR(300), 
		dtShipped		DATETIME, 
		TicketNumbers VARCHAR(2000)
	)		
		
	INSERT #tmpItems(Id, tInvoiceId, tShipItemId, tShowTicketId, iQuantity, 
		PurchaseName, ShippingMethod, dtShipped, TicketNumbers)		
	SELECT	ii.[Id], ii.[tInvoiceId], ii.[tShipItemId], ii.[tShowTicketId], ii.[iQuantity], ii.[PurchaseName], 
			ii.[ShippingMethod], ii.[dtShipped], ISNULL(ev.[vcValue],'') AS TicketNumbers
	FROM	[#tmpInvoiceItems] t, 
			[InvoiceItem] ii 
			LEFT OUTER JOIN [EntityValue] ev 
				ON	ev.[vcTableRelation] = 'InvoiceItem' 
					AND ev.[vcValueContext] = 'TicketNumbers' 
					AND ev.[tParentId] = ii.[Id]
	WHERE	t.[Id] = ii.[Id]
	ORDER BY ii.[tInvoiceId] ASC, ii.[tShowTicketId] ASC

	SELECT DISTINCT * FROM [#tmpItems]

	--UPDATE AGGREGATES FOR DISTINCT SHOWTICKET LIST
	CREATE TABLE #tmpTicketAggs (tShowTicketId INT, OrderQty INT, ItemQty INT)
	
	INSERT	#tmpTicketAggs(tShowTicketId, OrderQty, ItemQty)
	SELECT	p.[tShowTicketId], COUNT(DISTINCT(p.Id)) AS 'OrderQty', SUM(p.[iQuantity]) AS 'ItemQty'
	FROM	[#tmpDistinctTicketList] t 
			LEFT OUTER JOIN [#tmpInvoiceItems] p 
				ON p.[tShowTicketId] = t.[Id]
	GROUP BY p.[tShowTicketId]

	--RETURN DISTINCT SHOWTICKET LIST
	SELECT	st.[Id], st.[dtDateOfShow] AS 'DateOfShow', SUBSTRING(s.[Name], 22, LEN(s.[Name])) AS 'ShowName',
			st.[CriteriaText], st.[SalesDescription], 
			st.[mPrice], st.[mServiceCharge], ISNULL(st.[bAllowShipping],0) AS 'bAllowShipping', a.[Name] AS 'AgeName',
			ag.[OrderQty], ag.[ItemQty]
	FROM	[#tmpDistinctTicketList] t
			LEFT OUTER JOIN [#tmpTicketAggs] ag 
				ON t.[Id] = ag.[tShowTicketId], 
			[ShowTicket] st 
			LEFT OUTER JOIN [Age] a 
				ON st.[tAgeId] = a.[Id], 
			[Show] s
	WHERE	st.[Id] = t.[Id] 
			AND st.[tShowId] = s.[Id]
	ORDER BY st.[dtDateOfShow]

	--CLEANUP
	DROP TABLE [#tmpInvoiceItems]
	
	DROP TABLE [#tmpItems]

	DROP TABLE [#PageIndexForInvoices]

	DROP TABLE [#tmpDistinctTicketList]

END
GO
