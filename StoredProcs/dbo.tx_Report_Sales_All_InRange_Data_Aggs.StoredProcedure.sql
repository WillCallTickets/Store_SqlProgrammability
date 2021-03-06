USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_Report_Sales_All_InRange_Data_Aggs]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 07/12/10
-- Description:	Returns rows of invoices with their child objects aggregated. Also returns a row for 
--	aggregates of all invoices. 
-- Returns:		Wcss.ReportRow
-- exec [tx_Report_Sales_All_InRange_Data_Aggs] '1/1/2007','12/31/2007',1,10
-- exec [tx_Report_Sales_All_InRange_Data_Aggs] 'AC36EB0B-152E-4B69-8B39-BB4B6C9B01E6', '6/1/2009','6/30/2009',1,100
--select * from aspnet_Applications -- willcall - 83C1C3F6-C539-41D7-815D-143FBD40E41F - fox - AC36EB0B-152E-4B69-8B39-BB4B6C9B01E6
-- =============================================

CREATE	PROC [dbo].[tx_Report_Sales_All_InRange_Data_Aggs](

	@applicationId	UNIQUEIDENTIFIER,
	@StartDate		VARCHAR(50),
	@EndDate		VARCHAR(50),
	@StartRowIndex  INT,
	@PageSize       INT

)
AS

SET NOCOUNT ON

SET DEADLOCK_PRIORITY LOW 

