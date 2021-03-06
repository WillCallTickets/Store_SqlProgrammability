USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_Shipping_FulfillmentItems_Count]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 09/10/22
-- Description:	Returns  count of invoices matching the ticket ids. 
-- Returns:		int 
-- =============================================

CREATE	PROC [dbo].[tx_Shipping_FulfillmentItems_Count](

	@ticketIdList	VARCHAR(1000),	
	@filterMethod	VARCHAR(50),
	@willCallMethodText	VARCHAR(50)

)
AS

SET NOCOUNT ON

SET DEADLOCK_PRIORITY LOW 

BEGIN

	--SPLIT TICKET IDS INTO A TABLE
	CREATE TABLE #tmpTix(Id INT, TicketId INT)

	INSERT	#tmpTix(Id, TicketId)
	SELECT	ti.[Id], ti.[ListItem] AS TicketId
	FROM	fn_ListToTable( @ticketIdList ) ti

	--first get a list of invoiceitems that match the selected tickets
	--this will only get shippable items
	CREATE TABLE #tmpMatchingItemsOnly(Id INT, tInvoiceId INT)
	
	INSERT	#tmpMatchingItemsOnly(Id, tInvoiceId)
	SELECT	ii.[Id], ii.[tInvoiceId]
	FROM	[InvoiceItem] ii 
			LEFT OUTER JOIN [Invoice] i 
				ON i.[Id] = ii.[tInvoiceId] AND i.[InvoiceStatus]  <> 'NotPaid',
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

	--next, get a list of the invoices matching the matching ticket items   
	CREATE TABLE #tmpInvoices(Id INT)
	
	INSERT	#tmpInvoices(Id)         
    SELECT	DISTINCT([tInvoiceId]) AS Id
	FROM	[#tmpMatchingItemsOnly]	

	--we no longer need this as we will grab all ticket items for the invoice below
	DROP TABLE [#tmpMatchingItemsOnly]

	SELECT	COUNT(*) 
	FROM	[#tmpInvoices]

	DROP TABLE [#tmpInvoices]	

END
GO
