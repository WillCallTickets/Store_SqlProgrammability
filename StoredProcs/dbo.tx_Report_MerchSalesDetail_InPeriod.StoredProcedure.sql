USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_Report_MerchSalesDetail_InPeriod]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 10/01/19
-- Description:	Returns number of tickets sold for each tier of service fees within a given time period.
-- Returns:		Wcss.ServiceFeeBreakdownRow
-- exec [tx_Report_MerchSalesDetail_InPeriod] '83C1C3F6-C539-41D7-815D-143FBD40E41F', '7/1/2010','12/30/2010'
-- select * from aspnet_Applications
/*CREATING AN INDEX FOR THIS IS A NO_NO
profiler likes it the way it is
this index takes longer to build than just doing the query
I assume this is due to narrowing down the results to a smaller set by date

	--create an index for invoiceitem search
	CREATE NONCLUSTERED INDEX tx_IDX_InvoiceItem_pa_tmid
		ON [dbo].[InvoiceItem] ([PurchaseAction],[TMerchId])
		INCLUDE ([Id],[TInvoiceId]);
		
		--goes after populating table
--	DROP INDEX [dbo].[InvoiceItem].tx_IDX_InvoiceItem_pa_tmid;		
*/	
-- =============================================

CREATE PROC [dbo].[tx_Report_MerchSalesDetail_InPeriod](

	@appId		UNIQUEIDENTIFIER,
	@StartDate	VARCHAR(50),
	@EndDate	VARCHAR(50)

)
AS

SET NOCOUNT ON

SET DEADLOCK_PRIORITY LOW 

BEGIN
	
	--get a list of invoice items sold within the period
	CREATE	TABLE #tmpItemId(Id INT)
	
	INSERT	#tmpItemId(Id)
	SELECT	DISTINCT ii.[Id]
	FROM	[InvoiceItem] ii, [Invoice] i
	WHERE	ii.[PurchaseAction] = 'Purchased' 
			AND ii.[tMerchId] IS NOT NULL 
			AND i.[dtInvoiceDate] BETWEEN @startdate AND @enddate 
			AND i.[Id] = ii.[tInvoiceId] 
			AND i.[ApplicationId] = @appId 
			AND i.[InvoiceStatus] <> 'NotPaid'
			
	--because we are dealing with merch, we just need the total of the line
	--we do not have to worry so much about other charges within the line item
	--tally totals for categories
	SELECT	md.Name as 'DivName', mc.Name as 'CatName', 
			md.iDisplayOrder as 'DivOrder', mc.iDisplayOrder as 'CatOrder', 
			SUM(ii.[iQuantity]) as 'NumItemsSold', SUM(ii.[mLineItemTotal]) as 'TotalSales'
	FROM	#tmpItemId tmp 
			LEFT OUTER JOIN InvoiceItem ii 
				ON ii.Id = tmp.[Id] 
			LEFT OUTER JOIN Merch m 
				ON ii.tMerchId = m.Id 
			LEFT OUTER JOIN MerchJoinCat mjc 
				ON m.tParentListing = mjc.tMerchId
			LEFT OUTER JOIN MerchCategorie mc 
				ON mjc.tMerchCategorieId = mc.Id
			LEFT OUTER JOIN MerchDivision md 
				ON mc.tMerchDivisionId = md.Id	
	GROUP BY md.Name, mc.Name, md.iDisplayOrder, mc.iDisplayOrder
	ORDER BY md.iDisplayOrder, mc.iDisplayOrder
	
	DROP TABLE #tmpItemId

END
GO
