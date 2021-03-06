USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_Report_NumberOfTicketsInPeriodForShowsInPeriod]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 10/01/19
-- Description:	Returns number of tickets sold within a given time period for shows within that time period.
-- Returns:		NumTixInPeriodRow
-- exec [tx_Report_NumberOfTicketsInPeriodForShowsInPeriod] 'Foheatre', '6/1/2009','6/30/2009'
-- =============================================

CREATE	PROC [dbo].[tx_Report_NumberOfTicketsInPeriodForShowsInPeriod](

	@appId		UNIQUEIDENTIFIER,
	@StartDate	VARCHAR(50),
	@EndDate	VARCHAR(50)

)
AS

SET NOCOUNT ON

SET DEADLOCK_PRIORITY LOW 

BEGIN

	CREATE TABLE #tmpItemId(Id INT)
	
	INSERT	#tmpItemId(Id)
	SELECT	DISTINCT ii.[Id]
	FROM	[InvoiceItem] ii, [Invoice] i
	WHERE	ii.[PurchaseAction] = 'Purchased' 
			AND ii.[tShowticketid] IS NOT NULL 
			AND ii.[dtDateOfShow] IS NOT NULL
			AND ii.[dtDateOfShow] BETWEEN @startdate AND @enddate
			AND ii.[dtStamp] BETWEEN @startdate AND @enddate 
			AND i.[Id] = ii.[tInvoiceId] 
			AND i.[ApplicationId] = @appId 
			AND i.[InvoiceStatus] <> 'NotPaid'

	SELECT	ISNULL(SUM(ii.[iQuantity]),0) AS NumItems 
	FROM	[InvoiceItem] ii 
	WHERE	ii.[Id] IN 
				(SELECT Id FROM #tmpItemId)
	
	DROP	TABLE	#tmpItemId

END
GO
