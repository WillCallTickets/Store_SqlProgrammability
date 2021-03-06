USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_GetTicketSales]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 07/12/05
-- Description:	Returns sales row for current ticket or showdate. 
-- Returns:		Wcss.TicketSalesRow
-- =============================================

CREATE	PROC [dbo].[tx_GetTicketSales](

	@ShowDateId			INT,
	@ShowTicketIds		VARCHAR(1024),
	@willCallText		VARCHAR(256),
	@sortContext		VARCHAR(256),
	@ShipContext		VARCHAR(256), 
	@PurchaseContext	VARCHAR(256), 
	@EmailOnly			BIT,
	@StartRowIndex      INT,
	@PageSize           INT

)
AS

SET NOCOUNT ON

SET DEADLOCK_PRIORITY LOW 

BEGIN

	-- Create a temp table TO store the select results
    CREATE TABLE #PageIndexForItems(
        IndexId			INT IDENTITY (1, 1) NOT NULL,
        ItemId			INT,
		PickupName		VARCHAR(256),
		minAuthNetId	INT
	)

	--get all the sales for the date
	IF(@ShowDateId <> 0)
	BEGIN

		INSERT #PageIndexForItems (ItemId,PickupName,minAuthNetId)
		SELECT ItemId,PickupName,minAuthNetId FROM
		(
			SELECT	ii.[Id] AS ItemId, 
					st.[iDisplayOrder] AS DisplayOrder, 
					ISNULL(ii.[PickupName], ii.[PurchaseName]) AS PickupName, 
					MIN(auth.[Id]) AS minAuthNetId,
					ROW_NUMBER() OVER (ORDER BY 
						(CASE WHEN @sortContext = 'alphabetical' THEN ISNULL(ii.[PickupName], ii.[PurchaseName]) 
							ELSE CONVERT(VARCHAR(50), ii.[Id]) END) ) AS RowNum
			FROM	InvoiceItem ii, 
					ShowDate sd, 
					ShowTicket st, 
					AuthorizeNet auth
			WHERE	sd.[Id] = @ShowDateId 
					AND st.[TShowDateId] = @ShowDateId 
					AND ii.TShowTicketId = st.[Id] 
					AND ii.[vcContext] = 'Ticket' 
					AND  
					CASE @ShipContext
						WHEN @willCallText THEN 
							CASE WHEN 
									ii.[PurchaseAction] = 'Purchased' 
									AND (ii.[ShippingMethod] IS NULL OR (ii.[ShippingMethod] IS NOT NULL AND LEN(LTRIM(RTRIM(ii.[ShippingMethod]))) = 0))
									OR (ii.[ShippingMethod] IS NOT NULL AND LEN(LTRIM(RTRIM(ii.[ShippingMethod]))) > 0 
									AND ii.[ShippingMethod] = @willCallText) THEN 1 
								ELSE 0 
							END
						WHEN 'Shipped' THEN 
							CASE WHEN 
									ii.[PurchaseAction] = 'Purchased' 
									AND ii.[ShippingMethod] IS NOT NULL 
									AND LEN(LTRIM(RTRIM(ii.[ShippingMethod]))) > 0 
									AND ii.[ShippingMethod] <> @willCallText THEN 1 
								ELSE 0 
							END
						ELSE 1 
					END = 1 
					AND 
					CASE @PurchaseContext
						WHEN 'Purchases' THEN
							CASE WHEN	ii.[PurchaseAction] = 'Purchased' THEN 1 
								ELSE 0 
							END
						WHEN 'Refunds' THEN
							CASE WHEN	ii.[PurchaseAction] = 'PurchasedThenRemoved' 
										AND ISNULL(CHARINDEX(ii.[Notes], 'EXCHANGED'),-1) = -1 THEN 1 
								ELSE 0 
							END
					END = 1 
					AND ii.[tInvoiceId] = auth.[tInvoiceId] 
					AND auth.[transactiontype] = 'auth_capture' 
					AND auth.[bAuthorized] = 1
			GROUP BY ii.[Id], st.[iDisplayOrder], ISNULL(ii.[PickupName], ii.[PurchaseName])
		)	Items
		WHERE	Items.RowNum BETWEEN (@StartRowIndex) AND (@StartRowIndex + @PageSize - 1)
		ORDER BY Items.[RowNum] ASC

	END
	
	ELSE IF (LEN(RTRIM(LTRIM(@ShowTicketIds))) > 0 AND @ShowTicketIds <> '0') --get all the sales for the specified ticket
	BEGIN
		
		SET @ShowTicketIds = REPLACE(@ShowTicketIds, '~', ',')
		
		INSERT #PageIndexForItems (ItemId,PickupName,minAuthNetId)
		SELECT ItemId,PickupName,minAuthNetId FROM
		(
			SELECT	ii.[Id] AS ItemId, 
					st.[iDisplayOrder] AS DisplayOrder, 
					ISNULL(ii.[PickupName], 
					ii.[PurchaseName]) AS PickupName,
					MIN(auth.[Id]) AS minAuthNetId,					
					ROW_NUMBER() OVER (ORDER BY 
						(CASE WHEN @sortContext = 'alphabetical' THEN ISNULL(ii.[PickupName], ii.[PurchaseName]) 
							ELSE CONVERT(VARCHAR(50), ii.[Id]) END) ) AS RowNum
			FROM	InvoiceItem ii, 
					ShowTicket st, 
					AuthorizeNet auth
			WHERE	st.[Id] IN (SELECT DISTINCT [ListItem] FROM fn_ListToTable(@ShowTicketIds)) 
					AND ii.TShowTicketId = st.[Id] 
					AND ii.[vcContext] = 'Ticket' 
					AND 
					CASE @ShipContext
						WHEN @willCallText THEN 
							CASE WHEN	ii.[PurchaseAction] = 'Purchased' 
										AND (ii.[ShippingMethod] IS NULL OR (ii.[ShippingMethod] IS NOT NULL AND LEN(LTRIM(RTRIM(ii.[ShippingMethod]))) = 0))
										OR
										(ii.[ShippingMethod] IS NOT NULL AND LEN(LTRIM(RTRIM(ii.[ShippingMethod]))) > 0 
										AND ii.[ShippingMethod] = @willCallText) THEN 1 
								ELSE 0 
							END
						WHEN 'Shipped' THEN 
							CASE WHEN	ii.[PurchaseAction] = 'Purchased' 
										AND ii.[ShippingMethod] IS NOT NULL 
										AND LEN(LTRIM(RTRIM(ii.[ShippingMethod]))) > 0 
										AND ii.[ShippingMethod] <> @willCallText THEN 1 
								ELSE 0 
							END
						ELSE 1 
					END = 1 
					AND 
					CASE @PurchaseContext
						WHEN 'Purchases' THEN
							CASE WHEN ii.[PurchaseAction] = 'Purchased' THEN 1 
								ELSE 0 
							END
						WHEN 'Refunds' THEN
							CASE WHEN	ii.[PurchaseAction] = 'PurchasedThenRemoved' 
										AND ISNULL(CHARINDEX(ii.[Notes], 'EXCHANGED'),-1) = -1 THEN 1 
								ELSE 0 
							END
					END = 1 
					AND ii.[tInvoiceId] = auth.[tInvoiceId] 
					AND auth.[transactiontype] = 'auth_capture' 
					AND auth.[bAuthorized] = 1
			GROUP BY ii.[Id], st.[iDisplayOrder], ISNULL(ii.[PickupName], ii.[PurchaseName])
		)	Items
		WHERE	Items.RowNum BETWEEN (@StartRowIndex) AND (@StartRowIndex + @PageSize - 1)
		ORDER BY Items.[RowNum] ASC

	END

	--Get the transactions that match the invoices and make sure we get the original
	CREATE TABLE #tmpTrans(
		TInvoiceId	INT, 
		LastFour	VARCHAR(4), 
		Id INT
	)
	
	INSERT	#tmpTrans(TInvoiceId, LastFour, Id)
	SELECT	it.[TInvoiceId] AS TInvoiceId, 
			it.[LastFourDigits] AS LastFour, 
			MIN(it.[Id]) AS Id	
	FROM	InvoiceTransaction it, 
			InvoiceItem ii, 
			#PageIndexForItems p
	WHERE	ii.[Id] = p.[ItemId] 
			AND it.[TInvoiceId] = ii.[TInvoiceid] 
			AND it.[TransType] = 'Payment' 
			AND it.[FundsType] = 'CreditCard'
	GROUP BY it.[TInvoiceId], it.[LastFourDigits]

	IF (@EmailOnly = 1) 
	BEGIN
	
		SELECT	DISTINCT(u.[LoweredUserName]) AS PurchaseEmail
		FROM	InvoiceItem ii, 
				Invoice i, 
				AspNet_Users u, 
				#PageIndexForItems p
		WHERE	ii.[Id] = p.[ItemId] 
				AND ii.[TInvoiceId] = i.[Id] 
				AND i.[UserId] = u.[UserId] 
		ORDER BY u.[LoweredUserName] ASC

	END	ELSE 
	BEGIN

		SELECT	i.[Id] AS ParentInvoiceId, 
				i.[UniqueId] AS UniqueInvoiceId, 
				ii.[Id] AS ItemId, 
				ii.[tShowTicketId] AS ShowTicketId, 
				ii.[tShipItemId] AS ShipId, 
				ii.[PurchaseName], 
				ISNULL(ii.[PickupName], 
				ii.[PurchaseName]) AS PickupName, 
				auth.[NameOnCard] AS NameOnCard, 
				ISNULL(it.[LastFour],'') AS LastFour,
				u.[LoweredUserName] AS Email, 
				ibs.[blPhone] AS [PhoneBilling], 
				ibs.[Phone] AS [PhoneShipping],
				dbo.fn_GetProfileValue(auth.UserId, 'Phone') AS [PhoneProfile],
				ii.[iQuantity] AS Qty, 
				ii.[MainActName] AS ProductName , 
				ii.[AgeDescription] AS Age, 
				ii.[Notes], ii.[bRTS], 
				ii.[dtShipped] AS DateShipped, 
				ii.[ShippingMethod], 
				ii.[ShippingNotes]
		FROM	InvoiceItem ii, 
				Invoice i 
				LEFT OUTER JOIN #tmpTrans it 
					ON it.[TInvoiceId] = i.[Id]
				LEFT OUTER JOIN InvoiceBillShip ibs 
					ON ibs.tinvoiceid = i.[Id],
				AspNet_Users u, 
				#PageIndexForItems p, 
				AuthorizeNet auth
		WHERE	ii.[Id] = p.[ItemId] 
				AND ii.[TInvoiceId] = i.[Id] 
				AND i.[UserId] = u.[UserId] 
				AND i.[Id] = auth.[tInvoiceId] 
				AND p.[minAuthNetId] = auth.[Id]
		ORDER BY IndexId ASC

	END

END
GO
