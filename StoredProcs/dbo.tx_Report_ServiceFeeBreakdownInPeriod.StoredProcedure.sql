USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_Report_ServiceFeeBreakdownInPeriod]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 10/01/19
-- Description:	Returns number of tickets sold for each tier of service fees within a given time period.
-- Returns:		Wcss.ServiceFeeBreakdownRow
-- exec [tx_Report_ServiceFeeBreakdownInPeriod] 'AC36EB0B-152E-4B69-8B39-BB4B6C9B01E6', '6/1/2009','6/30/2009'
-- select * from aspnet_Applications
-- =============================================

CREATE	PROC [dbo].[tx_Report_ServiceFeeBreakdownInPeriod](

	@appId		UNIQUEIDENTIFIER,
	@StartDate	VARCHAR(50),
	@EndDate	VARCHAR(50)

)
AS

SET NOCOUNT ON

SET DEADLOCK_PRIORITY LOW 

BEGIN

	--Get a distinct list of service fees within the period
	-- only get the purchased/non-returned tickets
	CREATE TABLE #tmpItemId(Id INT)
	
	INSERT #tmpItemId(Id)
	SELECT	DISTINCT ii.[Id]
	FROM	[InvoiceItem] ii, [Invoice] i
	WHERE	ii.[PurchaseAction] = 'Purchased' 
			AND ii.[tShowticketid] IS NOT NULL 
			AND i.[dtInvoiceDate] BETWEEN @startdate AND @enddate 
			AND i.[Id] = ii.[tInvoiceId] 
			AND i.[ApplicationId] = @appId 
			AND i.[InvoiceStatus] <> 'NotPaid'

	CREATE	TABLE #tmpFees(ServiceCharge MONEY)
	
	INSERT  #tmpFees(ServiceCharge)
	SELECT	DISTINCT ii.[mServiceCharge] AS ServiceCharge
	FROM	[InvoiceItem] ii
	WHERE	ii.[Id] IN 
				(SELECT [Id] FROM #tmpItemId)
	
	SELECT	t.[ServiceCharge], 
			ISNULL(SUM(ii.[iQuantity]),0) AS NumItems,
			ISNULL(SUM(ii.[mPrice]*ii.[iQuantity]),0.0) AS BasePriceTotal,
			ISNULL(SUM(ii.[mServiceCharge]*ii.[iQuantity]),0.0) AS ServiceChargeTotal,
			ISNULL(SUM(ii.[mLineItemTotal]),0.0) AS LineItemTotal				
	FROM	#tmpFees t, 
			#tmpItemId ti, 
			[InvoiceItem] ii
	WHERE	ii.[mServiceCharge] > 0 
			AND t.[ServiceCharge] = ii.[mServiceCharge]
			AND	ii.[Id] = ti.[Id]
	GROUP BY t.[ServiceCharge]
	ORDER BY t.[ServiceCharge] ASC

	DROP	TABLE	#tmpItemId
	DROP	TABLE	#tmpFees

END
GO
