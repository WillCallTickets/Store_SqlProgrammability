USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_Report_Sales_Gifts_InRange]    Script Date: 10/02/2016 18:14:33 ******/
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
-- exec tx_Report_Sales_Gifts_InRange '83c1c3f6-c539-41d7-815d-143fbd40e41f', '5/1/2009','5/31/2009',1,100
-- exec [dbo].[tx_Report_Sales_Gifts_InRange] @applicationId='83C1C3F6-C539-41D7-815D-143FBD40E41F',@StartDate='04/01/2010 12:00AM',@EndDate='04/28/2010 11:59PM',@StartRowIndex=1,@PageSize=100
-- =============================================

CREATE	PROC [dbo].[tx_Report_Sales_Gifts_InRange](

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
	
        IndexId		INT IDENTITY (0, 1) NOT NULL,
        InvoiceId	INT
    )

	INSERT INTO #Invoices (InvoiceId)
	SELECT	i.[Id] as 'InvoiceId'
	FROM	Invoice i
	WHERE	i.[ApplicationId] = @applicationId 
			AND i.[InvoiceStatus] <> 'notpaid' 
			AND i.[dtInvoiceDate] BETWEEN @StartDate AND @EndDate
	ORDER BY i.[Id] DESC

	CREATE TABLE #tmpMerch(Id INT)
	
	INSERT	#tmpMerch(Id)
	SELECT	m.Id
	FROM	[Merch] m 
			LEFT OUTER JOIN [Merch] parent 
				ON parent.[Id] = m.[tParentListing] 
	WHERE	parent.[vcDeliveryType] = 'giftcertificate'
	ORDER BY m.[mPrice] ASC

	CREATE TABLE #tmpPurchases(
		
		Id				INT, 
		mLineItemTotal	MONEY, 
		[Description]	VARCHAR(500)
	)
	
	INSERT	#tmpPurchases(Id, mLineItemTotal, [Description])
	SELECT	ii.Id, ii.mLineItemTotal, ii.[Description]
	FROM	InvoiceItem ii, 
			#Invoices i, 
			#tmpMerch m
	WHERE	ii.[tInvoiceId] = i.[InvoiceId] 
			AND ii.[PurchaseAction] = 'Purchased' 
			AND ii.[tMerchId] IS NOT NULL 
			AND ii.[tMerchId] = m.[Id]

	CREATE TABLE #tmpRefunds(Id INT)
	
	INSERT	#tmpRefunds(Id)
	SELECT	ii.Id
	FROM	InvoiceItem ii, 
			#Invoices i, 
			#tmpMerch m
	WHERE	ii.[tInvoiceId] = i.[InvoiceId] 
			AND ii.[PurchaseAction] = 'PurchasedThenRemoved' 
			AND ii.[tMerchId] IS NOT NULL AND ii.[tMerchId] = m.[Id]

	CREATE TABLE #tmpCredits(
	
		Id						INT, 
		mAmount					MONEY, 
		RedemptionId			UNIQUEIDENTIFIER, 
		tInvoiceTransactionId	INT
	)
	
	INSERT	#tmpCredits(Id, mAmount, RedemptionId, tInvoiceTransactionId)
	SELECT	sc.Id, sc.mAmount, sc.RedemptionId, sc.tInvoiceTransactionId
	FROM	[StoreCredit] sc
	WHERE	sc.[ApplicationId] = @applicationId 
			AND sc.[dtStamp] BETWEEN @StartDate AND @EndDate
	ORDER BY sc.[Id] ASC

	DECLARE	@NumGiftSold INT, 
			@GiftMoneySold MONEY, 
			@StoreCreditSpent MONEY,
			@NumGiftRedeemed INT,	
			@GiftMoneyRedeemed MONEY, 
			@OutstandingRedemptionMoney MONEY, --sum of gift certs not yet redeemed
			@NumStoreCreditHolders INT, 
			@StoreCreditInHolding MONEY 

	SELECT	@NumGiftSold = COUNT(tp.Id),
			@GiftMoneySold = SUM(tp.[mLineItemTotal])
	FROM	#tmpPurchases tp

	SELECT	@OutstandingRedemptionMoney = SUM(tp.[mLineItemTotal])
	FROM	#tmpPurchases tp 
	WHERE	tp.[Description] IS NOT NULL
	
	CREATE TABLE #tmpStoreCredit(UserId UNIQUEIDENTIFIER, mAmount MONEY)
	
	INSERT	#tmpStoreCredit(UserId, mAmount)
	SELECT	sc.[UserId], SUM(sc.mAmount) AS mAmount
	FROM	[StoreCredit] sc
	WHERE	sc.[ApplicationId] = @applicationId
	GROUP BY sc.[UserId]
	HAVING	SUM(sc.mAmount) > 0

	SELECT	@NumStoreCreditHolders = COUNT(UserId),
			@StoreCreditInHolding = SUM(mAmount)
	FROM	#tmpStoreCredit

	SELECT	@NumGiftRedeemed = COUNT(sc.Id),
			@GiftMoneyRedeemed = SUM(sc.mAmount)		
	FROM	#tmpCredits sc
	WHERE	sc.[RedemptionId] IS NOT NULL 

	SELECT	@StoreCreditSpent = ABS(SUM(sc.mAmount))
	FROM	#tmpCredits sc
	WHERE	sc.[tInvoiceTransactionId] IS NOT NULL AND sc.[mAmount] < 0

	SELECT	ISNULL(@NumGiftSold,0) AS NumGiftSold, 
			ISNULL(@GiftMoneySold,0.0) AS GiftMoneySold, 
			ISNULL(@StoreCreditSpent,0.0) AS StoreCreditSpent, 
			ISNULL(@NumGiftRedeemed,0) AS NumGiftRedeemed,
			ISNULL(@GiftMoneyRedeemed,0.0) AS GiftMoneyRedeemed, 
			ISNULL(@OutstandingRedemptionMoney,0.0) AS OutstandingRedemptionMoney,
			ISNULL(@NumStoreCreditHolders,0) AS NumStoreCreditHolders,
			ISNULL(@StoreCreditInHolding,0.0) AS StoreCreditInHolding

END
GO