BEGIN

	CREATE TABLE #Invoices (
        IndexId		INT IDENTITY (1, 1) NOT NULL,
        InvoiceId	INT
    )

	INSERT #Invoices (InvoiceId)
	SELECT	i.[Id] AS InvoiceId
	FROM	Invoice i
	WHERE	i.[ApplicationId] = @applicationId 
			AND i.[InvoiceStatus] <> 'notpaid' 
			AND i.[dtInvoiceDate] BETWEEN @StartDate AND @EndDate
	ORDER BY i.[Id] DESC

	CREATE TABLE #tmpPurchases(
	
		Id INT, 
		tInvoiceId INT, 
		vcContext VARCHAR(256), 
		iQuantity INT, 
		mPrice MONEY, 
		mServiceCharge MONEY, 
		mAdjustment MONEY, 
		mLineItemTotal MONEY
	)
	
	INSERT	#tmpPurchases(Id, tInvoiceId, vcContext, iQuantity, mPrice, mServiceCharge, mAdjustment, mLineItemTotal)
	SELECT	ii.Id, ii.tInvoiceId, ii.vcContext, ii.iQuantity, ii.mPrice, ii.mServiceCharge, ii.mAdjustment, ii.mLineItemTotal
	FROM	InvoiceItem ii, #Invoices i
	WHERE	ii.[tInvoiceId] = i.[InvoiceId] 
			AND ii.[PurchaseAction] = 'Purchased'

	CREATE TABLE #tmpRefundItems(
	
		Id INT, 
		tInvoiceId INT, 
		vcContext VARCHAR(256), 
		mLineItemTotal DECIMAL
	)
	
	INSERT	#tmpRefundItems(Id, tInvoiceId, vcContext, mLineItemTotal)
	SELECT	ii.Id, ii.tInvoiceId, ii.vcContext, ii.mLineItemTotal
	FROM	InvoiceTransaction it, InvoiceItem ii
	WHERE	it.[TransType] = 'Refund' 
			AND it.[dtStamp] BETWEEN @StartDate AND @EndDate 
			AND it.[tInvoiceId] = ii.[tInvoiceId] 
			AND ii.[PurchaseAction] = 'PurchasedThenRemoved'	

	CREATE TABLE #tmpAggregates(
		
		IndexId INT, 
		InvoiceId INT, 
		LinePurchases INT, 
		ItemsPurchased INT, 
		TicketsPurchased INT, 
		MerchPurchased INT, 
		BundlesPurchased INT, 
		DonationsPurchased INT, 
		OtherPurchased INT, 
		BaseSales MONEY, 
		TicketPortion MONEY, 
		MerchPortion MONEY, 
		BundlePortion MONEY, 
		DonationPortion MONEY, 
		OtherPortion MONEY, 
		ServiceCharge MONEY, 
		Adjustment MONEY, 
		LineItemTotal MONEY, 
		ShipCharged MONEY, 
		ProcessingFee MONEY, 
		TotalPaid MONEY, 
		NetPaid MONEY, 
		Damaged MONEY, 
		ShipHandlingCalc MONEY, 
		ShipActual MONEY, 
		Shipments INT, 
		ShipDifferential MONEY, 
		ShipMerch MONEY, 
		ShipTicket MONEY	
	)		
		
	INSERT	#tmpAggregates(IndexId, InvoiceId, LinePurchases, ItemsPurchased, 
		TicketsPurchased, MerchPurchased, BundlesPurchased, DonationsPurchased, OtherPurchased, 
		BaseSales, TicketPortion, MerchPortion, BundlePortion, DonationPortion, OtherPortion, 
		ServiceCharge, Adjustment, LineItemTotal, ShipCharged, ProcessingFee, 
		TotalPaid, NetPaid, Damaged, ShipHandlingCalc, ShipActual, Shipments, 
		ShipDifferential, ShipMerch, ShipTicket)
	SELECT	inv.[IndexId]			AS IndexId, 
			inv.[InvoiceId],
			COUNT(purch.Id)			AS LinePurchases,
			SUM(CASE WHEN purch.[vcContext] = 'ticket' OR purch.[vcContext] = 'merch' OR purch.[vcContext] = 'charity' 
				THEN purch.[iQuantity] ELSE 0 END) AS ItemsPurchased,
			SUM(CASE WHEN purch.[vcContext] = 'ticket' THEN purch.[iQuantity] ELSE 0 END) AS TicketsPurchased,
			SUM(CASE WHEN purch.[vcContext] = 'merch' THEN purch.[iQuantity] ELSE 0 END) AS MerchPurchased,
			SUM(CASE WHEN purch.[vcContext] = 'bundle' THEN purch.[iQuantity] ELSE 0 END) AS BundlesPurchased,
			ISNULL(SUM(CASE WHEN purch.[vcContext] = 'charity' THEN purch.[iQuantity] ELSE 0 END),0) AS DonationsPurchased,
			SUM(CASE WHEN (purch.[vcContext] <> 'merch' AND purch.[vcContext] <> 'bundle' AND purch.[vcContext] <> 'ticket' AND purch.[vcContext] <> 'charity') 
				THEN purch.[iQuantity] ELSE 0 END) AS OtherPurchased,			
			ISNULL(SUM(purch.[mPrice] * purch.[iQuantity]),0.0) AS BaseSales,
			SUM(CASE WHEN purch.[vcContext] = 'ticket' THEN purch.[mPrice] * purch.[iQuantity] ELSE 0.0 END) AS TicketPortion,
			SUM(CASE WHEN purch.[vcContext] = 'merch' THEN purch.[mPrice] * purch.[iQuantity] ELSE 0.0 END) AS MerchPortion,
			SUM(CASE WHEN purch.[vcContext] = 'bundle' THEN purch.[mPrice] * purch.[iQuantity] ELSE 0.0 END) AS BundlePortion,
			SUM(CASE WHEN purch.[vcContext] = 'charity' THEN purch.[mPrice] * purch.[iQuantity] ELSE 0.0 END) AS DonationPortion,
			SUM(CASE WHEN (purch.[vcContext] <> 'merch' AND purch.[vcContext] <> 'bundle' AND purch.[vcContext] <> 'ticket' AND purch.[vcContext] <> 'charity') THEN 
				purch.[mPrice] * purch.[iQuantity] ELSE 0 END) AS OtherPortion,
			SUM(CASE WHEN purch.[vcContext] = 'ticket' THEN purch.[mServiceCharge] * purch.[iQuantity]  
					WHEN purch.[vcContext] = 'servicecharge' THEN purch.[mPrice] * purch.[iQuantity] ELSE 0.0 END) AS ServiceCharge,
			ISNULL(SUM(purch.[mAdjustment] * purch.[iQuantity]),0.0) AS Adjustment,
			ISNULL(SUM(purch.[mLineItemTotal]),0.0) AS LineItemTotal,
			ISNULL(SUM(CASE WHEN purch.[vcContext] = 'shippingmerch' OR purch.[vcContext] = 'shippingticket' 
				OR purch.[vcContext] = 'linkedshippingticket' THEN purch.[mLineItemTotal] ELSE 0 END),0.0) AS ShipCharged,			
			SUM(CASE WHEN purch.[vcContext] = 'processing' THEN purch.[mLineItemTotal] ELSE 0 END) AS ProcessingFee,
			i.[mTotalPaid]			AS TotalPaid,
			i.[mNetPaid]			AS NetPaid,
			CAST(0.0 AS decimal)	AS Damaged,			
			ibs.[mHandlingComputed] AS ShipHandlingCalc, 
			CAST(0.0 AS DECIMAL(9,2)) AS ShipActual,
			CAST(0.0 AS INT)		AS Shipments,
			ISNULL(SUM(CASE WHEN purch.[vcContext] = 'shippingmerch' OR purch.[vcContext] = 'shippingticket' 
				OR purch.[vcContext] = 'linkedshippingticket' THEN purch.[mLineItemTotal] ELSE 0 END),0.0) AS ShipDifferential, 
			ISNULL(SUM(CASE WHEN purch.[vcContext] = 'shippingmerch' THEN purch.[mLineItemTotal] ELSE 0 END),0.0) AS ShipMerch,
			ISNULL(SUM(CASE WHEN purch.[vcContext] = 'shippingticket' OR purch.[vcContext] = 'linkedshippingticket' 
				THEN purch.[mLineItemTotal] ELSE 0 END),0.0) AS ShipTicket
	FROM	InvoiceBillShip ibs, 
			Invoice i, 
			#Invoices inv 
			LEFT OUTER JOIN #tmpPurchases purch 
				ON purch.[tInvoiceId] = inv.[InvoiceId] 
	WHERE	i.[Id] = inv.[InvoiceId] 
			AND	ibs.[tInvoiceId] = inv.[InvoiceId]
	GROUP BY inv.[IndexId], inv.[InvoiceId], i.[mTotalPaid], i.[mTotalRefunds], i.[mNetPaid], ibs.[mHandlingComputed]
	ORDER BY inv.[InvoiceId] DESC


	--deal with shipments
	CREATE TABLE #tmpShipments(
		
		InvoiceId INT, 
		Shipments INT, 
		ShipActual MONEY
	)
	
	INSERT	#tmpShipments(InvoiceId, Shipments, ShipActual)
	SELECT	agg.[InvoiceId],
			COUNT(ship.[Id]) AS Shipments,
			ISNULL(SUM(ship.[mShippingActual]),0.0) AS ShipActual
	FROM	#tmpAggregates agg 
			LEFT OUTER JOIN InvoiceShipment ship 
				ON ship.[tInvoiceId] = agg.[InvoiceId]
	GROUP BY agg.[InvoiceId]
	ORDER BY agg.[InvoiceId] DESC

	--now deal with refunds
	CREATE TABLE #tmpRefundAdjustments(
		
		LineRefunds INT, 
		MerchRefunds INT, 
		BundleRefunds INT, 
		TicketsRefunds INT, 
		DonationsRefunds INT,
		ServiceRefunds INT, 
		ProcessingRefunds INT, 
		MerchShippingRefunds INT, 
		TicketShippingRefunds INT, 
		DamageRefunds INT,
		OtherRefunds INT, 
		MerchRefunded MONEY, 
		BundlesRefunded MONEY, 
		TicketsRefunded MONEY, 
		DonationsRefunded MONEY, 
		ServiceRefunded MONEY, 
		ProcessingRefunded MONEY, 
		MerchShippingRefunded MONEY, 
		TicketShippingRefunded MONEY, 
		DamageRefunded MONEY, 
		OtherRefunded MONEY
	)
	
	INSERT	#tmpRefundAdjustments(LineRefunds, MerchRefunds, BundleRefunds, TicketsRefunds, DonationsRefunds,
		ServiceRefunds, ProcessingRefunds, MerchShippingRefunds, TicketShippingRefunds, DamageRefunds,
		OtherRefunds, MerchRefunded, BundlesRefunded, TicketsRefunded, DonationsRefunded, ServiceRefunded, ProcessingRefunded,
		MerchShippingRefunded, TicketShippingRefunded, DamageRefunded, OtherRefunded)
	SELECT	COUNT(DISTINCT(ref.[tInvoiceId])) AS LineRefunds,
			SUM(CASE WHEN ref.[vcContext] = 'merch' THEN 1 ELSE 0 END) AS MerchRefunds,
			SUM(CASE WHEN ref.[vcContext] = 'merch' THEN 1 ELSE 0 END) AS BundleRefunds,
			SUM(CASE WHEN ref.[vcContext] = 'ticket' THEN 1 ELSE 0 END) AS TicketsRefunds,
			SUM(CASE WHEN ref.[vcContext] = 'charity' THEN 1 ELSE 0 END) AS DonationsRefunds,
			SUM(CASE WHEN ref.[vcContext] = 'servicecharge' THEN 1 ELSE 0 END) AS ServiceRefunds,			
			SUM(CASE WHEN ref.[vcContext] = 'processing' THEN 1 ELSE 0 END) AS ProcessingRefunds,
			SUM(CASE WHEN ref.[vcContext] = 'shippingmerch' THEN 1 ELSE 0 END) AS MerchShippingRefunds, 
			SUM(CASE WHEN ref.[vcContext] = 'shippingticket' OR ref.[vcContext] = 'linkedshippingticket' THEN 1 
				ELSE 0 END) AS TicketShippingRefunds,
			SUM(CASE WHEN ref.[vcContext] = 'damaged' THEN 1 ELSE 0 END) AS DamageRefunds,			
			SUM(CASE WHEN (ref.[vcContext] <> 'merch' AND ref.[vcContext] <> 'bundle' AND ref.[vcContext] <> 'ticket' AND ref.[vcContext] <> 'charity' AND 
				ref.[vcContext] <> 'servicecharge' AND ref.[vcContext] <> 'processing' AND 
				ref.[vcContext] <> 'shippingmerch' AND ref.[vcContext] <> 'shippingticket' AND 
				ref.[vcContext] <> 'damaged')  THEN 1 ELSE 0 END) AS OtherRefunds,
			SUM(CASE WHEN ref.[vcContext] = 'merch' THEN ABS(ref.[mLineItemTotal]) ELSE 0.0 END) AS MerchRefunded,
			SUM(CASE WHEN ref.[vcContext] = 'bundle' THEN ABS(ref.[mLineItemTotal]) ELSE 0.0 END) AS BundlesRefunded,
			SUM(CASE WHEN ref.[vcContext] = 'ticket' THEN ABS(ref.[mLineItemTotal]) ELSE 0.0 END) AS TicketsRefunded,
			SUM(CASE WHEN ref.[vcContext] = 'charity' THEN ABS(ref.[mLineItemTotal]) ELSE 0.0 END) AS DonationsRefunded,
			SUM(CASE WHEN ref.[vcContext] = 'servicecharge' THEN ABS(ref.[mLineItemTotal]) ELSE 0.0 END) AS ServiceRefunded,			
			SUM(CASE WHEN ref.[vcContext] = 'processing' THEN ABS(ref.[mLineItemTotal]) ELSE 0.0 END) AS ProcessingRefunded,
			SUM(CASE WHEN ref.[vcContext] = 'shippingmerch' THEN ABS(ref.[mLineItemTotal]) ELSE 0.0 END) AS MerchShippingRefunded, 
			SUM(CASE WHEN ref.[vcContext] = 'shippingticket' OR ref.[vcContext] = 'linkedshippingticket' THEN ABS(ref.[mLineItemTotal]) 
				ELSE 0.0 END) AS TicketShippingRefunded,
			SUM(CASE WHEN ref.[vcContext] = 'damaged' THEN ABS(ref.[mLineItemTotal]) ELSE 0.0 END) AS DamageRefunded,
			SUM(CASE WHEN (ref.[vcContext] <> 'merch' AND ref.[vcContext] <> 'bundle' AND ref.[vcContext] <> 'ticket' AND ref.[vcContext] <> 'charity' AND 
				ref.[vcContext] <> 'servicecharge' AND ref.[vcContext] <> 'processing' AND 
				ref.[vcContext] <> 'shippingmerch' AND ref.[vcContext] <> 'shippingticket' AND 
				ref.[vcContext] <> 'damaged')  THEN ABS(ref.[mLineItemTotal]) ELSE 0.0 END) AS OtherRefunded
	FROM	#tmpRefundItems ref	
	
	UPDATE	#tmpAggregates
	SET		[Shipments] = agg.[Shipments] + ISNULL(ship.[Shipments],0),
			[ShipActual] = agg.[ShipActual] + ISNULL(ship.[ShipActual],0),
			[ShipDifferential] = 
				CASE WHEN ISNULL(ship.[ShipActual], 0.0) = 0.0 
					THEN 0.0 ELSE agg.[ShipDifferential] - ship.[ShipActual] 
				END
	FROM	#tmpAggregates agg, #tmpShipments ship
	WHERE	agg.[InvoiceId] = ship.[InvoiceId] 

	SELECT	* 
	FROM	#tmpAggregates agg 
	WHERE	agg.[IndexId] BETWEEN (@StartRowIndex) AND (@StartRowIndex + @PageSize - 1) 

	SELECT	ISNULL(COUNT([InvoiceId]),0)		AS 'NumInvoices', 
			ISNULL(SUM(LinePurchases),0)		AS 'LinePurchases', 
			ISNULL(SUM(ItemsPurchased),0)		AS 'ItemsPurchased',
			ISNULL(SUM(MerchPurchased),0)		AS 'MerchPurchased',
			ISNULL(SUM(BundlesPurchased),0)		AS 'BundlesPurchased',
			ISNULL(SUM(TicketsPurchased),0)		AS 'TicketsPurchased', 
			ISNULL(SUM(DonationsPurchased),0)	AS 'DonationsPurchased', 
			ISNULL(SUM(OtherPurchased),0)		AS 'OtherPurchased', 
			ISNULL(SUM(BaseSales),0)			AS 'BaseSales', 
			ISNULL(SUM(TicketPortion),0)		AS 'TicketPortion', 
			ISNULL(SUM(MerchPortion),0)			AS 'MerchPortion', 
			ISNULL(SUM(BundlePortion),0)		AS 'BundlePortion', 
			ISNULL(SUM(DonationPortion),0)		AS 'DonationPortion', 
			ISNULL(SUM(OtherPortion),0)			AS 'OtherPortion', 
			ISNULL(SUM(ServiceCharge),0)		AS 'ServiceCharge',
			ISNULL(SUM(Adjustment),0)			AS 'Adjustment',
			ISNULL(SUM(LineItemTotal),0)		AS 'LineItemTotal',
			ISNULL(SUM(ShipCharged),0)			AS 'ShipCharged', 
			ISNULL(SUM(ProcessingFee),0)		AS 'ProcessingFee', 
			ISNULL(SUM(TotalPaid),0)			AS 'TotalPaid', 
			ISNULL(SUM(NetPaid),0)				AS 'NetPaid', 
			ISNULL(SUM(Damaged),0)				AS 'Damaged', 			 
			ISNULL(SUM(ShipHandlingCalc),0)		AS 'ShipHandlingCalc', 
			ISNULL(SUM(ShipActual),0) 			AS 'ShipActual', 
			ISNULL(SUM(Shipments),0)			AS 'Shipments',
			ISNULL(SUM(ShipDifferential),0)		AS 'ShipDifferential', 
			ISNULL(SUM(ShipMerch),0)			AS 'ShipMerch', 
			ISNULL(SUM(ShipTicket),0)			AS 'ShipTicket'
	FROM	#tmpAggregates agg

	SELECT  ISNULL(SUM(LineRefunds),0)						AS 'LineRefunds', 
			ISNULL(SUM(MerchRefunds),0)						AS 'MerchRefunds', 
			ISNULL(SUM(BundleRefunds),0)					AS 'BundleRefunds', 
			ISNULL(SUM(TicketsRefunds),0)					AS 'TicketsRefunds',
			ISNULL(SUM(DonationsRefunds),0)					AS 'DonationsRefunds',
			ISNULL(SUM(ServiceRefunds),0)					AS 'ServiceRefunds',
			ISNULL(SUM(ProcessingRefunds),0)				AS 'ProcessingRefunds',
			ISNULL(SUM(MerchShippingRefunds),0)				AS 'MerchShippingRefunds',
			ISNULL(SUM(TicketShippingRefunds),0)			AS 'TicketShippingRefunds',
			ISNULL(SUM(DamageRefunds),0)					AS 'DamageRefunds',
			ISNULL(SUM(OtherRefunds),0)						AS 'OtherRefunds',
			ISNULL(ABS(SUM(MerchRefunded)),0)				AS 'MerchRefunded', 
			ISNULL(ABS(SUM(BundlesRefunded)),0)				AS 'BundlesRefunded', 
			ISNULL(ABS(SUM(TicketsRefunded)),0)				AS 'TicketsRefunded',
			ISNULL(ABS(SUM(DonationsRefunded)),0)			AS 'DonationsRefunded',	
			ISNULL(ABS(SUM(ServiceRefunded)),0)				AS 'ServiceRefunded', 
			ISNULL(ABS(SUM(ProcessingRefunded)),0)			AS 'ProcessingRefunded', 
			ISNULL(ABS(SUM(MerchShippingRefunded)),0)		AS 'MerchShippingRefunded', 
			ISNULL(ABS(SUM(TicketShippingRefunded)),0)		AS 'TicketShippingRefunded',
			ISNULL(ABS(SUM(DamageRefunded)),0)				AS 'DamageRefunded',
			ISNULL(ABS(SUM(OtherRefunded)),0)				AS 'OtherRefunded'
	FROM	#tmpRefundAdjustments ref

END
GO
