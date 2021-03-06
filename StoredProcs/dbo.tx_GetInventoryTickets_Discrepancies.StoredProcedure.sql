USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_GetInventoryTickets_Discrepancies]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 07/12/05
-- Description:	Query to compare shows with pending sales that should not have pending sales. 
--	Will also show actual sold - based on invoiceitems sold versus what we have recorded AS sold
--	**note - will only return rows with actual tickets created
/*
exec [tx_GetInventoryTickets_Discrepancies] '83C1C3F6-C539-41D7-815D-143FBD40E41F',1,10, '11/1/2009 12AM', '11/20/2011 11:59PM'
exec [tx_GetInventoryTickets_Discrepancies] 'AC36EB0B-152E-4B69-8B39-BB4B6C9B01E6',0,100, '1/1/2007', '12/31/2007'
*/
-- =============================================

CREATE    PROC [dbo].[tx_GetInventoryTickets_Discrepancies] (

	@applicationId	UNIQUEIDENTIFIER,
	@StartRowIndex  INT,
	@PageSize       INT,
	@StartDate		DATETIME,
	@EndDate		DATETIME

)
AS

SET DEADLOCK_PRIORITY LOW

BEGIN

	--first, get a list of showtickets in the date range
	CREATE TABLE #PageIndexForTicketInventory ( Idx	INT )

	INSERT INTO #PageIndexForTicketInventory (Idx)
	SELECT ShowTicketId FROM
	(
		SELECT	DISTINCT(st.[Id]) AS ShowTicketId,
				ROW_NUMBER() OVER (ORDER BY st.[dtDateOfShow] ASC) AS RowNum
		FROM	ShowTicket st, Show s
		WHERE	st.[dtDateOfShow] BETWEEN @StartDate AND @EndDate 
				AND st.[tShowId] = s.[Id] 
				AND s.[ApplicationId] = @applicationId
	) ShowTickets
	WHERE	ShowTickets.RowNum BETWEEN (@StartRowIndex) AND (@StartRowIndex + @PageSize - 1)
	ORDER BY ShowTickets.[RowNum] ASC

	--create the table to hold all the nums
	CREATE	TABLE #figures (
		ShowName				VARCHAR(256),
		ShowDate				DATETIME,
		ShowTicketId			INT NOT NULL,
		Alloted					INT DEFAULT 0,
		Pending					INT DEFAULT 0,
		Sold					INT DEFAULT 0,
		Available				INT DEFAULT 0,
		Refunded				INT DEFAULT 0,
		ii_Purchased			INT DEFAULT 0,
		ii_PurchasedThenRemoved	INT DEFAULT 0,
		ii_NotYetPurchased		INT DEFAULT 0,
		Sold_Disc				BIT DEFAULT 0,--diff between purchase invoiceitems and sold
		Refund_Disc				BIT DEFAULT 0 --diff between purchasedthenremoved and refunds
	)

	--insert current values for tickets in range
	INSERT	#figures(ShowName,ShowDate,ShowTicketId,Alloted,Pending,Sold,Available,Refunded)
	SELECT	s.[Name], 
			sd.[dtDateOfShow], 
			st.[Id], 
			st.[iAllotment], 
			ISNULL(pending.[iQty], 0) AS iPending, 
			st.[iSold], 
			(st.[iAllotment] - ISNULL(pending.[iQty], 0) - st.[iSold]) AS iAvailable, 
			st.[iRefunded]
	FROM	Show s, 
			ShowDate sd, 
			ShowTicket st 
				LEFT OUTER JOIN fn_PendingStock('ticket') pending ON pending.[idx] = st.[Id], 
			#PageIndexForTicketInventory idx
	WHERE	idx.[Idx] = st.[Id] 
			AND st.[tShowDateId] = sd.[Id] 
			AND sd.[tShowId] = s.[Id] 
	ORDER BY sd.[dtDateOfShow] ASC

	--get the matching tickets purchased in invoice items and update the actual purchased
	CREATE TABLE #tmpPurchased (TicketId int, Purchased int)	
	
	INSERT	#tmpPurchased(TicketId, Purchased)
	SELECT	st.[Id] AS TicketId, 
			SUM(ii.[iQuantity]) AS Purchased
	FROM	ShowTicket st, 
			InvoiceItem ii, 
			Invoice i
	WHERE	i.[ApplicationId] = @applicationId 
			AND ii.[tInvoiceId] = i.[Id] 
			AND ii.[tShowTicketId] = st.[Id] 
			AND ii.[vcContext] = 'Ticket' 
			AND ii.PurchaseAction = 'Purchased' 
	GROUP BY st.[Id]

	UPDATE	#figures
	SET		ii_Purchased = p.[Purchased]
	FROM	#figures f, #tmpPurchased p
	WHERE	f.[ShowTicketId] = p.[TicketId]
	
	--refunds
	CREATE TABLE #tmpPurchasedThenRemoved (TicketId int, PurchasedThenRemoved int)
	
	--get the matching tickets purchased in invoice items and note the actual items purchased then removed
	INSERT	#tmpPurchasedThenRemoved(TicketId, PurchasedThenRemoved)
	SELECT	st.[Id] AS TicketId, SUM(ii.[iQuantity]) AS PurchasedThenRemoved
	FROM	ShowTicket st, 
			InvoiceItem ii, 
			Invoice i
	WHERE	i.[ApplicationId] = @applicationId 
			AND i.[Id] = ii.[tInvoiceId] 
			AND ii.[vcContext] = 'Ticket' 
			AND ii.PurchaseAction = 'PurchasedThenRemoved' 
			AND ii.[tShowTicketId] = st.[Id]
	GROUP BY st.[Id]

	UPDATE	#figures
	SET		ii_PurchasedThenRemoved = p.[PurchasedThenRemoved]
	FROM	#figures f, #tmpPurchasedThenRemoved p
	WHERE	f.[ShowTicketId] = p.[TicketId]

	--items not purchased
	CREATE TABLE #tmpNotYetPurchased (TicketId int, NotYetPurchased int)
	
	--get the matching tickets purchased in invoice items and note the actual items not yet purchased
	INSERT	#tmpNotYetPurchased
	SELECT	st.[Id] AS TicketId, SUM(ii.[iQuantity]) AS NotYetPurchased	
	FROM	ShowTicket st, 
			InvoiceItem ii, 
			Invoice i
	WHERE	i.[ApplicationId] = @applicationId 
			AND i.[Id] = ii.[tInvoiceId] 
			AND ii.[vcContext] = 'Ticket' 
			AND ii.PurchaseAction = 'NotYetPurchased' 
			AND ii.[tShowTicketId] = st.[Id]
	GROUP BY st.[Id]

	UPDATE	#figures
	SET		ii_NotYetPurchased = p.[NotYetPurchased]
	FROM	#figures f, #tmpNotYetPurchased p
	WHERE	f.[ShowTicketId] = p.[TicketId]

	--mark discrepancies
	UPDATE	#figures
	SET		Sold_Disc = 1
	WHERE	Sold <> ii_Purchased

	UPDATE	#figures
	SET		Refund_Disc = 1
	WHERE	Refunded <> ii_PurchasedThenRemoved

	SELECT	f.[ShowName], 
			f.[ShowDate], 
			st.[tShowId] AS ShowId, 
			st.[tShowDateId] AS ShowDateId, 
			f.[ShowTicketId],
			f.[Alloted], 
			f.[Pending], 
			f.[Sold], 
			f.[Available], 
			f.[Refunded], 
			st.[dtPublicOnsale] AS OnSaleDate, 
			st.[dtEndDate] AS OffSaleDate, 
			f.[ii_Purchased] AS Purchased_Actual, 
			f.[ii_PurchasedThenRemoved] AS Removed_Actual, 
			f.[ii_NotYetPurchased] AS NotYetPurchased_Actual, 
			f.[Sold_Disc], 
			f.[Refund_Disc], 
			a.[Name] AS AgeName, 
			st.[bActive] AS Active, 
			st.[bSoldOut] AS SoldOut, 
			st.[bDosTicket] AS DosTicket, 
			st.[mPrice] AS Price, 
			st.[mServiceCharge] AS ServiceCharge, 
			ISNULL(st.[Status],'') AS [Status],
			ISNULL(st.[SalesDescription], '') AS SalesDescription, 
			ISNULL(st.[CriteriaText], '') AS CriteriaText
	FROM	#figures f, 
			Age a, 
			ShowTicket st
	WHERE	f.[ShowTicketId] = st.[Id] 
			AND st.[TAgeId] = a.[Id]

END
GO
