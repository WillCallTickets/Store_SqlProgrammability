USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_ChargeStatement_View]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 08/02/01
-- Title:		[tx_ChargeStatement_View]
-- Description:	Returns charge statement rows for the year indicated. 
/*
	exec tx_ChargeStatement_View 'foxtheatre', 2008
*/
-- =============================================

CREATE	PROC [dbo].[tx_ChargeStatement_View] (

	@appName	VARCHAR(256),
	@year		INT

)
AS

SET NOCOUNT ON

BEGIN

	DECLARE @endMonth	INT,
			@appId		UNIQUEIDENTIFIER
	
	--if it is the current year, only show months past
	IF(@year = DATEPART(yyyy, GETDATE())) 
	BEGIN
	
		SET	@endMonth = DATEPART(mm, GETDATE())
		
	END
	ELSE BEGIN
	
		SET	@endMonth = 12
		
	END

	--retrieve appId
	SELECT	@appId = a.[ApplicationId] 
	FROM	[Aspnet_Applications] a 
	WHERE	a.[ApplicationName] = @appName

	CREATE	TABLE #tmpMonths (
		iMonth	INT, 
		iYear	INT
	)
	
	INSERT	#tmpMonths(iMonth, iYear)
	SELECT	num.[Number] AS 'iMonth', @year AS 'iYear'
	FROM	GetNumbers(1, @endMonth) num

	SELECT	ISNULL(cs.[Id], 0)					AS 'Id', 
			ISNULL(cs.[dtStamp], NULL)			AS 'dtStamp', 
			cs.[ApplicationId]					AS 'ApplicationId', 
			cs.[ChargeStatementId]				AS 'ChargeStatementId', 
			months.[iMonth], 
			months.[iYear], 
			SUBSTRING(DATENAME(m, CAST(months.[iMonth] AS VARCHAR(2)) + '/1/' + CAST(months.[iYear] AS VARCHAR(4))), 1, 3) + 
				' ' + CAST(months.[iYear] AS VARCHAR(4)) AS 'MonthYear',

			ISNULL(cs.[SalesQty], 0)			AS 'SalesQty', 
			ISNULL(cs.[SalesQtyPct], 0.0)		AS 'SalesQtyPct', 
			ISNULL(cs.[SalesQtyPortion], 0.0)	AS 'SalesQtyPortion', 
			ISNULL(cs.[RefundQty], 0)			AS 'RefundQty', 
			ISNULL(cs.[RefundQtyPct], 0.0)		AS 'RefundQtyPct', 
			ISNULL(cs.[RefundQtyPortion], 0.0)	AS 'RefundQtyPortion', 
			ISNULL(cs.[Gross], 0.0)				AS 'Gross', 
			ISNULL(cs.[GrossPct], 0.0)			AS 'GrossPct', 
			ISNULL(cs.[GrossThreshhold], 0.0)	AS 'GrossThreshhold', 
			ISNULL(cs.[GrossPortion], 0.0)		AS 'GrossPortion', 

			ISNULL(cs.[TicketInvoiceQty], 0)	AS 'TicketInvoiceQuantity', 
			ISNULL(cs.[TicketInvoicePct], 0.0)	AS 'TicketInvoicePct', 
			ISNULL(cs.[TicketUnitQty], 0)		AS 'TicketUnitQty', 
			ISNULL(cs.[TicketUnitPct], 0.0)		AS 'TicketUnitPct', 
			ISNULL(cs.[TicketSales], 0.0)		AS 'TicketSales', 
			ISNULL(cs.[TicketSalesPct], 0.0)	AS 'TicketSalesPct', 
			ISNULL(cs.[TicketPortion], 0.0)		AS 'TicketPortion', 

			ISNULL(cs.[MerchInvoiceQty], 0)		AS 'MerchInvoiceQuantity', 
			ISNULL(cs.[MerchInvoicePct], 0.0)	AS 'MerchInvoicePct', 
			ISNULL(cs.[MerchUnitQty], 0)		AS 'MerchUnitQty', 
			ISNULL(cs.[MerchUnitPct], 0.0)		AS 'MerchUnitPct', 
			ISNULL(cs.[MerchSales], 0.0)		AS 'MerchSales', 
			ISNULL(cs.[MerchSalesPct], 0.0)		AS 'MerchSalesPct', 
			ISNULL(cs.[MerchPortion], 0.0)		AS 'MerchPortion', 

			ISNULL(cs.[ShipUnitQty], 0)			AS 'ShipUnitQty', 
			ISNULL(cs.[ShipUnitPct], 0.0)		AS 'ShipUnitPct', 
			ISNULL(cs.[ShipSales], 0.0)			AS 'ShipSales', 
			ISNULL(cs.[ShipSalesPct], 0.0)		AS 'ShipSalesPct', 
			ISNULL(cs.[ShipPortion], 0.0)		AS 'ShipPortion', 

			ISNULL(cs.[SubscriptionsSent], 0)	AS 'SubscriptionsSent', 
			ISNULL(cs.[PerSubscription], 0.0)	AS 'PerSubscription', 
			ISNULL(cs.[MailSent], 0.0)			AS 'MailSent', 
			ISNULL(cs.[PerMailSent], 0.0)		AS 'PerMailSent', 
			ISNULL(cs.[MailerPortion], 0.0)		AS 'MailerPortion', 
		
			ISNULL(cs.[HourlyPortion], 0.0)		AS 'HourlyPortion', 
			ISNULL(cs.[Discount], 0.0)			AS 'Discount', 
			ISNULL(cs.[LineTotal], 0.0)			AS 'LineTotal', 
			ISNULL(cs.[AmountPaid], 0.0)		AS 'AmountPaid', 
			ISNULL(cs.[dtPaid], NULL)			AS 'dtPaid', 
			ISNULL(cs.[CheckNumber], '')		AS 'CheckNumber', 
			ISNULL(cs.[PayNotes], '')			AS 'PayNotes'
			
	FROM	[#tmpMonths] months 
			LEFT OUTER JOIN [Charge_Statement] cs 
				ON	cs.[ApplicationId] = @appId 
					AND cs.[iYear] = months.[iYear] 
					AND cs.[iMonth] = months.[iMonth] 
	ORDER BY months.[iMonth]

	DROP TABLE #tmpMonths

END
GO
