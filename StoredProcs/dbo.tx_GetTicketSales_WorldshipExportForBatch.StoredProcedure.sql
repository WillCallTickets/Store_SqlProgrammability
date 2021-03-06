USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_GetTicketSales_WorldshipExportForBatch]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 07/12/05
-- Description:	Per the given batch, create a list of worldship rows based on invoiceshipments in that batch
-- Returns:		Wcss.WorldshipRow
-- exec tx_GetTicketSales_WorldshipExport '10270,10271'
-- =============================================

CREATE	PROC [dbo].[tx_GetTicketSales_WorldshipExportForBatch](

	@batchId	INT,
	@filter		VARCHAR(256)

)
AS

SET DEADLOCK_PRIORITY LOW

SET NOCOUNT ON

BEGIN


	--RETURN THE INVOICESHIPMENTS FOR THE GIVEN BATCH
	CREATE TABLE #tmpInvoiceShipmentIds(
		InvoiceShipmentId	INT, 
		UniqueId			VARCHAR(128), 
		InvoiceDate			DATETIME, 
		PurchaseEmail		VARCHAR(256), 
		BillingName			VARCHAR(128)
	)
	
	INSERT	[#tmpInvoiceShipmentIds](InvoiceShipmentId, UniqueId, InvoiceDate, PurchaseEmail, BillingName)
	SELECT	invs.[Id] AS InvoiceShipmentId, 
			i.[UniqueId], 
			i.[dtInvoiceDate] AS InvoiceDate, 
			i.[PurchaseEmail],
			(ISNULL(ibs.[blFirstName],'') + ' ' + ISNULL(ibs.[blLastName],'')) AS BillingName	
	FROM	[InvoiceShipment] invs, 
			[ShipmentBatch_InvoiceShipment] sbis, 
			[Invoice] i 
			LEFT OUTER JOIN [InvoiceBillShip] ibs 
				ON ibs.[tInvoiceId] = i.[Id]
	WHERE	sbis.[tShipmentBatchId] = @batchId 
			AND sbis.[tInvoiceShipmentId] = invs.[Id] 
			AND invs.[tInvoiceId] = i.[Id] 
			AND invs.[vcContext] = 'ticket' 
			AND i.[InvoiceStatus] <> 'NotPaid'

	IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[#tmpReport]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	BEGIN
	
		CREATE TABLE #tmpReport	(
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

	INSERT	#tmpReport([UniqueId], [InvoiceDate], [ShipItemId], 
			[LastNameFirst], [Name], [Address1], [Address2], [Zip], [City], [Country], [State], 
			[Phone], [BillingName], [PurchaseEmail], [PackingListIds], [PackingListDescription])
	SELECT	t.[UniqueId], 
			t.[InvoiceDate], 
			invs.[tShipItemId] AS ShipItemId,
			(invs.[LastName] + ' ' + invs.[FirstName]) AS [LastNameFirst],
			(invs.[FirstName] + ' ' + invs.[LastName]) AS [Name], 
			invs.[Address1], 
			invs.[Address2],
			invs.[PostalCode] AS Zip, 
			invs.[City], 
			invs.[Country], 
			invs.[StateProvince], 
			invs.[Phone],
			t.[BillingName], 
			t.[PurchaseEmail], 
			'' AS PackingListIds, 
			invs.[PackingList] AS PackingListDescription
	FROM	[#tmpInvoiceShipmentIds] t, [InvoiceShipment] invs
	WHERE	t.[InvoiceShipmentId] = invs.[Id]

	--PACKING IDS - CREATE A SORTED (by id) LIST FOR LOOP
	CREATE TABLE #tmpItemsToShip(InvoiceItemId int)
	
	INSERT #tmpItemsToShip(InvoiceItemId)
	SELECT	DISTINCT isi.[tInvoiceItemId] AS InvoiceItemId
	FROM	[#tmpInvoiceShipmentIds] t, [InvoiceShipmentItem] isi
	WHERE	t.[InvoiceShipmentId] = isi.[tInvoiceShipmentId]
	ORDER BY isi.[tInvoiceItemId] ASC

	--foreach item in items to ship
	--update the coresponding report row
	DECLARE	@itemIdx	INT
	DECLARE	@maxIdx		INT
	SET		@itemIdx = 0

	SELECT	TOP 1 @maxIdx = [InvoiceItemId] 
	FROM	[#tmpItemsToShip] 
	ORDER BY [InvoiceItemId] DESC

	WHILE @itemIdx < @maxIdx 
	BEGIN
		
		SELECT	TOP 1 @itemIdx = t.[InvoiceItemId] 
		FROM	[#tmpItemsToShip] t 
		WHERE	t.[InvoiceItemId] > @itemIdx 
		ORDER BY [InvoiceItemId] ASC

		UPDATE	#tmpReport 
		SET		PackingListIds = report.[PackingListIds] + CAST(ISNULL(ii.[tShowTicketId],'') AS VARCHAR) + '~'
		FROM	[InvoiceItem] ii, [#tmpReport] report -- note that ii is limited by items in the selcted list
		WHERE	ii.[Id] = @itemIdx 
				AND ii.[TShipItemId] = report.[ShipItemId] 

	END

	--cleanup - remove extraneuos phone chars and get rid of closing ~ separator
	UPDATE	[#tmpReport]
	SET		PackingListIds = SUBSTRING(PackingListIds, 1, LEN(PackingListIds)-1),
			Phone = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Phone, '(', ''), ')',''), '-',''),'.',''),' ','')

	--select showdate info - Date - Venue - Act
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
