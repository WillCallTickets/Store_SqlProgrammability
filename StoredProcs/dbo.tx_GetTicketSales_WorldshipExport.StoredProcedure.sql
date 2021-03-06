USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_GetTicketSales_WorldshipExport]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 07/12/05
-- Description:	Given a list of showdateIds....
--				1) find the invoice items that match those ids
--				**future enhancement to filter by shipper/method, etc
--				2) from those invoiceItems - get a list of shipItemIds
--				3) for each shipItem Id
--	Returns sales row for current ticket or showdate. Choose one or the other - will not work for both. 
--	this will grab all info from the invoice bill ship prior to any shipment fulfillments
-- Returns:		Wcss.TicketSalesRow
-- exec tx_GetTicketSales_WorldshipExport '10270,10271'
-- exec tx_GetTicketSales_WorldshipExport '10125'--146
-- =============================================

CREATE	PROC [dbo].[tx_GetTicketSales_WorldshipExport](

	@ShowDateIdList_UseCommas	VARCHAR(4000)

)
AS

SET DEADLOCK_PRIORITY LOW

SET NOCOUNT ON

BEGIN

	--select @ids
	IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[#tmpRes]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	BEGIN
	
		-- this table is created to split up the passed in ids		
		CREATE TABLE #tmpIdx (
			[Id]	[INT] NOT NULL,
			[item]	VARCHAR(256) NOT NULL
		)
	END

	--get ids from input
	INSERT	#tmpIdx( [Id], [item] )
	SELECT	ti.[Id], ti.[ListItem]
	FROM	fn_ListToTable( @ShowDateIdList_UseCommas ) ti

	--two ways to do this
	--1)start from invoiceitems that are tix and get ship items
	--2) start from invoiceitems that are ship item that have those tix in shipment

	--1)159 rows - 307 items to ship
	CREATE	TABLE #tmpShipIdx(TShipItemId INT)
	
	INSERT	#tmpShipIdx(TShipItemId)
	SELECT	DISTINCT(ii.[TShipItemId])	
	FROM	[#tmpIdx] t, 
			[ShowTicket] st, 
			[InvoiceItem] ii, 
			[Invoice] i
	WHERE	t.[item] = st.[TShowDateId] 
			AND st.[Id] = ii.[TShowTicketId] 
			AND ii.[PurchaseAction] = 'Purchased' 
			AND ii.[TInvoiceId] = i.[Id] 
			AND i.[InvoiceStatus] <> 'NotPaid' 
			AND (ii.[ShippingMethod] IS NOT NULL AND LEN(RTRIM(LTRIM(ii.[ShippingMethod]))) > 0 AND ii.[ShippingMethod] <> 'Will Call')
			AND ii.[TShipItemId] IS NOT NULL
	ORDER BY ii.[TShipItemId]

	CREATE TABLE #tmpItemsToShip(Id INT)
	
	INSERT	#tmpItemsToShip(Id)
	SELECT	DISTINCT(ii.[Id])
	FROM	[#tmpShipIdx] t, [InvoiceItem] ii
	WHERE	t.[TShipItemId] = ii.[TShipItemId]
	ORDER BY ii.[Id] ASC

	--do not rely on invoiceshipments here as the chances are that they havenot been created yet
	--TODO: match shipping type/method, etc	

	--for each shipment
	--list customer details - first and last, address1, address2, zip, city, state, phone, email
	
	IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[#tmpReport]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	BEGIN
	
		CREATE TABLE #tmpReport (
			[UniqueId]					VARCHAR(60) NOT NULL,
			[InvoiceDate]				DATETIME NOT NULL,
			[ShipItemId]				INT NOT NULL,
			[LastNameFirst]				VARCHAR(300) NOT NULL,
			[Name]						VARCHAR(300) NOT NULL,
			[Address1]					VARCHAR(300) NOT NULL,
			[Address2]					VARCHAR(300) NOT NULL,
			[Zip]						VARCHAR(25) NOT NULL,
			[City]						VARCHAR(100) NOT NULL,
			[Country]					VARCHAR(100) NOT NULL,
			[State]						VARCHAR(100) NOT NULL,
			[Phone]						VARCHAR(50) NOT NULL,
			[BillingName]				VARCHAR(300) NOT NULL,
			[PurchaseEmail]				VARCHAR(300) NOT NULL,
			[PackingListIds]			VARCHAR(500) NOT NULL,
			[PackingListDescription]	VARCHAR(5000) NULL
		)
		
	END

	INSERT	#tmpReport([UniqueId], [InvoiceDate], ShipItemId, LastNameFirst, Name, 
			Address1, Address2, Zip, City, Country, State, Phone, 
			BillingName, PurchaseEmail, PackingListIds, PackingListDescription)
	SELECT	i.[UniqueId], 
			i.[dtInvoiceDate] as InvoiceDate, 
			ii.[Id] AS ShipItemId,
			CASE WHEN ibs.[bSameAsBilling] = 0 THEN ibs.[LastName] + ' ' + ibs.[FirstName] 
				ELSE ibs.[blLastName] + ' ' + ibs.[blFirstName] end as [LastNameFirst], 
			CASE WHEN ibs.[bSameAsBilling] = 0 THEN ibs.[FirstName] + ' ' + ibs.[LastName] 
				ELSE ibs.[blFirstName] + ' ' + ibs.[blLastName] end as [Name], 
			CASE WHEN ibs.[bSameAsBilling] = 0 THEN ibs.[Address1] ELSE ibs.[blAddress1] end as Address1, 
			CASE WHEN ibs.[bSameAsBilling] = 0 THEN ISNULL(ibs.[Address2],'') ELSE ISNULL(ibs.[blAddress2],'') end as Address2, 
			CASE WHEN ibs.[bSameAsBilling] = 0 THEN ibs.[PostalCode] ELSE ibs.[blPostalCode] end as Zip, 
			CASE WHEN ibs.[bSameAsBilling] = 0 THEN ibs.[City] ELSE ibs.[blCity] end as City, 
			CASE WHEN ibs.[bSameAsBilling] = 0 THEN ibs.[Country] ELSE ibs.[blCountry] end as Country, 
			CASE WHEN ibs.[bSameAsBilling] = 0 THEN ibs.[StateProvince] ELSE ibs.[blStateProvince] end as State, 
			CASE WHEN ibs.[bSameAsBilling] = 0 THEN ibs.[Phone] ELSE ibs.[blPhone] end as Phone, 
			ibs.[blFirstName] + ' ' + ibs.[blLastName] AS BillingName, 
			i.purchaseemail, 			 
			'' AS PackingListIds, 
			'' as PackingListDescription
	FROM	[#tmpShipIdx] t, 
			[InvoiceItem] ii, 
			[InvoiceBillShip] ibs, 
			[Invoice] i
	WHERE	t.[TShipItemId] = ii.[Id] 
			AND ii.[TInvoiceId] = ibs.[TInvoiceId] 
			AND ii.[TInvoiceId] = i.[Id] 
	ORDER BY i.purchaseemail

	--foreach item in items to ship
	--update the coresponding report row
	DECLARE	@itemIdx	INT, 
			@maxIdx		INT	
	SET	@itemIdx = 0
	SELECT	TOP 1 @maxIdx = Id 
	FROM	#tmpItemsToShip 
	ORDER BY Id DESC

	WHILE @itemIdx < @maxIdx 
	BEGIN
		
		SELECT	TOP 1 @itemIdx = t.[Id] 
		FROM	[#tmpItemsToShip] t 
		WHERE	t.[Id] > @itemIdx 
		ORDER BY Id ASC

		UPDATE	#tmpReport 
		SET		PackingListIds = report.[PackingListIds] + CAST(ii.[Id] AS VARCHAR) + '~',
				PackingListDescription = report.[PackingListDescription] + 
				CAST(ii.[IQuantity] AS VARCHAR) + '@ ' + 
					REPLACE(ii.[MainActName] + RTRIM(' ' + ii.[Criteria] + ' ' + ii.[Description]), '~', '') + '~'
		FROM	[InvoiceItem] ii, [#tmpReport] report
		WHERE	ii.[Id] = @itemIdx 
				AND ii.[TShipItemId] = report.[ShipItemId] 

	END

	--cleanup - remove extraneuos phone chars and get rid of closing ~ separator
	UPDATE	#tmpReport
	SET		PackingListIds = SUBSTRING(PackingListIds, 1, LEN(PackingListIds)-1),
			PackingListDescription = SUBSTRING(PackingListDescription, 1, LEN(PackingListDescription)-1),
			Phone = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Phone, '(', ''), ')',''), '-',''),'.',''),' ','')

	SELECT	[UniqueId], 
			[InvoiceDate], 
			[ShipItemId], 
			[LastNameFirst], 
			[Name], 
			[Address1], 
			[Address2], 
			[City], 
			[State], 
			[Zip], 
			[Country], 
			[Phone], 
			[BillingName], 
			[PurchaseEmail], 
			[PackingListIds], 
			[PackingListDescription]
	FROM	#tmpReport 
	ORDER BY [LastNameFirst]

END
GO
