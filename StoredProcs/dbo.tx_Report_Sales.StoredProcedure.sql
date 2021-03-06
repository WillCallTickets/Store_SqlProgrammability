USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_Report_Sales]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 11/04/11
-- Description:	Aggregates invoice item rows to provide sales totals. 
-- Returns:		Wcss.ReportRow
-- exec [tx_Report_Sales] '0B8BFCC3-F45E-44E8-A485-476B212437C0', '6/1/2009','6/30/2013'
/*
inv itms procfee	numtik		nummerch				dmged			tktrfds		merchrfd
7	21	 7			2		0	5			0	0	0	7		0	0	135		0	75			0	0	0	0	0

select * from invoiceitem where purchaseaction = 'purchasedthenremoved'
*/
-- =============================================

CREATE	PROC [dbo].[tx_Report_Sales](

	@applicationId	UNIQUEIDENTIFIER,
	@StartDate		VARCHAR(50),
	@EndDate		VARCHAR(50)

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
	
		Id				INT, 
		tInvoiceId		INT, 
		vcContext		VARCHAR(256), 
		iQuantity		INT, 
		mPrice			MONEY, 
		mServiceCharge	MONEY, 
		mAdjustment		MONEY, 
		mLineItemTotal	MONEY
	)			
			
	INSERT	#tmpPurchases(Id, tInvoiceId, vcContext, iQuantity, mPrice, mServiceCharge, mAdjustment, mLineItemTotal)
	SELECT	ii.Id, ii.tInvoiceId, ii.vcContext, ii.iQuantity, ii.mPrice, ii.mServiceCharge, ii.mAdjustment, ii.mLineItemTotal
	FROM	InvoiceItem ii, #Invoices i
	WHERE	ii.[tInvoiceId] = i.[InvoiceId] 
			AND ii.[PurchaseAction] = 'Purchased' 
			AND (ii.[vcContext] <> 'noteitem' AND ii.[vcContext] <> 'refund')

	CREATE TABLE #tmpRefundItems(
		Id				INT, 
		tInvoiceId		INT, 
		vcContext		VARCHAR(256), 
		iQuantity		INT, 
		mPrice			MONEY, 
		mServiceCharge	MONEY, 
		mLineItemTotal	MONEY
	)			
			
	INSERT	#tmpRefundItems(Id, tInvoiceId, vcContext, iQuantity, mPrice, mServiceCharge, mLineItemTotal)
	SELECT	ii.Id, ii.tInvoiceId, ii.vcContext, ii.iQuantity, ii.mPrice, ii.mServiceCharge, ii.mLineItemTotal
	FROM	InvoiceTransaction it, InvoiceItem ii
	WHERE	(it.[TransType] = 'Refund' OR it.[TransType] = 'Void') 
			AND it.[dtStamp] BETWEEN @StartDate AND @EndDate 
			AND it.[tInvoiceId] = ii.[tInvoiceId] 
			AND ii.[PurchaseAction] = 'PurchasedThenRemoved'
	
	CREATE TABLE #tmpAggregates(
	
		IndexId INT, 
		InvoiceId INT, 
		NumTickets INT, 
		NumAdditionalServiceCharges INT, 
		NumMerch INT, 
		NumBundles INT, 
		NumDonations INT, 
		NumTicketShipping INT, 
		NumMerchShipping INT, 
		NumDiscounts INT,
		NumOther INT, 
		SalesProcessingFee MONEY, 
		SalesTicket MONEY, 
		SalesServiceCharge MONEY, 
		SalesAdditionalServiceCharge MONEY,
		SalesMerch MONEY, 
		SalesBundle MONEY, 
		SalesDonation MONEY, 
		SalesTicketShipping MONEY, 
		SalesMerchShipping MONEY, 
		SalesDiscount MONEY,
		SalesOther MONEY, 
		AggTotalPaidOnInvoices MONEY, 
		AggNetPaidOnInvoices MONEY, 
		AggAdjustment MONEY, 
		AggShipHandlingCalculation MONEY, 
		AggShipActual MONEY, 
		NumShipments INT, 
		NumAdjustments INT, 
		AggShipDifferential MONEY	
	)
	
	INSERT	#tmpAggregates(
		IndexId, InvoiceId, 
		NumTickets, NumAdditionalServiceCharges, NumMerch, NumBundles, NumDonations, 
		NumTicketShipping, NumMerchShipping, NumDiscounts, NumOther, 
		SalesProcessingFee, SalesTicket, SalesServiceCharge, SalesAdditionalServiceCharge, 
		SalesMerch, SalesBundle, SalesDonation, 
		SalesTicketShipping, SalesMerchShipping, SalesDiscount, SalesOther, 		
		AggTotalPaidOnInvoices, AggNetPaidOnInvoices, AggAdjustment, 
		AggShipHandlingCalculation, 
		AggShipActual, NumShipments, NumAdjustments, AggShipDifferential)
	SELECT	inv.[IndexId]																						AS IndexId, 
			inv.[InvoiceId],			
			--ITEM ACTIVITY				
			ISNULL(SUM(CASE WHEN purch.[vcContext] = 'ticket' THEN purch.[iQuantity] ELSE 0 END), 0)			AS NumTickets,
			ISNULL(SUM(CASE WHEN purch.[vcContext] = 'servicecharge' THEN purch.[iQuantity] ELSE 0 END), 0)		AS NumAdditionalServiceCharges,
			ISNULL(SUM(CASE WHEN purch.[vcContext] = 'merch' THEN purch.[iQuantity] ELSE 0 END), 0)				AS NumMerch,
			ISNULL(SUM(CASE WHEN purch.[vcContext] = 'bundle' THEN purch.[iQuantity] ELSE 0 END), 0)			AS NumBundle,
			ISNULL(SUM(CASE WHEN purch.[vcContext] = 'charity' THEN purch.[iQuantity] ELSE 0 END), 0)			AS NumDonations,
			ISNULL(SUM(CASE WHEN purch.[vcContext] = 'shippingticket' THEN purch.[iQuantity] ELSE 0 END), 0)	AS NumTicketShipping,
			ISNULL(SUM(CASE WHEN purch.[vcContext] = 'shippingmerch' OR purch.[vcContext] = 'linkedshippingticket' 
							THEN purch.[iQuantity] ELSE 0 END), 0)												AS NumMerchShipping,
			ISNULL(SUM(CASE WHEN purch.[vcContext] = 'discount' THEN purch.[iQuantity] ELSE 0 END), 0)			AS NumDiscounts,
			--other is a catchall
			ISNULL(SUM(CASE WHEN (purch.[vcContext] <> 'processing' AND purch.[vcContext] <> 'ticket' AND 
							purch.[vcContext] <> 'servicecharge' AND 
							purch.[vcContext] <> 'merch' AND purch.[vcContext] <> 'bundle' AND purch.[vcContext] <> 'charity' AND 
							purch.[vcContext] <> 'shippingticket' AND purch.[vcContext] <> 'shippingmerch' AND 
							purch.[vcContext] <> 'discount' AND purch.[vcContext] <> 'damaged' AND 
							purch.[vcContext] <> 'linkedshippingticket') 
							THEN purch.[iQuantity] ELSE 0 END), 0)												AS NumOther,
			--ITEM SALES
			ISNULL(SUM(CASE WHEN purch.[vcContext] = 'processing' 
							THEN purch.[mPrice] * purch.[iQuantity] ELSE 0.0 END), 0)							AS SalesProcessingFee,
			ISNULL(SUM(CASE WHEN purch.[vcContext] = 'ticket' 
							THEN purch.[mPrice] * purch.[iQuantity] ELSE 0.0 END), 0)							AS SalesTicket,
			ISNULL(SUM(CASE WHEN purch.[vcContext] = 'ticket' THEN purch.[mServiceCharge] * purch.[iQuantity]  
							ELSE 0.0 END), 0)																	AS SalesServiceCharge,
			ISNULL(SUM(CASE WHEN purch.[vcContext] = 'servicecharge' 
							THEN purch.[mPrice] * purch.[iQuantity] ELSE 0.0 END), 0)							AS SalesAdditionalServiceCharge,							
			ISNULL(SUM(CASE WHEN purch.[vcContext] = 'merch' 
							THEN purch.[mPrice] * purch.[iQuantity] ELSE 0.0 END), 0)							AS SalesMerch,
			ISNULL(SUM(CASE WHEN purch.[vcContext] = 'bundle' 
							THEN purch.[mPrice] * purch.[iQuantity] ELSE 0.0 END), 0)							AS SalesBundle,
			ISNULL(SUM(CASE WHEN purch.[vcContext] = 'charity' 
							THEN purch.[mPrice] * purch.[iQuantity] ELSE 0.0 END), 0)							AS SalesDonation,			
			ISNULL(SUM(CASE WHEN purch.[vcContext] = 'shippingticket' OR purch.[vcContext] = 'linkedshippingticket' 
							THEN purch.[mPrice] * purch.[iQuantity] ELSE 0.0 END), 0)							AS SalesTicketShipping,
			ISNULL(SUM(CASE WHEN purch.[vcContext] = 'shippingmerch' 
							THEN purch.[mPrice] * purch.[iQuantity] ELSE 0.0 END), 0)							AS SalesMerchShipping,
			ISNULL(SUM(CASE WHEN purch.[vcContext] = 'discount' 
							THEN purch.[mPrice] * purch.[iQuantity] ELSE 0.0 END), 0)							AS SalesDiscount,							
			ISNULL(SUM(CASE WHEN (purch.[vcContext] <> 'processing' AND purch.[vcContext] <> 'ticket' AND 
							purch.[vcContext] <> 'servicecharge' AND 
							purch.[vcContext] <> 'merch' AND purch.[vcContext] <> 'bundle' AND purch.[vcContext] <> 'charity' AND 
							purch.[vcContext] <> 'shippingticket' AND purch.[vcContext] <> 'shippingmerch' AND 
							purch.[vcContext] <> 'discount' AND purch.[vcContext] <> 'damaged' AND 
							purch.[vcContext] <> 'linkedshippingticket')
							THEN purch.[mPrice] * purch.[iQuantity] ELSE 0.0 END), 0)							AS SalesOther,			
			i.[mTotalPaid]																						AS AggTotalPaidOnInvoices,
			i.[mNetPaid]																						AS AggNetPaidOnInvoices,
			SUM(purch.[mAdjustment] * purch.[iQuantity])														AS AggAdjustment,				
			ISNULL(ibs.[mHandlingComputed], 0)																	AS AggShipHandlingCalculation, 			
			CAST(0.0 AS DECIMAL(9,2))																			AS AggShipActual,
			CAST(0 AS INT)																						AS NumShipments,
			ISNULL(SUM(CASE WHEN purch.[mAdjustment] <> 0.0 THEN 1 ELSE 0 END), 0)								AS NumAdjustments,			
			ISNULL(SUM(CASE WHEN purch.[vcContext] = 'shippingmerch' OR purch.[vcContext] = 'shippingticket' 
				OR purch.[vcContext] = 'linkedshippingticket' THEN purch.[mLineItemTotal] ELSE 0 END), 0.0)		AS AggShipDifferential
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
		
		InvoiceId		INT, 
		NumShipments	INT, 
		AggShipActual	MONEY
	)
	
	INSERT #tmpShipments(InvoiceId, NumShipments, AggShipActual)
	SELECT	agg.[InvoiceId],
			COUNT(ship.[Id]) AS NumShipments,
			ISNULL(SUM(ship.[mShippingActual]),0.0) AS AggShipActual
	FROM	#tmpAggregates agg 
			LEFT OUTER JOIN InvoiceShipment ship 
				ON ship.[tInvoiceId] = agg.[InvoiceId]
	GROUP BY agg.[InvoiceId]
	ORDER BY agg.[InvoiceId] DESC

	-- refunds
	CREATE TABLE #tmpRefundAdjustments(
	
		NumInvoices INT, 
		NumItems INT,
		NumProcessingFees INT, 
		NumTickets INT, 
		NumAdditionalServiceCharges INT, 
		NumMerch INT, 
		NumBundles INT, 
		NumDonations INT, 
		NumTicketShipping INT, 
		NumMerchShipping INT, 
		NumOther INT, 
		NumDamaged INT, 		
		RefundedProcessingFees MONEY, 
		RefundedTickets MONEY, 
		RefundedServiceCharges MONEY, 
		RefundedMerch MONEY, 
		RefundedBundles MONEY, 
		RefundedDonations MONEY, 
		RefundedTicketShipping MONEY, 
		RefundedMerchShipping MONEY, 
		RefundedOther MONEY, 
		RefundedDamaged MONEY
	)
		
	INSERT	#tmpRefundAdjustments(
		NumInvoices, NumItems,		
		NumProcessingFees, 
		NumTickets, NumAdditionalServiceCharges, 
		NumMerch, NumBundles, NumDonations, 
		NumTicketShipping, NumMerchShipping, 
		NumOther, NumDamaged, 
		RefundedProcessingFees, 
		RefundedTickets, RefundedServiceCharges, 
		RefundedMerch, RefundedBundles, RefundedDonations, 
		RefundedTicketShipping, RefundedMerchShipping, 
		RefundedOther, RefundedDamaged)
	SELECT	ISNULL(COUNT(DISTINCT(ref.[tInvoiceId])), 0)																AS NumInvoices,
			ISNULL(SUM(ref.[iQuantity]), 0)																				AS NumItems,			
			ISNULL(SUM(CASE WHEN ref.[vcContext] = 'processing' THEN ref.[iQuantity] ELSE 0 END), 0)					AS NumProcessingFees,			
			ISNULL(SUM(CASE WHEN ref.[vcContext] = 'ticket' THEN ref.[iQuantity] ELSE 0 END), 0)						AS NumTickets,			
			ISNULL(SUM(CASE WHEN ref.[vcContext] = 'servicecharge' THEN ref.[iQuantity] ELSE 0 END), 0)					AS NumAdditionalServiceCharges,
			ISNULL(SUM(CASE WHEN ref.[vcContext] = 'merch' THEN ref.[iQuantity] ELSE 0 END), 0)							AS NumMerch,
			ISNULL(SUM(CASE WHEN ref.[vcContext] = 'bundle' THEN ref.[iQuantity] ELSE 0 END), 0)							AS NumBundles,
			ISNULL(SUM(CASE WHEN ref.[vcContext] = 'charity' THEN ref.[iQuantity] ELSE 0 END), 0)						AS NumDonations,
			ISNULL(SUM(CASE WHEN ref.[vcContext] = 'shippingticket' THEN ref.[iQuantity] ELSE 0 END), 0)				AS NumTicketShipping,
			ISNULL(SUM(CASE WHEN ref.[vcContext] = 'shippingmerch' THEN ref.[iQuantity] ELSE 0 END), 0)					AS NumMerchShipping,
			ISNULL(SUM(CASE WHEN ref.[vcContext] = 'damaged' THEN ref.[iQuantity] ELSE 0 END), 0)						AS NumDamaged,
			ISNULL(SUM(CASE WHEN (ref.[vcContext] <> 'processing' AND ref.[vcContext] <> 'ticket' AND 
							ref.[vcContext] <> 'servicecharge' AND 
							ref.[vcContext] <> 'merch' AND ref.[vcContext] <> 'bundle' AND ref.[vcContext] <> 'charity' AND 
							ref.[vcContext] <> 'shippingticket' AND ref.[vcContext] <> 'shippingmerch' AND 
							ref.[vcContext] <> 'discount' AND ref.[vcContext] <> 'damaged' AND 
							ref.[vcContext] <> 'linkedshippingticket') 
							THEN ref.[iQuantity] ELSE 0 END), 0)														AS NumOther, 	
			ISNULL(SUM(CASE WHEN ref.[vcContext] = 'processing' THEN ABS(ref.[mLineItemTotal]) ELSE 0.0 END), 0.0)		AS RefundedProcessingFees, 
			ISNULL(SUM(CASE WHEN ref.[vcContext] = 'ticket' THEN ABS(ref.[iQuantity] * ref.[mPrice]) ELSE 0.0 END), 0.0) AS RefundedTickets,			
			ISNULL(SUM(CASE WHEN ref.[vcContext] = 'ticket' THEN ref.[mServiceCharge] * ref.[iQuantity]  
							WHEN ref.[vcContext] = 'servicecharge' 
							THEN ref.[mLineItemTotal] ELSE 0.0 END), 0)													AS RefundedServiceCharges,
			ISNULL(SUM(CASE WHEN ref.[vcContext] = 'merch' THEN ABS(ref.[mLineItemTotal]) ELSE 0.0 END), 0.0)			AS RefundedMerch,
			ISNULL(SUM(CASE WHEN ref.[vcContext] = 'bundle' THEN ABS(ref.[mLineItemTotal]) ELSE 0.0 END), 0.0)			AS RefundedBundles,
			ISNULL(SUM(CASE WHEN ref.[vcContext] = 'charity' THEN ABS(ref.[mLineItemTotal]) ELSE 0.0 END), 0.0)			AS RefundedDonations,
			ISNULL(SUM(CASE WHEN ref.[vcContext] = 'shippingticket' THEN ABS(ref.[mLineItemTotal]) ELSE 0.0 END), 0.0)	AS RefundedTicketShipping,
			ISNULL(SUM(CASE WHEN ref.[vcContext] = 'shippingmerch' THEN ABS(ref.[mLineItemTotal]) ELSE 0.0 END), 0.0)	AS RefundedMerchShipping,
			ISNULL(SUM(CASE WHEN ref.[vcContext] = 'damaged' THEN ABS(ref.[mLineItemTotal]) ELSE 0.0 END), 0.0)			AS RefundedDamaged,
			ISNULL(SUM(CASE WHEN (ref.[vcContext] <> 'processing' AND ref.[vcContext] <> 'ticket' AND 
							ref.[vcContext] <> 'servicecharge' AND 
							ref.[vcContext] <> 'merch' AND ref.[vcContext] <> 'bundle' AND ref.[vcContext] <> 'charity' AND 
							ref.[vcContext] <> 'shippingticket' AND ref.[vcContext] <> 'shippingmerch' AND 
							ref.[vcContext] <> 'discount' AND ref.[vcContext] <> 'damaged' AND 
							ref.[vcContext] <> 'linkedshippingticket') 
							THEN ABS(ref.[mLineItemTotal]) ELSE 0.0 END), 0.0)											AS RefundedOther
	FROM	#tmpRefundItems ref
		
	UPDATE	#tmpAggregates
	SET		[NumShipments] = agg.[NumShipments] + ISNULL(ship.[NumShipments],0),
			[AggShipActual] = agg.[AggShipActual] + ISNULL(ship.[AggShipActual],0),
			[AggShipDifferential] = 
				CASE WHEN ISNULL(ship.[AggShipActual], 0.0) = 0.0 
					THEN 0.0 ELSE agg.[AggShipDifferential] - ship.[AggShipActual] END
	FROM	#tmpAggregates agg, #tmpShipments ship
	WHERE	agg.[InvoiceId] = ship.[InvoiceId] 	
	
	SELECT	ISNULL(COUNT([InvoiceId]), 0)						AS 'NumInvoices', 	
			ISNULL(SUM([NumTickets]), 0)						AS 'NumTickets', 
			ISNULL(SUM([NumAdditionalServiceCharges]), 0)		AS 'NumAdditionalServiceCharges', 
			ISNULL(SUM([NumMerch]), 0)							AS 'NumMerch', 
			ISNULL(SUM([NumBundles]), 0)						AS 'NumBundles', 
			ISNULL(SUM([NumDonations]), 0)						AS 'NumDonations', 
			ISNULL(SUM([NumTicketShipping]), 0)					AS 'NumTicketShipping', 
			ISNULL(SUM([NumMerchShipping]), 0)					AS 'NumMerchShipping', 
			ISNULL(SUM([NumDiscounts]), 0)						AS 'NumDiscounts', 
			ISNULL(SUM([NumOther]), 0)							AS 'NumOther', 
			ISNULL(SUM([NumShipments]), 0)						AS 'NumShipments',
			ISNULL(SUM([NumAdjustments]), 0)					AS 'NumAdjustments',
	
			ISNULL(SUM([SalesProcessingFee]), 0.0)				AS 'SalesProcessingFee',
			ISNULL(SUM([SalesTicket]), 0.0)						AS 'SalesTicket',
			ISNULL(SUM([SalesServiceCharge]), 0.0)				AS 'SalesServiceCharge',
			ISNULL(SUM([SalesAdditionalServiceCharge]), 0.0)	AS 'SalesAdditionalServiceCharge',
			ISNULL(SUM([SalesMerch]), 0.0)						AS 'SalesMerch',
			ISNULL(SUM([SalesBundle]), 0.0)						AS 'SalesBundle',
			ISNULL(SUM([SalesDonation]), 0.0)					AS 'SalesDonation',
			ISNULL(SUM([SalesTicketShipping]), 0.0)				AS 'SalesTicketShipping',
			ISNULL(SUM([SalesMerchShipping]), 0.0)				AS 'SalesMerchShipping',
			(ISNULL(SUM([SalesDiscount]), 0.0) * -1)			AS 'SalesDiscount',
			ISNULL(SUM([SalesOther]), 0.0)						AS 'SalesOther',
			
			ISNULL(SUM([AggTotalPaidOnInvoices]), 0.0)			AS 'AggTotalPaidOnInvoices',
			ISNULL(SUM([AggNetPaidOnInvoices]), 0.0)			AS 'AggNetPaidOnInvoices',
			ISNULL(SUM([AggAdjustment]), 0.0)					AS 'AggAdjustment',
			ISNULL(SUM([AggShipHandlingCalculation]), 0.0)		AS 'AggShipHandlingCalculation',
			ISNULL(SUM([AggShipActual]), 0.0)					AS 'AggShipActual',			
			ISNULL(SUM([AggShipDifferential]), 0.0)				AS 'AggShipDifferential'
	FROM	#tmpAggregates agg

	SELECT  ISNULL(SUM(NumInvoices),0)							AS 'NumInvoices', 
			ISNULL(SUM(NumItems),0)								AS 'NumItems', 
			ISNULL(SUM(NumProcessingFees),0)					AS 'NumProcessingFees', 
			ISNULL(SUM(NumTickets),0)							AS 'NumTickets',
			ISNULL(SUM(NumAdditionalServiceCharges),0)			AS 'NumAdditionalServiceCharges',
			ISNULL(SUM(NumMerch),0)								AS 'NumMerch',
			ISNULL(SUM(NumBundles),0)							AS 'NumBundles',
			ISNULL(SUM(NumDonations),0)							AS 'NumDonations',
			ISNULL(SUM(NumTicketShipping),0)					AS 'NumTicketShipping',
			ISNULL(SUM(NumMerchShipping),0)						AS 'NumMerchShipping',
			ISNULL(SUM(NumDamaged),0)							AS 'NumDamaged',
			ISNULL(SUM(NumOther),0)								AS 'NumOther',
			ISNULL(ABS(SUM(RefundedProcessingFees)),0)			AS 'RefundedProcessingFees', 
			ISNULL(ABS(SUM(RefundedTickets)),0)					AS 'RefundedTickets',
			ISNULL(ABS(SUM(RefundedServiceCharges)),0)			AS 'RefundedServiceCharges',	
			ISNULL(ABS(SUM(RefundedMerch)),0)					AS 'RefundedMerch', 
			ISNULL(ABS(SUM(RefundedBundles)),0)					AS 'RefundedBundles', 
			ISNULL(ABS(SUM(RefundedDonations)),0)				AS 'RefundedDonations', 
			ISNULL(ABS(SUM(RefundedMerchShipping)),0)			AS 'RefundedMerchShipping', 
			ISNULL(ABS(SUM(RefundedTicketShipping)),0)			AS 'RefundedTicketShipping',
			ISNULL(ABS(SUM(RefundedDamaged)),0)					AS 'RefundedDamaged',
			ISNULL(ABS(SUM(RefundedOther)),0)					AS 'RefundedOther'
	FROM	#tmpRefundAdjustments ref

END
GO
